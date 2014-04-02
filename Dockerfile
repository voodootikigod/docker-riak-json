# Riak-JSON
#
# VERSION       0.1.0


# Use the Ubuntu base image with LTS
FROM ubuntu:12.04
MAINTAINER Chris Williams voodootikigod@gmail.com



# Update the APT cache
RUN sed -i.bak 's/main$/main universe/' /etc/apt/sources.list
RUN apt-get update
# RUN DEBIAN_FRONTEND=noninteractive apt-get upgrade -qqy

# Install and setup project dependencies
RUN apt-get install -qqy curl lsb-release supervisor libssl-dev openssh-server  build-essential

RUN mkdir -p /var/run/sshd
RUN mkdir -p /var/log/supervisor

RUN locale-gen en_US en_US.UTF-8


RUN apt-get install -qqy git

# Install Java 7

RUN DEBIAN_FRONTEND=noninteractive apt-get install -q -y software-properties-common
RUN DEBIAN_FRONTEND=noninteractive apt-get install -q -y python-software-properties
RUN DEBIAN_FRONTEND=noninteractive apt-add-repository ppa:webupd8team/java -y
RUN apt-get update
RUN echo oracle-java7-installer shared/accepted-oracle-license-v1-1 select true | /usr/bin/debconf-set-selections
RUN DEBIAN_FRONTEND=noninteractive apt-get install oracle-java7-installer -y

#FML


# Install Erlangs

RUN apt-get install -qqy libwxbase2.8-0
RUN apt-get install -qqy libwxgtk2.8-0

RUN apt-get install -qqy logrotate
RUN wget http://packages.erlang-solutions.com/erlang/esl-erlang/FLAVOUR_1_general/esl-erlang_16.b.3-1~ubuntu~precise_amd64.deb
RUN dpkg -i esl-erlang_16.b.3-1~ubuntu~precise_amd64.deb
RUN apt-get install -qqy libpam0g-dev


RUN echo 'root:basho' | chpasswd


RUN wget http://ps-tools.data.riakcs.net:8080/riak_2.0.0pre20-riak_json-0.0.3-1_amd64.deb
RUN dpkg -i riak_2.0.0pre20-riak_json-0.0.3-1_amd64.deb








RUN sed -i -e 0,/"enabled, false"/{s/"enabled, false"/"enabled, true"/} /etc/riak/riak.conf
RUN sed -i.bak 's/search = off/search = on/' /etc/riak/riak.conf
RUN sed -i.bak 's/127.0.0.1/0.0.0.0/' /etc/riak/riak.conf
RUN echo "ulimit -n 9000" >> /etc/default/riak


ADD ./etc/supervisord.conf /etc/supervisor/conf.d/supervisord.conf



RUN echo 'root:basho' | chpasswd





RUN apt-get install -qqy iputils-ping

# Hack for initctl
# See: https://github.com/dotcloud/docker/issues/1024
RUN dpkg-divert --local --rename --add /sbin/initctl
RUN mv /sbin/initctl /sbin/initctl.bk
RUN ln -s /bin/true /sbin/initctl


# Expose Riak Protocol Buffers and HTTP interfaces, along with SSH
EXPOSE 8087 8098 22

RUN echo " *               soft     nofile          65536" >> /etc/security/limits.conf
RUN echo " *               hard     nofile          65536" >> /etc/security/limits.conf
RUN echo " root            soft     nofile          65536" >> /etc/security/limits.conf
RUN echo " root            hard     nofile          65536" >> /etc/security/limits.conf



CMD ["/usr/bin/supervisord"]
