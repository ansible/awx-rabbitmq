#!/bin/sh

[[ -n "$DEBUG" ]] && set -x
set -e

if [ `id -u` -ge 500 ]; then
    echo "rabbitmq:x:`id -u`:`id -g`:,,,:${HOME}:/bin/ash" >> /tmp/passwd
    cat /tmp/passwd > /etc/passwd
    rm /tmp/passwd
fi

echo "$RABBITMQ_ERLANG_COOKIE" > $HOME/.erlang.cookie
chmod 0600 $HOME/.erlang.cookie

if [ "$RABBITMQ_NODENAME" ]; then
    if [ -d "/var/lib/rabbitmq/mnesia/\${RABBITMQ_NODENAME}" ]; then rabbitmqctl force_boot; fi
fi

docker-entrypoint.sh rabbitmq-server
