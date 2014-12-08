# gui81/alfresco

FROM centos:centos7
MAINTAINER Lucas Johnson <lucasejohnson@netscape.net>

# install some necessary/desired RPMs and get updates
RUN yum update -y
RUN yum install -y chkconfig && \
    yum install -y unzip && \
    yum install -y wget

# install java
COPY assets/install_java.sh /tmp/install_java.sh
RUN chmod 755 /tmp/install_java.sh
RUN /tmp/install_java.sh

# install alfresco
COPY assets/install_alfresco.sh /tmp/install_alfresco.sh
RUN chmod 755 /tmp/install_alfresco.sh
RUN /tmp/install_alfresco.sh
# this is for LDAP configuration
RUN mkdir -p /alfresco/tomcat/shared/classes/alfresco/extension/subsystems/Authentication/ldap/ldap1/
COPY assets/ldap-authentication.properties /alfresco/tomcat/shared/classes/alfresco/extension/subsystems/Authentication/ldap/ldap1/ldap-authentication.properties

COPY assets/init.sh /alfresco/init.sh
RUN chmod 755 /alfresco/init.sh

RUN yum clean all

VOLUME /alfresco/alf_data
VOLUME /alfresco/tomcat/logs

EXPOSE 21 137 138 139 445 7070 8080
WORKDIR /alfresco
CMD /usr/bin/supervisord -c /etc/supervisord.conf -n
