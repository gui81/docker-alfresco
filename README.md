
### Introduction

Alfresco is a leading Enterprise Content Management system which provides document management, collaboration, web content services and records and knowledge management.

This image aims to help you run the latest version of the Alfresco Community Edition in a Docker container.

### Quick Start

Run the alfresco image:

```bash
docker run --name='alfresco' -it --rm -p 8080:8080 fjudith/alfresco
```

**NOTE**: Please allow a few minutes for the application to start, especially if
populating the database for the first time. If you want to make sure that everything went fine, watch the log:

```bash
docker exec -it alfresco /bin/bash
tail -f /alfresco/tomcat/logs/catalina.out
```
Go to `http://localhost:8080/share` or point to the IP of your docker host.  On
Mac or Windows, replace `localhost` with the IP address of your Docker host which you can get using

```bash
docker-machine ip default
```

The default username and password are:
* username: **admin**
* password: **admin**

### Configuration

#### Datastore

If you use this image in production, you'll probably want to store files and database separately in an external location. Use the CONTENT_STORE environment variable to set the content store to a bind-mounted volume or a network share.

#### Database

If `DB_KIND` is `postgresql` and the `DB_HOST` environment variable is not set (or `localhost`),
then the internal PostgreSQL server will be started and used.

By setting `DB_KIND` to `mysql`, you can use an external MySQL server, e.g. one running in a Docker container:
```bash
docker run --name 'mysql' -d -p 3306:3306 \
    -e MYSQL_ROOT_PASSWORD=secret \
    -e MYSQL_DATABASE=alfresco \
    -e MYSQL_USER=alfresco \
    -e MYSQL_PASSWORD=secret \
    mysql \
    --character-set-server=utf8 \
    --collation-server=utf8_general_ci \
    --max_connections=1024
```

Configure the Alfresco container to use this MySQL server as database and a bind-mounted volume as content store:

```bash
docker run --name='alfresco' -d -p 8080:8080 \
    -v /mnt/alfresco_content_store:/mnt/content_store \
    -e CONTENT_STORE=/mnt/content_store \
    -e DB_KIND=mysql \
    -e DB_HOST=mysql \
    -e DB_PASSWORD=secret \
    --link mysql:mysql \
    fjudith/alfresco
```

#### Options

Below is the complete list of currently available parameters that can be set
using environment variables.
- **ALFRESCO_HOSTNAME**: hostname of the Alfresco server; default = `localhost`
- **SHARE_HOSTNAME**: hostname of the share server; default = `localhost`
- **CONTENT_STORE**: location of content store; default = `${dir.root}` (/alfresco/alf_data)
- **DB_KIND**: postgresql or mysql; default = `postgresql`
- **DB_USERNAME**: username to use when connecting to the database; default = `alfresco`
- **DB_PASSWORD**: password to use when connecting to the database; default = `admin`
- **DB_NAME**: name of the database to connect to; default = `alfresco`
- **DB_HOST**: host of the database server; default = `localhost`
- **DB_CONN_PARAMS**: database connection parameters; for MySQL, default = `?useSSL=false`, otherwise empty
- **FTP_PORT**: port of the FTP server; default = `5432`
- **CIFS_ENABLED**: whether or not to enable CIFS; default = `true`
- **CIFS_SERVER_NAME**: hostname of the CIFS server; default = `localhost`
- **CIFS_DOMAIN**: domain of the CIFS server; default = `WORKGROUP`
- **NFS_ENABLED**: whether or not to enable NFS; default = `false`
- **LDAP_ENABLED**: whether or not to enable LDAP; default = `false`
- **LDAP_KIND**: ldap (e.g. for OpenLDAP) or ldap-ad (Active Directory); default = `ldap`
- **LDAP_AUTH_USERNAMEFORMAT**: default = `uid=%s,cn=users,cn=accounts,dc=example,dc=com`
- **LDAP_URL**: URL of LDAP server; default = `ldap://ldap.example.com:389`
- **LDAP_DEFAULT_ADMINS**: comma separated list of admin names in ldap; default = `admin`
- **LDAP_SECURITY_PRINCIPAL**: default = `uid=admin,cn=users,cn=accounts,dc=example,dc=com`
- **LDAP_SECURITY_CREDENTIALS**: default = `password`
- **LDAP_GROUP_SEARCHBASE**: default = `cn=groups,cn=accounts,dc=example,dc=com`
- **LDAP_USER_SEARCHBASE**: default = `cn=users,cn=accounts,dc=example,dc=com`
- **AMP_DIR_ALFRESCO**: directory containing AMP files (modules) for alfresco.war (bind mount as volume)
- **AMP_DIR_SHARE**: directory containing AMP files (modules) for share.war (bind mount as volume)

### Build from Source

The source code is available at https://github.com/fjudith/alfresco.

Make sure your Docker host has more than 2 GB RAM available. Docker Hub uses 2 GB for automated builds which is not enough, the Alfresco installer will complain and fail. The Docker Toolbox VM also uses 2 GB by default, use VirtualBox to change it to at least 4GB.

```bash
git clone https://github.com/fjudith/alfresco.git
cd docker-alfresco
docker build --tag="$(echo $USERNAME | awk '{print tolower($0)}')/alfresco" .
```

### References

* http://www.alfresco.com/community
* http://docs.alfresco.com/community/concepts/welcome-infocenter_community.html