#!/bin/bash
set -e

ALF_HOME=/alfresco
CONNECTOR=mysql-connector-java-5.1.38

cd /tmp
curl -OL http://dev.mysql.com/get/Downloads/Connector-J/${CONNECTOR}.tar.gz
tar xvzf ${CONNECTOR}.tar.gz ${CONNECTOR}/${CONNECTOR}-bin.jar

mv ${CONNECTOR}/${CONNECTOR}-bin.jar ${ALF_HOME}/tomcat/lib

rm -rf /tmp/${CONNECTOR}*
