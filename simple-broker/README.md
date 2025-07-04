# simple-broker

## Init
```
mkdir -p workspace
wget -O workspace/apache-artemis-2.41.0-bin.zip https://dlcdn.apache.org/activemq/activemq-artemis/2.41.0/apache-artemis-2.41.0-bin.zip
unzip workspace/apache-artemis-2.41.0-bin.zip -d workspace/apache-artemis-2.41.0-bin
mv workspace/apache-artemis-2.41.0-bin/apache-artemis-2.41.0 workspace/apache-artemis-2.41.0
rm -rf workspace/apache-artemis-2.41.0-bin*

mkdir -p workspace/simple-broker
cp -r simple-broker/bin workspace/simple-broker
cp -r simple-broker/etc workspace/simple-broker

export ARTEMIS_HOME='workspace/apache-artemis-2.41.0'
export ARTEMIS_INSTANCE='workspace/simple-broker'
```

## Broker
```
./workspace/simple-broker/bin/run.sh
```

## Test
```
./workspace/simple-broker/bin/run-test.sh
```