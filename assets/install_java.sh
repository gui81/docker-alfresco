#!/usr/bin/env sh
set -e

JAVA_RPM=jdk-8u111-linux-x64.rpm
JAVA_URL=http://download.oracle.com/otn-pub/java/jdk/8u111-b14/$JAVA_RPM

# get java
wget --no-cookies --no-check-certificate \
     --header "Cookie: gpw_e24=http%3A%2F%2Fwww.oracle.com%2F; oraclelicense=accept-securebackup-cookie" \
     $JAVA_URL

# install java
yum localinstall -y ./$JAVA_RPM

# make sure the oracle jdk is the default
update-alternatives --install /usr/bin/java java /usr/java/latest/bin/java 1065
update-alternatives --install /usr/bin/javac javac /usr/java/latest/bin/javac 1065
update-alternatives --install /usr/bin/jar jar /usr/java/latest/bin/jar 1065
update-alternatives --install /usr/bin/javaws javaws /usr/java/latest/bin/javaws 1065
