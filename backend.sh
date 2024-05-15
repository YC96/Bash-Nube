#!/bin/bash

for i in $(seq 1 3); do

    lxc launch ubuntu:22.04 "backend${i}"

    lxc exec "backend${i}" -- /bin/bash -c "apt-get update && apt-get install -y npm"

    lxc exec "backend${i}" -- /bin/bash -c "git clone https://github.com/manuelenrq9/CRUDubuntu.git && ls"

    lxc exec "backend${i}" -- /bin/bash -c "cd CRUDubuntu && npm install"

    # production mode
    lxc exec "backend${i}" -- /bin/bash -c "cd CRUDubuntu && npm run start:prod"
done