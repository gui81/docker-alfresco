#!/usr/bin/env bash

# first check to see if alf_data has keystore directory, this is a crude way
# to determine if the mounted location has data or not, then we can bootstrap
# if it is the first time this is run
# let's copy data into the volume if it does not exist
if [ ! -d /alfresco/alf_data/keystore ]; then
  rsync -av --no-o --no-g /alf_data.install/alf_data /alfresco/

  echo
  echo 'Alfresco copied data from an original installation; ready for start up.'
  echo 'WARNING: if this was not expected, then you likely mounted a volume'
  echo '         that did not have the necessary files.  Please check your'
  echo '         volume paths.'
  echo
fi

ALF_HOME=/alfresco
ALF_BIN=$ALF_HOME/bin
ALF_SETUP=$ALF_HOME/setup
CATALINA_HOME=$ALF_HOME/tomcat

ALFRESCO_HOSTNAME=${ALFRESCO_HOSTNAME:-127.0.0.1}
ALFRESCO_PROTOCOL=${ALFRESCO_PROTOCOL:-http}
if [ "${ALFRESCO_PROTOCOL,,}" = "https" ]; then
  ALFRESCO_PORT=${ALFRESCO_PORT:-8443}
else
  ALFRESCO_PORT=${ALFRESCO_PORT:-8080}
fi


SHARE_HOSTNAME=${SHARE_HOSTNAME:-127.0.0.1}
SHARE_PROTOCOL=${SHARE_PROTOCOL:-http}
if [ "${SHARE_PROTOCOL,,}" = "https" ]; then
  SHARE_PORT=${SHARE_PORT:-8443}
else
  SHARE_PORT=${SHARE_PORT:-8080}
fi

DB_KIND=${DB_KIND:-postgresql}
DB_USERNAME=${DB_USERNAME:-alfresco}
DB_PASSWORD=${DB_PASSWORD:-admin}
DB_NAME=${DB_NAME:-alfresco}
DB_HOST=${DB_HOST:-localhost}
case "${DB_KIND,,}" in
  postgresql)
    DB_DRIVER=org.postgresql.Driver
    DB_PORT=${DB_PORT:-5432}
    ;;
  mysql)
    DB_DRIVER=org.gjt.mm.mysql.Driver
    DB_PORT=${DB_PORT:-3306}
    DB_CONN_PARAMS=${DB_CONN_PARAMS:-?useSSL=false}
    ;;
  *)
    echo "Database kind '$DB_KIND' not supported!"
    exit 1
esac

SYSTEM_SERVERMODE=${SYSTEM_SERVERMODE:-PRODUCTION}

MAIL_HOST=${MAIL_HOST:-localhost}
MAIL_PORT=${MAIL_PORT:-25}
MAIL_USERNAME=${MAIL_USERNAME:-}
MAIL_PASSWORD=${MAIL_PASSWORD:-}
MAIL_FROM_DEFAULT=${MAIL_FROM_DEFAULT:-alfresco@alfresco.org}
MAIL_PROTOCOL=${MAIL_PROTOCOL:-smtp}
MAIL_SMTP_AUTH=${MAIL_SMTP_AUTH:-false}
MAIL_SMTP_STARTTLS_ENABLE=${MAIL_SMTP_STARTTLS_ENABLE:-false}
MAIL_SMTPS_AUTH=${MAIL_SMTPS_AUTH:-false}
MAIL_SMTPS_STARTTLS_ENABLE=${MAIL_SMTPS_STARTTLS_ENABLE:-false}

FTP_PORT=${FTP_PORT:-21}

CIFS_ENABLED=${CIFS_ENABLED:-true}
CIFS_SERVER_NAME=${CIFS_SERVER_NAME:-localhost}
CIFS_DOMAIN=${CIFS_DOMAIN:-WORKGROUP}

NFS_ENABLED=${NFS_ENABLED:-true}

SOLR_ENABLE=${SOLR_ENABLE:-false}
SOLR_MODULE=${SOLR_MODULE:-solr4}
SOLR_HOST=${SOLR_HOST:-locahost}
SOLR_PORT=${SOLR_PORT:-8080}
SOLR_PORT_SSL=${SOLR_PORT_SSL:-8443}
SOLR_SECURE_COMMS=${SOLR_SECURE_COMMS:-https}

AUDIT_ENABLED=${AUDIT_ENABLED:-false}
AUDIT_ALFRESCO_ACCESS_ENABLED=${AUDIT_ALFRESCO_ACCESS_ENABLED:-false}

EXTERNAL_AUTH_ENABLED=${EXTERNAL_AUTH_ENABLED:-false}
EXTERNAL_AUTH_PROXY_USER_NAME=${EXTERNAL_AUTH_PROXY_USER_NAME:-}
EXTERNAL_AUTH_DEFAULT_ADMINS=${EXTERNAL_AUTH_DEFAULT_ADMINS:-admin}
EXTERNAL_AUTH_PROXY_HEADER=${EXTERNAL_AUTH_PROXY_HEADER:-X-Alfresco-Remote-User}
EXTERNAL_AUTH_USER_ID_PATTERN=${EXTERNAL_AUTH_USER_ID_PATTERN:-}


LDAP_ENABLED=${LDAP_ENABLED:-false}
LDAP_KIND=${LDAP_KIND:-ldap}
LDAP_AUTH_USERNAMEFORMAT=${LDAP_AUTH_USERNAMEFORMAT-uid=%s,cn=users,cn=accounts,dc=example,dc=com}
LDAP_URL=${LDAP_URL:-ldap://ldap.example.com:389}
LDAP_DEFAULT_ADMINS=${LDAP_DEFAULT_ADMINS:-admin}
LDAP_SECURITY_PRINCIPAL=${LDAP_SECURITY_PRINCIPAL:-uid=admin,cn=users,cn=accounts,dc=example,dc=com}
LDAP_SECURITY_CREDENTIALS=${LDAP_SECURITY_CREDENTIALS:-password}
LDAP_GROUP_SEARCHBASE=${LDAP_GROUP_SEARCHBASE:-cn=groups,cn=accounts,dc=example,dc=com}
LDAP_USER_SEARCHBASE=${LDAP_USER_SEARCHBASE:-cn=users,cn=accounts,dc=example,dc=com}
LDAP_USER_ATTRIBUTENAME=${LDAP_USER_ATTRIBUTENAME:-uid}
LDAP_GROUP_MEMBER_ATTRIBUTENAME=${LDAP_GROUP_MEMBER_ATTRIBUTENAME:-memberUid}

CONTENT_STORE=${CONTENT_STORE:-/content}

TOMCAT_CSRF_PATCH="${ALF_HOME}/disable_tomcat_CSRF.patch"
TOMCAT_CSRF_ENABLED=${TOMCAT_CSRF_ENABLED:-true}

function cfg_replace_option {
  grep "$1" "$3" > /dev/null
  if [ $? -eq 0 ]; then
    # replace option
    echo "replacing option  $1=$2  in  $3"
    sed -i "s#^\($1\s*=\s*\).*\$#\1$2#" $3
    if (( $? )); then
      echo "cfg_replace_option failed"
      exit 1
    fi
  else
    # add option if it does not exist
    echo "adding option  $1=$2  in  $3"
    echo "$1=$2" >> $3
  fi
}

function tweak_alfresco {
  ALFRESCO_GLOBAL_PROPERTIES=$CATALINA_HOME/shared/classes/alfresco-global.properties

  cfg_replace_option audit.enabled $AUDIT_ENABLED $ALFRESCO_GLOBAL_PROPERTIES
  cfg_replace_option audit.alfresco-access.enabled $AUDIT_ALFRESCO_ACCESS_ENABLED $ALFRESCO_GLOBAL_PROPERTIES

  #alfresco host+proto+port
  cfg_replace_option alfresco.host $ALFRESCO_HOSTNAME $ALFRESCO_GLOBAL_PROPERTIES
  cfg_replace_option alfresco.protocol $ALFRESCO_PROTOCOL $ALFRESCO_GLOBAL_PROPERTIES
  cfg_replace_option alfresco.port $ALFRESCO_PORT $ALFRESCO_GLOBAL_PROPERTIES

  #share host+proto+port
  cfg_replace_option share.host $SHARE_HOSTNAME $ALFRESCO_GLOBAL_PROPERTIES
  cfg_replace_option share.protocol $SHARE_PROTOCOL $ALFRESCO_GLOBAL_PROPERTIES
  cfg_replace_option share.port $SHARE_PORT $ALFRESCO_GLOBAL_PROPERTIES

  #set server mode
  cfg_replace_option system.serverMode $SYSTEM_SERVERMODE $ALFRESCO_GLOBAL_PROPERTIES

  #db.schema.update=true
  cfg_replace_option db.driver $DB_DRIVER $ALFRESCO_GLOBAL_PROPERTIES
  cfg_replace_option db.username $DB_USERNAME $ALFRESCO_GLOBAL_PROPERTIES
  cfg_replace_option db.password $DB_PASSWORD $ALFRESCO_GLOBAL_PROPERTIES
  cfg_replace_option db.name $DB_NAME $ALFRESCO_GLOBAL_PROPERTIES
  cfg_replace_option db.url jdbc:${DB_KIND,,}://${DB_HOST}:${DB_PORT}/${DB_NAME}${DB_CONN_PARAMS} $ALFRESCO_GLOBAL_PROPERTIES

  cfg_replace_option mail.host $MAIL_HOST $ALFRESCO_GLOBAL_PROPERTIES
  cfg_replace_option mail.port $MAIL_PORT $ALFRESCO_GLOBAL_PROPERTIES
  cfg_replace_option mail.username $MAIL_USERNAME $ALFRESCO_GLOBAL_PROPERTIES
  cfg_replace_option mail.password $MAIL_PASSWORD $ALFRESCO_GLOBAL_PROPERTIES
  cfg_replace_option mail.from.default $MAIL_FROM_DEFAULT $ALFRESCO_GLOBAL_PROPERTIES
  cfg_replace_option mail.protocol $MAIL_PROTOCOL $ALFRESCO_GLOBAL_PROPERTIES
  cfg_replace_option mail.smtp.auth $MAIL_SMTP_AUTH $ALFRESCO_GLOBAL_PROPERTIES
  cfg_replace_option mail.smtp.starttls.enable $MAIL_SMTP_STARTTLS_ENABLE $ALFRESCO_GLOBAL_PROPERTIES
  cfg_replace_option mail.smtps.auth $MAIL_SMTPS_AUTH $ALFRESCO_GLOBAL_PROPERTIES
  cfg_replace_option mail.smtps.starttls.enable $MAIL_SMTPS_STARTTLS_ENABLE $ALFRESCO_GLOBAL_PROPERTIES

  cfg_replace_option ftp.port $FTP_PORT $ALFRESCO_GLOBAL_PROPERTIES

  # @see https://forums.alfresco.com/en/viewtopic.php?f=8&t=20893
  # CIFS works, but you have to login as a native Alfresco account, like admin
  # because CIFS does not work with LDAP authentication
  cfg_replace_option cifs.enabled $CIFS_ENABLED $ALFRESCO_GLOBAL_PROPERTIES
  cfg_replace_option cifs.Server.Name $CIFS_SERVER_NAME $ALFRESCO_GLOBAL_PROPERTIES
  cfg_replace_option cifs.domain $CIFS_DOMAIN $ALFRESCO_GLOBAL_PROPERTIES
  cfg_replace_option cifs.hostannounce "true" $ALFRESCO_GLOBAL_PROPERTIES
  cfg_replace_option cifs.broadcast "0.0.0.255" $ALFRESCO_GLOBAL_PROPERTIES
  cfg_replace_option cifs.ipv6.enabled "false" $ALFRESCO_GLOBAL_PROPERTIES

  cfg_replace_option nfs.enabled $NFS_ENABLED $ALFRESCO_GLOBAL_PROPERTIES



  # authentication matrix
  if [ "$LDAP_ENABLED" == "true"  ] && [ "$EXTERNAL_AUTH_ENABLED" == "false" ]; then
    cfg_replace_option authentication.chain "alfrescoNtlm1:alfrescoNtlm,ldap1:${LDAP_KIND}" $ALFRESCO_GLOBAL_PROPERTIES
  fi
  
  if [ "$LDAP_ENABLED" == "false"  ] && [ "$EXTERNAL_AUTH_ENABLED" == "true" ]; then
    cfg_replace_option authentication.chain "external1:external,alfrescoNtlm1:alfrescoNtlm" $ALFRESCO_GLOBAL_PROPERTIES
  fi

  if [ "$LDAP_ENABLED" == "true"  ] && [ "$EXTERNAL_AUTH_ENABLED" == "true" ]; then
    cfg_replace_option authentication.chain "external1:external,alfrescoNtlm1:alfrescoNtlm,ldap1:${LDAP_KIND}" $ALFRESCO_GLOBAL_PROPERTIES
  fi
  
  if [ "$LDAP_ENABLED" == "false"  ] && [ "$EXTERNAL_AUTH_ENABLED" == "false" ]; then
    cfg_replace_option authentication.chain "alfrescoNtlm1:alfrescoNtlm" $ALFRESCO_GLOBAL_PROPERTIES
  fi
  
  if [ "$EXTERNAL_AUTH_ENABLED" == "true" ]; then
    cfg_replace_option external.authentication.enabled $EXTERNAL_AUTH_ENABLED $ALFRESCO_GLOBAL_PROPERTIES
    cfg_replace_option external.authentication.proxyUserName "$EXTERNAL_AUTH_PROXY_USER_NAME" $ALFRESCO_GLOBAL_PROPERTIES
    cfg_replace_option external.authentication.defaultAdministratorUserNames $EXTERNAL_AUTH_DEFAULT_ADMINS $ALFRESCO_GLOBAL_PROPERTIES
    cfg_replace_option external.authentication.proxyHeader $EXTERNAL_AUTH_PROXY_HEADER $ALFRESCO_GLOBAL_PROPERTIES
    cfg_replace_option external.authentication.userIdPattern "$EXTERNAL_AUTH_USER_ID_PATTERN" $ALFRESCO_GLOBAL_PROPERTIES
  fi
  

  if [ "$LDAP_ENABLED" == "true" ]; then
    # now make substitutions in the LDAP config file
    LDAP_CONFIG_FILE=$CATALINA_HOME/shared/classes/alfresco/extension/subsystems/Authentication/${LDAP_KIND}/ldap1/${LDAP_KIND}-authentication.properties

    cfg_replace_option "ldap.authentication.userNameFormat" "$LDAP_AUTH_USERNAMEFORMAT" "$LDAP_CONFIG_FILE"
    cfg_replace_option ldap.authentication.java.naming.provider.url $LDAP_URL $LDAP_CONFIG_FILE
    cfg_replace_option ldap.authentication.defaultAdministratorUserNames $LDAP_DEFAULT_ADMINS $LDAP_CONFIG_FILE
    cfg_replace_option ldap.synchronization.java.naming.security.principal $LDAP_SECURITY_PRINCIPAL $LDAP_CONFIG_FILE
    cfg_replace_option ldap.synchronization.java.naming.security.credentials $LDAP_SECURITY_CREDENTIALS $LDAP_CONFIG_FILE
    cfg_replace_option ldap.synchronization.groupSearchBase $LDAP_GROUP_SEARCHBASE $LDAP_CONFIG_FILE
    cfg_replace_option ldap.synchronization.userSearchBase $LDAP_USER_SEARCHBASE $LDAP_CONFIG_FILE
    cfg_replace_option ldap.synchronization.userIdAttributeName $LDAP_USER_ATTRIBUTENAME $LDAP_CONFIG_FILE
    cfg_replace_option ldap.synchronization.groupMemberAttributeName $LDAP_GROUP_MEMBER_ATTRIBUTENAME $LDAP_CONFIG_FILE
  fi

  if [ "$SOLR_ENABLE" == "true" ]; then
    cfg_replace_option index.subsystem.name $SOLR_MODULE $ALFRESCO_GLOBAL_PROPERTIES
    cfg_replace_option solr.host $SOLR_HOST $ALFRESCO_GLOBAL_PROPERTIES
    cfg_replace_option solr.port "$SOLR_PORT" $ALFRESCO_GLOBAL_PROPERTIES
    cfg_replace_option solr.port.ssl "$SOLR_PORT_SSL" $ALFRESCO_GLOBAL_PROPERTIES
    cfg_replace_option solr.secureComms $SOLR_SECURE_COMMS $ALFRESCO_GLOBAL_PROPERTIES
  fi



  index.subsystem.name=solr4
solr.host=solr
solr.port=8080
solr.port.ssl=8443
#solr.max.total.connections=
#solr.max.host.connections=
solr.secureComms=none

  # content store
  cfg_replace_option dir.contentstore "${CONTENT_STORE}/contentstore" $ALFRESCO_GLOBAL_PROPERTIES
  cfg_replace_option dir.contentstore.deleted "${CONTENT_STORE}/contentstore.deleted" $ALFRESCO_GLOBAL_PROPERTIES
}

tweak_alfresco

if [ -d "$AMP_DIR_ALFRESCO" ]; then
  echo "Installing Alfresco AMPs from $AMP_DIR_ALFRESCO..."
  $ALF_HOME/java/bin/java -jar $ALF_HOME/bin/alfresco-mmt.jar install $AMP_DIR_ALFRESCO $CATALINA_HOME/webapps/alfresco.war -directory -force -verbose
  $ALF_HOME/java/bin/java -jar $ALF_HOME/bin/alfresco-mmt.jar list $CATALINA_HOME/webapps/alfresco.war
fi

if [ -d "$AMP_DIR_SHARE" ]; then
  echo "Installing Share AMPs from $AMP_DIR_SHARE..."
  $ALF_HOME/java/bin/java -jar $ALF_HOME/bin/alfresco-mmt.jar install $AMP_DIR_SHARE $CATALINA_HOME/webapps/share.war -directory -force -verbose
  $ALF_HOME/java/bin/java -jar $ALF_HOME/bin/alfresco-mmt.jar list $CATALINA_HOME/webapps/share.war
fi

# setup environment
source $ALF_HOME/scripts/setenv.sh
export FONTCONFIG_PATH=/etc/fonts

# start internal postgres server only if the host is localhost
if [ "${DB_KIND,,}" == "postgresql" ] && [ "$DB_HOST" == "localhost" ]; then
  $ALF_HOME/postgresql/scripts/ctl.sh start
fi

#disable CSRF if needed
#rename the patch to prevent reuse
if [ "$TOMCAT_CSRF_ENABLED" == "false" ] && [ -f "$TOMCAT_CSRF_PATCH" ] ;then
  patch -Np0 < $TOMCAT_CSRF_PATCH
  [ $? == 0 ] && mv "$TOMCAT_CSRF_PATCH" "${TOMCAT_CSRF_PATCH}.done"
fi

# start alfresco
$ALF_HOME/tomcat/scripts/ctl.sh start
