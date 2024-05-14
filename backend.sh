#!/bin/bash

for i in $(seq 1 3); do

    lxc launch ubuntu:22.04 "backend${i}"

    lxc exec "backend${i}" -- /bin/bash -c "apt-get update && apt-get install -y npm"

    lxc exec "backend${i}" -- /bin/bash -c "git clone https://github.com/manuelenrq9/CRUDubuntu.git && ls"

    lxc exec "backend${i}" -- /bin/bash -c "cd CRUDubuntu && npm install"

    lxc exec "backend${i}" -- /bin/bash -c "apt install nginx -y"

    lxc exec "backend${i}" -- /bin/bash -c "cp /etc/nginx/nginx.conf /etc/nginx/nginx.conf__bak"

    lxc exec "backend${i}" -- /bin/bash -c "cat << EOF > /etc/nginx/nginx.conf
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
        server c1.lxd;
        server c2.lxd;
        server c3.lxd;
    }

    server {
        listen 80;

        location / {
            proxy_pass http://myapp1;
        }   
    }
}
EOF"

    lxc exec "backend${i}" -- /bin/bash -c "sudo nginx -t"

    lxc exec "backend${i}" -- /bin/bash -c "sudo systemctl restart nginx"

    # production mode
    lxc exec "backend${i}" -- /bin/bash -c "cd CRUDubuntu && npm run start:prod"
done


