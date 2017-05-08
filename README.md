docker-alfresco
===============

# Table of Contents

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


# Introduction
Dockerfile to build an Alfresco container image.


# Contributing
Here is how you can help:
- Send a Pull Request with your awesome new features and bug fixes
- Report [Issues](https://github.com/gui81/docker-alfresco/issues)


# Installation
Pull the image from the docker index.
```bash
docker pull gui81/alfresco:latest
```

or pull a particular version:
```bash
docker pull gui81/alfresco:5.0.d-1
```

Alternatively, you can build the image yourself:
```bash
git clone https://github.com/gui81/docker-alfresco.git
cd docker-alfresco
docker build --tag="$USER/alfresco" .
```


# Quick Start
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
* username: **admin**
* password: **admin**

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


# Configuration
## Datastore
In production, you will want to make sure to specify and mount the
CONTENT_STORE and /alfresco/alf_data directories to persist this data.  Example:
* `/content`
* `/alfresco/alf_data`

Volumes can be mounted by passing the **'-v'** option to the docker run command.
The following is an example:
```bash
docker run --name alfresco -it --rm -v /host/alfresco/content:/content -v /host/alfresco/data:/alfresco/alf_data
```

## Database
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


## Options
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
- **LDAP_AUTH_USERNAMEFORMAT**: default = `uid=%s,cn=users,cn=accounts,dc=example,dc=com`
- **LDAP_URL**: URL of LDAP server; default = `ldap://ldap.example.com:389`
- **LDAP_DEFAULT_ADMINS**: comma separated list of admin names in ldap; default = `admin`
- **LDAP_SECURITY_PRINCIPAL**: default = `uid=admin,cn=users,cn=accounts,dc=example,dc=com`
- **LDAP_SECURITY_CREDENTIALS**: default = `password`
- **LDAP_GROUP_SEARCHBASE**: default = `cn=groups,cn=accounts,dc=example,dc=com`
- **LDAP_USER_SEARCHBASE**: default = `cn=users,cn=accounts,dc=example,dc=com`
- **LDAP_USER_ID_ATTRIBUTE_NAME**: default = `uid`
- **LDAP_GROUP_QUERY**: default = `(objectclass=posixGroup)`
- **LDAP_GROUP_DIFFERENTIAL_QUERY**: default = `(&(objectclass=posixGroup)(!(modifyTimestamp<={0})))`
- **LDAP_PERSON_QUERY**: default = `(objectclass=inetOrgPerson)`
- **LDAP_PERSON_DIFFERENTIAL_QUERY**: default = `(&(objectclass=inetOrgPerson)(!(modifyTimestamp<={0})))`
- **LDAP_GROUP_TYPE**: default = `posixGroup`
- **LDAP_PERSON_TYPE**: default = `inetOrgPerson`
- **LDAP_GROUP_MEMBER_ATTRIBUTE_NAME**: default = `memberUid`
- **CROWD_ENABLED**: default: = `false`
- **CROWD_AUTH_LICENSE**: There is no default value for the license string. It must **always** be set as an environment variable. The licence file provided by the issuer must be converted to a single string by replacing newlines by spaces. This can be done by sourcing the little helper script `crowd/crowd_source_license.sh` with the filename of the license file as first parameter. 
- **CROWD_URL**: URL for calls to the Crowd API; default: = `http://localhost:8095/crowd`
- **CROWD_SYNCHRONIZATION_ENABLE**: activate synchronization of a few select attributes from Crowd; default: = `true`
- **CROWD_AUTH_SSO_ENABLED**: active SSL in calls the Crowd API; default: = `false`
- **CROWD_AUTHENTICATION_ALLOW_GUEST_LOGIN**: default: = `false`
- **CROWD_GROUP_UPPERCASE**: convert alle Crowd group names into uppercase; default: = `true`
- **CROWD_GROUP_PREFIX_STRIP**: provide a prefix that will be stripped from Crowd group names if present; default: not set
- **CROWD_GROUP_PREFIX_ADD**: provide a suffix that will be added to Crowd group names if present; default: not set
- **CROWD_GROUP_REPLACE_DASHES**: replace all dashes in Crowd group names by underscores; default: = `true`
- **ALFRESCO_CROWD_APPLICATION_NAME**: the name of the registered Alfresco application in Crowd; default: = `alfresco`
- **ALFRESCO_CROWD_APPLICATION_PASSWORD**: the password of the registered Alfresco applcation in Crowd; default: not set
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


# Upgrading
TODO: I might be able to add some options that aid in upgrading.  For now though,
backup, backup, backup, and then follow this guide:
* http://docs.alfresco.com/community/concepts/ch-upgrade.html


# References
* http://www.alfresco.com/community
* http://docs.alfresco.com/community/concepts/welcome-infocenter_community.html
