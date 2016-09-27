# Nexus3
Ready to go docker registry listening on port 5000 preconfigured with a default docker repository.

## Starting
```
docker build -t nexus3 .
docker run -d -p 8081:8081 -p 5000:5000 --name nexus3 nexus3
``` 

## Default User
```
Username: admin
Password: admin
```

## Docker Registry
The docker capability is an add-on for Nexus3. This image comes preconfigured with a docker repository named default. If you want to create more repositories, export /nexus-data/db and add it back to the image filesystem src/ directory.

## Test the docker registry
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

## Contribute
If you want to further customize this image, please feel free to contribute.
