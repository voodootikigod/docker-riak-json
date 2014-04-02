# Docker: riak-json

A [docker](http://docker) image for Riak 2.0 pre 20 running the [riak-json](https://github.com/basho-labs/riak_json) which makes Riak act like a JSON data store with using SOLR to query the JSON documents.

I recommend starting this using the following manner (assuming Docker is [installed](https://www.docker.io/gettingstarted/#h_installation) already).

```
docker pull voodootikigod/riak-json
CONTAINER_ID = $(docker run -p 8087:8087 -p 8098:8098 -d -t voodootikigod/riak-json)
```

This will expose the protocol buffers and HTTP interface for the Riak JSON interface.
