# Nexus3
Ready to go API configurable and extensible general purpose repository.

## Docker Registry
A docker repository is not configured from scratch. To do so set the environment variables `DOCKER_REPOSITORY_NAME` and `DOCKER_REPOSITORY_PORT`.

## Getting started
Please define your password, it will be changed on startup. The according default username is `admin`. Please refer to the official [API Docs](https://books.sonatype.com/nexus-book/reference3/scripting.html) Basically you can extend the API script located on `/usr/local/bin/postconfig.sh` up to your requirements.

```
docker run -d -p 8081:8081 -p 5000:5000 \
    -e DOCKER_REPOSITORY_NAME=default \
    -e DOCKER_REPOSITORY_PORT=5000 \
    -e NEXUS_DEFAULT_PASSWORD=admin123 \
    -e NEXUS_PASSWORD=changeme 
    -v /tmp/vogel:/nexus-data 
    --name nexus3 serverking/nexus3
``` 

### Docker compose 
For your convenience use docker compose to start nexus as shown below:

```
 nexus:
    image: serverking/nexus3
    environment:
      - DOCKER_REPOSITORY_NAME=default
      - DOCKER_REPOSITORY_PORT=5000
      - NEXUS_DEFAULT_PASSWORD=admin123
      - NEXUS_PASSWORD=changeme
    ports:
      - 5000:5000
      - 8081:8081
    volumes:
      - /data/nexus:/nexus-data
    restart: always
```

### Push Docker images to registry

Login to the registry:
```
Docker logs localhost:5000
```
Login to your local registry eg. nexus:
```
docker login localhost:5000
```
Get any image from the hub and tag it to point to your registry:
```
docker pull busybox  && docker tag busybox localhost:5000/default/busybox
```
...then push it to your registry:
```
docker push localhost:5000/default/busybox
```
...then pull it back from your registry:
```
docker pull localhost:5000/default/busybox
```

## Contribute
If you want to further customize this image, please feel free to contribute.
