# 关于N2N

[n2n][n2n] 是一个 **第二层对等 VPN**，可轻松创建绕过中间防火墙的虚拟网络。

通过编译 [ntop 团队][ntop] 发布的n2n,直连成功率高(仅局域网内不及), 且速度更快.

N2N 是通过UDP方式建立链接，如果某个网络禁用了 UDP，那么该网络下的设备就不适合使用本软件来加入这个虚拟局域网（用"blue's port scanner"，选择UDP来扫描，扫出来的就是未被封的，正常情况下应该超级多）

为了开始使用N2N，需要两个元素：

1. *supernode* ：
它允许edge节点链接和发现其他edge的超级节点。
它必须具有可在公网上公开端口。

2. *edge* ：将成为虚拟网络一部分的节点;
在n2n中的多个边缘节点之间共享的虚拟网络称为community。

单个supernode节点可以中继多个edge，而单个电脑可以同时连接多个supernode。
边缘节点可以使用加密密钥对社区中的数据包进行加密。
n2n尽可能在edge节点之间建立直接的P2P连接;如果不可能（通常是由于特殊的NAT设备），则超级节点也用于中继数据包。

### 组网示意

![组网示意][组网示意]

### 连接原理

![连接原理][连接原理]

## 快速入门

#指定supernode允许分配的IP地址范围
docker run --name supernode01v3 --restart=always -it -d -p 10087:10087/udp registry.cn-hangzhou.aliyuncs.com/sourcegarden/n2n:v3 \
supernode -p 10087 \
-a 10.0.20.0-10.0.25.0/24 -F myn2nv3 -f


#supernode也可以不指定分配的IP范围
docker run  --name supernode01v3 --restart=always -it -d -p 10087:10087/udp  registry.cn-hangzhou.aliyuncs.com/sourcegarden/n2n:v3 \
supernode -p 10087 \
 -F myn2nv3 -f



#edge 自动从supernode允许分配的IP范围中获取IP地址
docker run --name edge01v3 --restart=always -it -d --privileged --net=host registry.cn-hangzhou.aliyuncs.com/sourcegarden/n2n:v3 \
edge -l 1xx2:10087 \
-c mxxxxxxy_v3 \
-k mxxxxxxxy \
-A2 \
-a DHCP:0.0.0.0 \
-d edge01v3 \
-r \
-e auto -f



#edge 自动从supernode允许分配的IP范围中获取IP地址
docker run  --name edge01v3 --restart=always -it -d --privileged --net=host registry.cn-hangzhou.aliyuncs.com/sourcegarden/n2n:v3 \
edge -l xxxxx2:10087 \
-c xxxxxx \
-k xxxxxx \
-A2 \
-a 10.0.20.20 \
-d edge01v3 \
-r \
-e auto -f

更多帮助请参考 [好运博客][好运博客] 中 [N2N 新手向导及最新信息][N2N 新手向导及最新信息]

更多节点请访问 [N2N中心节点][N2N中心节点]

## 使用 *docker-compose* 配置运行

```bash
git clone -b Beta https://github.com/zctmdc/docker.git
# docker-compose build #编译

#启动 n2n_edge_dhcp
cd n2n_ntop
# docker-compose up n2n_edge_dhcp #前台运行 n2n_edge_dhcp
# docker-compose up -d n2n_edge_dhcp #后台运行
```

更多介绍请访问 [docker-compose CLI概述][Overview of docker-compose CLI]



[n2n]: https://web.archive.org/web/20110924083045/http://www.ntop.org:80/products/n2n/ "n2n官网"
[ntop]: https://github.com/ntop "ntop团队"
[组网示意]: https://web.archive.org/web/20110924083045im_/http://www.ntop.org/wp-content/uploads/2011/08/n2n_network.png "组网示意"
[连接原理]: https://web.archive.org/web/20110924083045im_/http://www.ntop.org/wp-content/uploads/2011/08/n2n_com.png "连接原理"
[好运博客]: http://www.lucktu.com "好运博客"
[N2N 新手向导及最新信息]: http://www.lucktu.com/archives/783.html "N2N 新手向导及最新信息（2019-12-05 更新）"
[N2N中心节点]: http://supernode.ml/ "N2N中心节点"

[zctmdc—docker]: https://hub.docker.com/u/zctmdc "我的docker主页"
[zctmdc—github]: https://github.com/zctmdc/docker.git "我github的docker项目页"
[n2n_ntop]: https://hub.docker.com/r/zctmdc/n2n_ntop "n2n_ntop的docker项目页"
[n2n_proxy]: https://hub.docker.com/r/zctmdc/n2n_proxy "n2n_proxy的docker项目页"
[Overview of docker-compose CLI]: https://docs.docker.com/compose/reference/overview/ "docker-compose CLI概述"
