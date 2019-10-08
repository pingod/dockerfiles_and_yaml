## This repository holds a docker recipe for the x2go server.


[![Build Status](https://travis-ci.org/spielhuus/docker-x2go.svg?branch=master)](https://travis-ci.org/spielhuus/docker-x2go)
[![GitHub version](https://badge.fury.io/gh/spielhuus%2Fdocker-x2go.svg)](https://hub.docker.com/r/spielhuus/x2go)

[Docker](https://docker.io/) recipe for [x2go](https://wiki.x2go.org/doku.php) project

### Create an image with xterm

```
docker pull spielhuus/x2go
docker run --name xterm -p 2222:22 -itd \
           -e USER={USERNAME} -e PASSWORD={PASS} \
           -v /srv/home:/home/{USER} \
           spielhuus/x2go
sudo docker exec xterm apt-get update -y && apt-get upgrade -y
sudo docker exec xterm apt-get install -y xterm

```

### Configure the client

Download the x2go client for your OS from:
http://wiki.x2go.org/doku.php/doc:installation:x2goclient

Connect to your server with docker hosts's IP , port : 2222 , username : {USERNAME} ,{PASS} : ( look at docker logs for container)

Select the session type as : xterm

### Create a new container

Create a new Dockerfile and add applications.

```
FROM spielhuus/x2go

# install packages
RUN apt-get update -y && apt-get upgrade -y && \
    apt-get install -y xfce4 epiphany
```

Change to xfce session startup in the client.


### Credits:

* https://github.com/paimpozhil/DockerX2go
* https://docker.io
* https://wiki.x2go.org/doku.php


### License 

[Boost Software License](http://www.boost.org/LICENSE_1_0.txt) - Version 1.0 - August 17th, 2003


