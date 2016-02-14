#!/bin/bash
set -e

# vars
export JAVA_HOME=/usr/java/latest
ALF_HOME=/alfresco
ALF_BIN=alfresco-community-5.0.d-installer-linux-x64.bin
ALF_URL=http://dl.alfresco.com/release/community/5.0.d-build-00002/$ALF_BIN

# get alfresco installer
mkdir -p $ALF_HOME
cd /tmp
curl -O $ALF_URL
chmod +x $ALF_BIN

# install alfresco
./$ALF_BIN --mode unattended --prefix $ALF_HOME --alfresco_admin_password admin

# get rid of installer - makes image smaller
rm $ALF_BIN

# add alfresco user
#useradd alfresco
