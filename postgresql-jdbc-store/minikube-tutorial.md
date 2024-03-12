# postgresql-jdbc-store

## Init
```
mkdir -p workspace
wget -O workspace/apache-artemis-2.32.0-bin.zip https://dlcdn.apache.org/activemq/activemq-artemis/2.32.0/apache-artemis-2.32.0-bin.zip
unzip workspace/apache-artemis-2.32.0-bin.zip -d workspace/apache-artemis-2.32.0-bin
mv workspace/apache-artemis-2.32.0-bin/apache-artemis-2.32.0 workspace/apache-artemis-2.32.0
rm -rf workspace/apache-artemis-2.32.0-bin*
```

## Minikube
```
minikube start --cpus 4 --memory 8192
minikube addons enable ingress
minikube kubectl -- patch deployment -n ingress-nginx ingress-nginx-controller --type='json' -p='[{"op": "add", "path": "/spec/template/spec/containers/0/args/-", "value":"--enable-ssl-passthrough"}]'
minikube dashboard
kubectl create namespace postgresql-jdbc-store
kubectl config set-context --current --namespace=postgresql-jdbc-store
```

## PostgreSQL
```
kubectl apply -f postgresql-jdbc-store/postgresql-install.yaml
```

## Certificates
```
wget -O workspace/server-keystore.jks https://github.com/apache/activemq-artemis/raw/main/tests/security-resources/server-keystore.jks
wget -O workspace/server-ca-truststore.jks https://github.com/apache/activemq-artemis/raw/main/tests/security-resources/server-ca-truststore.jks
wget -O workspace/client-ca-truststore.jks https://github.com/apache/activemq-artemis/raw/main/tests/security-resources/client-ca-truststore.jks
kubectl create secret generic ext-acceptor-ssl-secret \
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
kubectl apply -f postgresql-jdbc-store/activemq-artemis-install.yaml
```

## Hosts
```
export BROKER_EXT_ACCEPTOR_HOST=$(kubectl get ingress broker-ext-acceptor-0-svc-ing -o json | jq -r '.spec.rules[].host')
export BROKER_CONSOLE_HOST=$(kubectl get ingress broker-wconsj-0-svc-ing -o json | jq -r '.spec.rules[].host')

echo "$(minikube ip) ${BROKER_EXT_ACCEPTOR_HOST}" | sudo tee -a /etc/hosts
echo "$(minikube ip) ${BROKER_CONSOLE_HOST}" | sudo tee -a /etc/hosts
```

## Producer
```
workspace/apache-artemis-2.32.0/bin/artemis producer --verbose --destination queue://TEST --user admin --password admin --protocol core --sleep 1000 --url "tcp://${BROKER_EXT_ACCEPTOR_HOST}:443?sslEnabled=true&verifyHost=false&trustStorePath=workspace/server-ca-truststore.jks&trustStorePassword=securepass&useTopologyForLoadBalancing=false"
```

## Consumer
```
workspace/apache-artemis-2.32.0/bin/artemis consumer --verbose --destination queue://TEST --user admin --password admin --protocol core --sleep 1000 --url "tcp://${BROKER_EXT_ACCEPTOR_HOST}:443?sslEnabled=true&verifyHost=false&trustStorePath=workspace/server-ca-truststore.jks&trustStorePassword=securepass&useTopologyForLoadBalancing=false"
```

## Test
```
workspace/apache-artemis-2.32.0/bin/artemis check queue --name TEST --produce 10 --browse 10 --consume 10 --url "tcp://${BROKER_EXT_ACCEPTOR_HOST}:443?sslEnabled=true&verifyHost=false&trustStorePath=workspace/server-ca-truststore.jks&trustStorePassword=securepass&useTopologyForLoadBalancing=false"
```
