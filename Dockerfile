# gui81/alfresco
#
# VERSION 5.0.b

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

EXPOSE 8080 8005 8443 8009 21 50500 7070 8100
WORKDIR /alfresco
CMD /alfresco/init.sh
