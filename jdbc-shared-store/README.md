# jdbc-shared-store

## Init
```
mkdir -p workspace
wget -O workspace/apache-artemis-2.28.0-bin.zip https://dlcdn.apache.org/activemq/activemq-artemis/2.28.0/apache-artemis-2.28.0-bin.zip
unzip workspace/apache-artemis-2.28.0-bin.zip -d workspace/apache-artemis-2.28.0-bin
mv workspace/apache-artemis-2.28.0-bin/apache-artemis-2.28.0 workspace/apache-artemis-2.28.0
rm -rf workspace/apache-artemis-2.28.0-bin*

docker run --name artemis-postgres -e POSTGRES_PASSWORD=postgres -p 5432:5432 --rm postgres
```

## Master
```
workspace/apache-artemis-2.28.0/bin/artemis create workspace/master --user admin --password admin --require-login --clustered --cluster-password artemis --cluster-user artemis --shared-store --failover-on-shutdown --jdbc --jdbc-driver-class-name org.postgresql.Driver --jdbc-connection-url 'jdbc:postgresql://localhost:5432/postgres?user=postgres&#38;password=postgres' --host localhost --port-offset 0
wget -O workspace/master/lib/postgresql-42.6.0.jar https://jdbc.postgresql.org/download/postgresql-42.6.0.jar

workspace/master/bin/artemis run
```

## Slave
```
workspace/apache-artemis-2.28.0/bin/artemis create workspace/slave --user admin --password admin --require-login --clustered --cluster-password artemis --cluster-user artemis --shared-store --slave --jdbc --jdbc-driver-class-name org.postgresql.Driver --jdbc-connection-url 'jdbc:postgresql://localhost:5432/postgres?user=postgres&#38;password=postgres' --host localhost --port-offset 1
wget -O workspace/slave/lib/postgresql-42.6.0.jar https://jdbc.postgresql.org/download/postgresql-42.6.0.jar

workspace/slave/bin/artemis run
```

## Test
```
workspace/master/bin/artemis producer --verbose --destination queue://TEST --user admin --password admin --protocol core --message-count 1
workspace/master/bin/artemis consumer --verbose --destination queue://TEST --user admin --password admin --protocol core --message-count 1
workspace/master/bin/artemis producer --verbose --destination queue://TEST --user admin --password admin --protocol core --message-count 1
workspace/master/bin/artemis stop && sleep 5
workspace/slave/bin/artemis consumer --verbose --destination queue://TEST --user admin --password admin --protocol core --message-count 1
```
