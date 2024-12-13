## Run a single Maven command

docker run -it --rm --name my-maven-project -v "$(pwd)":/usr/src/mymaven -w /usr/src/mymaven daocloud.io/djyesu/docker-maven-aliyun:jdk-8 mvn clean install