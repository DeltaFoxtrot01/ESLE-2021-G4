FROM ubuntu:21.04

RUN apt update && apt install -y curl gnupg && \
    echo "deb https://downloads.apache.org/cassandra/debian 40x main" | tee /etc/apt/sources.list.d/cassandra.sources.list && \
    curl https://downloads.apache.org/cassandra/KEYS | gpg --dearmor | tee /etc/apt/trusted.gpg.d/cassandra.gpg  && \
    apt update && DEBIAN_FRONTEND=noninteractive apt install -y cassandra-tools

ENTRYPOINT ["cassandra-stress"]
