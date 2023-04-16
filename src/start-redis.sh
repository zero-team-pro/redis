#!/usr/bin/env bash

echo "Redis start script"

echo "Modules installed:"
ls -l /usr/lib/redis/modules

cat /app/redis.conf > /usr/local/etc/redis/redis.conf

# Generates X.509 certificate and places in /certs
if [ -n "$REDIS_TLS_GEN" ]
then
  echo "REDIS_TLS_GEN detected"
  echo "Generating certificate..."
  /app/gen-certs.sh
fi

# Place password from environment variable to config
if [ -n "$REDIS_PASSWORD" ]
then
  echo "REDIS_PASSWORD detected"
  echo "requirepass $REDIS_PASSWORD" >> /usr/local/etc/redis/redis.conf
  echo "Password injected"
fi

# Place max memory from environment variable to config
if [ -n "$REDIS_MAX_MEMORY" ]
then
  echo "REDIS_MAX_MEMORY detected"
  echo "maxmemory $REDIS_MAX_MEMORY" >> /usr/local/etc/redis/redis.conf
  echo "maxmemory injected"
fi

# Place save from environment variable to config
if [ -n "$REDIS_SAVE" ]
then
  echo "REDIS_SAVE detected"
  echo "save $REDIS_SAVE" >> /usr/local/etc/redis/redis.conf
  echo "save injected"
fi

# Place log level from environment variable to config
if [ -n "$REDIS_LOG_LEVEL" ]
then
  echo "REDIS_LOG_LEVEL detected"
  echo "loglevel $REDIS_LOG_LEVEL" >> /usr/local/etc/redis/redis.conf
  echo "loglevel injected"
fi

# Adds certs from /certs to config and changes port to TLS
if [ -n "$REDIS_TLS_ON" ]
then
  echo "REDIS_TLS_ON detected"
  cat /app/redis.tls.conf >> /usr/local/etc/redis/redis.conf
  echo "Certs injected"
fi

# Adds custom conf to generated redis.conf
if [ -f /app/redis.custom.conf ]
then
  cat /app/redis.custom.conf >> /usr/local/etc/redis/redis.conf
fi

# Define cleanup function
stop_redis() {
    echo "==========   Stopping Redis server...   =========="
    redis-cli shutdown
    exit 0
}

# Trap SIGINT signal and run cleanup function
trap stop_redis SIGINT

# Start redis
redis-server /usr/local/etc/redis/redis.conf &
wait %?redis-server
