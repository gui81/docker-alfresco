#!/usr/bin/env sh
set -e

# Marcus Rickert (05/26/2017): It's not clear why this Java JDK is installed, since the Alfresco installation package
# already contains one. Also, the specific download URL is not valid anymore. It become obsolete sometime between
# seven days ago and today.
#
# Automatically downloading an Oracle Java JDK has some strings attached to it. See http://blog.takipi.com/running-java-on-docker-youre-breaking-the-law/

#JAVA_RPM=jdk-8u91-linux-x64.rpm
#JAVA_URL=http://download.oracle.com/otn-pub/java/jdk/8u91-b14/$JAVA_RPM
#
## get java
#wget -nv --no-cookies --no-check-certificate \
#     --header "Cookie: gpw_e24=http%3A%2F%2Fwww.oracle.com%2F; oraclelicense=accept-securebackup-cookie" \
#     $JAVA_URL
#
## install java
#yum localinstall -y ./$JAVA_RPM
#rm -f ./$JAVA_RPM
#
## make sure the oracle jdk is the default
#update-alternatives --install /usr/bin/java java /usr/java/latest/bin/java 1065
#update-alternatives --install /usr/bin/javac javac /usr/java/latest/bin/javac 1065
#update-alternatives --install /usr/bin/jar jar /usr/java/latest/bin/jar 1065
#update-alternatives --install /usr/bin/javaws javaws /usr/java/latest/bin/javaws 1065
