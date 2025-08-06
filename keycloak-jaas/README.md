# keycloak-jaas

## Init
```
mkdir -p workspace
wget -O workspace/apache-artemis-2.42.0-bin.zip https://dlcdn.apache.org/activemq/activemq-artemis/2.42.0/apache-artemis-2.42.0-bin.zip
unzip workspace/apache-artemis-2.42.0-bin.zip -d workspace/apache-artemis-2.42.0-bin
mv workspace/apache-artemis-2.42.0-bin/apache-artemis-2.42.0 workspace/apache-artemis-2.42.0
rm -rf workspace/apache-artemis-2.42.0-bin*
```

## Minikube
```
minikube start --cpus 4 --memory 8192
minikube addons enable ingress
minikube kubectl -- patch deployment -n ingress-nginx ingress-nginx-controller --type='json' -p='[{"op": "add", "path": "/spec/template/spec/containers/0/args/-", "value":"--enable-ssl-passthrough"}]'
minikube dashboard
kubectl create namespace keycloak-jaas
kubectl config set-context --current --namespace=keycloak-jaas
```

## Certificates
```
openssl req -x509 -newkey rsa:4096 -keyout workspace/keycloak-key.pem -out workspace/keycloak-cert.pem -sha256 -days 365 -nodes -subj "/CN=Keycloak" -addext "subjectAltName=DNS:keycloak-service.keycloak-jaas.svc.cluster.local"
openssl pkcs12 -export -jdktrust anyExtendedKeyUsage -nokeys -in workspace/keycloak-cert.pem -password pass:keycloak -out workspace/keycloak-truststore.p12
kubectl create secret generic keycloak-ssl-secret \
--from-file=keycloak-cert.pem=workspace/keycloak-cert.pem \
--from-file=keycloak-key.pem=workspace/keycloak-key.pem \
--from-file=keycloak-truststore.p12=workspace/keycloak-truststore.p12

wget -O workspace/server-keystore.jks https://github.com/apache/activemq-artemis/raw/main/tests/security-resources/server-keystore.jks
wget -O workspace/server-ca-truststore.jks https://github.com/apache/activemq-artemis/raw/main/tests/security-resources/server-ca-truststore.jks
wget -O workspace/client-ca-truststore.jks https://github.com/apache/activemq-artemis/raw/main/tests/security-resources/client-ca-truststore.jks
kubectl create secret generic ext-acceptor-ssl-secret \
--from-file=broker.ks=workspace/server-keystore.jks \
--from-file=client.ts=workspace/client-ca-truststore.jks \
--from-literal=keyStorePassword=securepass \
--from-literal=trustStorePassword=securepass
```

## Keycloak
```
kubectl create secret generic keycloak-import-secret \
--from-file=artemis-realm.json=keycloak-jaas/artemis-realm.json

kubectl apply -f keycloak-jaas/keycloak-install.yaml
```


## ArkMQ Operator
```
wget -O workspace/activemq-artemis-operator-v2.0.5.zip https://github.com/arkmq-org/activemq-artemis-operator/releases/download/v2.0.5/activemq-artemis-operator-v2.0.5.zip
unzip workspace/activemq-artemis-operator-v2.0.5.zip -d workspace/activemq-artemis-operator-v2.0.5
rm -rf workspace/activemq-artemis-operator-v2.0.5.zip
workspace/activemq-artemis-operator-v2.0.5/install_opr.sh
```

## ActiveMQ Artemis
```
kubectl create secret generic keycloak-jaas-config --from-file=login.config=keycloak-jaas/login.config --from-file=keycloak-direct-access.json=keycloak-jaas/keycloak-direct-access.json
kubectl apply -f keycloak-jaas/activemq-artemis-install.yaml
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
workspace/apache-artemis-2.42.0/bin/artemis producer --verbose --destination queue://TEST --user jdoe --password password --protocol core --sleep 1000 --url "tcp://${BROKER_EXT_ACCEPTOR_HOST}:443?sslEnabled=true&verifyHost=false&trustStorePath=workspace/server-ca-truststore.jks&trustStorePassword=securepass&useTopologyForLoadBalancing=false"
```

## Consumer
```
workspace/apache-artemis-2.42.0/bin/artemis consumer --verbose --destination queue://TEST --user jdoe --password password --protocol core --sleep 1000 --url "tcp://${BROKER_EXT_ACCEPTOR_HOST}:443?sslEnabled=true&verifyHost=false&trustStorePath=workspace/server-ca-truststore.jks&trustStorePassword=securepass&useTopologyForLoadBalancing=false"
```

## Test
```
workspace/apache-artemis-2.42.0/bin/artemis queue stat --user jdoe --password password --url "tcp://${BROKER_EXT_ACCEPTOR_HOST}:443?sslEnabled=true&verifyHost=false&trustStorePath=workspace/server-ca-truststore.jks&trustStorePassword=securepass&useTopologyForLoadBalancing=false"
```
