# Based from the good work from https://github.com/yangxuan8282/docker-image

FROM alpine

COPY config /etc/skel/.config

RUN echo "http://dl-cdn.alpinelinux.org/alpine/edge/main" > /etc/apk/repositories && \
    echo "http://dl-cdn.alpinelinux.org/alpine/edge/community" >> /etc/apk/repositories && \
    echo "http://dl-cdn.alpinelinux.org/alpine/edge/testing" >> /etc/apk/repositories && \
    sed -i 's/dl-cdn.alpinelinux.org/mirrors.aliyun.com/g' /etc/apk/repositories


RUN apk update && \
    apk upgrade && \
    apk --update --no-cache add xvfb x11vnc xfce4 xfce4-terminal paper-icon-theme arc-theme chromium python bash sudo htop procps curl openssh x2goserver git openjdk8 libressl x11vnc vim firefox midori xterm

RUN mkdir -p /usr/share/wallpapers \
  #&& curl http://getwallpapers.com/wallpaper/full/d/5/0/62105.jpg -o /usr/share/wallpapers/android-5-0-lollipop-material-5355.jpg \
  && echo "CHROMIUM_FLAGS=\"--no-sandbox --no-first-run --disable-gpu\"" >> /etc/chromium/chromium.conf \
  && addgroup alpine \
  && adduser -G alpine -s /bin/bash -D alpine \
  && echo "alpine:alpine" | /usr/sbin/chpasswd \
  && echo "alpine ALL=NOPASSWD: ALL" >> /etc/sudoers

USER alpine

ENV USER=alpine \
    DISPLAY=:1 \
    LANG=en_GB.UTF-8 \
    LANGUAGE=en_GB.UTF-8 \
    HOME=/home/alpine \
    TERM=xterm \
    SHELL=/bin/bash \
    VNC_PASSWD=alpinelinux \
    VNC_PORT=5900 \
    VNC_RESOLUTION=1024x768 \
    VNC_COL_DEPTH=24  \
    SSH_PORT=22 \
    NOVNC_PORT=6080 \
    NOVNC_HOME=/home/alpine/noVNC 

RUN set -xe \
  && sudo apk update \
  && sudo apk add ca-certificates wget \
  && sudo update-ca-certificates \
  && mkdir -p $NOVNC_HOME/utils/websockify \
  && wget -qO- https://github.com/novnc/noVNC/archive/v1.0.0.tar.gz | tar xz --strip 1 -C $NOVNC_HOME \
  && wget -qO- https://github.com/novnc/websockify/archive/v0.8.0.tar.gz | tar xzf - --strip 1 -C $NOVNC_HOME/utils/websockify \
  && chmod +x -v $NOVNC_HOME/utils/*.sh \
  && ln -s $NOVNC_HOME/vnc_auto.html $NOVNC_HOME/index.html 

RUN sudo bash -c 'echo "X11Forwarding yes" >> /etc/ssh/sshd_config' && \
    sudo bash -c 'echo "X11UseLocalhost no" >> /etc/ssh/sshd_config' && \
    sudo ssh-keygen -A 
    
WORKDIR $HOME

#RUN set -xe && \
#    mkdir $HOME/idea  && \
#    wget -qO- https://download.jetbrains.com/idea/ideaIU-2018.1.5.tar.gz | tar zx --strip 1 -C $HOME/idea

EXPOSE $VNC_PORT $NOVNC_PORT $SSH_PORT

COPY run_novnc /usr/bin/

COPY desktop.jpg  /usr/share/wallpapers/android-5-0-lollipop-material-5355.jpg

CMD ["run_novnc"]
