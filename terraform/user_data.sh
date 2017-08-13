#!/bin/sh
sudo apt update
curl -s https://packages.gitlab.com/install/repositories/gitlab/gitlab-ce/script.deb.sh | sudo bash
sudo apt install -y gitlab-ce postgresql-client
# set up gitlab

sudo cat <<EOF > /etc/gitlab/gitlab.rb
external_url 'https://${elb_url}'
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

EOF
chmod 600 /etc/gitlab/gitlab.rb
PGPASSWORD='${db_password}' psql -h '${postgres_url}' -d '${db_name}' -U '${db_user}' -c 'create database ${gitlab_db_name};' > /dev/null 2>&1 && echo yes | sudo gitlab-rake gitlab:setup
gitlab-ctl reconfigure
