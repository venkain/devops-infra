#!/bin/sh
sudo apt update
curl -s https://packages.gitlab.com/install/repositories/gitlab/gitlab-ce/script.deb.sh | sudo bash
sudo apt install -y gitlab-ce postgresql-client nfs-common python-pip jq
pip install --upgrade awscli
cat <<"EOF" > /home/ubuntu/update_ssh_authorized_keys.sh
#!/bin/bash
set -e
BUCKET_NAME=${s3_bucket_name}
BUCKET_URI=${s3_bucket_uri}
SSH_USER=ubuntu
MARKER="# KEYS_BELOW_WILL_BE_UPDATED_BY_TERRAFORM"
KEYS_FILE=/home/$SSH_USER/.ssh/authorized_keys
TEMP_KEYS_FILE=$(mktemp /tmp/authorized_keys.XXXXXX)
PUB_KEYS_DIR=/home/$SSH_USER/pub_key_files/
PATH=/usr/local/bin:$PATH
[[ -z $BUCKET_URI ]] && BUCKET_URI="s3://$BUCKET_NAME/"
mkdir -p $PUB_KEYS_DIR
# Add marker, if not present, and copy static content.
grep -Fxq "$MARKER" $KEYS_FILE || echo -e "\n$MARKER" >> $KEYS_FILE
line=$(grep -n "$MARKER" $KEYS_FILE | cut -d ":" -f 1)
head -n $line $KEYS_FILE > $TEMP_KEYS_FILE
# Synchronize the keys from the bucket.
aws s3 sync --delete $BUCKET_URI $PUB_KEYS_DIR
for filename in $PUB_KEYS_DIR/*; do
    sed 's/\n\?$/\n/' < $filename >> $TEMP_KEYS_FILE
done
# Move the new authorized keys in place.
chown $SSH_USER:$SSH_USER $KEYS_FILE
chmod 600 $KEYS_FILE
mv $TEMP_KEYS_FILE $KEYS_FILE
EOF

cat <<"EOF" > /home/ubuntu/.ssh/config
Host *
    StrictHostKeyChecking no
EOF
chmod 600 /home/ubuntu/.ssh/config
chown ubuntu:ubuntu /home/ubuntu/.ssh/config

chown ubuntu:ubuntu /home/ubuntu/update_ssh_authorized_keys.sh
chmod 755 /home/ubuntu/update_ssh_authorized_keys.sh

# Execute now
su ubuntu -c /home/ubuntu/update_ssh_authorized_keys.sh

keys_update_frequency="0 * * * *"

# Add to cron
if [ -n "$keys_update_frequency" ]; then
  croncmd="/home/ubuntu/update_ssh_authorized_keys.sh"
  cronjob="$keys_update_frequency $croncmd"
  ( crontab -u ubuntu -l | grep -v "$croncmd" ; echo "$cronjob" ) | crontab -u ubuntu -
fi

echo '${efs_url}:/ /gitlab-data nfs4 nfsvers=4.1,rsize=1048576,wsize=1048576,hard,timeo=600,retrans=2 0 0' >> /etc/fstab
mkdir /gitlab-data
mount -a

# set up gitlab

sudo cat <<EOF > /etc/gitlab/gitlab.rb
external_url '${url}'
nginx['enable'] = true
nginx['listen_port'] = 80
nginx['listen_https'] = false
nginx['proxy_set_headers'] = {
  "X-Forwarded-Proto" => "https",
  "X-Forwarded-Ssl" => "on"
}
# Disable the built-in Postgres
postgresql['enable'] = false
gitlab_rails['auto_migrate'] = false
# Fill in the connection details for database.yml
gitlab_rails['db_adapter'] = 'postgresql'
gitlab_rails['db_encoding'] = 'utf8'
gitlab_rails['db_host'] = '${postgres_url}'
gitlab_rails['db_port'] = '5432'
gitlab_rails['db_database'] = '${gitlab_db_name}'
gitlab_rails['db_username'] = '${db_user}'
gitlab_rails['db_password'] = '${db_password}'

redis['enable'] = false
# Redis via TCP
gitlab_rails['redis_host'] = '${redis_url}'
gitlab_rails['redis_port'] = '6379'

# Shared FS
git_data_dirs({"default" => "/gitlab-data/git-data"})
user['home'] = '/gitlab-data/home'
gitlab_rails['uploads_directory'] = '/gitlab-data/uploads'
gitlab_rails['shared_path'] = '/gitlab-data/shared'
gitlab_ci['builds_directory'] = '/gitlab-data/builds'

EOF
chmod 600 /etc/gitlab/gitlab.rb
PGPASSWORD='${db_password}' psql -h '${postgres_url}' -d '${db_name}' -U '${db_user}' -c 'create database ${gitlab_db_name};' && gitlab-ctl reconfigure && echo yes | sudo gitlab-rake gitlab:setup || gitlab-ctl stop && sleep 120
gitlab-ctl reconfigure
