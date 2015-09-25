FROM docker.io/jordan/icinga2

MAINTAINER Norio ISHIZAKI

# http://www.webupd8.org/2014/03/how-to-install-oracle-java-8-in-debian.html
RUN echo "deb http://ppa.launchpad.net/webupd8team/java/ubuntu trusty main" | tee /etc/apt/sources.list.d/webupd8team-java.list
RUN echo "deb-src http://ppa.launchpad.net/webupd8team/java/ubuntu trusty main" | tee -a /etc/apt/sources.list.d/webupd8team-java.list
RUN echo oracle-java8-installer shared/accepted-oracle-license-v1-1 select true | sudo /usr/bin/debconf-set-selections
RUN apt-key adv --keyserver hkp://keyserver.ubuntu.com:80 --recv-keys EEA14886

ENV GRADLE_HOME /opt/gradle-2.6

RUN apt-get update
RUN apt-get -qqy install --no-install-recommends vim gcc g++ make unzip oracle-java8-installer parallel && apt-get clean

# Download and deploy gradle to /opt/gradle-2.6
RUN wget https://services.gradle.org/distributions/gradle-2.6-bin.zip -O /tmp/gradle-2.6-bin.zip
RUN unzip /tmp/gradle-2.6-bin.zip -d /opt

# Build Nextra
RUN wget http://www.inspire-intl.com/product/nextra/download/broker-6.1-0.1.tgz -O /tmp/broker-6.1-0.1.tgz
RUN tar xvfz /tmp/broker-6.1-0.1.tgz -C /tmp
RUN cd /tmp && ./build.sh
RUN cp /tmp/install/linux.x86_64/tcp/bin/broker /usr/local/bin
RUN cp /tmp/install/linux.x86_64/tcp/bin/broklist /usr/local/bin
RUN mkdir -p /opt/nextra/bin && mkdir -p /opt/nextra/lib
RUN cp /tmp/install/linux.x86_64/tcp/bin/spring-boot-broklist.sh /opt/nextra/bin
RUN cp /tmp/install/linux.x86_64/tcp/lib/spring-boot-broklist-6.1.jar /opt/nextra/lib

# Deploy icinga plugins 
COPY plugins/* /usr/lib/nagios/plugins/
RUN chmod +x /usr/lib/nagios/plugins/*.sh
RUN chown nagios /usr/lib/nagios/plugins/*.sh
RUN chown nagios /usr/lib/nagios/plugins/service_status_syslog.pl
RUN mkdir /etc/icingaweb2/modules/pnp4nagios
COPY pnpplugin/* /etc/icingaweb2/modules/pnp4nagios/
RUN apt-get update && apt-get -y install --no-install-recommends pnp4nagios
RUN apt-get update && apt-get -y install rrdcached
RUN update-rc.d rrdcached defaults
RUN mkdir -p /var/cache/rrdcached
COPY configFiles/rrdcached /etc/default/
COPY configFiles/process_perfdata.cfg /etc/pnp4nagios/
COPY configFiles/config.php /etc/pnp4nagios/
COPY configFiles/pnp4nagios.conf /etc/apache2/conf.d/
COPY configFiles/npcd /etc/default/
COPY configFiles/npcd.cfg /etc/pnp4nagios/
COPY configFiles/htpasswd.users /etc/icinga2/
