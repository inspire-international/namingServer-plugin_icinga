# Author: Norio ISHIZAKI
# Date: 2015.08.17
# Usage: ./registEntriesToBroker.sh
# This shell test program inserts the user specified # of pseudo service entries
# to the broker running in the Icinga Docker container.
#
#!/bin/sh
echo -n "Specify the number of entries. e.g. 1000: "
sudo docker exec icinga /bin/bash -c "rm -f /tmp/data.txt"
read ANS
for i in `seq 1 $ANS`
do
    j=`expr $i + 10000`
    sudo docker exec icinga /bin/bash -c "echo test/icinga/$i 10.10.10.1 $j >>  /tmp/data.txt"
done

start=$(date +'%s')
sudo docker exec icinga /bin/bash -c "broklist -load localhost 39001 /tmp/data.txt"
echo "It took $(($(date +'%s') - $start)) seconds"

echo

echo "The number of registered entries"
start=$(date +'%s')
sudo docker exec icinga /bin/bash -c "broklist localhost 39001 | wc -l"
echo "It took $(($(date +'%s') - $start)) seconds"