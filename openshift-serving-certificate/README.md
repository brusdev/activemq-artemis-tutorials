# openshift-serving-certificate

## ArtemisCloud Operator
```
kubectl apply -f https://github.com/artemiscloud/activemq-artemis-operator/releases/download/1.2.0/activemq-artemis-operator.yaml
```

## ActiveMQ Artemis
```
kubectl apply -f - <<EOF
apiVersion: v1
kind: Secret
metadata:
  name: broker-secacc-secret
type: Opaque
stringData:
  broker.pemcfg: |
    source.cert=/etc/secacc-secret-volume/tls.crt
    source.key=/etc/secacc-secret-volume/tls.key
  keyStorePath: /etc/broker-secacc-secret-volume/broker.pemcfg
  trustStorePath: /etc/secacc-secret-volume/tls.crt
---
apiVersion: broker.amq.io/v1beta1
kind: ActiveMQArtemis
metadata: 
  name: broker
spec:
  acceptors:
    - name: secacc
      protocols: CORE
      port: 61626
      sslEnabled: true
  brokerProperties:
    - "acceptorConfigurations.secacc.params.keyStoreType=PEMCFG"
    - "acceptorConfigurations.secacc.params.trustStoreType=PEM"
  deploymentPlan:
    extraVolumes:
      - name: secacc-secret-volume
        secret:
          secretName: secacc-secret
    extraVolumeMounts:
      - mountPath: "/etc/secacc-secret-volume"
        name: secacc-secret-volume
        readOnly: true
  resourceTemplates:
    - selector:
        kind: Service
        name: broker-secacc-0-svc
      annotations:
        service.beta.openshift.io/serving-cert-secret-name: secacc-secret
#  env:
#    - name: JAVA_ARGS_APPEND
#      value: -Djavax.net.debug=all
EOF
```

## Check
```
kubectl exec broker-ss-0 -- amq-broker/bin/artemis check queue --name TEST --produce 10 --browse 10 --consume 10 --url 'tcp://broker-secacc-0-svc.default.svc.cluster.local:61626?sslEnabled=true&trustStorePath=/etc/secacc-secret-volume/tls.crt&trustStoreType=PEM'
```
