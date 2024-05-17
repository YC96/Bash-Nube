#!/bin/bash

# Permisos de ejecución (ya no es necesario dentro del script)

# Nombres de los contenedores
containers=("mongo1-prueba" "mongo2-prueba" "mongo3-prueba")

# Imagen base del contenedor (Ubuntu 22.04 Jammy Jellyfish con MongoDB)
image="ubuntu:jammy"

# Crear e instalar MongoDB en cada contenedor
for container in "${containers[@]}"; do
    echo "Creando contenedor $container..."
    lxc launch $image $container

    echo "Instalando software necesario en $container..."
    lxc exec $container -- bash -c "apt-get update && apt-get install -y gnupg curl software-properties-common"

    echo "Agregando clave GPG de MongoDB en $container..."
    lxc exec $container -- bash -c "curl -fsSL https://www.mongodb.org/static/pgp/server-7.0.asc | apt-key add -"

    echo "Agregando repositorio de MongoDB en $container..."
    lxc exec $container -- add-apt-repository "deb [ arch=amd64,arm64 ] https://repo.mongodb.org/apt/ubuntu jammy/mongodb-org/7.0 multiverse"

    echo "Instalando MongoDB en $container..."
    lxc exec $container -- bash -c "apt-get update && apt-get install -y mongodb-org"

    echo "Configurando mongod.conf en $container..."
    lxc exec $container -- bash -c "cat << EOF | tee -a /etc/mongod.conf
replication:
    replSetName: myReplicaSet
bindIp: 0.0.0.0  # Permitir conexiones desde cualquier IP
EOF"

    echo "Iniciando MongoDB en $container..."
    lxc exec $container -- systemctl start mongod
    lxc exec $container -- systemctl enable mongod

    echo "Verificando estado de MongoDB en $container..."
    lxc exec $container -- systemctl status mongod
done

echo "Esperando a que los contenedores estén listos..."
sleep 10 

# Obtener las IPs de los contenedores (método más confiable)
IP_MONGO1=$(lxc list mongo1-prueba | grep eth0 | awk '{print $6}')
IP_MONGO2=$(lxc list mongo2-prueba | grep eth0 | awk '{print $6}')
IP_MONGO3=$(lxc list mongo3-prueba | grep eth0 | awk '{print $6}')


echo "Configurando replica set desde mongo1..."
lxc exec mongo1-prueba -- mongosh --eval "rs.initiate({_id: 'myReplicaSet', members: [{_id: 0, host: '$IP_MONGO1:27017'}, {_id: 1, host: '$IP_MONGO2:27017'}, {_id: 2, host: '$IP_MONGO3:27017'}]})"

echo "Instalación y configuración completa."