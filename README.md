# docker-alfresco

## Table of Contents

- [Introduction](#introduction)
- [Contributing](#contributing)
- [Installation](#installation)
- [Quick Start](#quick-start)
- [Configuration](#configuration)
  - [Datastore](#datastore)
  - [Database](#database)
  - [Options](#options)
- [Upgrading](#upgrading)
- [References](#references)

## Introduction
Dockerfile to build an Alfresco container image.

## Contributing
Here is how you can help:
- Send a Pull Request with your awesome new features and bug fixes
- Report [Issues](https://github.com/gui81/docker-alfresco/issues)

## Installation
Pull the image from the docker index.
```bash
docker pull gui81/alfresco:latest
```

or pull a particular version:
```bash
docker pull gui81/alfresco:201707
```

Alternatively, you can build the image yourself:
```bash
git clone https://github.com/gui81/docker-alfresco.git
cd docker-alfresco
docker build --tag="$USER/alfresco" .
```

## Quick Start
Run the alfresco image with the name "alfresco".

```bash
docker run --name='alfresco' -it --rm -p 8080:8080 gui81/alfresco
```

**NOTE**: Please allow a few minutes for the application to start, especially if
populating the database for the first time.

Go to `http://localhost:8080/share` or point to the ip of your docker server.
On the Mac, if you are running docker-machine, then you can go to the ip
reported by:

```bash
docker-machine ip [name of Docker VM]
```

The default username and password are:
- username: **admin**
- password: **admin**

Alfresco should now be up and running.  The following is an example that would
mount the appropriate volume, connect to a remote PostgreSQL database, and use
an external LDAP server for authentication:
```bash
docker run --name='alfresco' -it --rm -p 445:445 -p 7070:7070 -p 8080:8080 \
    -v '/host/alfresco/content:/content' \
    -v '/host/alfresco/data:/alfresco/alf_data' \
    -e 'CONTENT_STORE=/content' \
    -e 'LDAP_ENABLED=true' \
    -e 'LDAP_AUTH_USERNAMEFORMAT=uid=%s,cn=users,cn=accounts,dc=example,dc=com' \
    -e 'LDAP_URL=ldap://ipa.example.com:389' \
    -e 'LDAP_DEFAULT_ADMINS=admin' \
    -e 'LDAP_SECURITY_PRINCIPAL=uid=admin,cn=users,cn=accounts,dc=example,dc=com' \
    -e 'LDAP_SECURITY_CREDENTIALS=password' \
    -e 'LDAP_GROUP_SEARCHBASE=cn=groups,cn=accounts,dc=example,dc=com' \
    -e 'LDAP_USER_SEARCHBASE=cn=users,cn=accounts,dc=example,dc=com' \
    -e 'DB_KIND=postgresql' \
    -e 'DB_HOST=db_server.example.com' \
    -e 'DB_USERNAME=alfresco' \
    -e 'DB_PASSWORD=alfresco' \
    -e 'DB_NAME=alfresco' \
    gui81/alfresco
```

If you want to use this image in production, then please read on.

## Configuration
### Datastore
In production, you will want to make sure to specify and mount the
CONTENT_STORE and /alfresco/alf_data directories to persist this data.  Example:
- `/content`
- `/alfresco/alf_data`

Volumes can be mounted by passing the **'-v'** option to the docker run command.
The following is an example:
```bash
docker run --name alfresco -it --rm -v /host/alfresco/content:/content -v /host/alfresco/data:/alfresco/alf_data
```

### Database
If the `DB_HOST` environment variable is not set, or set to localhost, then the
image will use the internal PostgreSQL server.

PostgreSQL is the default, but MySQL/MariaDB is also supported.  If you are
using an existing database installation, then make sure to create the database
and a user:
```sql
CREATE ROLE alfresco WITH LOGIN PASSWORD 'alfresco';
CREATE DATABASE alfresco;
GRANT ALL PRIVILEGES ON DATABASE alfresco TO alfresco;
```

### Options
Below is the complete list of currently available parameters that can be set
using environment variables.
- **ALFRESCO_HOSTNAME**: hostname of the Alfresco server; default = `localhost`
- **ALFRESCO_PORT**: port for afresco to listen to; default = `8080` if protocol is http or `8443` if protocol is https
- **ALFRESCO_PROTOCOL**: protocol used by alfresco to generate links; default = `http`
- **AMP_DIR_ALFRESCO**: directory containing AMP files (modules) for alfresco.war (bind mount as volume)
- **AMP_DIR_SHARE**: directory containing AMP files (modules) for share.war (bind mount as volume)
- **CIFS_ENABLED**: whether or not to enable CIFS; default = `true`
- **CIFS_SERVER_NAME**: hostname of the CIFS server; default = `localhost`
- **CIFS_DOMAIN**: domain of the CIFS server; default = `WORKGROUP`
- **CONTENT_STORE**: where content is stored; default = `/content`
- **DB_CONN_PARAMS**: database connection parameters; for MySQL, default = ?useSSL=false, otherwise empty
- **DB_HOST**: host of the database server; default = `localhost`
- **DB_KIND**: postgresql or mysql; default = `postgresql`
- **DB_NAME**: name of the database to connect to; default = `alfresco`
- **DB_PASSWORD**: password to use when connecting to the database; default = `admin`
- **DB_USERNAME**: username to use when connecting to the database; default = `alfresco`
- **FTP_PORT**: port of the database server; default = `5432`
- **LDAP_ENABLED**: whether or not to enable LDAP; default = `false`
- **LDAP_KIND**: ldap (e.g. for OpenLDAP) or ldap-ad (Active Directory); default = ldap
- **LDAP_AUTH_USERNAMEFORMAT**: Specifies how to map the user identifier entered by the user to that passed through to LDAP. Could be empty to enable "search and bind" method. default = `uid=%s,cn=users,cn=accounts,dc=example,dc=com`
- **LDAP_URL**: URL of LDAP server; default = `ldap://ldap.example.com:389`
- **LDAP_DEFAULT_ADMINS**: comma separated list of admin names in ldap; default = `admin`
- **LDAP_SECURITY_PRINCIPAL**: default = `uid=admin,cn=users,cn=accounts,dc=example,dc=com`
- **LDAP_SECURITY_CREDENTIALS**: default = `password`
- **LDAP_GROUP_SEARCHBASE**: default = `cn=groups,cn=accounts,dc=example,dc=com`
- **LDAP_USER_SEARCHBASE**: default = `cn=users,cn=accounts,dc=example,dc=com`
- **LDAP_USER_ATTRIBUTENAME**: The attribute name on people objects found in LDAP to use as the uid in Alfresco (commonly `uid` in OpenLDAP or `sAMAccountName` in Active Directory); default = `uid`
- **LDAP_GROUP_MEMBER_ATTRIBUTENAME**: The attribute in LDAP on group objects that defines the DN for its members (commonly `memberUid` in OpenLDAP or `member` in Active Directory); default = `memberUid`
- **MAIL_HOST**: hostname or IP where email should be sent; default = `localhost`
- **MAIL_PORT**: default = `25`
- **MAIL_USERNAME**: username to connect to the smtp server
- **MAIL_PASSWORD**: password to connect to the smtp server
- **MAIL_FROM_DEFAULT**: what is in the from field; default = `alfresco@alfresco.org`
- **MAIL_PROTOCOL**: smtp or smtps; default = `smtp`
- **MAIL_SMTP_AUTH**: is authentication required or not; default = `false`
- **MAIL_SMTP_STARTTLS_ENABLE**: use starttls or not; default = `false`
- **MAIL_SMTPS_AUTH**: is authentication required or not; default = `false`
- **MAIL_SMTPS_STARTTLS_ENABLE**: use starttls or not; default = `false`
- **NFS_ENABLED**: whether or not to enable NFS; default = `true`
- **SHARE_HOSTNAME**: hostname of the share server; default = `localhost`
- **SHARE_PORT**: port for share to listen to; default = `8080` if protocol is http or `8443` if protocol is https
- **SHARE_PROTOCOL**: protocol use by share to generate links; default = `http`
- **SYSTEM_SERVERMODE**: the server running mode for you system; default = `PRODUCTION`
- **TOMCAT_CSRF_ENABLED**: Disable the tomcat CSRF policy; default = `false`
- **EXTERNAL_AUTH_ENABLED**: Enable external authentification for SSO; default = `false`
- **EXTERNAL_AUTH_DEFAULT_ADMINS**: comma separated list of user names who should be considered administrators by default. default = `admin`
- **EXTERNAL_AUTH_PROXY_HEADER**: The name of the HTTP header that carries the name of a proxied user. default = `X-Alfresco-Remote-User` 
- **EXTERNAL_AUTH_PROXY_USER_NAME**: The name of the remote user that should be considered the proxy user. Requests made by this user will be made under the identity of the user named in the HTTP Header indicated by the external.authentication.proxyHeader property. If not set, then the HTTP Header indicated by the external.authentication.proxyHeader property is always assumed to carry the user name (alfresco default value is : alfresco-system); default = ``
- **EXTERNAL_AUTH_USER_ID_PATTERN**: An optional regular expression to be used to extract a user ID from the HTTP header. The portion of the header matched by the first bracketed group in the regular expression will become the user name. If not set (the default), then the entire header contents are assumed to be the proxied user name; default = ``
- **SOLR_ENABLE**: Enable solr default; default = `false`
- **SOLR_MODULE**: solr driver; default = `solr4`
- **SOLR_HOST**: solr host; default = `locahost`
- **SOLR_POR**: solr port; default = `8080`
- **SOLR_PORT_SSL**: solr ssl port; default = `8443` 
- **SOLR_SECURE_COMMS**: solr secure comms; default = `https` 
- **AUDIT_ENABLED**: ; default = `false` 
- **AUDIT_ALFRESCO_ACCESS_ENABLED**: ; default = `false` 


## Upgrading
TODO: I might be able to add some options that aid in upgrading.  For now
though, backup, backup, backup, and then follow this guide:
- <http://docs.alfresco.com/community/concepts/ch-upgrade.html>

## References
- <http://www.alfresco.com/community>
- <http://docs.alfresco.com/community/concepts/welcome-infocenter_community.html>
