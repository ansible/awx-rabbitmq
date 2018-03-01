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

cat <<EOF > /etc/rabbitmq/rabbitmq.config
%% -*- mode: erlang -*-
[ {rabbit,
   [
    {default_user, <<"$RABBITMQ_DEFAULT_USER">>},
    {default_pass, <<"$RABBITMQ_DEFAULT_PASS">>},
    {default_vhost, <<"$RABBITMQ_DEFAULT_VHOST">>},
    {default_permissions, [<<".*">>, <<".*">>, <<".*">>]},
    {default_user_tags, [administrator]}
   ]
  }
].
EOF

${RABBITMQ_ROOT}/sbin/rabbitmq-server
