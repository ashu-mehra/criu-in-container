FROM websphere-liberty:openj9-nightly

USER root
ARG workdir
RUN apt-get update && apt-get install -y --no-install-recommends criu iptables gdb vim \
    libprotobuf-dev libprotobuf-c0-dev protobuf-c-compiler protobuf-compiler python-protobuf \
    pkg-config python-ipaddress libbsd-dev iproute2 libcap-dev libnl-3-dev libnet-dev libaio-dev \
    python3-future \
    && rm -rf /var/lib/apt/lists/*

ADD Dockerfile /root/Dockerfile

RUN rm -rf /opt/ibm/wlp/usr/servers/defaultServer/server.xml
ADD server.xml /opt/ibm/wlp/usr/servers/defaultServer/server.xml

RUN installUtility install --acceptLicense defaultServer
RUN rm -rf /opt/ibm/wlp/usr/servers/defaultServer/workarea

ADD ./build/libs/*.war /opt/ibm/wlp/usr/servers/defaultServer/apps

EXPOSE 80

ENV MONGO_HOST=acmeair-db
ENV MONGO_DBNAME=acmeair

WORKDIR ${workdir}

ADD common_env_vars.sh ${workdir}/common_env_vars.sh
ADD startLiberty.sh ${workdir}/startLiberty.sh
#ADD restoreLiberty.sh ${workdir}/restoreLiberty.sh
#ADD criu ${workdir}/criu

CMD ["/opt/ibm/wlp/bin/server", "run", "defaultServer"]
