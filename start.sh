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
sudo docker exec $CONTAINER_NAME /bin/bash -c "broker -bg" &
sudo docker exec $CONTAINER_NAME /bin/bash -c "/opt/nextra/bin/spring-boot-broklist.sh" &

sleep 10

# Add services you want to be monitored by Nextra Naming Server.
sudo docker exec $CONTAINER_NAME /bin/bash -c "broklist -add localhost 39001 httpd+localhost+80"
sudo docker exec $CONTAINER_NAME /bin/bash -c "broklist -add localhost 39001 tomcat+localhost+8080"
