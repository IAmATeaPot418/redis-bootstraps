#!/bin/bash
sudo sudo apt update -y
sudo apt install build-essential tcl -y
sudo apt install tcl-tls -y
sudo apt install libssl-dev -y
sudo apt install redis-tools -y
useradd redisuser 
git clone https://github.com/antirez/redis.git
cd ./redis
make BUILD_TLS=yes
./utils/gen-test-certs.sh
./runtest --tls
./src/redis-server --tls-port 6379 --port 0 \
        --tls-cert-file ./tests/tls/redis.crt \
        --tls-key-file ./tests/tls/redis.key \
        --tls-ca-cert-file ./tests/tls/ca.crt
