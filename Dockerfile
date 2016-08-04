# gui81/alfresco

FROM centos:centos7
MAINTAINER Lucas Johnson <lucasejohnson@netscape.net>

# install some necessary/desired RPMs and get updates
RUN yum update -y && \
    yum install -y https://dl.fedoraproject.org/pub/epel/epel-release-latest-7.noarch.rpm && \
    yum install -y \
                   cups-libs \
                   dbus-glib \
                   fontconfig \
                   hostname \
                   libICE \
                   libSM \
                   libXext \
                   libXinerama \
                   libXrender \
                   supervisor \
                   wget \
                   patch && \
    yum clean all

# install oracle java
COPY assets/install_java.sh /tmp/install_java.sh
RUN /tmp/install_java.sh && \
    rm -f /tmp/install_java.sh

# install alfresco
COPY assets/install_alfresco.sh /tmp/install_alfresco.sh
RUN /tmp/install_alfresco.sh && \
    rm -f /tmp/install_alfresco.sh
# install mysql connector for alfresco
COPY assets/install_mysql_connector.sh /tmp/install_mysql_connector.sh
RUN /tmp/install_mysql_connector.sh && \
    rm -f /tmp/install_mysql_connector.sh
# this is for LDAP configuration
RUN mkdir -p /alfresco/tomcat/shared/classes/alfresco/extension/subsystems/Authentication/ldap/ldap1/
RUN mkdir -p /alfresco/tomcat/shared/classes/alfresco/extension/subsystems/Authentication/ldap-ad/ldap1/
COPY assets/ldap-authentication.properties /alfresco/tomcat/shared/classes/alfresco/extension/subsystems/Authentication/ldap/ldap1/ldap-authentication.properties
COPY assets/ldap-ad-authentication.properties /alfresco/tomcat/shared/classes/alfresco/extension/subsystems/Authentication/ldap-ad/ldap1/ldap-ad-authentication.properties

# adding path file used to disable tomcat CSRF
COPY assets/disable_tomcat_CSRF.patch /alfresco/disable_tomcat_CSRF.patch

# install scripts
COPY assets/init.sh /alfresco/init.sh
COPY assets/supervisord.conf /etc/supervisord.conf

RUN mkdir -p /alfresco/tomcat/webapps/ROOT
COPY assets/index.jsp /alfresco/tomcat/webapps/ROOT/

VOLUME /alfresco/alf_data
VOLUME /alfresco/tomcat/logs

ENV JPDA_ADDRESS=5005
ENV JPDA_TRANSPORT=dt_socket

EXPOSE 21 137 138 139 445 7070 8009 8080 5005
CMD /usr/bin/supervisord -c /etc/supervisord.conf -n
