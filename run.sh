#!/bin/sh
# You must set hostname and its ipaddress in /etc/hosts in order for `hostname -i` 
# export IPADDR=`hostname -i`

# Please specify Syslog server ipaddress here in order to send warning syslog message
# to local0 facility running at $SYSLOGIP
read -p "Do you wish to send warning syslog message? If YES then provide Syslog server ipaddress Else hit Enter : " syslog_ip
export SYSLOGIP=$syslog_ip

export IMAGE_NAME=debian_icinga_broker
export CONTAINER_NAME=icinga_broker

sudo docker rm $CONTAINER_NAME 

sudo cp -f ./conf/commands.conf /tmp
sudo cp -f ./conf/services.conf /tmp

# -v /etc/localtime:/etc/localtime does not work on Virtual Box
if [ -z "$SYSLOGIP" ];
then
    sudo docker run --name $CONTAINER_NAME --privileged -i -t -d -p 80:80 -p 39001:39001 -p 8080:8080 -v /tmp/commands.conf:/etc/icinga2/conf.d/commands.conf -v /tmp/services.conf:/etc/icinga2/conf.d/services.conf $IMAGE_NAME /sbin/init
else
    sudo docker run --name $CONTAINER_NAME --privileged -i -t -d -p 80:80 -p 39001:39001 -p 8080:8080 -v /tmp/commands.conf:/etc/icinga2/conf.d/commands.conf -v /tmp/services.conf:/etc/icinga2/conf.d/services.conf -e "SYSLOGIP=$SYSLOGIP" $IMAGE_NAME /sbin/init
fi
sudo docker exec $CONTAINER_NAME /bin/bash -c "ln -s /etc/icingaweb2/modules/pnp4nagios /etc/icingaweb2/enabledModules/pnp4nagios" 
sudo docker exec $CONTAINER_NAME /bin/bash -c "ln -s /usr/local/pnp4nagios/etc /etc/pnp4nagios"
sudo docker exec $CONTAINER_NAME /bin/bash -c "mv /usr/local/pnp4nagios/share/install.php /usr/local/pnp4nagios/share/install.php.bak"
sudo docker exec $CONTAINER_NAME icinga2 feature enable perfdata

sleep 10

sudo docker exec $CONTAINER_NAME service apache2 restart

sleep 10

sudo docker exec $CONTAINER_NAME service npcd start

#sleep 10

#sudo docker exec $CONTAINER_NAME service rrdcached restart

sleep 10
# Temporarily commented out due to an error on 2015.11.18
# sudo docker exec $CONTAINER_NAME mv /etc/icingaweb2/modules/monitoring/instances.ini /etc/icingaweb2/modules/monitoring/commandtransports.ini
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
