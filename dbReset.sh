#!/bin/bash
echo "Initializing db"
sudo docker exec icinga_broker rm -rf /var/lib/pnp4nagios/perfdata/
sleep 30
echo "Done"
