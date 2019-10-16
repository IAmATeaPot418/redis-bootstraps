#!/bin/bash
sudo sudo apt update -y
sudo apt install build-essential tcl -y
sudo apt install tcl-tls -y
sudo apt install libssl-dev -y
sudo apt install redis-tools -y
git clone https://github.com/antirez/redis.git
cd ./redis
make BUILD_TLS=yes
./utils/gen-test-certs.sh
./runtest --tls
git clone https://github.com/IAmATeaPot418/redis-bootstraps.git
./src/redis-server ./redis-bootstraps/redis.conf
