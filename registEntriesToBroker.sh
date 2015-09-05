# Author: Norio ISHIZAKI
# Date: 2015.08.17
# Usage: ./registEntriesToBroker.sh
# This shell test program inserts the user specified # of pseudo service entries
# to the broker running in the Icinga Docker container.
#
#!/bin/sh
export CONTAINER_NAME=icinga_broker

echo -n "Specify the number of entries. e.g. 1000: "
sudo docker exec $CONTAINER_NAME /bin/bash -c "rm -f /tmp/data.txt"
read ANS
for i in `seq 1 $ANS`
do
    j=`expr $i + 10000`
    sudo docker exec $CONTAINER_NAME /bin/bash -c "echo test/icinga/$i 10.10.10.1 $j >>  /tmp/data.txt"
done

sudo docker exec $CONTAINER_NAME /bin/bash -c "echo Amazon www.amazon.com 80 >>  /tmp/data.txt"
sudo docker exec $CONTAINER_NAME /bin/bash -c "echo Apple www.apple.com 80 >>  /tmp/data.txt"
sudo docker exec $CONTAINER_NAME /bin/bash -c "echo Facebook www.facebook.com 80 >>  /tmp/data.txt"
sudo docker exec $CONTAINER_NAME /bin/bash -c "echo GMail www.gmail.com 80 >>  /tmp/data.txt"
sudo docker exec $CONTAINER_NAME /bin/bash -c "echo Google www.google.com 80 >>  /tmp/data.txt"
sudo docker exec $CONTAINER_NAME /bin/bash -c "echo Microsoft www.microsoft.com 80 >>  /tmp/data.txt"
sudo docker exec $CONTAINER_NAME /bin/bash -c "echo Twitter www.twitter.com 80 >>  /tmp/data.txt"
sudo docker exec $CONTAINER_NAME /bin/bash -c "echo Yahoo www.yahoo.com 80 >>  /tmp/data.txt"
sudo docker exec $CONTAINER_NAME /bin/bash -c "echo Youtube www.youtube.com 80 >>  /tmp/data.txt"

start=$(date +'%s')
sudo docker exec $CONTAINER_NAME /bin/bash -c "broklist -load localhost 39001 /tmp/data.txt"
echo "It took $(($(date +'%s') - $start)) seconds"

echo

echo "The number of registered entries"
start=$(date +'%s')
sudo docker exec $CONTAINER_NAME /bin/bash -c "broklist localhost 39001 | wc -l"
echo "It took $(($(date +'%s') - $start)) seconds"