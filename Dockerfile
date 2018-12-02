#--------- Generic stuff --------------------------------------------------------------------
FROM tomcat:8.5.34-jre8-slim

RUN apt-get -y update

#-------------Application Specific Stuff ----------------------------------------------------

RUN apt-get -y install unzip groovy2 wget

ADD resources /tmp/resources

ARG GEOSERVER_VERSION=2.14.1

ENV GEOSERVER_DIR /opt/webapps/geoserver
ENV TOMCAT_DIR /usr/local/tomcat

# Fetch the geoserver zip file if it is not available locally in the resources dir
RUN if [ ! -f /tmp/resources/geoserver.zip ]; then \
    wget -c https://sourceforge.net/projects/geoserver/files/GeoServer/${GEOSERVER_VERSION}/geoserver-${GEOSERVER_VERSION}-war.zip/download -O /tmp/resources/geoserver.zip; \
    fi; \
    mkdir /tmp/resources/geoserver && cd /tmp/resources/geoserver && unzip ../geoserver.zip; \
    mkdir /opt/webapps && mv -v geoserver.war /opt/webapps && mkdir ${GEOSERVER_DIR} && cd ${GEOSERVER_DIR} && unzip ../geoserver.war; \
    rm -rf /tmp/resources/geoserver;

WORKDIR /tmp
ARG JAI_IMAGEIO=true
RUN if [ "$JAI_IMAGEIO" = true ]; then \
    wget http://download.java.net/media/jai/builds/release/1_1_3/jai-1_1_3-lib-linux-amd64.tar.gz && \
    wget http://download.java.net/media/jai-imageio/builds/release/1.1/jai_imageio-1_1-lib-linux-amd64.tar.gz && \
    gunzip -c jai-1_1_3-lib-linux-amd64.tar.gz | tar xf - && \
    gunzip -c jai_imageio-1_1-lib-linux-amd64.tar.gz | tar xf - && \
    mv /tmp/jai-1_1_3/lib/*.jar $JAVA_HOME/lib/ext/ && \
    mv /tmp/jai-1_1_3/lib/*.so $JAVA_HOME/lib/amd64/ && \
    mv /tmp/jai_imageio-1_1/lib/*.jar $JAVA_HOME/lib/ext/ && \
    mv /tmp/jai_imageio-1_1/lib/*.so $JAVA_HOME/lib/amd64/ && \
    rm /tmp/jai-1_1_3-lib-linux-amd64.tar.gz && \
    rm -r /tmp/jai-1_1_3 && \
    rm /tmp/jai_imageio-1_1-lib-linux-amd64.tar.gz && \
    rm -r /tmp/jai_imageio-1_1; \
    fi

# delete default workspaces
RUN rm -rf ${GEOSERVER_DIR}/data/workspaces && mkdir ${GEOSERVER_DIR}/data/workspaces; \
    rm -rf ${GEOSERVER_DIR}/data/layergroups/*

COPY ./ROOT.xml ${TOMCAT_DIR}/conf/Catalina/localhost/ROOT.xml

WORKDIR /geoserver-exts/default
RUN wget -c http://sourceforge.net/projects/geoserver/files/GeoServer/${GEOSERVER_VERSION}/extensions/geoserver-${GEOSERVER_VERSION}-vectortiles-plugin.zip && \
    mkdir vectortiles && \
    unzip geoserver-${GEOSERVER_VERSION}-vectortiles-plugin.zip -d vectortiles

RUN wget -c http://sourceforge.net/projects/geoserver/files/GeoServer/${GEOSERVER_VERSION}/extensions/geoserver-${GEOSERVER_VERSION}-mongodb-plugin.zip && \
    mkdir mongodb && \
    unzip geoserver-${GEOSERVER_VERSION}-mongodb-plugin.zip -d mongodb

RUN wget -c http://sourceforge.net/projects/geoserver/files/GeoServer/${GEOSERVER_VERSION}/extensions/geoserver-${GEOSERVER_VERSION}-querylayer-plugin.zip && \
    mkdir querylayer && \
    unzip geoserver-${GEOSERVER_VERSION}-querylayer-plugin.zip -d querylayer

RUN wget -c http://sourceforge.net/projects/geoserver/files/GeoServer/${GEOSERVER_VERSION}/extensions/geoserver-${GEOSERVER_VERSION}-monitor-plugin.zip && \
    mkdir monitor && \
    unzip geoserver-${GEOSERVER_VERSION}-monitor-plugin.zip -d monitor

RUN wget -c http://sourceforge.net/projects/geoserver/files/GeoServer/${GEOSERVER_VERSION}/extensions/geoserver-${GEOSERVER_VERSION}-wps-plugin.zip && \
    mkdir wps && \
    unzip geoserver-${GEOSERVER_VERSION}-wps-plugin.zip -d wps

ADD scripts /tmp/scripts
RUN chmod -R a+x /tmp/scripts

# Run setup script to apply initial settings
RUN /tmp/scripts/setup.groovy ${GEOSERVER_DIR}

VOLUME ["/geoserver-exts","/opt/webapps/geoserver"]

EXPOSE 8080
CMD ["/tmp/scripts/launch.sh"]
