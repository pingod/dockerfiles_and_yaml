# README

基础镜像为docker in docker 

用于制作awscli v1 和 v2 版本的镜像

附带安装kubectl命令行工具


## 镜像说明

- aws-v2 + kubectl-v1.21.0 + dind :

#参考: https://stackoverflow.com/questions/60298619/awscli-version-2-on-alpine-linux

  registry.cn-hangzhou.aliyuncs.com/sourcegarden/aws2720:20-dind

- aws-v1 + kubectl-v1.21.0 + dind :

  registry.cn-hangzhou.aliyuncs.com/sourcegarden/aws1-docker:20-dind
