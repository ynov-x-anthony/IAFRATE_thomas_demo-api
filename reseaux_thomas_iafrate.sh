set -euo pipefail


FRONT="demo_front"
BACK="demo_back"
DB="demo-db"
API="demo-api"

cleanup() {
  echo "=== Nettoyage ==="
  docker rm -f "$API" "$DB" >/dev/null 2>&1 || true
  docker network rm "$FRONT" "$BACK" >/dev/null 2>&1 || true
}
trap cleanup EXIT

echo "=== 1. Construction de l'image API ==="
docker build -t demo-api:1.0 ./api

echo "=== 2. Création des réseaux ==="
docker network create "$FRONT"
docker network create "$BACK"

echo "=== 3. Démarrage de PostgreSQL sur demo_back ==="
docker run -d \
  --name "$DB" \
  --network "$BACK" \
  -v "$(pwd)/db/init.sql:/docker-entrypoint-initdb.d/init.sql:ro" \
  -e POSTGRES_USER=demo \
  -e POSTGRES_PASSWORD=demo \
  -e POSTGRES_DB=demo \
  postgres:16-alpine

echo "=== 4. Attente de PostgreSQL ==="
for i in $(seq 1 60); do
  if docker exec "$DB" pg_isready -U demo -d demo >/dev/null 2>&1; then
    echo "PostgreSQL est prêt."
    break
  fi
  if [ "$i" -eq 60 ]; then
    docker logs "$DB"
    exit 1
  fi
  sleep 2
done

echo "=== 5. Démarrage de l'API sur demo_front ==="
docker run -d \
  --name "$API" \
  --network "$FRONT" \
  -p 127.0.0.1:8080:3000 \
  -e PGHOST="$DB" \
  -e PGUSER=demo \
  -e PGPASSWORD=demo \
  -e PGDATABASE=demo \
  demo-api:1.0

echo "=== 6. Connexion de l'API à demo_back ==="
docker network connect "$BACK" "$API"

echo "=== 7. Test DNS depuis l'API ==="
docker exec "$API" getent hosts "$DB"

echo "=== 8. Test d'isolation depuis demo_front ==="
if docker run --rm --network "$FRONT" alpine \
  sh -c "nc -z -w 3 $DB 5432" 2>&1; then
  echo "ÉCHEC : la base est accessible depuis demo_front."
  exit 1
else
  echo "SUCCÈS : demo-db est inaccessible depuis demo_front."
fi

echo "=== 9. Adresses IPv4 de PostgreSQL ==="
docker inspect -f \
  '{{range $name, $net := .NetworkSettings.Networks}}{{$name}} : {{$net.IPAddress}}{{"\n"}}{{end}}' \
  "$DB"

echo "=== 10. Adresses IPv4 de l'API ==="
docker inspect -f \
  '{{range $name, $net := .NetworkSettings.Networks}}{{$name}} : {{$net.IPAddress}}{{"\n"}}{{end}}' \
  "$API"

echo "=== 11. Vérification de /products ==="
SUCCESS=0
for i in $(seq 1 30); do
  if RESULT=$(curl -fsS http://localhost:8080/products 2>/dev/null); then
    echo "$RESULT"
    SUCCESS=1
    break
  fi
  sleep 2
done

if [ "$SUCCESS" -ne 1 ]; then
  echo "ERREUR : /products ne répond pas correctement."
  docker logs "$API"
  docker logs "$DB"
  exit 1
fi

echo "=== 12. Vérification des produits ==="
if echo "$RESULT" | grep -q "Sticker Demo" &&
   echo "$RESULT" | grep -q "Mug Docker" &&
   echo "$RESULT" | grep -q "T-shirt conteneur"; then
  echo "SUCCÈS : les trois produits de init.sql sont présents."
else
  echo "ÉCHEC : produits attendus introuvables."
  exit 1
fi

echo "=== 13. Vérification des ports publiés ==="
docker ps --format 'table {{.Names}}\t{{.Ports}}' \
  --filter "name=^/${DB}$" \
  --filter "name=^/${API}$"

echo "=== Fin de la quête 6 ==="
echo "SUCCÈS : isolation réseau et API vérifiées."
