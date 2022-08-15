#!/usr/bin/env bash

echo "发布v1.0.0"
docker tag ddc8fe7e5c23 registry.cn-shanghai.aliyuncs.com/gclm/oracle-jdk-8:v1.0.0
docker push registry.cn-shanghai.aliyuncs.com/gclm/oracle-jdk-8:v1.0.0

echo "发布v1.1.0"
docker tag 04f3806049e9 registry.cn-shanghai.aliyuncs.com/gclm/oracle-jdk-8:v1.1.0
docker push registry.cn-shanghai.aliyuncs.com/gclm/oracle-jdk-8:v1.1.0

echo "发布v1.1.2"
docker tag 93fa8f6b8df7 registry.cn-shanghai.aliyuncs.com/gclm/oracle-jdk-8:v1.1.2
docker push registry.cn-shanghai.aliyuncs.com/gclm/oracle-jdk-8:v1.1.2

echo "发布v1.1.3"
docker tag a6d1ad346ef6 registry.cn-shanghai.aliyuncs.com/gclm/oracle-jdk-8:v1.1.3
docker push registry.cn-shanghai.aliyuncs.com/gclm/oracle-jdk-8:v1.1.3

echo "发布v1.1.4"
docker tag a28b81080597 registry.cn-shanghai.aliyuncs.com/gclm/oracle-jdk-8:v1.1.4
docker push registry.cn-shanghai.aliyuncs.com/gclm/oracle-jdk-8:v1.1.4

echo "发布v1.1.5"
docker tag d6e0b6d25c1e registry.cn-shanghai.aliyuncs.com/gclm/oracle-jdk-8:v1.1.5
docker push registry.cn-shanghai.aliyuncs.com/gclm/oracle-jdk-8:v1.1.5

echo "发布v1.1.6"
docker tag f17808b2491c registry.cn-shanghai.aliyuncs.com/gclm/oracle-jdk-8:v1.1.6
docker push registry.cn-shanghai.aliyuncs.com/gclm/oracle-jdk-8:v1.1.6

echo "发布v1.1.7"
docker tag 21649125c37b registry.cn-shanghai.aliyuncs.com/gclm/oracle-jdk-8:v1.1.7
docker push registry.cn-shanghai.aliyuncs.com/gclm/oracle-jdk-8:v1.1.7

echo "发布v1.1.8"
docker tag fbd9099674a3 registry.cn-shanghai.aliyuncs.com/gclm/oracle-jdk-8:v1.1.8
docker push registry.cn-shanghai.aliyuncs.com/gclm/oracle-jdk-8:v1.1.8

echo "发布v1.2.0"
docker tag 77c657bd3d53 registry.cn-shanghai.aliyuncs.com/gclm/oracle-jdk-8:v1.2.0
docker push registry.cn-shanghai.aliyuncs.com/gclm/oracle-jdk-8:v1.2.0

echo "发布v1.2.1"
docker tag 0076d866581a registry.cn-shanghai.aliyuncs.com/gclm/oracle-jdk-8:v1.2.1
docker push registry.cn-shanghai.aliyuncs.com/gclm/oracle-jdk-8:v1.2.1

