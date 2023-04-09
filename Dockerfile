ARG REDIS_VERSION=7.0.10
ARG BUILDER_RUST_VERSION=1.68.2

FROM redis:${REDIS_VERSION} AS redis
FROM rust:${BUILDER_RUST_VERSION} AS moduleBuilder

RUN apt clean && apt -y update && apt -y install --no-install-recommends clang && rm -rf /var/lib/apt/lists/*

ARG MODULE_PATH=/usr/lib/redis/modules
RUN mkdir -p ${MODULE_PATH}

COPY --from=redis /usr/local/ /usr/local/

# https://github.com/RediSearch/RediSearch
ARG MODULE=RediSearch
ARG VERSION=v2.6.6
WORKDIR /modules
RUN git clone --recursive --depth 1 --branch ${VERSION} https://github.com/${MODULE}/${MODULE}.git
WORKDIR /modules/${MODULE}
# BULD
RUN make setup
RUN make fetch SHOW=1
RUN make build SHOW=1
# RESULT
RUN cp "$(ls -d /modules/${MODULE}/bin/linux-*-release)/search/redisearch.so" ${MODULE_PATH}/redisearch.so

# https://github.com/RedisJSON/RedisJSON
ARG MODULE=RedisJSON
ARG VERSION=v2.4.6
WORKDIR /modules
RUN git clone --depth 1 --branch ${VERSION} https://github.com/${MODULE}/${MODULE}.git
WORKDIR /modules/${MODULE}
# BUILD
RUN cargo build --release
# RESULT
RUN cp /modules/${MODULE}/target/release/librejson.so ${MODULE_PATH}/rejson.so

# https://github.com/RedisTimeSeries/RedisTimeSeries
ARG MODULE=RedisTimeSeries
ARG VERSION=v1.8.9
WORKDIR /modules
RUN git clone --recursive --branch ${VERSION} https://github.com/${MODULE}/${MODULE}.git
WORKDIR /modules/${MODULE}
# BUILD
RUN ./sbin/setup
RUN make build
# RESULT
RUN cp "$(ls -d /modules/${MODULE}/bin/* | head -n 1)/redistimeseries.so" ${MODULE_PATH}/redistimeseries.so

RUN ls -al ${MODULE_PATH}


FROM redis:${REDIS_VERSION}

RUN apt-get update && apt-get install -y openssl && rm -rf /var/lib/apt/lists/*

ARG MODULE_PATH=/usr/lib/redis/modules

# Modules copy
COPY --from=moduleBuilder ${MODULE_PATH}/redisearch.so ${MODULE_PATH}/
COPY --from=moduleBuilder ${MODULE_PATH}/rejson.so ${MODULE_PATH}/
COPY --from=moduleBuilder ${MODULE_PATH}/redistimeseries.so ${MODULE_PATH}/

RUN mkdir -p /usr/local/etc/redis

COPY src /app

RUN mkdir /certs && chown redis:redis /certs
VOLUME /certs

CMD ["/app/start-redis.sh"]
