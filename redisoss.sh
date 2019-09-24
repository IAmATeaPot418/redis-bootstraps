#!/bin/bash
sudo apt install redis-tools -y
sudo sudo apt update -y
sudo apt install build-essential tcl -y
git clone https://github.com/antirez/redis.git
cd ./redis
make
cd ./src
./redis-server
