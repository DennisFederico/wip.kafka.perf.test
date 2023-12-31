#!/bin/bash

echo "Starting Kafka Consumer Perfomance Test"
echo "Bootstrap Server: '$BOOTSTRAP_SERVERS'"
echo "Topic: '$TOPIC_NAME', Group: '$GROUP_ID', Messages: '$MESSAGE_COUNT', Timeout: '$TIMEOUT_MS'"
echo "Propeties: \n$(cat /config/consumer/connection.properties)"
echo "\n"

echo "Start TS... $(date +'%Y-%m-%d %H:%M:%S')"
start_time=$(date +%s)

kafka-consumer-perf-test.sh \
  --bootstrap-server $BOOTSTRAP_SERVERS \
  --consumer.config /config/consumer/connection.properties \
  --topic $TOPIC_NAME \
  --group $GROUP_ID \
  --messages $MESSAGE_COUNT \
  --timeout $TIMEOUT_MS \
  --show-detailed-stats \
  --print-metrics

echo "\nKafka Consumer Perfomance Test Ended."

echo "End TS... $(date +'%Y-%m-%d %H:%M:%S')"
end_time=$(date +%s)
elapsed_time=$((end_time - start_time))
echo "Elapsed Time... $elapsed_time seconds"
