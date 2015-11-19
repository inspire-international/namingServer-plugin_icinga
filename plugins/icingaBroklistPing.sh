#!/bin/bash
serviceName=$1
serviceIp=$2
servicePort=$3
deadMsg="Server is not alive"
connect=$($ODEDIR/bin/broklist -ping $serviceIp $servicePort)
#Message format used by Icinga : 'Service Name IP:Port'=Value;Warning Value;Critical Value;Min Value;Max Value
if [[ "$connect" == "$deadMsg" ]];
then
    if [ -n "$SYSLOGIP" ];
    then
        statusMsg="Nextra Naming Server[$serviceName]: <warn> $serviceIp:$servicePort is down."
        perl /usr/lib/nagios/plugins/service_status_syslog.pl $SYSLOGIP local0 warning "$statusMsg"
    fi
    echo "'$serviceName@$serviceIp:$servicePort'=0;0;0;0;1"
    #icingaData="$icingaData '$serviceName'=0;0;0;0;1"
else
    echo "'$serviceName@$serviceIp:$servicePort'=1;0;0;0;1"
    #icingaData="$icingaData '$serviceName'=1;0;0;0;1"
fi
