FROM alpine:latest

ADD launch.sh /launch.sh

ENV RABBITMQ_VERSION="3.6.12"
ENV ERL_EPMD_PORT="4369"
ENV AUTOCLUSTER_VERSION="0.8.0"
ENV RABBITMQ_LOGS="-"
ENV RABBITMQ_SASL_LOGS="-"
ENV RABBITMQ_DIST_PORT="25672"
ENV RABBITMQ_SERVER_ERL_ARGS="+K true +A128 +P 1048576 -kernel inet_default_connect_options [{nodelay,true}]"
ENV RABBITMQ_MNESIA_DIR="/var/lib/rabbitmq/mnesia"
ENV RABBITMQ_PID_FILE="/var/lib/rabbitmq/rabbitmq.pid"
ENV RABBITMQ_PLUGINS_DIR="/usr/lib/rabbitmq/plugins"
ENV RABBITMQ_PLUGINS_EXPAND_DIR="/var/lib/rabbitmq/plugins"
ENV HOME="/var/lib/rabbitmq"
ENV DEBUG=1

RUN apk --update add coreutils curl xz erlang erlang-asn1 erlang-crypto erlang-eldap erlang-erts erlang-inets erlang-mnesia erlang-os-mon erlang-public-key erlang-sasl erlang-ssl erlang-syntax-tools erlang-xmerl && \
    curl -sL -o /tmp/rabbitmq-server-generic-unix-${RABBITMQ_VERSION}.tar.gz https://www.rabbitmq.com/releases/rabbitmq-server/v${RABBITMQ_VERSION}/rabbitmq-server-generic-unix-${RABBITMQ_VERSION}.tar.xz && \
    cd /usr/lib/ && \
    tar xf /tmp/rabbitmq-server-generic-unix-${RABBITMQ_VERSION}.tar.gz && \
    rm /tmp/rabbitmq-server-generic-unix-${RABBITMQ_VERSION}.tar.gz && \
    mv /usr/lib/rabbitmq_server-${RABBITMQ_VERSION} /usr/lib/rabbitmq && \
    curl -sL -o /usr/lib/rabbitmq/plugins/autocluster-${AUTOCLUSTER_VERSION}.ez https://github.com/rabbitmq/rabbitmq-autocluster/releases/download/${AUTOCLUSTER_VERSION}/autocluster-${AUTOCLUSTER_VERSION}.ez && \
    curl -sL -o /usr/lib/rabbitmq/plugins/rabbitmq_aws-${AUTOCLUSTER_VERSION}.ez https://github.com/rabbitmq/rabbitmq-autocluster/releases/download/${AUTOCLUSTER_VERSION}/rabbitmq_aws-${AUTOCLUSTER_VERSION}.ez && \
    apk --purge del curl tar gzip xz
    
# cp /var/lib/rabbitmq/.erlang.cookie /root/ &&
# chown rabbitmq /var/lib/rabbitmq/.erlang.cookie &&
# chmod 0600 /var/lib/rabbitmq/.erlang.cookie /root/.erlang.cookie &&
RUN adduser -D -u 1000 -h $HOME rabbitmq rabbitmq && \
    chown -R rabbitmq /usr/lib/rabbitmq /var/lib/rabbitmq && \
    sync && \
    /usr/lib/rabbitmq/sbin/rabbitmq-plugins --offline enable     rabbitmq_management     rabbitmq_consistent_hash_exchange     rabbitmq_federation     rabbitmq_federation_management     rabbitmq_mqtt     rabbitmq_shovel     rabbitmq_shovel_management     rabbitmq_stomp     rabbitmq_web_stomp     autocluster && \
    chown -R rabbitmq /usr/lib/rabbitmq /var/lib/rabbitmq && \
    rm -rf /var/lib/rabbitmq/.erlang.cookie && \
    mkdir -p /etc/rabbitmq/ && \
    chmod g+w /etc/passwd && chmod a+rw /var/lib/rabbitmq && chmod a+rw /etc/rabbitmq
ADD .erlang.cookie /.erlang.cookie
VOLUME /var/lib/rabbitmq
EXPOSE 15672/tcp 25672/tcp 4369/tcp 5671/tcp 5672/tcp
CMD /launch.sh
