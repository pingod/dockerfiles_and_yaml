FROM centos:7.5.1804

MAINTAINER pingod

ENV COBBLER_VERSION 2.8.3

RUN yum -y install wget  epel-release && \
wget -O /etc/yum.repos.d/cobbler28.repo http://download.opensuse.org/repositories/home:/libertas-ict:/cobbler28/CentOS_7/home:libertas-ict:cobbler28.repo && \
yum -y install cobbler tftp-server dhcp openssl cobbler-web supervisor && \
yum -y update && \
rm -rf /var/cache/yum

ADD supervisord.d/conf.ini /etc/supervisord.d/conf.ini
ADD start.sh /start.sh
RUN chmod +x /start.sh

ADD centos7-dvd.cfg /var/lib/cobbler/kickstarts/centos7-dvd.cfg
ADD centos7-mini.cfg /var/lib/cobbler/kickstarts/centos7-mini.cfg

CMD ["/start.sh"]
