#!/bin/bash
#Icinga Plugin Script to display the connection status of the registered services to broker
#Broker IP & Port
ip="localhost"
port="39001"

# Broker server status messages
aliveMsg="Server is alive"
deadMsg="Server is not alive"
isBrokerAlive=$(/usr/local/bin/broklist -ping $ip $port)
icingaData=""

# Commented the below code due to a known issue while invoking broker within the script
#if [ "$isBrokerAlive" == "$deadMsg" ];
#then
#    broker="/usr/local/bin/broker -e /tmp/tmp_broker.env -bg"
#    #broker="/usr/local/bin/broker -bg"
#    $broker
#    #/bin/bash /usr/lib/nagios/plugins/brokerStart.sh
#fi
if [ -f /tmp/_out ];
then
    rm /tmp/_out
fi
isBrokerAlive=$(/usr/local/bin/broklist -ping $ip $port)
if [ "$isBrokerAlive" == "$aliveMsg" ];
then
    #Script to register ORCA and MPAP services
    #source /usr/lib/nagios/plugins/register_services.sh
    serviceMsg=$(/usr/local/bin/broklist $ip $port)
    icingaData="Broker running at $ip $port\nRegistered Services\n"
    for index in ${!serviceMsg[@]};
    do
        if [ $(($index % 5)) -eq 0 ];
        then
            icingaData="$icingaData ${serviceMsg[$index]} ${serviceMsg[$index+1]} ${serviceMsg[$index+2]} ${serviceMsg[$index+3]} ${serviceMessage[$index+4]} ${serviceMsg[$index+5]}\n"
        fi
    done
    icingaData="$icingaData |"
    broklistServices=($(/usr/local/bin/broklist $ip $port | awk '{$4=$5=""; print $0}'))
    if [[ ${!broklistServices[@]} == "" ]];
    then
        icingaData="$icingaData \n No services registered to broker"
        echo -e " $icingaData"
    else
        for index in ${!broklistServices[@]};
        do
            ctr=$index
            if [ $(($index % 3)) -eq 0 ];
            then
                serviceName="${broklistServices[$index]}"
                serviceIp="${broklistServices[$index+1]}"
                servicePort="${broklistServices[$index+2]}"
                commands[$ctr]="/usr/lib/nagios/plugins/icingaBroklistPing.sh $serviceName $serviceIp $servicePort"
            fi
        done
        op=$(SHELL=/bin/bash parallel --gnu -j 20 ::: "${commands[@]}")
        icingaData="$icingaData $op"
        echo -e $icingaData
    fi
else
    icingaData="Broker not running"
    echo -e $icingaData
    exit 2
fi
exit 0
