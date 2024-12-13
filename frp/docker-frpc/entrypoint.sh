#!/bin/sh

if [ -z "$server_addr" ]; then
  export server_addr=0.0.0.0
fi

if [ -z "$server_port" ]; then
  export server_port=7100
fi

if [ -z "$token" ]; then
  export token=12345
fi

if [ -z "$login_fail_exit" ]; then
  export login_fail_exit=true
fi

if [ -z "$hostname_in_docker" ]; then
  export hostname_in_docker=hostname_in_docker
fi

if [ -z "$ip_out_docker" ]; then
  export ip_out_docker=127.0.0.1
fi

if [ -z "$ssh_port_out_docker" ]; then
  export ssh_port_out_docker=22
fi

export config_file_frpc=/etc/frp/frpc-docker.ini

if [[ ! -f ${config_file_frpc} ]];then
mkdir -p $(dirname ${config_file_frpc})
cat > ${config_file_frpc} << EOF
[common]
server_addr = ${server_addr}
server_port = ${server_port}
log_file = console
log_level = info
log_max_days = 3
token = ${token}

admin_addr = 127.0.0.1
admin_port = 7400
admin_user = admin
admin_pwd = admin

pool_count = 5
tcp_mux = true
#user = your_name
login_fail_exit = ${login_fail_exit}
protocol = tcp

[range:sshindocker ${hostname_in_docker} ]
type = tcp
local_ip = 127.0.0.1
local_port = 22
remote_port = 0
use_encryption = true
use_compression = true

[range:sshoutdocker ${hostname_in_docker} ]
type = tcp
local_ip = ${ip_out_docker}
local_port = ${ssh_port_out_docker}
remote_port = 0
use_encryption = false
use_compression = false


[range:ovn-t ${hostname_in_docker} ]
type = tcp
local_ip = open
local_port = 1194
remote_port = 0
use_encryption = false
use_compression = false

[range:ovn-u ${hostname_in_docker} ]
type = udp
local_ip = open
local_port = 1194
remote_port = 0
use_encryption = false
use_compression = false

[range:proxy ${hostname_in_docker} ]
type = tcp
local_ip = squid
local_port = 3128
remote_port = 0
use_encryption = false
use_compression = false
EOF

else
	echo "配置文件已经存在,将直接使用现有配置文件"
fi


#通过环境变量来判断容器是否运行在k8s中,其中open和squid是k8s中的service名称,具体需要编排来定
if [[  "$KUBERNETES_SERVICE_HOST" ]];then
	sed -i 's/open/127.0.0.1/g' ${config_file_frpc}
	sed -i 's/squid/127.0.0.1/g' ${config_file_frpc}
fi

/usr/bin/frpc -c ${config_file_frpc} 