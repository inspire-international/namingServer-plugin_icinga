#!/bin/bash
echo "Initializing db"
sudo docker exec icinga_broker rm -rf /usr/local/pnp4nagios/var/perfdata
sleep 30
echo "Done"
