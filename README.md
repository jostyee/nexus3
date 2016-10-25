# Nexus3
API configurable and extensible general purpose software repository.

## Getting started
Please define a password starting the repository as shown below. The accroding username is `admin`.
```
docker run -d -p 8081:8081 -p 5000:5000 -e NEXUS_PASSWORD=changeme serverking/nexus3
``` 
## Docker Registry
The docker capability is an add-on for Nexus3. Please set the docker registry using the variables `DOCKER_REPOSITORY_NAME` and `DOCKER_REPOSITORY_PORT`.

### Docker compose 
For your convenience use docker compose to start nexus as shown below:

```
 nexus:
    image: serverking/nexus3
    network_mode: "bridge"
    env_file: .env
    environment:
      - VIRTUAL_HOST=nexus.${DOMAIN}
      - VIRTUAL_HTTP_PORT=8081
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

