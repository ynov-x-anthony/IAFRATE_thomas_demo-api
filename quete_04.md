# Quête 04 — Docker Builds multi-étapes et gestion des secrets

## 1. Dépôt GitHub

- **Repository :** https://github.com/ynov-x-anthony/IAFRATE_thomas_demo-api
- **Dockerfile multi-étapes :** [`api/Dockerfile.multi`](https://github.com/ynov-x-anthony/IAFRATE_thomas_demo-api/blob/main/api/Dockerfile.multi)


## 2. Construction des images


```powershell
PS C:\Users\thoma\OneDrive\Documents\Github Repositories\IAFRATE_thomas_demo-api> docker build -t demo-api:naive ./api
[+] Building 1.8s (11/11) FINISHED                                                                                                                         docker:desktop-linux
 => [internal] load build definition from Dockerfile                                                                                                                       0.0s
 => => transferring dockerfile: 454B                                                                                                                                       0.0s
 => [internal] load metadata for docker.io/library/node:22.11-alpine                                                                                                       1.5s
 => [auth] library/node:pull token for registry-1.docker.io                                                                                                                0.0s
 => [internal] load .dockerignore                                                                                                                                          0.0s
 => => transferring context: 78B                                                                                                                                           0.0s
 => [1/5] FROM docker.io/library/node:22.11-alpine@sha256:b64ced2e7cd0a4816699fe308ce6e8a08ccba463c757c00c14cd372e3d2c763e                                                 0.0s
 => => resolve docker.io/library/node:22.11-alpine@sha256:b64ced2e7cd0a4816699fe308ce6e8a08ccba463c757c00c14cd372e3d2c763e                                                 0.0s
 => [internal] load build context                                                                                                                                          0.0s
 => => transferring context: 126B                                                                                                                                          0.0s
 => CACHED [2/5] WORKDIR /app                                                                                                                                              0.0s
 => CACHED [3/5] COPY --chown=node:node package.json package-lock.json ./                                                                                                  0.0s
 => CACHED [4/5] RUN npm ci --omit=dev                                                                                                                                     0.0s
 => CACHED [5/5] COPY --chown=node:node server.js db.js ./                                                                                                                 0.0s
 => exporting to image                                                                                                                                                     0.1s
 => => exporting layers                                                                                                                                                    0.0s
 => => exporting manifest sha256:2d6f748e51ee0f90bb16fbbf4a2a1c81eee43dca12f72480f58bcce6320dcac0                                                                          0.0s
 => => exporting config sha256:8ab9b3faa7aec3c12b6cefb0bb4377eed6cc0262ba381ef9aa6b0890a2f3f120                                                                            0.0s
 => => exporting attestation manifest sha256:3eacf152b394418089aa151d00f4b6b1a615f02a6c32d43b001ecc10175a745e                                                              0.0s
 => => exporting manifest list sha256:6114fd003b99bdd82f57097c69d634d47197e59a8c6fbfeaeb290faddb16fe20                                                                     0.0s
 => => naming to docker.io/library/demo-api:naive                                                                                                                          0.0s
 => => unpacking to docker.io/library/demo-api:naive                                                                                                                       0.0s
```
```powershell
PS C:\Users\thoma\OneDrive\Documents\Github Repositories\IAFRATE_thomas_demo-api> docker build -f api/Dockerfile.multi -t demo-api:multi ./api
[+] Building 7.0s (14/14) FINISHED                                                                                                                         docker:desktop-linux
 => [internal] load build definition from Dockerfile.multi                                                                                                                 0.0s
 => => transferring dockerfile: 717B                                                                                                                                       0.0s
 => resolve image config for docker-image://docker.io/docker/dockerfile:1                                                                                                  1.6s
 => [auth] docker/dockerfile:pull token for registry-1.docker.io                                                                                                           0.0s
 => docker-image://docker.io/docker/dockerfile:1@sha256:4edf897a3ffa55b89f906fc8cc78afdb3f1834cc9c7083565e611a8a7d5fe99e                                                   0.9s
 => => resolve docker.io/docker/dockerfile:1@sha256:4edf897a3ffa55b89f906fc8cc78afdb3f1834cc9c7083565e611a8a7d5fe99e                                                       0.0s
 => => sha256:9d2b4f57f9e20f33279375ce25c6ff14f30f64270ed5c7b613b2b30256754f62 14.28MB / 14.28MB                                                                           0.7s
 => => extracting sha256:9d2b4f57f9e20f33279375ce25c6ff14f30f64270ed5c7b613b2b30256754f62                                                                                  0.1s
 => [internal] load metadata for docker.io/library/node:22.11-alpine                                                                                                       0.2s
 => [internal] load .dockerignore                                                                                                                                          0.0s
 => => transferring context: 78B                                                                                                                                           0.0s
 => [internal] load build context                                                                                                                                          0.0s
 => => transferring context: 126B                                                                                                                                          0.0s
 => [deps 1/4] FROM docker.io/library/node:22.11-alpine@sha256:b64ced2e7cd0a4816699fe308ce6e8a08ccba463c757c00c14cd372e3d2c763e                                            0.0s
 => => resolve docker.io/library/node:22.11-alpine@sha256:b64ced2e7cd0a4816699fe308ce6e8a08ccba463c757c00c14cd372e3d2c763e                                                 0.0s
 => CACHED [deps 2/4] WORKDIR /app                                                                                                                                         0.0s
 => [deps 3/4] COPY package.json package-lock.json ./                                                                                                                      0.0s
 => [deps 4/4] RUN npm ci --omit=dev                                                                                                                                       2.8s
 => [runtime 3/4] COPY --from=deps --chown=node:node /app/node_modules ./node_modules                                                                                      0.2s
 => [runtime 4/4] COPY --chown=node:node server.js db.js package.json ./                                                                                                   0.1s
 => exporting to image                                                                                                                                                     0.6s
 => => exporting layers                                                                                                                                                    0.3s
 => => exporting manifest sha256:856406377b0d5c62125125c3bcf4c6ed467f8dc3de1bea1d634947ff57053065                                                                          0.0s
 => => exporting config sha256:14d8830572e366fddf291ebfbc5a6ae9250ca707ce8ef31f36f05660f7fd7e2b                                                                            0.0s
 => => exporting attestation manifest sha256:1b09aa4decee6851bd083dc03a150349ce5eb6800583c975542cc7847b0e50f2                                                              0.0s
 => => exporting manifest list sha256:aa3ab808cc855290460b4348073f8840f49c7b70b97c27f5baf8f34853a529a1                                                                     0.0s
 => => naming to docker.io/library/demo-api:multi                                                                                                                          0.0s
 => => unpacking to docker.io/library/demo-api:multi                                                                                                                       0.2s
```

```powershell
PS C:\Users\thoma\OneDrive\Documents\Github Repositories\IAFRATE_thomas_demo-api> docker image ls demo-api
REPOSITORY   TAG        IMAGE ID       CREATED          SIZE
demo-api     multi      aa3ab808cc85   10 seconds ago   228MB
demo-api     hardened   bd10f7ec6b17   19 minutes ago   232MB
demo-api     naive      6114fd003b99   19 minutes ago   232MB
demo-api     1.0        9a714a4854d5   42 hours ago     252MB
```


## 3. Simulation d'un secret de build

Un **faux** token `FAKE-123` a été utilisé pour tester la gestion des secrets BuildKit.

Instruction de l'étape `deps` utilisée pour le test :

```dockerfile
RUN --mount=type=secret,id=npmrc,target=/root/.npmrc npm ci --omit=dev
```

Construction avec le secret fourni au build :

```powershell
PS C:\Users\thoma\OneDrive\Documents\Github Repositories\IAFRATE_thomas_demo-api> docker build -f api/Dockerfile.multi --secret "id=npmrc,src=$HOME\.npmrc" -t demo-api:multi ./api
```

### 3.1. Absence du token dans l'historique

Commande :

```powershell
PS C:\Users\thoma\OneDrive\Documents\Github Repositories\IAFRATE_thomas_demo-api> docker history --no-trunc demo-api:multi | Select-String "FAKE-123"
```


### 3.2. Absence du fichier secret dans l'image finale

Premier essai :

```powershell
PS C:\Users\thoma\OneDrive\Documents\Github Repositories\IAFRATE_thomas_demo-api> docker run --rm --user root demo-api:multi sh -c 'cat /root/.npmrc 2>&1'
cat: can't open '/root/.npmrc': No such file or directory
```





## 4. Vérification du fonctionnement de l'API

Lancement :

```powershell
PS C:\Users\thoma\OneDrive\Documents\Github Repositories\IAFRATE_thomas_demo-api> docker run -d --name api-multi -p 8080:3000 --network demo_net -e PGHOST=demo-db demo-api:multi
b6a283f1ec440c83e3897222bc6ac0d4eeb8535edecd8f27f0646110bb799554
```

Test :

```powershell
PS C:\Users\thoma\OneDrive\Documents\Github Repositories\IAFRATE_thomas_demo-api> curl.exe -s http://localhost:8080/health
{"status":"UP"}
```


