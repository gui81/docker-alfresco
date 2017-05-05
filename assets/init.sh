#!/usr/bin/env bash

set +e

ALF_HOME=/alfresco
ALF_BIN=$ALF_HOME/bin
ALF_SETUP=$ALF_HOME/setup
CATALINA_HOME=$ALF_HOME/tomcat
AMP_DIR_ALFRESCO=$ALF_HOME/amps
AMP_DIR_SHARE=$ALF_HOME/amps_share

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

export LDAP_ENABLED=${LDAP_ENABLED:-false}
export LDAP_KIND=${LDAP_KIND:-ldap}
export LDAP_AUTH_USERNAMEFORMAT=${LDAP_AUTH_USERNAMEFORMAT:-uid=%s,cn=users,cn=accounts,dc=example,dc=com}
export LDAP_URL=${LDAP_URL:-ldap://ldap.example.com:389}
export LDAP_DEFAULT_ADMINS=${LDAP_DEFAULT_ADMINS:-admin}
export LDAP_SECURITY_PRINCIPAL=${LDAP_SECURITY_PRINCIPAL:-uid=admin,cn=users,cn=accounts,dc=example,dc=com}
export LDAP_SECURITY_CREDENTIALS=${LDAP_SECURITY_CREDENTIALS:-password}
export LDAP_GROUP_SEARCHBASE=${LDAP_GROUP_SEARCHBASE:-cn=groups,cn=accounts,dc=example,dc=com}
export LDAP_USER_SEARCHBASE=${LDAP_USER_SEARCHBASE:-cn=users,cn=accounts,dc=example,dc=com}
export LDAP_USER_ID_ATTRIBUTE_NAME=${LDAP_USER_ID_ATTRIBUTE_NAME:-uid}
export LDAP_GROUP_QUERY=${LDAP_GROUP_QUERY:-\(objectclass=posixGroup\)}
export LDAP_GROUP_DIFFERENTIAL_QUERY=${LDAP_GROUP_DIFFERENTIAL_QUERY:-\(&\(objectclass=posixGroup\)\(!\(modifyTimestamp<=\{0\}\)\)\)}
export LDAP_PERSON_QUERY=${LDAP_PERSON_QUERY:-\(objectclass=inetOrgPerson\)}
export LDAP_PERSON_DIFFERENTIAL_QUERY=${LDAP_PERSON_DIFFERENTIAL_QUERY:-\(&\(objectclass=inetOrgPerson\)\(!\(modifyTimestamp<=\{0\}\)\)\)}
export LDAP_GROUP_TYPE=${LDAP_GROUP_TYPE:-posixGroup}
export LDAP_PERSON_TYPE=${LDAP_PERSON_TYPE:-inetOrgPerson}
export LDAP_GROUP_MEMBER_ATTRIBUTE_NAME=${LDAP_GROUP_MEMBER_ATTRIBUTE_NAME:-memberUid}

export CROWD_ENABLED=${CROWD_ENABLED:-false}
export CROWD_URL=${CROWD_URL:-http://localhost:8095/crowd}
export CROWD_SYNCHRONIZATION_ENABLE=${CROWD_SYNCHRONIZATION_ENABLE:-true}
export CROWD_AUTH_SSO_ENABLED=${CROWD_AUTH_SSO_ENABLED:-false}
export CROWD_AUTH_LICENSE=${CROWD_AUTH_LICENSE:-LICENSE_NOT_SET_AS_ENVIRONMENT_IN_DOCKER}
export CROWD_AUTHENTICATION_ALLOW_GUEST_LOGIN=${CROWD_AUTHENTICATION_ALLOW_GUEST_LOGIN:-false}
export CROWD_GROUP_UPPERCASE=${CROWD_GROUP_UPPERCASE:-true}
export CROWD_GROUP_PREFIX_STRIP=${CROWD_GROUP_PREFIX_STRIP:-}
export CROWD_GROUP_PREFIX_ADD=${CROWD_GROUP_PREFIX_ADD:-}
export CROWD_GROUP_REPLACE_DASHES=${CROWD_GROUP_REPLACE_DASHES:-true}

export ALFRESCO_CROWD_APPLICATION_NAME=${ALFRESCO_CROWD_APPLICATION_NAME:-alfresco}
export ALFRESCO_CROWD_APPLICATION_PASSWORD=${ALFRESCO_CROWD_APPLICATION_PASSWORD}

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

  # authentication
  if [ "$LDAP_ENABLED" == "true" ]; then
    cfg_replace_option authentication.chain "alfrescoNtlm1:alfrescoNtlm,ldap1:${LDAP_KIND}" $ALFRESCO_GLOBAL_PROPERTIES

    # now make substitutions in the LDAP config file
    LDAP_CONFIG_FILE=$CATALINA_HOME/shared/classes/alfresco/extension/subsystems/Authentication/${LDAP_KIND}/ldap1/${LDAP_KIND}-authentication.properties

    gawk -f /tmp/replace_vars.awk $LDAP_CONFIG_FILE > /tmp/properties.new
    mv -f /tmp/properties.new $LDAP_CONFIG_FILE
                
  elif [ "$CROWD_ENABLED" == "true" ]; then
    cfg_replace_option authentication.chain "alfrescoNtlm1:alfrescoNtlm,crowd-auth:crowd-auth" $ALFRESCO_GLOBAL_PROPERTIES

    echo "Configuring Crowd..."
    # Now make substitutions in the CROWD config file crowd-auth-authentication.properties
    CROWD_CONFIG_FILE=/templates/crowd-auth/crowd-auth-authentication.properties

    gawk -f /tmp/replace_vars.awk $CROWD_CONFIG_FILE > /tmp/properties.new
    mv -f /tmp/properties.new $CROWD_CONFIG_FILE

    # Update patched file in WAR archive
    RELATIVE_WAR_PATH=WEB-INF/classes/alfresco/subsystems/Authentication/crowd-auth
    mkdir -p $RELATIVE_WAR_PATH
    cp -f $CROWD_CONFIG_FILE $RELATIVE_WAR_PATH
    echo "Patching WAR file..."
    /usr/bin/jar uf $CATALINA_HOME/webapps/alfresco.war $RELATIVE_WAR_PATH/crowd-auth-authentication.properties
    rm -rf $RELATIVE_WAR_PATH

    # now make substitutions in the CROWD config file crowd.properties
    CROWD_CONFIG_FILE=$CATALINA_HOME/shared/classes/crowd.properties

    gawk -f /tmp/replace_vars.awk $CROWD_CONFIG_FILE > /tmp/properties.new
    mv -f /tmp/properties.new $CROWD_CONFIG_FILE

    wget -nv -O /alfresco/amps/crowd-auth-${CROWD_PLUGIN_VERSION}.amp ${CROWD_PLUGIN_DOWNLOAD_URL}

  else

    cfg_replace_option authentication.chain "alfrescoNtlm1:alfrescoNtlm" $ALFRESCO_GLOBAL_PROPERTIES

  fi

  # content store
  cfg_replace_option dir.contentstore "${CONTENT_STORE}/contentstore" $ALFRESCO_GLOBAL_PROPERTIES
  cfg_replace_option dir.contentstore.deleted "${CONTENT_STORE}/contentstore.deleted" $ALFRESCO_GLOBAL_PROPERTIES
}

if [ -d "$AMP_DIR_ALFRESCO" ]; then
  echo "Installing Alfresco AMPs from $AMP_DIR_ALFRESCO..."
  $ALF_HOME/java/bin/java -jar $ALF_HOME/bin/alfresco-mmt.jar install $AMP_DIR_ALFRESCO $CATALINA_HOME/webapps/alfresco.war -directory -force -verbose
  $ALF_HOME/java/bin/java -jar $ALF_HOME/bin/alfresco-mmt.jar list $CATALINA_HOME/webapps/alfresco.war
  rm -rf $CATALINA_HOME/webapps/alfresco
  . $ALF_HOME/bin/clean_tomcat.sh
fi

if [ -d "$AMP_DIR_SHARE" ]; then
  echo "Installing Share AMPs from $AMP_DIR_SHARE..."
  $ALF_HOME/java/bin/java -jar $ALF_HOME/bin/alfresco-mmt.jar install $AMP_DIR_SHARE $CATALINA_HOME/webapps/share.war -directory -force -verbose
  $ALF_HOME/java/bin/java -jar $ALF_HOME/bin/alfresco-mmt.jar list $CATALINA_HOME/webapps/share.war
  rm -rf $CATALINA_HOME/webapps/share
  . $ALF_HOME/bin/clean_tomcat.sh
fi

tweak_alfresco

# setup environment
source $ALF_HOME/scripts/setenv.sh

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
