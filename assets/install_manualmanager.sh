#!/bin/bash
set -e

# vars
ALF_HOME=/alfresco

# get Loftux Manual Manager installer
cd /tmp
git clone git://github.com/loftuxab/manual-manager.git ManualManager

# Generate JAR file
pushd ManualManager
ant package

cp /tmp/ManualManager/build/dist/loftux-manual-manager.jar $ALF_HOME/tomcat/webapps/alfresco/WEB-INF/lib/
cp /tmp/ManualManager/build/dist/loftux-manual-manager.jar $ALF_HOME/tomcat/webapps/share/WEB-INF/lib/

popd

rm -rf /tmp/ManualManager