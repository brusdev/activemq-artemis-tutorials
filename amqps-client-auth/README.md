# amqps-client-auth

## Init
```
mkdir -p workspace
wget -O workspace/apache-artemis-2.29.0-bin.zip https://dlcdn.apache.org/activemq/activemq-artemis/2.29.0/apache-artemis-2.29.0-bin.zip
unzip workspace/apache-artemis-2.29.0-bin.zip -d workspace/apache-artemis-2.29.0-bin
mv workspace/apache-artemis-2.29.0-bin/apache-artemis-2.29.0 workspace/apache-artemis-2.29.0
rm -rf workspace/apache-artemis-2.29.0-bin*
```

## Broker
./run.sh

## Test
```
wget -O workspace/activemq-artemis/etc/client-keystore.p12 https://github.com/apache/activemq-artemis/raw/main/tests/security-resources/client-keystore.p12
wget -O workspace/activemq-artemis/etc/server-ca-truststore.p12 https://github.com/apache/activemq-artemis/raw/main/tests/security-resources/server-ca-truststore.p12
workspace/apache-artemis-2.29.0/bin/artemis producer --verbose --destination TEST --protocol amqp --url "amqps://localhost:5671?transport.keyStoreLocation=workspace/activemq-artemis/etc/client-keystore.p12&transport.keyStorePassword=securepass&transport.trustStoreLocation=workspace/activemq-artemis/etc/server-ca-truststore.p12&transport.trustStorePassword=securepass"
```
