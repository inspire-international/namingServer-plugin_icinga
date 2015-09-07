# Naming server plugin for icinga
Icinga on Docker container empowered with naming server plugin through which any registered network processes are to be monitored.

![Naming server plugin for Icinga](http://www.inspire-intl.com/images/namingServer-plugin_icinga_monitor.jpg)


# Prerequisite
Software: Docker


# Demo video on YouTube(158 secs)

[![YouTube](https://i.ytimg.com/vi/wLoUvtex1kY/hqdefault.jpg)](https://youtu.be/wLoUvtex1kY)


# Preparation

1) On your HostOS, issue the following git command to create the clone.
```sh
    $git clone https://github.com/inspire-international/namingServer-plugin_icinga.git
```

2) cd to namingServer-plugin_icinga directory and kick the build.sh.
```sh
    $./build.sh 
```

3) kick the run.sh to create & start the container.
```sh
    $./run.sh 
```

4) stop the container.


```sh
    $./stop.sh 
```

5) From 2nd time, use start.sh to start the container.
```sh
    $./start.sh 
```


# Acccess to Icinga

Open your browser, input
http://localhost/icingaweb2
and type

> Username: icingaadmin

> Password: icinga

Please check services registered to Nextra Naming Server.


# Handling services

To see which services are registered to the naming server, type as following.
http://localhost:8080/broklist

### Adding service

> $ sudo docker exec icinga_broker /bin/bash -c "broklist -add localhost 39001 [serviceName]+[HOSTNAME]+[PORT#]"

For instance, type as following on your host machine.

```sh
$ sudo docker exec icinga_broker /bin/bash -c "broklist -add localhost 39001 httpd+www.example.com+80"
```

### Deleting service

> $ sudo docker exec icinga_broker /bin/bash -c "broklist -del localhost 39001 [serviceName]+[HOSTNAME]+[PORT#]"

For instance, type as following on your host machine.

```sh
$ sudo docker exec icinga_broker /bin/bash -c "broklist -del localhost 39001 httpd+www.example.com+80"
```


[Nextra](http://www.inspire-intl.com/product/product_nextra.html)

#### Copyright (C) 1998 - 2015  Inspire International Inc.