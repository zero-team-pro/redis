#!/usr/bin/env bash

echo "Redis start script"

echo "Modules installed:"
ls -l /usr/lib/redis/modules

cat /app/redis.conf > /usr/local/etc/redis/redis.conf

# Place password from environment variable to config
if [ -n "$REDIS_PASSWORD" ]
then
  echo "REDIS_PASSWORD detected"
  if grep -Fq "requirepass " /usr/local/etc/redis/redis.conf
  then
    echo "Password already places"
  else
    echo "Password injected"
    echo "requirepass \"$REDIS_PASSWORD\"" >> /usr/local/etc/redis/redis.conf
  fi
fi

# TODO: remove
echo "Running with conf:"
cat /usr/local/etc/redis/redis.conf

# Start redis
redis-server /usr/local/etc/redis/redis.conf
