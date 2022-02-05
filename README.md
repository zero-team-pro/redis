# Redis
Redis with modules for amd64 and arm64.

Default redis.conf can be enriched from environment variables.

# How to use this image

## Start instance
```
$ docker run -d --name redis ams.ocir.io/ax4e0xrv7kjj/redis
```

## Start instance with mounted storage
```
$ docker run -d --name redis -v /opt/project/redis:/data ams.ocir.io/ax4e0xrv7kjj/redis
```

## Start instance specific variant
```
$ docker run -d --name redis ams.ocir.io/ax4e0xrv7kjj/redis:<version>
```

## Open port
```
$ docker run -d --name redis -p 6379:6379 ams.ocir.io/ax4e0xrv7kjj/redis
```

## Default redis.conf enriched from environment variables
```
$ docker run -d --name redis -e REDIS_PASSWORD=verySecurePassword ams.ocir.io/ax4e0xrv7kjj/redis
```

Adds `requirepass verySecurePassword` to default redis.conf

## Custom redis.conf
```
$ docker run -d --name redis -v /your-redis.conf:/app/redis.conf ams.ocir.io/ax4e0xrv7kjj/redis
```

Note! Some environment variables can enrich `/app/redis.conf`. Do not use the same keys in your `redis.conf`
and environment variables (list bellow).

# Enrich redis.conf from environment variables

## REDIS_PASSWORD
env:
```
REDIS_PASSWORD=somePassword
```
redis.conf new line:
```
requirepass=somePassword
```

# Custom Docker image

## Dockerfile example
```
FROM ams.ocir.io/ax4e0xrv7kjj/redis[:version]

COPY redis.conf /app/redis.conf

# Optional change CMD
# Default: #CMD ["/app/start-redis.sh"]

# The script copies /app/redis.conf to /usr/local/etc/redis/redis.conf,
# enriches it with environment variables, and
# runs redis-server with config /usr/local/etc/redis/redis.conf
CMD ["/app/start-redis.sh"] # Default for this image

# Change config to yours and ignore invironment variables 
# NOTE! default CMD script will use your /app/redis.conf anyway,
# but alsa enriches it with environment variables.
# Using this custom CMD ignores all environment variables
# described above.
CMD ["redis-server", "/app/redis.conf"]
```
