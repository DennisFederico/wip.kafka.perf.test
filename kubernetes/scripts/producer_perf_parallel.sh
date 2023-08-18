#!/bin/bash

echo "Starting Kafka Producer Perfomance Test"
echo "Topic: $TOPIC_NAME, NumRecords: $NUM_RECORDS, RecordSize: $RECORD_SIZE, Throughput: $THROUGHPUT"
echo "Propeties: \n$(cat /config/producer/connection.properties)"
echo "\n"

echo "Start TS... $(date +'%Y-%m-%d %H:%M:%S')"
start_time=$(date +%s)

kafka-producer-perf-test.sh \
  --producer.config /config/producer/connection.properties \
  --topic $TOPIC_NAME \
  --num-records $NUM_RECORDS \
  --record-size $RECORD_SIZE \
  --throughput $THROUGHPUT \
  --print-metrics

echo "\nKafka Producer Perfomance Test Ended."

echo "End TS... $(date +'%Y-%m-%d %H:%M:%S')"
end_time=$(date +%s)
elapsed_time=$((end_time - start_time))
echo "Elapsed Time... $elapsed_time seconds"