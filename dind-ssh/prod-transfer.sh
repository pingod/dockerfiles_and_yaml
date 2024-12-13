#!/bin/sh

projectname=$1
filename="${projectname}.json"

username=team0
password=root@123

ip=192.168.4.149
testgroup=his-application-test
prodgroup=his-application-pro

rm -rf $filename

echo '------busybox wget-----------------'
echo "busybox wget -O$filename http://$username:$password@$ip/api/repositories/$testgroup/$projectname/tags?detail=1"
busybox wget -O$filename http://$username:$password@$ip/api/repositories/$testgroup/$projectname/tags?detail=1
tags=`cat $filename | grep name | awk -F"\"" 'NR==1 {print $4}'`
echo $tags

echo '------docker pull-----------------'
echo "docker pull $ip/$testgroup/$projectname:$tags"
docker pull $ip/$testgroup/$projectname:$tags

echo '------docker tag-----------------'
echo "docker tag $ip/$testgroup/$projectname:$tags $ip/$prodgroup/$projectname:$tags"
docker tag $ip/$testgroup/$projectname:$tags $ip/$prodgroup/$projectname:$tags

echo '------docker push -----------------'
echo "docker push $ip/$prodgroup/$projectname:$tags"
docker push $ip/$prodgroup/$projectname:$tags


echo '------docker delete -----------------'
docker rmi $ip/$testgroup/$projectname:$tags   
docker rmi $ip/$prodgroup/$projectname:$tags

echo '-------------END---------------'

