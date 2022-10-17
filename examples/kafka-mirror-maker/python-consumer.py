cat << EOF > python-consumer.py
from kafka import KafkaConsumer

# To consume latest messages and auto-commit offsets
consumer = KafkaConsumer('my-topic',
                         group_id='python-consumer',
                         bootstrap_servers=['my-old-cluster-kafka-bootstrap.stage-old:9092'])

for message in consumer:
    print ("%s:%d:%d: key=%s value=%s" % (message.topic, message.partition,
                                          message.offset, message.key,
                                          message.value))
EOF



cat << EOF > python-consumer.py
from kafka import KafkaConsumer

# To consume latest messages and auto-commit offsets
consumer = KafkaConsumer('my-topic',
                         group_id='python-consumer',
                         bootstrap_servers=['my-new-cluster-kafka-bootstrap:9092'])

for message in consumer:
    print ("%s:%d:%d: key=%s value=%s" % (message.topic, message.partition,
                                          message.offset, message.key,
                                          message.value))
EOF

cat << EOF > python-consumer.py
from kafka import KafkaConsumer

# To consume latest messages and auto-commit offsets
consumer = KafkaConsumer('my-compact-topic',
                         group_id='python-consumer',
                         bootstrap_servers=['my-new-cluster-kafka-bootstrap:9092'])

for message in consumer:
    print ("%s:%d:%d: key=%s value=%s" % (message.topic, message.partition,
                                          message.offset, message.key,
                                          message.value))
EOF