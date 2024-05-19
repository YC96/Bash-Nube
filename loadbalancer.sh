lxc launch ubuntu:jammy loadbalancer

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
                listen 3000;
                location / {
                        proxy_pass http://myapp1;
                }
        }       
}
EOF"

lxc exec loadbalancer -- /bin/bash -c "sudo systemctl restart nginx"