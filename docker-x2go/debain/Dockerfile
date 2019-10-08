FROM debian:buster

ENV DEBIAN_FRONTEND noninteractive

RUN apt-get update && apt-get upgrade -y && apt-get install -y gnupg
RUN apt-key adv --recv-keys --keyserver keys.gnupg.net E1F958385BFE2B6E
RUN echo "deb http://packages.x2go.org/debian stretch extras main\n\
deb-src http://packages.x2go.org/debian stretch extras main" \
> /etc/apt/sources.list.d/x2go.list

RUN apt-get update && apt-get install -y less locales sudo zsh x2goserver

RUN sed -i 's/# de_CH.UTF-8 UTF-8/de_CH.UTF-8 UTF-8/' /etc/locale.gen && \
    sed -i 's/# en_US.UTF-8 UTF-8/en_US.UTF-8 UTF-8/' /etc/locale.gen && \
    ln -fs /etc/locale.alias /usr/share/locale/locale.alias && \
    locale-gen && update-locale LANG=en_US.UTF-8
RUN cp /usr/share/zoneinfo/Europe/Zurich /etc/localtime && \
    echo "Europe/Zurich" >  /etc/timezone

# configure system
RUN sed -i 's/^#X11Forwarding.*/X11Forwarding yes/' /etc/ssh/sshd_config && \
    sed -i "s/Port 22/#Port 22/g" /etc/ssh/sshd_config && \
    echo "Port 2222" >> /etc/ssh/sshd_config && \
    x2godbadmin --createdb

RUN mkdir -p /var/run/sshd
COPY container_init.sh /container_init.sh
COPY run.sh /run.sh
RUN chmod +x /*.sh

EXPOSE 2222
CMD ["/run.sh"]
