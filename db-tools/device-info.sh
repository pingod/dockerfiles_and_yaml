#!/bin/bash
# 本脚本将通过mysql中的mac字段，去mongo中查询对应的日志 包名等信息

echo $@

MysqlGroupName=${1:-zf127}
MysqlHostIp=${MysqlHostIp:-10.0.32.127}
MysqlHostPort=${MysqlHostPort:-3306}
MysqlHostUser=${MysqlHostUser:-root}
MysqlHostPasswd=${MysqlHostPasswd:-root}
MysqlHostDbName=${MysqlHostDbName:-db_tds}

MongoHostIp=${MongoHostIp:-10.0.32.49}
MongoHostPort=${MongoHostPort:-27017}
MongoHostUser=${MongoHostUser:-thundersoft}
MongoHostPasswd=${MongoHostPasswd:-ThunderSoft@88}
MongoCollection=${MongoCollection:-device_upgrade_info}
MongoDbName=${MongoDbName:-db_tds}


echo $MysqlGroupName

if [[ $# -lt 1 ]];then
    echo '$1 为要查询mysql的group name'
    echo "由于没有输入参数，将采用默认mysql组名称:zf127"
    echo '注意： 修改脚本中的数据库ip地址，以及对应的账号密码'
fi

cat >  mac-mysql.sql << EOF
select mac from t_device D
 left join t_device_group DG on D.id = DG.device_id
 left join t_group G on G.id = DG.group_id
where G.group_name='$MysqlGroupName'
EOF


cat > ~/.my.cnf << EOF
[client]
user=${MysqlHostUser}
password="${MysqlHostPasswd}"
EOF


mysql -h ${MysqlHostIp}  -P ${MysqlHostPort}  ${MysqlHostDbName} < mac-mysql.sql |sed '1,2d' > mac.list

mac_list=$(cat mac.list|sed 's#^#\"#g' |sed 's#$#\"#g'|sed 's#$#, #g'|tr -d '\n'|sed s'/, $//')



cat > mongo.js << EOF
{"\$and": [{"flag": 0}, {"log_info": {"\$ne": null}}, {"mac": {"\$in": [$mac_list]}}]}
EOF

mongoexport -h ${MongoHostIp} --port ${MongoHostPort}  -d ${MongoDbName} -c ${MongoCollection} \
--username ${MongoHostUser} \
--password ${MongoHostPasswd} \
--fields mac,package_name,from_version,to_version,log_info,create_time \
--queryFile ./mongo.js \
--type=csv \
--out ./device-info.csv


cp ./device-info.csv /tmp/tds-device/


echo ----------------------------------------------------------------------------
echo '容器运行方式为: docker run -v /tmp/tds-device/:/tmp/tds-device/ \
      -e MysqlHostIp=192.168.221.1 \
      -e MongoHostIp=192.168.11.1 \
      registry.cn-hangzhou.aliyuncs.com/sourcegarden/db-tools:v0.1 zf127
      '
echo  '-v 后面的挂载路径请不要变更，容器生成的表格文件将放置在该路径'
echo  '你可以在容器启动时，-e 指定下面变量值(直接运行脚本，也可以通过定义环境变量的方式来指定)：'
echo     'MysqlGroupName'
echo     'MysqlHostIp'
echo     'MysqlHostPort'
echo     'MysqlHostUser'
echo     'MysqlHostPasswd'
echo     'MysqlHostDbName'
echo     'MongoHostIp'
echo     'MongoHostPort'
echo     'MongoHostUser'
echo     'MongoHostPasswd'
echo     'MongoCollection'
echo     'MongoDbName'
echo ----------------------------------------------------------------------------
