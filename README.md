docker-alfresco
===============

# Table of Contents

- [Introduction](#introduction)
  - [Version](#version)
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

## Version
Current version: **5.0.b-1**

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
docker pull gui81/alfresco:5.0.b-1
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

Go to `http://localhost:8080` or point to the ip of your docker server.  On the
Mac, if you are running boot2docker, then you can go to the ip reported by:

```bash
boot2docker ip
```

The default username and password are:
* username: **admin**
* password: **admin**

Alfresco should now be up and running.  The following is an example that would
mount the appropriate volume, connect to a remote PostgreSQL database, and use
an external LDAP server for authentication:
```bash
docker run --name='alfresco' -it --rm -p 445:445 -p 7070:7070 -p 8080:8080 \
    -v /host/alfresco_data:/alfresco/alf_data \
    -e 'LDAP_ENABLED=true' \
    -e 'LDAP_AUTH_USERNAMEFORMAT=uid=%s,cn=users,cn=accounts,dc=example,dc=com' \
    -e 'LDAP_URL=ldap://ipa.example.com:389' \
    -e 'LDAP_DEFAULT_ADMINS=admin' \
    -e 'LDAP_SECURITY_PRINCIPAL=uid=admin,cn=users,cn=accounts,dc=example,dc=com' \
    -e 'LDAP_SECURITY_CREDENTIALS=password' \
    -e 'LDAP_GROUP_SEARCHBASE=cn=groups,cn=accounts,dc=example,dc=com' \
    -e 'LDAP_USER_SEARCHBASE=cn=users,cn=accounts,dc=example,dc=com' \
    -e 'DB_HOST=db_server.example.com' \
    -e 'DB_USERNAME=alfresco' \
    -e 'DB_PASSWORD=admin' \
    -e 'DB_NAME=alfresco' \
    gui81/alfresco
```

If you want to use this image in production, then please read on.

# Configuration
## Datastore
To persist data, you will want to make sure to mount the volume shared by the
image.  The following volume is shared:
* `/alfresco/alf_data`

Volumes can be mounted by passing the **'-v'** option to the docker run command.
The following is an example:
```bash
docker run --name alfresco -it --rm -v /host/alfresco_data:/alfresco/alf_data
```

## Database
If the `DB_HOST` environment variable is not set, then the image will use the
internal PostgreSQL server.  If it is set, then it will not turn on

This image assumes that you are using PostgreSQL.  MySQL is supported by Alfresco
as well as other database vendors, but this image currently only supports
PostgreSQL.  Create the database and a user that can access it with:
```sql
CREATE ROLE alfresco WITH LOGIN PASSWORD 'admin';
CREATE DATABASE alfresco;
GRANT ALL PRIVILEGES ON DATABASE alfresco TO alfresco;
```

## Options
Below is the complete list of currently available parameters that can be set
using environment variables.
- **ALFRESCO_HOSTNAME**: hostname of the Alfresco server; default = `localhost`
- **SHARE_HOSTNAME**: hostname of the share server; default = `localhost`
- **DB_USERNAME**: username to use when connecting to the database; default = `alfresco`
- **DB_PASSWORD**: password to use when connecting to the database; default = `admin`
- **DB_NAME**: name of the database to connect to; default = `alfresco`
- **DB_HOST**: host of the database server; default = `localhost`
- **FTP_PORT**: port of the database server; default = `5432`
- **CIFS_ENABLED**: whether or not to enable CIFS; default = `true`
- **CIFS_SERVER_NAME**: hostname of the CIFS server; default = `localhost`
- **CIFS_DOMAIN**: domain of the CIFS server; default = `WORKGROUP`
- **NFS_ENABLED**: whether or not to enable NFS; default = `true`
- **LDAP_ENABLED**: whether or not to enable LDAP; default = `false`
- **LDAP_AUTH_USERNAMEFORMAT**: default = `uid=%s,cn=users,cn=accounts,dc=example,dc=com`
- **LDAP_URL**: URL of LDAP server; default = `ldap://ldap.example.com:389`
- **LDAP_DEFAULT_ADMINS**: comma separated list of admin names in ldap; default = `admin`
- **LDAP_SECURITY_PRINCIPAL**: default = `uid=admin,cn=users,cn=accounts,dc=example,dc=com`
- **LDAP_SECURITY_CREDENTIALS**: default = `password`
- **LDAP_GROUP_SEARCHBASE**: default = `cn=groups,cn=accounts,dc=example,dc=com`
- **LDAP_USER_SEARCHBASE**: default = `cn=users,cn=accounts,dc=example,dc=com`

# Upgrading
TODO: I might be able to add some options that aid in upgrading.  For now though,
backup, backup, backup, and then follow this guide:
* http://docs.alfresco.com/community/concepts/ch-upgrade.html

# References
* http://www.alfresco.com/community
* http://docs.alfresco.com/community/concepts/welcome-infocenter_community.html
