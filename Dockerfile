# gui81/alfresco

FROM centos:centos7
MAINTAINER Lucas Johnson <lucasejohnson@netscape.net>

# install some necessary/desired RPMs and get updates
RUN yum update -y \
    && yum install -y https://dl.fedoraproject.org/pub/epel/epel-release-latest-7.noarch.rpm \
    && yum install -y \
                   cairo \
                   cups-libs \
                   fontconfig \
                   java-1.8.0-openjdk \
                   libICE \
                   libSM \
                   libXext \
                   libXinerama \
                   libXrender \
                   mesa-libGLU \
                   patch \
                   rsync \
                   supervisor \
                   wget \
                   less \
                   ghostscript \
                   tesseract \
                   tesseract-langpack-fra \
    && yum clean all \
    && rm -rf /tmp/* /var/tmp/* /var/cache/yum/*

# install alfresco
COPY assets/install_alfresco.sh /tmp/install_alfresco.sh
RUN /tmp/install_alfresco.sh && \
    rm -rf /tmp/* /var/tmp/*
# install mysql connector for alfresco
COPY assets/install_mysql_connector.sh /tmp/install_mysql_connector.sh
RUN /tmp/install_mysql_connector.sh && \
    rm -rf /tmp/* /var/tmp/*
# this is for LDAP configuration
RUN mkdir -p /alfresco/tomcat/shared/classes/alfresco/extension/subsystems/Authentication/ldap/ldap1/
RUN mkdir -p /alfresco/tomcat/shared/classes/alfresco/extension/subsystems/Authentication/ldap-ad/ldap1/
COPY assets/ldap-authentication.properties /alfresco/tomcat/shared/classes/alfresco/extension/subsystems/Authentication/ldap/ldap1/ldap-authentication.properties
COPY assets/ldap-ad-authentication.properties /alfresco/tomcat/shared/classes/alfresco/extension/subsystems/Authentication/ldap-ad/ldap1/ldap-ad-authentication.properties

# backup alf_data so that it can be used in init.sh if necessary
ENV ALF_DATA /alfresco/alf_data
RUN rsync -av $ALF_DATA /alf_data.install/

# adding path file used to disable tomcat CSRF
COPY assets/disable_tomcat_CSRF.patch /alfresco/disable_tomcat_CSRF.patch

# install scripts
COPY assets/init.sh /alfresco/init.sh
COPY assets/supervisord.conf /etc/supervisord.conf

# OCR
COPY assets/ocr.sh /alfresco/ocr.sh
COPY assets/transformer-context.xml /alfresco/tomcat/shared/classes/alfresco/extension/transformer-context.xml

RUN mkdir -p /alfresco/tomcat/webapps/ROOT
COPY assets/index.jsp /alfresco/tomcat/webapps/ROOT/

VOLUME /alfresco/alf_data
VOLUME /alfresco/tomcat/logs
VOLUME /content

EXPOSE 21 137 138 139 445 7070 8009 8080
CMD /usr/bin/supervisord -c /etc/supervisord.conf -n
