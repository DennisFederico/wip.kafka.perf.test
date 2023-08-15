#!/bin/bash

echo "Start creation of '$TOPIC_COUNT' topics with prefix '$TOPIC_PREFIX' ..."
echo "Using RF='$REPLICATION_FACTOR', partitions='$TOPIC_PARTITIONS', config='$TOPIC_CONFIG'"

for ((i=1; i<=TOPIC_COUNT; i++)); do
    TOPIC_NAME="${TOPIC_PREFIX}-${i}"
    kafka-topics.sh \
      --bootstrap-server $BOOTSTRAP_SERVERS \
      --command-config /config/properties/connection.properties \
      --create \
      --if-not-exists \
      --topic $TOPIC_NAME \
      --partitions $TOPIC_PARTITIONS \
      --replication-factor $REPLICATION_FACTOR
      #--config $TOPIC_CONFIG
    echo "Created topic: $TOPIC_NAME"
    #sleep 0.5
done

echo "Topic creation completed."