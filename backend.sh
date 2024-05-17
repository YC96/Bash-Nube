#!/bin/bash

for i in $(seq 1 3); do

    lxc launch ubuntu:22.04 "backend${i}"

    lxc exec "backend${i}" -- /bin/bash -c "apt-get update && apt-get install -y npm"

    lxc exec "backend${i}" -- /bin/bash -c "npm install -g @nestjs/cli"

    lxc exec "backend${i}" -- /bin/bash -c "git clone https://github.com/manuelenrq9/CRUDubuntu.git && ls"

    lxc exec "backend${i}" -- /bin/bash -c "cd CRUDubuntu && npm install"

    # production mode
    lxc exec "backend${i}" -- /bin/bash -c "cd CRUDubuntu && npm run start:prod"
done

lxc launch ubuntu:22.04 loadbalancer

lxc exec loadbalancer -- /bin/bash -c "apt install nginx -y"

lxc exec loadbalancer -- /bin/bash -c "cp /etc/nginx/nginx.conf /etc/nginx/nginx.conf__bak"

lxc exec loadbalancer -- /bin/bash -c "cat << EOF > /etc/nginx/nginx.conf
user www-data;
worker_processes auto;
pid /run/nginx.pid;
include /etc/nginx/modules-enabled/*.conf;
events {
worker_connections 768;
# multi_accept on;
}
http {
upstream myapp1 {
server backend1.lxd;
server backend2.lxd;
server backend3.lxd;
}
server {
listen 80;
location / {
proxy_pass http://myapp1;
}
}
}
EOF"