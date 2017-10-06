#!/bin/sh

[[ -n "$DEBUG" ]] && set -x
set -e

if [ `id -u` -ge 500 ]; then
    echo "rabbitmq:x:`id -u`:`id -g`:,,,:/var/lib/rabbitmq:/bin/ash" >> /tmp/passwd
    cat /tmp/passwd > /etc/passwd
    rm /tmp/passwd
    cp /.erlang.cookie /var/lib/rabbitmq/.erlang.cookie
    chmod 0600 /var/lib/rabbitmq/.erlang.cookie
fi

# cat <<EOF > /etc/rabbitmq/rabbitmq.config
# [ {rabbitm, [
#   {default_user, <<"${RABBITMQ_DEFAULT_USER}">>},
#   {default_pass, <<"${RABBITMQ_DEFAULT_PASS}">>},
#   {default_vhost, <<"${RABBITMQ_DEFAULT_VHOST}">>},
#   {default_permissions, [<<".*">>, <<".*">>, <<".*">>]},
#   {default_user_tags, [administrator]}
# ]
# }].
# EOF

( sleep 30 ; \
  /usr/lib/rabbitmq/sbin/rabbitmqctl add_user $RABBITMQ_DEFAULT_USER $RABBITMQ_DEFAULT_PASS 2>/dev/null ; \
  /usr/lib/rabbitmq/sbin/rabbitmqctl set_user_tags $RABBITMQ_DEFAULT_USER administrator ; \
  /usr/lib/rabbitmq/sbin/rabbitmqctl add_vhost $RABBITMQ_DEFAULT_VHOST ; \
  /usr/lib/rabbitmq/sbin/rabbitmqctl set_permissions -p awx $RABBITMQ_DEFAULT_USER ".*" ".*" ".*" ; \
  echo "*** User '$RABBITMQ_USER' with password '$RABBITMQ_PASSWORD' completed. ***") &
/usr/lib/rabbitmq/sbin/rabbitmq-server
