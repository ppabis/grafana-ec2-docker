#!/bin/bash

yum install -y docker
systemctl enable --now docker
curl -o /usr/local/bin/docker-compose -L "https://github.com/docker/compose/releases/download/v2.28.1/docker-compose-linux-aarch64"
chmod +x /usr/local/bin/docker-compose

useradd -r -s /sbin/nologin grafana

mkdir -p /opt/grafana
chown -R grafana:grafana /opt/grafana
aws ssm get-parameter --name ${param_grafana_ini} --with-decryption --query Parameter.Value --output text > /opt/grafana.ini
chown grafana:grafana /opt/grafana.ini

mkdir -p /opt/nginx
openssl req -x509 -nodes -days 365 -newkey rsa:2048 -keyout /opt/nginx/selfsigned.key -out /opt/nginx/selfsigned.crt -subj "/CN=grafana"
aws ssm get-parameter --name ${param_nginx_conf} --query Parameter.Value --output text > /opt/nginx/nginx.conf

aws ssm get-parameter --name ${param_docker_compose} --query Parameter.Value --output text > /opt/docker-compose.yml

export RUN_AS_ID=$(id -u grafana)
export RUN_AS_GROUP=$(id -g grafana)
docker-compose -f /opt/docker-compose.yml up -d