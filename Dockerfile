#--------- Generic stuff --------------------------------------------------------------------
FROM tomcat:9.0.7-jre8-slim

RUN apt-get -y update

#-------------Application Specific Stuff ----------------------------------------------------

RUN apt-get -y install unzip groovy2 wget

ADD resources /tmp/resources

ARG GEOSERVER_VERSION=2.13.2

ENV GEOSERVER_DIR /opt/webapps/geoserver
ENV TOMCAT_DIR /usr/local/tomcat

# Fetch the geoserver zip file if it is not available locally in the resources dir
RUN if [ ! -f /tmp/resources/geoserver.zip ]; then \
    wget -c https://sourceforge.net/projects/geoserver/files/GeoServer/${GEOSERVER_VERSION}/geoserver-${GEOSERVER_VERSION}-war.zip/download -O /tmp/resources/geoserver.zip; \
    fi; \
    mkdir /tmp/resources/geoserver && cd /tmp/resources/geoserver && unzip ../geoserver.zip; \
    mkdir /opt/webapps && mv -v geoserver.war /opt/webapps && mkdir ${GEOSERVER_DIR} && cd ${GEOSERVER_DIR} && unzip ../geoserver.war; \
    rm -rf /tmp/resources/geoserver;

# delete default workspaces
RUN rm -rf ${GEOSERVER_DIR}/data/workspaces && mkdir ${GEOSERVER_DIR}/data/workspaces; \
    rm -rf ${GEOSERVER_DIR}/data/layergroups/*

COPY ./ROOT.xml ${TOMCAT_DIR}/conf/Catalina/localhost/ROOT.xml
COPY ./web.xml ${GEOSERVER_DIR}/WEB-INF/web.xml

ADD exts /geoserver-exts/default
ADD scripts /tmp/scripts
RUN chmod -R a+x /tmp/scripts

# Run setup script to apply initial settings
RUN /tmp/scripts/setup.groovy ${GEOSERVER_DIR}

VOLUME ["/geoserver-exts","/opt/webapps/geoserver"]

EXPOSE 8080
CMD ["/tmp/scripts/launch.sh"]
