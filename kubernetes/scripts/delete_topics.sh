#!/bin/bash

echo "Start deletion of '$TOPIC_COUNT' topics with prefix '$TOPIC_PREFIX' ..."

for ((i=1; i<=TOPIC_COUNT; i++)); do
    TOPIC_NAME="${TOPIC_PREFIX}-${i}"
    kafka-topics.sh \
      --bootstrap-server $BOOTSTRAP_SERVERS \
      --command-config /config/properties/connection.properties \
      --delete \
      --if-exists \
      --topic $TOPIC_NAME
    echo "Deleted topic: $TOPIC_NAME"
    #sleep 0.5
done

echo "Topic deletion completed."