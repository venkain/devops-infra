sudo apt update
curl -s https://packages.gitlab.com/install/repositories/gitlab/gitlab-ce/script.deb.sh | sudo bash
sudo apt install -y gitlab-ce postgresql-client
# set up gitlab

sudo cat <<EOF > /etc/gitlab/gitlab.rb
external_url '${elb_url}'
# Disable the built-in Postgres
postgresql['enable'] = false
gitlab_rails['auto_migrate'] = false
# Fill in the connection details for database.yml
gitlab_rails['db_adapter'] = 'postgresql'
gitlab_rails['db_encoding'] = 'utf8'
gitlab_rails['db_host'] = '${postgres_url}'
gitlab_rails['db_port'] = '5432'
gitlab_rails['db_database'] = '${db_name}'
gitlab_rails['db_username'] = '${db_user}'
gitlab_rails['db_password'] = '${db_password}'
redis['enable'] = false

# Redis via TCP
gitlab_rails['redis_host'] = '${redis_url}'
gitlab_rails['redis_port'] = 6380

EOF
chmod 600 /etc/gitlab/gitlab.rb
gitlab-ctl reconfigure
