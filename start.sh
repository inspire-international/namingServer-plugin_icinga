#!/bin/sh

export CONTAINER_NAME=icinga_broker

sudo docker start $CONTAINER_NAME

sudo docker exec $CONTAINER_NAME service apache2 reload

sleep 10

sudo docker exec $CONTAINER_NAME service npcd start

sleep 10

sudo docker exec $CONTAINER_NAME service rrdcached restart

sleep 10

sudo docker exec $CONTAINER_NAME service icinga2 reload

sleep 10
# Run broker and rpcjava 2 samples
sudo docker exec $CONTAINER_NAME /bin/bash -c "cd /home/nextra/build/Nextra/install/linux.x86_64/samples/nextra-rest-server/java/standard && ./fly.sh" &

# Run nextra-rest-server 
sudo docker exec $CONTAINER_NAME /bin/bash -c "cd /tmp && nextra-rest-server.sh" &
sleep 10

# Add services you want to be monitored by Nextra Naming Server.
sudo docker exec $CONTAINER_NAME /bin/bash -c "broklist -add localhost 39001 httpd+localhost+80"
sudo docker exec $CONTAINER_NAME /bin/bash -c "broklist -add localhost 39001 tomcat+localhost+8080"
