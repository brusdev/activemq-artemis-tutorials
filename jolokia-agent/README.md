# jolokia-agent

## Init
```
mkdir -p workspace
wget -O workspace/apache-artemis-2.41.0-bin.zip https://dlcdn.apache.org/activemq/activemq-artemis/2.41.0/apache-artemis-2.41.0-bin.zip
unzip workspace/apache-artemis-2.41.0-bin.zip -d workspace/apache-artemis-2.41.0-bin
mv workspace/apache-artemis-2.41.0-bin/apache-artemis-2.41.0 workspace/apache-artemis-2.41.0
rm -rf workspace/apache-artemis-2.41.0-bin*

wget -O workspace/apache-artemis-2.41.0/lib/jolokia-agent-jvm-2.2.9-javaagent.jar https://repo1.maven.org/maven2/org/jolokia/jolokia-agent-jvm/2.2.9/jolokia-agent-jvm-2.2.9-javaagent.jar
```

## Setup
```
workspace/apache-artemis-2.41.0/bin/artemis create workspace/broker-with-jolokia-agent --user admin --password admin --require-login

cat >workspace/broker-with-jolokia-agent/etc/jolokia-agent.config <<EOL
port=8778
protocol=http
authClass=org.apache.activemq.artemis.spi.core.security.jaas.HttpServerAuthenticator
disabledServices=org.jolokia.service.history.HistoryMBeanRequestInterceptor
disableDetectors=true
... 
EOL

sed -i "s~UNNAMED~UNNAMED -javaagent:${PWD}/workspace/apache-artemis-2.41.0/lib/jolokia-agent-jvm-2.2.9-javaagent.jar=config=${PWD}/workspace/broker-with-jolokia-agent/etc/jolokia-agent.config -DhttpServerAuthenticator.realm=activemq -DhttpServerAuthenticator.requestSubjectAttribute=org.jolokia.jaasSubject~" workspace/broker-with-jolokia-agent/etc/artemis.profile

sed -i 's~-classpath.*~-classpath "${ARTEMIS_HOME}/lib/*" \\~' workspace/broker-with-jolokia-agent/bin/artemis

workspace/broker-with-jolokia-agent/bin/artemis run
```

## Test
```
curl -v -H "Origin: http://localhost" -u admin:admin http://localhost:8778/jolokia/read/org.apache.activemq.artemis:broker=%220.0.0.0%22/Status
```

## Generate the broker configuration as properties and peek at them
```
curl -v -H "Origin: http://localhost" -u admin:admin http://localhost:8778/jolokia/exec/org.apache.activemq.artemis:broker=%220.0.0.0%22/exportConfigAsProperties
cat workspace/broker-with-jolokia-agent/tmp/broker_config_as_properties.txt
```
