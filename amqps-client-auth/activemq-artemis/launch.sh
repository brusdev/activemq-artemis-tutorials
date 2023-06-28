#!/bin/sh
set -e

AMQ_ARGS="--user $AMQ_USER --password $AMQ_PASSWORD --require-login $AMQ_ARGS "

$AMQ_HOME/bin/artemis create broker $AMQ_ARGS

cp /var/lib/activemq-artemis/etc/* /home/jboss/broker/etc

exec ~/broker/bin/artemis run
