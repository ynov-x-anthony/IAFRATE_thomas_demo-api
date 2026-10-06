# Quête 02 - Le Dockerfile

## Liens

### Repository GitHub

https://github.com/ynov-x-anthony/IAFRATE_thomas_demo-api

### Image Docker Hub

https://hub.docker.com/repository/docker/thomas040/demo-api/general

## Sortie de `docker image ls demo-api`

``` powershell
PS C:\Users\thoma\OneDrive\Documents\Github Repositories\IAFRATE_thomas_demo-api> docker image ls demo-api
REPOSITORY   TAG       IMAGE ID       CREATED          SIZE
demo-api     1.0       9a714a4854d5   12 minutes ago   252MB
```

## Preuve du cache Docker

Après modification d'un commentaire dans `server.js`, l'image a été
reconstruite avec `--progress=plain`.

``` powershell
PS C:\Users\thoma\OneDrive\Documents\Github Repositories\IAFRATE_thomas_demo-api> docker build -t demo-api:1.0 ./api --progress=plain
#0 building with "desktop-linux" instance using docker driver

#1 [internal] load build definition from Dockerfile
#1 transferring dockerfile: 212B 0.0s done
#1 DONE 0.0s

#2 [internal] load metadata for docker.io/library/node:22-alpine
#2 DONE 0.8s

#3 [internal] load .dockerignore
#3 transferring context: 78B done
#3 DONE 0.0s

#4 [internal] load build context
#4 transferring context: 3.09kB done
#4 DONE 0.0s

#5 [1/5] FROM docker.io/library/node:22-alpine@sha256:0a7108bf6c7bf5de370ffb1a3ed6be93d405b43ff159f681a8d18c0e2bc2e402
#5 resolve docker.io/library/node:22-alpine@sha256:0a7108bf6c7bf5de370ffb1a3ed6be93d405b43ff159f681a8d18c0e2bc2e402 0.1s done
#5 DONE 0.1s

#6 [2/5] WORKDIR /app
#6 CACHED

#7 [3/5] COPY package.json package-lock.json ./
#7 CACHED

#8 [4/5] RUN npm ci --omit=dev
#8 CACHED

#9 [5/5] COPY server.js db.js ./
#9 DONE 0.1s

#10 exporting to image
#10 exporting layers 0.1s done
#10 exporting manifest sha256:2b31d25b8a5862322fd698651555b597011c21a8f9e3862fdb37b4f85af7f7c2 0.0s done
#10 exporting config sha256:81686f6cfcc402d47d053286ae0e63aff34e2bcd65de218baac6f2904b4c67b8 0.0s done
#10 exporting attestation manifest sha256:79c469a4d5e591c1dcb43ad9a36aa187d7a514f1ea20e2d9ad950980ef293472 0.1s done
#10 exporting manifest list sha256:9a714a4854d5732f5e293e375514e29d7a7a2de0509060a5b81de6c533cdbef3
#10 exporting manifest list sha256:9a714a4854d5732f5e293e375514e29d7a7a2de0509060a5b81de6c533cdbef3 0.0s done
#10 naming to docker.io/library/demo-api:1.0 done
#10 unpacking to docker.io/library/demo-api:1.0 0.1s done
#10 DONE 0.4s
```

L'étape suivante confirme que l'installation des dépendances est bien
réutilisée depuis le cache :

``` text
#8 [4/5] RUN npm ci --omit=dev
#8 CACHED
```
