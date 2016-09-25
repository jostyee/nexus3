FROM alpine:latest

ENV JAVA_HOME /usr/lib/jvm/java-1.8-openjdk/jre
ENV NEXUS_DATA /nexus-data
ENV NEXUS_VERSION 3.0.2-02

# Add local files and according directories to image
ADD src /

# Packages
RUN apk add --no-cache --repository http://dl-cdn.alpinelinux.org/alpine/edge/main && \
    apk add --no-cache --repository  http://dl-cdn.alpinelinux.org/alpine/edge/community && \
    apk update && \
    apk upgrade && \
    apk add ca-certificates openjdk8 bash curl tar && \
    rm -rf /var/cache/apk/*

# Nexus
RUN echo "Installing Nexus ${NEXUS_VERSION} ..." && \
    mkdir -p /opt/sonatype/nexus && \
    curl -sSL --retry 3 https://download.sonatype.com/nexus/3/nexus-${NEXUS_VERSION}-unix.tar.gz | tar -C /opt/sonatype/nexus -xvz --strip-components=1 nexus-${NEXUS_VERSION} && \
    chown -R root:root /opt/sonatype/nexus && \
    adduser -h ${NEXUS_DATA} -SD nexus && \
    chown -R nexus /nexus-data && \
    chmod -R 755 /nexus-data && \
    sed \
    -e "s|karaf.home=.|karaf.home=/opt/sonatype/nexus|g" \
    -e "s|karaf.base=.|karaf.base=/opt/sonatype/nexus|g" \
    -e "s|karaf.etc=etc|karaf.etc=/opt/sonatype/nexus/etc|g" \
    -e "s|java.util.logging.config.file=etc|java.util.logging.config.file=/opt/sonatype/nexus/etc|g" \
    -e "s|karaf.data=data|karaf.data=${NEXUS_DATA}|g" \
    -e "s|java.io.tmpdir=data/tmp|java.io.tmpdir=${NEXUS_DATA}/tmp|g" \
    -i /opt/sonatype/nexus/bin/nexus.vmoptions

EXPOSE 8081

USER nexus

WORKDIR /opt/sonatype/nexus

CMD bin/nexus run
