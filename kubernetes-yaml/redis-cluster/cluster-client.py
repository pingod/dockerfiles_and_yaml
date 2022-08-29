#!/usr/bin/env python
from rediscluster import StrictRedisCluster
startup_nodes = [{"host": "10.102.195.230", "port": "6379"}]
rc = StrictRedisCluster(startup_nodes=startup_nodes, decode_responses=True)
rc.set("foo", "bar")
print(rc.get("foo"))
