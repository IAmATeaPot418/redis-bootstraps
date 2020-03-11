#!/bin/bash
#Install Dependencies
sudo apt update -y
sudo apt install build-essential tcl -y
sudo apt install tcl-tls -y
sudo apt install redis-tools -y
sudo apt install libssl-dev -y
#Install unstable
git clone https://github.com/antirez/redis.git
cd ./redis
#Build Redis and then make the TLS portion.
make && make BUILD_TLS=yes
#create test certs
./utils/gen-test-certs.sh
#Run Tests
./runtest --tls
#Connect with Tests 
./src/redis-server --tls-port 6379 --port 0 \
        --tls-cert-file ./tests/tls/redis.crt \
        --tls-key-file ./tests/tls/redis.key \
        --tls-ca-cert-file ./tests/tls/ca.crt &
        
#Note Commands After this point may need to be modified and have no need to be run in a bootstrap. These are manual test steps.

#Test Client Connection and Shutdown Server
./src/redis-cli --tls \
        --cert ./tests/tls/redis.crt \
        --key ./tests/tls/redis.key \
        --cacert ./tests/tls/ca.crt shutdown
#You should get the redis shutdown after this.
#create my own certificate for rotation out of test certs
openssl genrsa -out ca.key 4096 
openssl req \
    -x509 -new -nodes -sha256 \
    -key ca.key \
    -days 3650 \
    -subj '/O=Redislabs/CN=Redis Prod CA' \
    -out ca.crt
openssl genrsa -out redis.key 2048
openssl req \
    -new -sha256 \
    -key redis.key \
    -subj '/O=Redislabs/CN=Production Redis' | \
    openssl x509 \
        -req -sha256 \
        -CA ca.crt \
        -CAkey ca.key \
        -CAserial ca.txt \
        -CAcreateserial \
        -days 365 \
        -out redis.crt
openssl dhparam -out redis.dh 2048
#restart redis server
./src/redis-server --tls-port 6379 --port 0 \
        --tls-cert-file redis.crt \
        --tls-key-file redis.key \
        --tls-ca-cert-file ca.crt &
#Test New Certificate Rotated Key
./src/redis-cli --tls \
        --cert redis.crt \
        --key redis.key \
        --cacert ca.crt ping
        
#test with basic tls config defined (found in github repo) just intended to get it running and not to harden in any way.
./src/redis-cli --tls --cacert ca.crt

#test with intermediate TLS config defined. May be run in cluster or standalone mode (some directives just wont work in cluster) This is intended to do due dilligence but not be hardcore
#Same test works for hardcore configuration
./src/redis-cli --tls \
        --cert redis.crt \
        --key redis.key \
        --cacert ca.crt




