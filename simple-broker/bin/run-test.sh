#!/bin/bash
set -ex

# Uncomment to enable remote debugging
# JAVA_ARGS_APPEND="${JAVA_ARGS_APPEND} -agentlib:jdwp=transport=dt_socket,server=y,suspend=y,address=5005"

CLIENT_PROCESS_ARGS='--rate 30000 --warmup 20 --duration 60 --max-pending 100 --show-latency --url tcp://localhost:61616?confirmationWindowSize=20000 --consumer-url tcp://localhost:61616 queue://TEST_QUEUE'

${ARTEMIS_HOME}/bin/artemis perf client --user admin --password admin --hdr client.hdr --json results.json ${CLIENT_PROCESS_ARGS} | tee client.log