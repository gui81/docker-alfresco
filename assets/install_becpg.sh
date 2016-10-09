#!/bin/bash
echo "Open source Add-On by BeCPG (http://becpg.net)"
echo "Download from Sourceforge.net (http://sourcefoge.net/projects/becpg-community"
set -e

# vars
ALF_HOME=/alfresco
BECPG_SF_PROJECT=2_1_a
BECPG_VERSION=2.1.0
BECPG_BUILD=2.1.0-20160421

# get beCPG installer
cd /tmp
wget http://downloads.sourceforge.net/project/becpg-community/becpg-community-$BECPG_SF_PROJECT/becpg-plm-$BECPG_BUILD.zip

# Decompress BeCPG PLM, Designer and Project archives
unzip -o becpg-plm-$BECPG_BUILD.zip -d becpg-plm

# Install beCPG PLM (Contains beCPG designer, project and plm)
cd /tmp/becpg-plm/becpg-plm-$BECPG_BUILD*
# Alfresco AMPS
java -jar  $ALF_HOME/bin/alfresco-mmt.jar install ./amps/becpg-core-$BECPG_VERSION.amp $ALF_HOME/tomcat/webapps/alfresco.war -force
java -jar  $ALF_HOME/bin/alfresco-mmt.jar install ./amps/becpg-plm-core-$BECPG_VERSION.amp $ALF_HOME/tomcat/webapps/alfresco.war -force
java -jar  $ALF_HOME/bin/alfresco-mmt.jar install ./amps/becpg-designer-core-$BECPG_VERSION.amp $ALF_HOME/tomcat/webapps/alfresco.war -force
java -jar  $ALF_HOME/bin/alfresco-mmt.jar install ./amps/becpg-project-core-$BECPG_VERSION.amp $ALF_HOME/tomcat/webapps/alfresco.war -force
# Share AMPS
java -jar  $ALF_HOME/bin/alfresco-mmt.jar install ./amps/becpg-share-$BECPG_VERSION.amp $ALF_HOME/tomcat/webapps/share.war -force
java -jar  $ALF_HOME/bin/alfresco-mmt.jar install ./amps/becpg-plm-share-$BECPG_VERSION.amp $ALF_HOME/tomcat/webapps/share.war -force
java -jar  $ALF_HOME/bin/alfresco-mmt.jar install ./amps/becpg-designer-share-$BECPG_VERSION.amp $ALF_HOME/tomcat/webapps/share.war -force
java -jar  $ALF_HOME/bin/alfresco-mmt.jar install ./amps/becpg-project-share-$BECPG_VERSION.amp $ALF_HOME/tomcat/webapps/share.war -force

rm -rf /tmp/becpg*