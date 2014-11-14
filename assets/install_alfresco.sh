#!/bin/bash
set -e

# vars
export JAVA_HOME=/usr/java/latest
ALF_HOME=/alfresco
ALF_BIN=alfresco-community-5.0.b-installer-linux-x64.bin

# satisfy dependencies
yum install -y http://download.fedoraproject.org/pub/epel/7/x86_64/e/epel-release-7-2.noarch.rpm
yum install -y fontconfig libSM libICE libXrender libXext hostname libXinerama cups-libs dbus-glib
yum install -y supervisor

# get alfresco installer
mkdir -p $ALF_HOME
cd /tmp
wget http://dl.alfresco.com/release/community/5.0.b-build-00092/$ALF_BIN
chmod +x $ALF_BIN

# install alfresco
./$ALF_BIN --mode unattended --prefix $ALF_HOME --alfresco_admin_password admin

# get rid of installer - makes image smaller
rm $ALF_BIN

# setup supervisor configs
cat > /etc/supervisord.d/libreoffice.conf <<EOF
[program:libreoffice]
priority=20
directory=/tmp
command=/alfresco/libreoffice/program/.soffice.bin --nofirststartwizard --nologo --headless --accept=socket,host=localhost,port=8100\;urp\;
user=root
autostart=true
autorestart=true
stdout_logfile=/var/log/supervisor/%(program_name)s.log
stderr_logfile=/var/log/supervisor/%(program_name)s.log
EOF
