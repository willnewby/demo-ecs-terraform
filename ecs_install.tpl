#!/bin/bash

# Let's log to both a log file, and to syslog
exec > >(tee /var/log/user-data.log|logger -t user-data -s 2>/dev/console) 2>&1

yum -y update
yum -y install aws-cli jq ecs-init
service docker start

cat <<'EOF' >> /etc/ecs/ecs.config
ECS_CLUSTER=hello-ecs-cluster
#ECS_ENGINE_AUTH_TYPE=docker
#ECS_ENGINE_AUTH_DATA={"https://index.docker.io/v1/":{"username":"my_name","password":"my_password","email":"email@example.com"}}
ECS_LOGLEVEL=debug
EOF

start ecs



#start ecs
#until $(curl --output /dev/null --silent --head --fail http://localhost:51678/v1/metadata); do
#  printf '.'
#  sleep 1
#done
