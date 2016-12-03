# Nexus3
API configurable and extensible general purpose software repository.

## Getting started
Please define a password starting the repository as shown below. The according username is `admin`. Please refer to the official [API Docs](https://books.sonatype.com/nexus-book/reference3/scripting.html)
```
docker run -d -p 8081:8081 -p 5000:5000 -e NEXUS_PASSWORD=changeme --name nexus3 nexus3
``` 
## Docker Registry
The docker capability is an add-on for Nexus3. Please set the docker registry using the variables `DOCKER_REPOSITORY_NAME` and `DOCKER_REPOSITORY_PORT`.

### Docker compose 
For your convenience use docker compose to start nexus as shown below:

```
 nexus:
    build: nexus3/.
    depends_on:
      - sni-router
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

## Versioning
Versioning is an issue when deploying the latest release. For this purpose an additional label will be provided during build time. 
The Dockerfile must be extended with an according label argument as shown below:
```
ARG TAG
LABEL TAG=${TAG}
```
Arguments must be passed to the build process using `--build-arg TAG="${TAG}"`.

## Reporting
```
docker inspect --format \
&quot;{{ index .Config.Labels \&quot;com.docker.compose.project\&quot;}},\
 {{ index .Config.Labels \&quot;com.docker.compose.service\&quot;}},\
 {{ index .Config.Labels \&quot;TAG\&quot;}},\
 {{ index .State.Status }},\
 {{ printf \&quot;%.16s\&quot; .Created }},\
 {{ printf \&quot;%.16s\&quot; .State.StartedAt }},\
 {{ index .RestartCount }}&quot; $(docker ps -f name=${STAGE} -q) &gt;&gt; reports/${SHORTNAME}.report
```

