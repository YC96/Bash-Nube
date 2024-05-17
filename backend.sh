#!/bin/bash

for i in $(seq 1 3); do

    lxc launch ubuntu:22.04 "backend${i}"

    lxc exec "backend${i}" -- /bin/bash -c "apt-get update && apt-get install -y npm"

    #error fix
    lxc exec "backend${i}" -- /bin/bash -c"curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.3/install.sh | bash"

    lxc exec "backend${i}" -- /bin/bash -c "export NVM_DIR="$([ -z "${XDG_CONFIG_HOME-}" ] && printf %s "${HOME}/.nvm" || printf %s "${XDG_CONFIG_HOME}/nvm")"
   [ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh""

    lxc exec "backend${i}" -- /bin/bash -c " command -v nvm"

    #lxc exec "backend${i}" -- /bin/bash -c "nvm install --lts"

    #lxc exec "backend${i}" -- /bin/bash -c "nvm use --lts"

    #lxc exec "backend${i}"-- /bin/bash -c "node -v"

    lxc exec "backend${i}" -- /bin/bash -c "nvm install node"


    #lxc exec "backend${i}"-- /bin/bash -c "rm -rf node_modules package-lock.json"

    #lxc exec "backend${i}"-- /bin/bash -c "npm install"

    #

   #lxc exec "backend${i}" -- /bin/bash -c "npm install -g @nestjs/cli"

    lxc exec "backend${i}" -- /bin/bash -c "git clone https://github.com/manuelenrq9/CRUDubuntu.git && ls"

    lxc exec "backend${i}" -- /bin/bash -c "cd CRUDubuntu && npm install"

    # production mode
    lxc exec "backend${i}" -- /bin/bash -c "cd CRUDubuntu && npm run start:dev"
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