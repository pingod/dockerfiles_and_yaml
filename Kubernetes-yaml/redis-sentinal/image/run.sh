#!/bin/bash

function launchmaster() {
    if [[ ! -e /redis-master-data ]]; then
	echo "Rdis master data doesn't exist, data won't be persistent!"
	mkdir /redis-master-data
    fi
    sed -i "s/%redis-pass%/${REDIS_PASS}/" /redis-master/redis.conf
    redis-server /redis-master/redis.conf --protected-mode no
}

function launchsentinel() {
    while true; do
	master=$(redis-cli -a $REDIS_PASS -h ${REDIS_SENTINEL_SERVICE_HOST} -p ${REDIS_SENTINEL_SERVICE_PORT} --csv SENTINEL get-master-addr-by-name mymaster | tr ',' ' ' | cut -d' ' -f1)
	if [[ -n ${master} ]]; then
	    master="${master//\"}"
	else
	    master=${REDIS_MASTER_SERVICE_HOST}
	fi

	redis-cli -a $REDIS_PASS -h ${master} INFO
	if [[ "$?" == "0" ]]; then
	    break
	fi
	echo "Connecting to master failed. Waiting..."
	sleep 10
    done

    sentinel_conf=sentinel.conf
    echo "sentinel monitor mymaster ${master} 6379 2" > ${sentinel_conf}
    echo "sentinel auth-pass mymaster ${REDIS_PASS}" >> ${sentinel_conf}
    echo "sentinel down-after-milliseconds mymaster 60000" >> ${sentinel_conf}
    echo "sentinel failover-timeout mymaster 180000" >> ${sentinel_conf}
    echo "sentinel parallel-syncs mymaster 1" >> ${sentinel_conf}
    echo "bind 0.0.0.0" >> ${sentinel_conf}

    redis-sentinel ${sentinel_conf} --protected-mode no
}

function launchslave() {
    while true; do
        master=$(redis-cli -a $REDIS_PASS -h ${REDIS_SENTINEL_SERVICE_HOST} -p ${REDIS_SENTINEL_SERVICE_PORT} --csv SENTINEL get-master-addr-by-name mymaster | tr ',' ' ' | cut -d' ' -f1)
	if [[ -n ${master} ]]; then
	    master="${master//\"}"
	else
	    echo "Failed to find master."
	    sleep 60
	    exit 1
	fi
	redis-cli -a $REDIS_PASS -h ${master} INFO
	if [[ "$?" == "0" ]]; then
	    break
	fi
	echo "Connecting to master failed. Waiting ..."
	sleep 10
    done

    sed -i "s/%master-ip%/${master}/" /redis-slave/redis.conf
    sed -i 's/%master-port%/6379/' /redis-slave/redis.conf
    sed -i 's/%redis-pass%/${REDIS_PASS}/' /redis-slave/redis.conf
    redis-server /redis-slave/redis.conf --protected-mode no
}

if [[ "${MASTER}" == "true" ]]; then
    launchmaster
    exit 0
fi

if [[ "${SENTINEL}" == "true" ]]; then
    launchsentinel
    exit 0
fi

launchslave
