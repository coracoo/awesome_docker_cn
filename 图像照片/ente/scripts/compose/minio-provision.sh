#!/bin/sh

# 对应修改minio的端口，账号，密码
while ! mc config host add h0 http://minio:3200 test testtest
do
   echo "waiting for minio..."
   sleep 0.5
done

cd /data

mc mb -p b2-eu-cen
mc mb -p wasabi-eu-central-2-v3
mc mb -p scw-eu-fr-v3
