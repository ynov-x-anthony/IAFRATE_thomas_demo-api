set -euo pipefail


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

