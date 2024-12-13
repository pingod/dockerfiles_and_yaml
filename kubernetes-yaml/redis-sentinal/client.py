#!/usr/bin/env python
# -*- encoding=utf-8 -*-
import os
import redis
from redis.sentinel import Sentinel

redis_host = "10.110.197.166"
redis_port = 26379
redis_pass = "redispass"
sentinel = Sentinel([(redis_host, int(redis_port))], password=redis_pass, socket_timeout=0.1)
print(sentinel.discover_master('mymaster'))
print(sentinel.discover_slaves('mymaster'))
master = sentinel.master_for('mymaster', socket_timeout=0.1)
master.set('foo', 'bar')
slave = sentinel.slave_for('mymaster', socket_timeout=0.1)
print(slave.get('foo'))
print(master.get('test'))
