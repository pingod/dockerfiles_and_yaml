From https://github.com/BinkyWong/alpine-x2go

Based on https://github.com/yangxuan8282/docker-image

very very much alpha!!!

What you get:
* Minimal Alpine Linux base
* Xfce desktop
* Chomium, Firefox and Midori browser
* x2goserver running over SSH
* Intellij IDEA IDE 

To build:

`docker build -t alpine-desktop .`

To run:

docker run -d -p 6080:6080 -p 2222:22 -p 5900:5900 alpine-desktop


