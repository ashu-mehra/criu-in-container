FROM acmeair_liberty:latest

USER root
ARG workdir
RUN apt-get update && apt-get install -y --no-install-recommends criu iptables gdb vim \
    libprotobuf-dev libprotobuf-c0-dev protobuf-c-compiler protobuf-compiler python-protobuf \
    pkg-config python-ipaddress libbsd-dev iproute2 libcap-dev libnl-3-dev libnet-dev libaio-dev \
    python3-future \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /root/appcr

ENV CR_LOG_DIR="/root/appcr/cr_logs"
ENV CHECKPOINT_SUCCESS_MSG="Checkpoint success" 
ENV CHECKPOINT_FAILED_MSG="Checkpoint failed"
ENV DUMP_LOG_FILE="dump.log"
ENV RESTORE_LOG_FILE="restore.log"
ENV APP_PID_FILE="app.pid"

RUN mkdir -p /root/appcr/cr_logs
ADD appcr.sh /root/appcr/appcr.sh
ADD app.sh /root/appcr/app.sh
ADD create_checkpoint.sh /root/appcr/create_checkpoint.sh

ENTRYPOINT ["/root/appcr/appcr.sh"]
