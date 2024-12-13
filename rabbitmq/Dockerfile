FROM rabbitmq:3.7.12-alpine

RUN  cd /plugins; wget https://dl.bintray.com/rabbitmq/community-plugins/3.7.x/rabbitmq_delayed_message_exchange/rabbitmq_delayed_message_exchange-20171201-3.7.x.zip;unzip rabbitmq_delayed_message_exchange-20171201-3.7.x.zip; rm -fr rabbitmq_delayed_message_exchange-20171201-3.7.x.zip; chown rabbitmq:rabbitmq rabbitmq_delayed_message_exchange-20171201-3.7.x.ez

#RUN cd /plugins; rabbitmq-plugins enable --offline rabbitmq_delayed_message_exchange

