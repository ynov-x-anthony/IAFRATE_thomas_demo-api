# Quête 07 : Docker Compose

## 1. Livrables

### `compose.yml`

```bash

services:
  api:
    build: ./api
    environment:
      PGHOST: db
      PGUSER: ${POSTGRES_USER}
      PGPASSWORD: ${POSTGRES_PASSWORD}
      PGDATABASE: ${POSTGRES_DB}
    ports:
      - "${API_PORT:-8080}:3000"
    depends_on:
      db:
        condition: service_healthy
    restart: unless-stopped

  db:
    image: postgres:16-alpine
    environment:
      POSTGRES_USER: ${POSTGRES_USER}
      POSTGRES_PASSWORD: ${POSTGRES_PASSWORD}
      POSTGRES_DB: ${POSTGRES_DB}
    volumes:
      - pgdata:/var/lib/postgresql/data
      - ./db/init.sql:/docker-entrypoint-initdb.d/init.sql:ro
    healthcheck:
      test: ["CMD-SHELL", "pg_isready -U ${POSTGRES_USER} -d ${POSTGRES_DB}"]
      interval: 5s
      timeout: 3s
      retries: 10
    restart: unless-stopped

  adminer:
    image: adminer:4
    ports:
      - "${ADMINER_PORT:-8081}:8080"
    depends_on:
      db:
        condition: service_healthy
    restart: unless-stopped

volumes:
  pgdata:
```

### `.env.example`

```bash
POSTGRES_USER=demo
POSTGRES_PASSWORD=motdepasse
POSTGRES_DB=demo
API_PORT=8080
ADMINER_PORT=8081
```

.

## 2. Vérification de la configuration

Commande :

```bash
thoma@LAPTOP-RTBPB5OG MINGW64 ~/OneDrive/Documents/Github Repositories/IAFRATE_thomas_demo-api (7--Docker---Compose)
$ docker compose config --quiet
```

## 3. Construction et démarrage des services

Commande :

```bash
thoma@LAPTOP-RTBPB5OG MINGW64 ~/OneDrive/Documents/Github Repositories/IAFRATE_thomas_demo-api (7--Docker---Compose)
$ docker compose up -d --build
[+] Running 18/18
 ✔ adminer Pulled                                                                                                                               5.0s 
Compose can now delegate builds to bake for better performance.
 To do so, set COMPOSE_BAKE=true.
[+] Building 1.3s (12/12) FINISHED                                                                                              docker:desktop-linux
 => [api internal] load build definition from Dockerfile                                                                                        0.0s
 => => transferring dockerfile: 454B                                                                                                            0.0s
 => [api internal] load metadata for docker.io/library/node:22.11-alpine                                                                        0.9s
 => [api auth] library/node:pull token for registry-1.docker.io                                                                                 0.0s
 => [api internal] load .dockerignore                                                                                                           0.0s
 => => transferring context: 78B            
 ...
```


## 4. Vérification des conteneurs

Commande :

```bash
thoma@LAPTOP-RTBPB5OG MINGW64 ~/OneDrive/Documents/Github Repositories/IAFRATE_thomas_demo-api (7--Docker---Compose)
$ docker compose ps
NAME                                IMAGE                         COMMAND                  SERVICE   CREATED          STATUS                    PORTS
iafrate_thomas_demo-api-adminer-1   adminer:4                     "entrypoint.sh docke…"   adminer   38 seconds ago   Up 32 seconds             0.0.0.0:8081->8080/tcp
iafrate_thomas_demo-api-api-1       iafrate_thomas_demo-api-api   "docker-entrypoint.s…"   api       38 seconds ago   Up 32 seconds (healthy)   0.0.0.0:8080->3000/tcp
iafrate_thomas_demo-api-db-1        postgres:16-alpine            "docker-entrypoint.s…"   db        38 seconds ago   Up 38 seconds (healthy)   5432/tcp

```

## 5. Vérification de l'API

Commande :

```bash
thoma@LAPTOP-RTBPB5OG MINGW64 ~/OneDrive/Documents/Github Repositories/IAFRATE_thomas_demo-api (7--Docker---Compose)
$ curl -fsS http://localhost:8080/products
[{"id":3,"name":"T-shirt conteneur","price_cents":1990,"created_at":"2026-10-08T09:47:31.129Z"},{"id":2,"name":"Mug Docker","price_cents":990,"created_at":"2026-10-08T09:47:31.129Z"},{"id":1,"name":"Sticker Demo","price_cents":150,"created_at":"2026-10-08T09:47:31.129Z"}]
```

## 6. Ajout d'un produit

Commande :

```bash
thoma@LAPTOP-RTBPB5OG MINGW64 ~/OneDrive/Documents/Github Repositories/IAFRATE_thomas_demo-api (7--Docker---Compose)
$ curl -fsS -X POST \
  -H "Content-Type: application/json" \
  -d '{"name":"Gourde","price_cents":900}' \
  http://localhost:8080/products
{"id":4,"name":"Gourde","price_cents":900,"created_at":"2026-10-08T09:48:23.613Z"}
```

```bash
thoma@LAPTOP-RTBPB5OG MINGW64 ~/OneDrive/Documents/Github Repositories/IAFRATE_thomas_demo-api (7--Docker---Compose)
$ curl -s http://localhost:8080/products
[{"id":4,"name":"Gourde","price_cents":900,"created_at":"2026-10-08T09:48:23.613Z"},{"id":3,"name":"T-shirt conteneur","price_cents":1990,"created_at":"2026-10-08T09:47:31.129Z"},{"id":2,"name":"Mug Docker","price_cents":990,"created_at":"2026-10-08T09:47:31.129Z"},{"id":1,"name":"Sticker Demo","price_cents":150,"created_at":"2026-10-08T09:47:31.129Z"}]
```


## 7. Test de persistance des données

Suppression des conteneurs et du réseau Docker Compose :

```bash
thoma@LAPTOP-RTBPB5OG MINGW64 ~/OneDrive/Documents/Github Repositories/IAFRATE_thomas_demo-api (7--Docker---Compose)
$ docker compose down
[+] Running 4/4
 ✔ Container iafrate_thomas_demo-api-adminer-1  Removed                                                                                         1.1s 
 ✔ Container iafrate_thomas_demo-api-api-1      Removed                                                                                         0.9s 
 ✔ Container iafrate_thomas_demo-api-db-1       Removed                                                                                         0.6s 
 ✔ Network iafrate_thomas_demo-api_default      Removed                                                                                         0.9s 

```


Redémarrage des services :

```bash
thoma@LAPTOP-RTBPB5OG MINGW64 ~/OneDrive/Documents/Github Repositories/IAFRATE_thomas_demo-api (7--Docker---Compose)
$ docker compose up -d
[+] Running 4/4
 ✔ Network iafrate_thomas_demo-api_default      Created                                                                                         0.0s 
 ✔ Container iafrate_thomas_demo-api-db-1       Healthy                                                                                         6.2s 
 ✔ Container iafrate_thomas_demo-api-adminer-1  Started                                                                                         6.3s 
 ✔ Container iafrate_thomas_demo-api-api-1      Started                                                                                         6.4s 
```


