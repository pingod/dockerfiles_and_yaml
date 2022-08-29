摘要：
1.数据库集群基于debian系统部署，使用的mysql5.7版本
2.持久化存储采用nfs方式
3.采用1主1从方式部署mysql集群
4.未配置命名空间，可自行添加

部署：

a.生成docker镜像
1.进入master目录，执行docker build -t mysql57:master .
2.进入client目录，执行docker build -t mysql57.slave .

docker镜像名和tag必须跟statefulset.yaml文件内的image内容相同

b.部署到k8s集群中
1.生成service资源对象，执行kubectl apply -f service.yaml
2.生成statefulset资源对象，执行kubectl apply -f statefulset.yaml

必须优先生成service资源对象，从数据库通过访问主服务器service地址和端口进行数据同步，statefulset.yaml内含数据库相关账号密码