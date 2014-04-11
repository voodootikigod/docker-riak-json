# docker-riak-json

A [Docker](http://docker.io) image for Riak 2.0pre20 running the
[riak-json](https://github.com/basho-labs/riak_json) addon, which makes Riak
act like a JSON data store (using [Apache Solr](https://lucene.apache.org/solr/)
to query the documents).

## Prerequisites

Follow the [instructions on Docker's website](https://www.docker.io/gettingstarted/#h_installation)
to install Docker.

From there, ensure that your `DOCKER_HOST` environmental variable is set
correctly:

```bash
$ export DOCKER_HOST="tcp://127.0.0.1:4243"
```

**Note:** If you're using [boot2docker](https://github.com/boot2docker/boot2docker)
ensure that you forward the virtual machine port range (`49000-49900`). This
will allow you to interact with the containers as if they were running
locally:

```bash
$ for i in {49000..49900}; do
 VBoxManage modifyvm "boot2docker-vm" --natpf1 "tcp-port$i,tcp,,$i,,$i";
 VBoxManage modifyvm "boot2docker-vm" --natpf1 "udp-port$i,udp,,$i,,$i";
done
```

## Running

This will expose the Protocol Buffers and HTTP interfaces for Riak JSON:

```bash
$ docker pull voodootikigod/riak-json
$ CONTAINER_ID=$(docker run -P --name "riak_json" -d voodootikigod/riak-json)
```

## Testing (HTTP interface)

Add an item to the `demo_collection`:

```bash
$ curl -s -i -XPUT -H 'Content-Type: application/json' \
     "http://localhost:$(docker port $CONTAINER_ID 8098 | cut -d":" -f2)/document/collection/demo_collection/casey" \
     -d '{"name": "Casey", "metric": 9000}'
HTTP/1.1 204 No Content
Server: MochiWeb/1.1 WebMachine/1.10.5 (jokes are better explained)
Date: Fri, 11 Apr 2014 15:31:48 GMT
Content-Type: application/json
Content-Length: 0
```

And now query for that document:

```bash
$ curl -s -XPUT -H 'Content-Type: application/json' -H 'Accept: application/json' \
     "http://localhost:$(docker port $CONTAINER_ID 8098 | cut -d":" -f2)/document/collection/demo_collection/query/one" \
     -d '{"name": {"$regex": "/C.*/"}}' | python -mjson.tool
{
    "_id": "casey",
    "metric": 9000,
    "name": "Casey"
}
```

## Connecting via SSH

The [phusion/baseimage-docker](https://github.com/phusion/baseimage-docker)
image has the ability to enable an __insecure__ key for conveniently logging
into a container via SSH. It is enabled in the `Dockerfile` by default here:

```docker
RUN /usr/sbin/enable_insecure_key
```

In order to login to the container via SSH using the __insecure__ key, follow
the steps below.

Use `docker inspect` to determine the container IP address:

```bash
$ docker inspect $CONTAINER_ID | grep IPAddress
        "IPAddress": "172.17.0.2",
```

Download the insecure key, alter its permissions, and use it to SSH into the
container via its IP address:

```bash
$ curl -o insecure_key -fSL https://github.com/phusion/baseimage-docker/raw/master/image/insecure_key
$ chmod 600 insecure_key
$ ssh -i insecure_key root@172.17.0.2
```

**Note:** If you're using
[boot2docker](https://github.com/boot2docker/boot2docker), ensure that you're
issuing the SSH command from within the virtual machine running `boot2docker`.
