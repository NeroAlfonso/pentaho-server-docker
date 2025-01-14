#docker build -t pentaho-server:9.2 .
FROM openjdk:8

MAINTAINER Luan luan.m.paschoal@gmail.com
LABEL Pentaho='Server 9.0 com drivers postgres e oracle'

# Init ENV
ENV BISERVER_VERSION 9.2
ENV BISERVER_TAG 9.2.0.0-290
ENV PENTAHO_HOME /opt/pentaho

# Apply JAVA_HOME
ENV PENTAHO_JAVA_HOME $JAVA_HOME
ENV PENTAHO_JAVA_HOME /usr/local/openjdk-8
ENV JAVA_HOME /usr/local/openjdk-8
RUN . /etc/environment \
 export JAVA_HOME

# Install Dependences
RUN apt-get update; apt-get install zip -y; \
apt-get install wget unzip git vim -y; \
apt-get clean && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*;

#RUN mkdir ${PENTAHO_HOME}; useradd -s /bin/bash -d ${PENTAHO_HOME} pentaho; chown -R pentaho:pentaho ${PENTAHO_HOME};

# Download Pentaho BI Server
# Disable first-time startup prompt
# Disable daemon mode for Tomcat
COPY ./versions/bin/pentaho-server-ce-${BISERVER_TAG}.zip /tmp/pentaho-server-ce-${BISERVER_TAG}.zip
RUN /usr/bin/unzip -q /tmp/pentaho-server-ce-${BISERVER_TAG}.zip -d $PENTAHO_HOME
RUN rm -f /tmp/pentaho-server-ce-${BISERVER_TAG}.zip $PENTAHO_HOME/pentaho-server/promptuser.sh
RUN sed -i -e 's/\(exec ".*"\) start/\1 run/' $PENTAHO_HOME/pentaho-server/tomcat/bin/startup.sh
RUN chmod +x $PENTAHO_HOME/pentaho-server/start-pentaho.sh

#ADD DB drivers
COPY ./lib/. $PENTAHO_HOME/pentaho-server/tomcat/lib

#COPY ./scripts/. ${PENTAHO_HOME}/pentaho-server/scripts

#Always non-root user
#USER pentaho

WORKDIR /opt/pentaho

EXPOSE 8080 8009

CMD ["sh", "/opt/pentaho/pentaho-server/start-pentaho.sh"]
#ENTRYPOINT ["sh", "-c", "$PENTAHO_HOME/pentaho-server/scripts/run.sh"]
