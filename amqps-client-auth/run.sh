RUN_PATH="$( cd -- "$(dirname "$0")" >/dev/null 2>&1 ; pwd -P )"
WORKSPACE_PATH="${RUN_PATH}/../workspace"

cp -r ${RUN_PATH}/activemq-artemis ${WORKSPACE_PATH}

# Download required stores.
wget -O ${WORKSPACE_PATH}/activemq-artemis/etc/server-keystore.p12 https://github.com/apache/activemq-artemis/raw/main/tests/security-resources/server-keystore.p12
wget -O ${WORKSPACE_PATH}/activemq-artemis/etc/client-ca-truststore.p12 https://github.com/apache/activemq-artemis/raw/main/tests/security-resources/client-ca-truststore.p12

# Debug java ssl, it is useful to get the certificate text
#docker run --rm --name activemq-artemis -e JAVA_ARGS_APPEND="-Djavax.net.debug=all" \
docker run --rm --name activemq-artemis \
    -e AMQ_USER=admin -e AMQ_PASSWORD=admin -e AMQ_ARGS="--http-host 0.0.0.0" \
    -p61616:61616 -p5671:5671 -p5672:5672 -p8161:8161 \
    -v ${WORKSPACE_PATH}/activemq-artemis:/var/lib/activemq-artemis \
    --entrypoint /var/lib/activemq-artemis/launch.sh \
    quay.io/artemiscloud/activemq-artemis-broker
