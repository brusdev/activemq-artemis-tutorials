#!/bin/bash
set -ex

# Uncomment to enable remote debugging
# JAVA_ARGS_APPEND="${JAVA_ARGS_APPEND} -agentlib:jdwp=transport=dt_socket,server=y,suspend=y,address=5005"

exec java \
-Dlog4j2.level=INFO \
-Dlog4j2.disableJmx=true \
-Djava.net.preferIPv4Stack=true \
-Djava.io.tmpdir=/tmp \
-XX:+PrintClassHistogram \
-XX:+UseG1GC \
-XX:+UseStringDeduplication \
-Xms512M \
-Xmx2G \
-classpath "${ARTEMIS_HOME}/lib/*" \
-Dartemis.instance="${ARTEMIS_INSTANCE}" \
-Dbroker.properties="${ARTEMIS_INSTANCE}/etc/broker.properties" \
-Djava.security.auth.login.config="${ARTEMIS_INSTANCE}/etc/login.config" \
-Djavax.management.builder.initial=org.apache.activemq.artemis.core.server.management.ArtemisRbacMBeanServerBuilder \
$JAVA_ARGS_APPEND \
org.apache.activemq.artemis.core.server.embedded.Main
