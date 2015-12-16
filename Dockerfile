FROM docker.io/jordan/icinga2

MAINTAINER Norio ISHIZAKI

# Modify according to your timezone, or just comment out if catering UTC.
RUN echo "Asia/Tokyo" > /etc/timezone && dpkg-reconfigure -f noninteractive tzdata

# http://www.webupd8.org/2014/03/how-to-install-oracle-java-8-in-debian.html
RUN echo "deb http://ppa.launchpad.net/webupd8team/java/ubuntu trusty main" | tee /etc/apt/sources.list.d/webupd8team-java.list
RUN echo "deb-src http://ppa.launchpad.net/webupd8team/java/ubuntu trusty main" | tee -a /etc/apt/sources.list.d/webupd8team-java.list
RUN echo oracle-java8-installer shared/accepted-oracle-license-v1-1 select true | sudo /usr/bin/debconf-set-selections
RUN apt-key adv --keyserver hkp://keyserver.ubuntu.com:80 --recv-keys EEA14886

RUN apt-get update
RUN apt-get -qqy install --no-install-recommends vim gcc g++ ksh unzip parallel && apt-get clean

RUN apt-get -qqy install --no-install-recommends oracle-java8-installer && apt-get clean
ENV JAVA_HOME /usr/lib/jvm/java-8-oracle
RUN apt-get -qqy install --no-install-recommends ant swig && apt-get clean

# Install pnp4nagios dependencies
RUN apt-get -qqy install --no-install-recommends make rrdtool librrds-perl php5-cli php5-gd libapache2-mod-php5 && apt-get clean
RUN cp /usr/bin/make /usr/bin/gmake

# Download and deploy gradle to /opt/gradle-2.8
RUN wget --no-check-certificate https://services.gradle.org/distributions/gradle-2.8-bin.zip -O /tmp/gradle-2.8-bin.zip
RUN unzip /tmp/gradle-2.8-bin.zip -d /opt
ENV GRADLE_HOME /opt/gradle-2.8

# Nextra65
RUN wget http://www.inspire-intl.com/product/nextra/download/nextra-65.tgz -O /tmp/nextra-65.tgz
RUN mkdir -p /home/nextra/build
RUN tar xvfz /tmp/nextra-65.tgz -C /home/nextra/build
ENV MODULE_BUILD_TYPE R
ENV ODEDIR /home/nextra/build/Nextra/src/../install/linux.x86_64/tcp
ENV PATH "$PATH:$ODEDIR/bin:$ODEDIR/../cmn/bin"
ENV LD_LIBRARY_PATH "$JAVA_HOME/jre/lib/amd64/server:$ODEDIR/lib"
RUN cd /home/nextra/build/Nextra/src && ./build.sh all
RUN cd /home/nextra/build/Nextra/src && ./build.sh install
RUN cd $ODEDIR/../samples/nextra-rest-server/java/standard && ./build.sh
RUN mkdir /tmp/options
COPY options/* /tmp/options/

# Deploy icinga plugins 
COPY plugins/* /usr/lib/nagios/plugins/
RUN chmod +x /usr/lib/nagios/plugins/*.sh
RUN chmod +x /usr/lib/nagios/plugins/service_status_syslog.pl
RUN chown nagios /usr/lib/nagios/plugins/*.sh
RUN chown nagios /usr/lib/nagios/plugins/service_status_syslog.pl
RUN mkdir /etc/icingaweb2/modules/pnp4nagios
COPY pnpplugin/* /etc/icingaweb2/modules/pnp4nagios/

# Install pnp4nagios
RUN wget https://docs.pnp4nagios.org/_media/dwnld/pnp4nagios-head.tar.gz -O /tmp/pnp4nagios-head.tar.gz
RUN tar -xvzf /tmp/pnp4nagios-head.tar.gz -C /tmp
RUN cd /tmp/pnp4nagios-head && ./configure && make all && make fullinstall

# COPY config files
COPY configFiles/pnp4nagios.conf /etc/apache2/conf-enabled/
COPY configFiles/npcd.cfg /usr/local/pnp4nagios/etc/npcd.cfg
COPY configFiles/graph_content.php /usr/local/pnp4nagios/share/application/views/graph_content.php