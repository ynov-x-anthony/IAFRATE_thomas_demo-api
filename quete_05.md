# Quête 05 : Docker, les volumes

## Dépôt GitHub

https://github.com/ynov-x-anthony/IAFRATE_thomas_demo-api

## 1. Script Bash : `volumes_thomas_iafrate.sh`

```bash
#!/usr/bin/env bash
set -euo pipefail

# Quête 5 : persistance des données PostgreSQL

VOLUME="demo_pgdata"
NETWORK="demo_volumes_net"
DB="demo-db"
API="demo-api-volumes"

cleanup() {
  docker rm -f "$API" "$DB" >/dev/null 2>&1 || true
  docker network rm "$NETWORK" >/dev/null 2>&1 || true
}
trap cleanup EXIT

echo "=== 1. Construction de l'image API ==="
docker build -t demo-api:1.0 ./api

echo "=== 2. Création du volume ==="
if docker volume inspect "$VOLUME" >/dev/null 2>&1; then
  echo "ERREUR : le volume $VOLUME existe déjà."
  echo "Arrêt pour éviter de modifier des données existantes."
  exit 1
fi
docker volume create "$VOLUME"

echo "=== 3. Création du réseau ==="
docker network create "$NETWORK"

start_db() {
  docker run -d \
    --name "$DB" \
    --network "$NETWORK" \
    -v "$VOLUME:/var/lib/postgresql/data" \
    -v "$(pwd)/db/init.sql:/docker-entrypoint-initdb.d/init.sql:ro" \
    -e POSTGRES_USER=demo \
    -e POSTGRES_PASSWORD=demo \
    -e POSTGRES_DB=demo \
    postgres:16-alpine
}

wait_db() {
  echo "Attente de PostgreSQL..."
  for i in $(seq 1 60); do
    if docker exec "$DB" pg_isready -U demo -d demo >/dev/null 2>&1; then
      echo "PostgreSQL est prêt."
      return 0
    fi
    sleep 2
  done
  echo "ERREUR : PostgreSQL n'est pas prêt."
  docker logs "$DB"
  exit 1
}

start_api() {
  docker run -d \
    --name "$API" \
    --network "$NETWORK" \
    -p 8080:3000 \
    -e PGHOST="$DB" \
    demo-api:1.0
}

wait_api() {
  echo "Attente de l'API..."
  for i in $(seq 1 30); do
    if curl -fsS http://localhost:8080/health >/dev/null 2>&1; then
      echo "API disponible."
      return 0
    fi
    sleep 2
  done
  echo "ERREUR : API indisponible."
  docker logs "$API"
  exit 1
}

echo "=== 4. Démarrage de PostgreSQL ==="
start_db
wait_db

echo "=== 5. Démarrage de l'API ==="
start_api
wait_api

echo "=== 6. Ajout du produit ==="
curl -fsS -X POST \
  -H "Content-Type: application/json" \
  -d '{"name":"Casquette Démo","price_cents":1200}' \
  http://localhost:8080/products

echo
echo "=== 7. Produits AVANT suppression ==="
curl -fsS http://localhost:8080/products
echo

echo "=== 8. Suppression des conteneurs ==="
docker rm -f "$API" "$DB"

echo "=== 9. Recréation avec le MÊME volume ==="
start_db
wait_db
start_api
wait_api

echo "=== 10. Produits APRÈS recréation ==="
RESULT=$(curl -fsS http://localhost:8080/products)
echo "$RESULT"

echo "=== 11. Vérification de la persistance ==="
if echo "$RESULT" | grep -q "Casquette Démo"; then
  echo "SUCCÈS : Casquette Démo a survécu à la suppression du conteneur !"
else
  echo "ÉCHEC : produit introuvable."
  exit 1
fi

echo "=== 12. Volume conservé ==="
docker volume ls --filter "name=^${VOLUME}$"

echo "=== Fin du challenge ==="
echo "Le volume $VOLUME est conservé."

# Pour le supprimer plus tard, après vérification :
# docker volume rm demo_pgdata
```

## 2. Preuve d'exécution : `quete_05_execution.txt`

Le script a été lancé depuis Git Bash avec la commande suivante :

```bash
set -o pipefail
bash volumes_thomas_iafrate.sh 2>&1 | tee quete_05_execution.txt
```

### Résultat obtenu

```text
=== 1. Construction de l'image API ===
#0 building with "desktop-linux" instance using docker driver

#1 [internal] load build definition from Dockerfile
#1 transferring dockerfile: 454B 0.0s done
#1 DONE 0.0s

#2 [internal] load metadata for docker.io/library/node:22.11-alpine
#2 ...

#3 [auth] library/node:pull token for registry-1.docker.io
#3 DONE 0.0s

#2 [internal] load metadata for docker.io/library/node:22.11-alpine
#2 DONE 1.3s

#4 [internal] load .dockerignore
#4 transferring context: 78B done
#4 DONE 0.0s

#5 [internal] load build context
#5 transferring context: 126B done
#5 DONE 0.0s

#6 [1/5] FROM docker.io/library/node:22.11-alpine@sha256:b64ced2e7cd0a4816699fe308ce6e8a08ccba463c757c00c14cd372e3d2c763e
#6 resolve docker.io/library/node:22.11-alpine@sha256:b64ced2e7cd0a4816699fe308ce6e8a08ccba463c757c00c14cd372e3d2c763e 0.0s done
#6 DONE 0.0s

#7 [3/5] COPY --chown=node:node package.json package-lock.json ./
#7 CACHED

#8 [4/5] RUN npm ci --omit=dev
#8 CACHED

#9 [2/5] WORKDIR /app
#9 CACHED

#10 [5/5] COPY --chown=node:node server.js db.js ./
#10 CACHED

#11 exporting to image
#11 exporting layers done
#11 exporting manifest sha256:2d6f748e51ee0f90bb16fbbf4a2a1c81eee43dca12f72480f58bcce6320dcac0 done
#11 exporting config sha256:8ab9b3faa7aec3c12b6cefb0bb4377eed6cc0262ba381ef9aa6b0890a2f3f120 done
#11 exporting attestation manifest sha256:14aeeb71f90703a62a432e577d1ec5cb461de04b015420469fc0ef077612a177
#11 exporting attestation manifest sha256:14aeeb71f90703a62a432e577d1ec5cb461de04b015420469fc0ef077612a177 0.0s done
#11 exporting manifest list sha256:9bdef155854229aa54e8ce5f0e33d60e6529195efb0b20d1d4881eb6576a91ef 0.0s done
#11 naming to docker.io/library/demo-api:1.0 done
#11 unpacking to docker.io/library/demo-api:1.0 done
#11 DONE 0.1s

=== 2. Création du volume ===
demo_pgdata

=== 3. Création du réseau ===
619c18205c674f7a59af658f5bae0ac0f690f183da4a70a067aa80e04efe361f

=== 4. Démarrage de PostgreSQL ===
2f881f15d4a6c1d3eb14fc50042035672dc5a25eeb93c79f0af7aa9950372150
Attente de PostgreSQL...
PostgreSQL est prêt.

=== 5. Démarrage de l'API ===
f326e7fcb49b3c8fa0e77250f30aa99da0bfe83f726a36657ab27a3ccf46f91d
Attente de l'API...
API disponible.

=== 6. Ajout du produit ===
curl: (22) The requested URL returned error: 503
```
