#!/bin/bash

#Install dependencies for basic functionality and for TLS support.

sudo apt update -y
sudo apt install build-essential tcl -y
sudo apt install tcl-tls -y
sudo apt install redis-tools -y
sudo apt install libssl-dev -y

#Add user and group so Redis does not run as a privledged user.

sudo adduser --system --group --no-create-home redis

# Make the working directory (configured to be so later).
sudo mkdir /var/lib/redis

# Change ownership to the Redis user so it will be run in unprivledged mode.
sudo chown redis:redis /var/lib/redis

# Change permissions to be non-readable by other to enforce granular access controls at the operating system level.
sudo chmod 770 /var/lib/redis

# Create Directory for Log Files and create log file.
sudo mkdir /var/log/redis
sudo touch /var/log/redis/redis.log

# change permissions on directory and log file
sudo chmod 770 /var/log/redis/
sudo chmod 640 /var/log/redis/redis.log
sudo chown redis:redis /var/log/redis/
sudo chown redis:redis /var/log/redis/redis.log


# Install Redis in /tmp initially

cd /tmp
sudo git clone https://github.com/antirez/redis.git #TODO change this to the actual release once it comes out. 
# Cloning from unstable is not fun for anyone who does security for production systems except me. 
# This boostrap will not work if all of the tests do not currently pass in unstable.

cd redis/
sudo make && sudo make BUILD_TLS=yes && sudo make test && sudo make install

# Create redis configuration directory
sudo mkdir /etc/redis
sudo cp /tmp/redis/redis.conf /etc/redis
sudo chown -R redis:redis /etc/redis
sudo chmod 640 /etc/redis/redis.conf

# Edit Redis.conf to add working directory and to direct it to be supervised
sudo sed -i "s/supervised no/supervised systemd/" /etc/redis/redis.conf
sudo sed -i "s/dir .\//dir \/var\/lib\/redis/" /etc/redis/redis.conf

# Create Redis Service SystemD Unit File & configure it.

sudo touch /etc/systemd/system/redis.service
sudo bash -c 'cat << EOF > /etc/systemd/system/redis.service
[Unit]
Description=Redis Deployment
After=network.target

[Service]
User=redis
Group=redis
ExecStart=/usr/local/bin/redis-server /etc/redis/redis.conf
ExecStop=/usr/local/bin/redis-cli shutdown
Restart=always

[Install]
WantedBy=multi-user.target
EOF'

#Start Redis and Enable it on startup
sudo systemctl start redis
sudo systemctl enable redis
