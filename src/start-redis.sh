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

# Place password from environment variable to config
if [ -n "$REDIS_MAX_MEMORY" ]
then
  echo "REDIS_MAX_MEMORY detected"
  echo "maxmemory $REDIS_MAX_MEMORY" >> /usr/local/etc/redis/redis.conf
  echo "maxmemory injected"
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

# Start redis
redis-server /usr/local/etc/redis/redis.conf
