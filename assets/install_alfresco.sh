#!/usr/bin/env sh
set -e

# vars
export JAVA_HOME=/usr/java/latest
ALF_HOME=/alfresco
ALF_BIN=alfresco-community-installer-201604-linux-x64.bin
ALF_URL=http://dl.alfresco.com/release/community/201604-build-00007/$ALF_BIN

# get alfresco installer
mkdir -p $ALF_HOME
cd /tmp
echo "Downloading $ALF_URL..."
curl -sS -O $ALF_URL
chmod +x $ALF_BIN

# install alfresco
echo "Executing Alfresco installer..."
./$ALF_BIN --mode unattended --prefix $ALF_HOME --alfresco_admin_password admin

# get rid of installer - makes image smaller
rm $ALF_BIN

echo "Downloading ${CROWD_PLUGIN_DOWNLOAD_URL}..."
wget -nv -O /alfresco/amps/crowd-auth-${CROWD_PLUGIN_VERSION}.amp ${CROWD_PLUGIN_DOWNLOAD_URL}

# add alfresco user
#useradd alfresco
