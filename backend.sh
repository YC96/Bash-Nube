#!/bin/bash

for i in $(seq 1 3); do

    lxc launch ubuntu:jammy "backend${i}"

    lxc exec "backend${i}" -- /bin/bash -c "sudo apt update"

    lxc exec "backend${i}" -- /bin/bash -c "curl -sL https://deb.nodesource.com/setup_lts.x | sudo -E bash -"

    lxc exec "backend${i}" -- /bin/bash -c "sudo apt update"

    lxc exec "backend${i}" -- /bin/bash -c "sudo apt install nodejs"

    lxc exec "backend${i}" -- /bin/bash -c "node -v"

    lxc exec "backend${i}" -- /bin/bash -c "git clone https://github.com/manuelenrq9/CRUDubuntu.git"

    lxc exec "backend${i}" -- /bin/bash -c "cd CRUDubuntu && npm install"

    lxc exec "backend${i}" -- /bin/bash -c "cd CRUDubuntu && npm run start:dev" 

done