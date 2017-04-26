#!/usr/bin/env sh
set -e

ALF_HOME=/alfresco
CONNECTOR=mysql-connector-java-5.1.38

cd /tmp
URL=http://dev.mysql.com/get/Downloads/Connector-J/${CONNECTOR}.tar.gz
echo "Download $URL..."
curl -sS -OL $URL
tar xvzf ${CONNECTOR}.tar.gz ${CONNECTOR}/${CONNECTOR}-bin.jar

mv ${CONNECTOR}/${CONNECTOR}-bin.jar ${ALF_HOME}/tomcat/lib

rm -rf /tmp/${CONNECTOR}*
