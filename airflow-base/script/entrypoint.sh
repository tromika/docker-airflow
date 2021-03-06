#!/usr/bin/env bash

CMD="airflow"
DB_LOOPS="10"
MYSQL_PORT="3306"
RABBITMQ_CREDS="airflow:airflow"
FERNET_KEY=$(python -c "from cryptography.fernet import Fernet; FERNET_KEY = Fernet.generate_key().decode(); print FERNET_KEY")


# Generate Fernet key
sed -i "s/{FERNET_KEY}/${FERNET_KEY}/" $AIRFLOW_HOME/airflow.cfg
sed -i "s/{HOST}/${HOST}/" $AIRFLOW_HOME/airflow.cfg


# wait for rabbitmq
if [ "$@" = "webserver" ] || [ "$@" = "worker" ] || [ "$@" = "scheduler" ] || [ "$@" = "flower" ] ; then
  j=0
  while ! curl -sI -u $RABBITMQ_CREDS http://$HOST:15672/api/whoami |grep '200 OK'; do
    j=`expr $j + 1`
    if [ $j -ge $DB_LOOPS ]; then
      echo "$(date) - $HOST still not reachable, giving up"
      exit 1
    fi
    echo "$(date) - waiting for RabbitMQ..."
    sleep 2
  done
fi
if [ "$@" = "flower" ]; then
  sleep 10
fi

# wait for DB
if [ "$@" = "webserver" ] || [ "$@" = "worker" ] || [ "$@" = "scheduler" ] ; then
  i=0
  while ! nc $HOST $MYSQL_PORT >/dev/null 2>&1 < /dev/null; do
    i=`expr $i + 1`
    if [ $i -ge $DB_LOOPS ]; then
      echo "$(date) - ${HOST}:${MYSQL_PORT} still not reachable, giving up"
      exit 1
    fi
    echo "$(date) - waiting for ${HOST}:${MYSQL_PORT}..."
    sleep 1
  done
  sleep 2
  $CMD initdb
fi

exec $CMD "$@"
