ARG REDIS_VERSION=6.2.6

FROM redis:${REDIS_VERSION} AS redis
FROM rust:1.57.0 AS moduleBuilder

RUN apt clean && apt -y update && apt -y install --no-install-recommends clang && rm -rf /var/lib/apt/lists/*

ARG MODULE_PATH=/usr/lib/redis/modules
RUN mkdir -p ${MODULE_PATH}

COPY --from=redis /usr/local/ /usr/local/

# https://github.com/RediSearch/RediSearch
ARG MODULE=RediSearch
ARG VERSION=v2.2.6
WORKDIR /modules
RUN git clone --depth 1 --branch ${VERSION} https://github.com/${MODULE}/${MODULE}.git
WORKDIR /modules/${MODULE}
RUN make setup
RUN make fetch SHOW=1
RUN make build SHOW=1
# RESULT
RUN cp "$(ls -d /modules/${MODULE}/bin/linux-*-release)/search/redisearch.so" ${MODULE_PATH}/redisearch.so

# https://github.com/RedisJSON/RedisJSON
ARG MODULE=RedisJSON
ARG VERSION=v2.0.6
WORKDIR /modules
RUN git clone --depth 1 --branch ${VERSION} https://github.com/${MODULE}/${MODULE}.git
WORKDIR /modules/${MODULE}
RUN cargo build --release
# RESULT
RUN cp /modules/${MODULE}/target/release/librejson.so ${MODULE_PATH}/rejson.so

# https://github.com/RedisTimeSeries/RedisTimeSeries
ARG MODULE=RedisTimeSeries
ARG VERSION=v1.6.8
WORKDIR /modules
RUN git clone --recursive --branch ${VERSION} https://github.com/${MODULE}/${MODULE}.git
WORKDIR /modules/${MODULE}
#RUN make setup
RUN ./deps/readies/bin/getupdates
RUN ./deps/readies/bin/getpy3
RUN ./system-setup.py
RUN make fetch
RUN make build
# RESULT
RUN cp /modules/${MODULE}/bin/redistimeseries.so ${MODULE_PATH}/redistimeseries.so

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
