# oracle-jdbc-shared-store

## Init
```
mkdir -p workspace
wget -O workspace/apache-artemis-2.32.0-bin.zip https://dlcdn.apache.org/activemq/activemq-artemis/2.32.0/apache-artemis-2.32.0-bin.zip
unzip workspace/apache-artemis-2.32.0-bin.zip -d workspace/apache-artemis-2.32.0-bin
mv workspace/apache-artemis-2.32.0-bin/apache-artemis-2.32.0 workspace/apache-artemis-2.32.0
rm -rf workspace/apache-artemis-2.32.0-bin*
```

## Openshift
Log in to your server by using the command `oc login` and create new project y using the command `oc new-project`, i.e.
```
oc login --token=sha256~n1eCPRPn2jSgVXJU8ObmfmvRqlIfFxz-MjJ2f6WnYqM --server=https://a603c8cd206bf4fe98f4d3817cda2dda-011da12348812db5.elb.us-east-1.amazonaws.com:6443
oc new-project oracle-jdbc-shared-store
```

## Oracle Database
```
oc apply -f oracle-jdbc-shared-store/oracle-database-install.yaml
```

## Certificates
```
wget -O workspace/server-keystore.jks https://github.com/apache/activemq-artemis/raw/main/tests/security-resources/server-keystore.jks
wget -O workspace/server-ca-truststore.jks https://github.com/apache/activemq-artemis/raw/main/tests/security-resources/server-ca-truststore.jks
wget -O workspace/client-ca-truststore.jks https://github.com/apache/activemq-artemis/raw/main/tests/security-resources/client-ca-truststore.jks
oc create secret generic ext-acceptor-ssl-secret \
--from-file=broker.ks=workspace/server-keystore.jks \
--from-file=client.ts=workspace/client-ca-truststore.jks \
--from-literal=keyStorePassword=securepass \
--from-literal=trustStorePassword=securepass
```

## ArtemisCloud Operator
```
wget -O workspace/activemq-artemis-operator-1.1.0.zip https://github.com/artemiscloud/activemq-artemis-operator/releases/download/1.1.0/activemq-artemis-operator-1.1.0.zip
unzip workspace/activemq-artemis-operator-1.1.0.zip -d workspace/activemq-artemis-operator-1.1.0
rm -rf workspace/activemq-artemis-operator-1.1.0.zip
workspace/activemq-artemis-operator-1.1.0/install_opr.sh
```

## ActiveMQ Artemis
```
oc apply -f oracle-jdbc-shared-store/activemq-artemis-install.yaml
oc apply -f oracle-jdbc-shared-store/ext-acceptor-openshift-install.yaml
```

## Hosts
```
export EXT_ACCEPTOR_HOST=$(oc get route ext-acceptor-svc-rte -o json | jq -r '.spec.host')
export PRIMARY_BROKER_EXT_ACCEPTOR_HOST=$(oc get route primary-broker-ext-acceptor-0-svc-rte -o json | jq -r '.spec.host')
export PRIMARY_BROKER_CONSOLE_HOST=$(oc get route primary-broker-wconsj-0-svc-rte -o json | jq -r '.spec.host')
export BACKUP_BROKER_EXT_ACCEPTOR_HOST=$(oc get route backup-broker-ext-acceptor-0-svc-rte -o json | jq -r '.spec.host')
export BACKUP_BROKER_CONSOLE_HOST=$(oc get route backup-broker-wconsj-0-svc-rte -o json | jq -r '.spec.host')
```

## Producer
```
workspace/apache-artemis-2.32.0/bin/artemis producer --verbose --destination queue://TEST --user admin --password admin --protocol core --sleep 1000 --url "tcp://${EXT_ACCEPTOR_HOST}:443?sslEnabled=true&verifyHost=false&trustStorePath=workspace/server-ca-truststore.jks&trustStorePassword=securepass&useTopologyForLoadBalancing=false&initialConnectAttempts=-1&failoverAttempts=-1"
```

## Consumer
```
workspace/apache-artemis-2.32.0/bin/artemis consumer --verbose --destination queue://TEST --user admin --password admin --protocol core --sleep 1000 --url "tcp://${EXT_ACCEPTOR_HOST}:443?sslEnabled=true&verifyHost=false&trustStorePath=workspace/server-ca-truststore.jks&trustStorePassword=securepass&useTopologyForLoadBalancing=false&initialConnectAttempts=-1&failoverAttempts=-1"
```

## Test
```
oc delete ActiveMQArtemis primary-broker

oc apply -f oracle-jdbc-shared-store/activemq-artemis-install.yaml

oc delete ActiveMQArtemis backup-broker

oc apply -f oracle-jdbc-shared-store/activemq-artemis-install.yaml

workspace/apache-artemis-2.32.0/bin/artemis check queue --name TEST --produce 10 --browse 10 --consume 10 --url "tcp://${PRIMARY_BROKER_EXT_ACCEPTOR_HOST}:443?name=artemis&useTopologyForLoadBalancing=false&sslEnabled=true&verifyHost=false&trustStorePath=workspace/server-ca-truststore.jks&trustStorePassword=securepass"

workspace/apache-artemis-2.32.0/bin/artemis check queue --name TEST --produce 10 --browse 10 --consume 10 --url "tcp://${BACKUP_BROKER_EXT_ACCEPTOR_HOST}:443?name=artemis&useTopologyForLoadBalancing=false&sslEnabled=true&verifyHost=false&trustStorePath=workspace/server-ca-truststore.jks&trustStorePassword=securepass"

workspace/apache-artemis-2.32.0/bin/artemis producer --verbose --destination queue://TEST --user admin --password admin --protocol core --sleep 1000 --url "(tcp://${PRIMARY_BROKER_EXT_ACCEPTOR_HOST}:443,tcp://${BACKUP_BROKER_EXT_ACCEPTOR_HOST}:443)?sslEnabled=true&verifyHost=false&trustStorePath=workspace/server-ca-truststore.jks&trustStorePassword=securepass&useTopologyForLoadBalancing=false&initialConnectAttempts=-1&failoverAttempts=-1"

workspace/apache-artemis-2.32.0/bin/artemis consumer --verbose --destination queue://TEST --user admin --password admin --protocol core --sleep 1000 --url "(tcp://${PRIMARY_BROKER_EXT_ACCEPTOR_HOST}:443,tcp://${BACKUP_BROKER_EXT_ACCEPTOR_HOST}:443)?sslEnabled=true&verifyHost=false&trustStorePath=workspace/server-ca-truststore.jks&trustStorePassword=securepass&useTopologyForLoadBalancing=false&initialConnectAttempts=-1&failoverAttempts=-1"
```
