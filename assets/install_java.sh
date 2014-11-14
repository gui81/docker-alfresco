#!/bin/bash
set -e

JAVA_RPM=jdk-8u25-linux-x64.rpm

# get java
wget --no-cookies --no-check-certificate --header "Cookie: gpw_e24=http%3A%2F%2Fwww.oracle.com%2F; oraclelicense=accept-securebackup-cookie" http://download.oracle.com/otn-pub/java/jdk/8u25-b17/$JAVA_RPM

# install java
yum localinstall -y ./$JAVA_RPM

# make sure the oracle jdk is the default
update-alternatives --install /usr/bin/java java /usr/java/latest/bin/java 1065
update-alternatives --install /usr/bin/javac javac /usr/java/latest/bin/javac 1065
update-alternatives --install /usr/bin/jar jar /usr/java/latest/bin/jar 1065
update-alternatives --install /usr/bin/javaws javaws /usr/java/latest/bin/javaws 1065
