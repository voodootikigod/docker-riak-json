# Riak-JSON
#
# VERSION       0.1.0

FROM phusion/baseimage:0.9.9
MAINTAINER Chris Williams voodootikigod@gmail.com

# Environmental variables
ENV DEBIAN_FRONTEND noninteractive
ENV ERLANG_VERSION 16.b.3-1
ENV RIAK_VERSION 2.0.0pre20
ENV RIAK_JSON_VERSION 0.0.3-1

# Install dependencies
RUN sed -i.bak 's/main$/main universe/' /etc/apt/sources.list
RUN apt-get update && apt-get install -y \
      software-properties-common \
      python-software-properties \
      libwxbase2.8-0 \
      libwxgtk2.8-0 \
      libpam0g-dev

# Install Java 7
RUN apt-add-repository ppa:webupd8team/java -y && apt-get update && \
      echo oracle-java7-installer shared/accepted-oracle-license-v1-1 select true | /usr/bin/debconf-set-selections && \
      apt-get install -y oracle-java7-installer -y

# Install Erlang
ADD http://packages.erlang-solutions.com/erlang/esl-erlang/FLAVOUR_1_general/esl-erlang_${ERLANG_VERSION}~ubuntu~precise_amd64.deb /
RUN (cd / && dpkg -i "esl-erlang_${ERLANG_VERSION}~ubuntu~precise_amd64.deb")

# Install Riak JSON
ADD http://ps-tools.data.riakcs.net:8080/riak_${RIAK_VERSION}-riak_json-${RIAK_JSON_VERSION}_amd64.deb /
RUN (cd / && dpkg -i "riak_${RIAK_VERSION}-riak_json-${RIAK_JSON_VERSION}_amd64.deb")

# Setup the Riak JSON service
RUN mkdir -p /etc/service/riak_json
ADD bin/riak_json.sh /etc/service/riak_json/run

RUN sed -i -e 0,/"enabled, false"/{s/"enabled, false"/"enabled, true"/} /etc/riak/riak.conf && \
    sed -i.bak 's/search = off/search = on/' /etc/riak/riak.conf && \
    sed -i.bak 's/127.0.0.1:8098/0.0.0.0:8098/' /etc/riak/riak.conf && \
    sed -i.bak 's/127.0.0.1:8087/0.0.0.0:8087/' /etc/riak/riak.conf

# sysctl
RUN echo "vm.swappiness = 0" > /etc/sysctl.d/riak.conf && \
    echo "net.ipv4.tcp_max_syn_backlog = 40000" >> /etc/sysctl.d/riak.conf && \
    echo "net.core.somaxconn = 40000" >> /etc/sysctl.d/riak.conf && \
    echo "net.ipv4.tcp_sack = 1" >> /etc/sysctl.d/riak.conf && \
    echo "net.ipv4.tcp_window_scaling = 1" >> /etc/sysctl.d/riak.conf && \
    echo "net.ipv4.tcp_fin_timeout = 15" >> /etc/sysctl.d/riak.conf && \
    echo "net.ipv4.tcp_keepalive_intvl = 30" >> /etc/sysctl.d/riak.conf && \
    echo "net.ipv4.tcp_tw_reuse = 1" >> /etc/sysctl.d/riak.conf && \
    echo "net.ipv4.tcp_moderate_rcvbuf = 1" >> /etc/sysctl.d/riak.conf && \
    sysctl -e -p /etc/sysctl.d/riak.conf

# Make Riak's data and log directories volumes
VOLUME /var/lib/riak
VOLUME /var/log/riak

# Open ports for HTTP and Protocol Buffers
EXPOSE 8098 8087

# Enable insecure SSH key
# See: https://github.com/phusion/baseimage-docker#using_the_insecure_key_for_one_container_only
RUN /usr/sbin/enable_insecure_key

# Cleanup
RUN rm "/esl-erlang_${ERLANG_VERSION}~ubuntu~precise_amd64.deb" \
       "/riak_${RIAK_VERSION}-riak_json-${RIAK_JSON_VERSION}_amd64.deb"
RUN apt-get clean && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

# Leverage the baseimage-docker init system
CMD ["/sbin/my_init", "--quiet"]
