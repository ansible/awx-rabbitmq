ARG RABBITMQ_VERSION
FROM rabbitmq:${RABBITMQ_VERSION}-management-alpine

ENV RABBITMQ_ERLANG_COOKIE="cookiemonster"

RUN chgrp -R root /var/lib/rabbitmq /var/log/rabbitmq /etc/rabbitmq
RUN chmod g+w /etc/passwd &&\
    chmod -R g+rwx /var/lib/rabbitmq /var/log/rabbitmq /etc/rabbitmq

ADD launch.sh /launch.sh
VOLUME /var/lib/rabbitmq
EXPOSE 15672/tcp 25672/tcp 4369/tcp 5671/tcp 5672/tcp

CMD /launch.sh
