# README

基础镜像为docker in docker 

用于制作awscli v1 和 v2 版本的镜像

附带安装kubectl命令行工具


## 镜像说明

- awsv2 + kubectl + dind :

  #参考: https://stackoverflow.com/questions/60298619/awscli-version-2-on-alpine-linux

  registry.cn-hangzhou.aliyuncs.com/sourcegarden/aws2720:20-dind

- awsv1 + kubectl + dind :

  registry.cn-hangzhou.aliyuncs.com/sourcegarden/aws1-docker:20-dind

- awscliv2 + kubectl + k9s + helm +dind :

  registry.cn-hangzhou.aliyuncs.com/sourcegarden/aws2810:20-dind
