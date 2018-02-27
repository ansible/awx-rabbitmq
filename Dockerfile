FROM alpine:latest

ADD launch.sh /launch.sh

ARG RABBITMQ_VERSION
ENV RABBITMQ_DEFAULT_USER="awx"
ENV RABBITMQ_DEFAULT_PASS="abcdefg"
ENV RABBITMQ_DEFAULT_VHOST="awx"
ENV ERL_EPMD_PORT="4369"
ENV AUTOCLUSTER_VERSION="0.8.0"
ENV RABBITMQ_LOGS="-"
ENV RABBITMQ_SASL_LOGS="-"
ENV RABBITMQ_DIST_PORT="25672"
ENV RABBITMQ_SERVER_ERL_ARGS="+K true +A128 +P 1048576 -kernel inet_default_connect_options [{nodelay,true}]"
ENV RABBITMQ_CONFIG_FILE="/etc/rabbitmq/rabbitmq"
ENV RABBITMQ_MNESIA_DIR="/var/lib/rabbitmq/mnesia"
ENV RABBITMQ_PID_FILE="/var/lib/rabbitmq/rabbitmq.pid"
ENV RABBITMQ_ROOT="/usr/lib/rabbitmq"
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
    chown -R rabbitmq $RABBITMQ_ROOT $HOME && \
    sync && \
    $RABBITMQ_ROOT/sbin/rabbitmq-plugins --offline enable     rabbitmq_management     rabbitmq_consistent_hash_exchange     rabbitmq_federation     rabbitmq_federation_management     rabbitmq_mqtt     rabbitmq_shovel     rabbitmq_shovel_management     rabbitmq_stomp     rabbitmq_web_stomp     autocluster && \
    mkdir /etc/rabbitmq && \
    touch /etc/rabbitmq/rabbitmq.config && \
    chown -R rabbitmq $RABBITMQ_ROOT $HOME /etc/rabbitmq && \
    rm -rf $HOME/.erlang.cookie && \
    chmod g+w /etc/passwd && chmod a+rw $HOME && chmod g+w -R /etc/rabbitmq
ADD .erlang.cookie /.erlang.cookie
VOLUME /var/lib/rabbitmq
EXPOSE 15672/tcp 25672/tcp 4369/tcp 5671/tcp 5672/tcp
CMD /launch.sh
