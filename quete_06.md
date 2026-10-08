# Quête 06 : Docker, les réseaux

## 1. Script Bash : `reseaux_thomas_iafrate.sh`

```bash

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

```

## 2. Preuve d'exécution : `quete_06_execution.txt`

Exécution du script depuis Git Bash et enregistrement de la sortie du terminal :

```bash
thoma@LAPTOP-RTBPB5OG MINGW64 ~/OneDrive/Documents/Github Repositories/IAFRATE_thomas_demo-api (6--Docker---Les-reseaux)
$ set -o pipefail
bash reseaux_thomas_iafrate.sh 2>&1 | tee quete_06_execution.txt
=== 1. Construction de l'image API ===
#0 building with "desktop-linux" instance using docker driver

#1 [internal] load build definition from Dockerfile
#1 transferring dockerfile: 454B done
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

#7 [2/5] WORKDIR /app
#7 CACHED

#8 [3/5] COPY --chown=node:node package.json package-lock.json ./
#8 CACHED

#9 [4/5] RUN npm ci --omit=dev
#9 CACHED

#10 [5/5] COPY --chown=node:node server.js db.js ./
#10 CACHED

#11 exporting to image
#11 exporting layers done
#11 exporting manifest sha256:2d6f748e51ee0f90bb16fbbf4a2a1c81eee43dca12f72480f58bcce6320dcac0 done
#11 exporting config sha256:8ab9b3faa7aec3c12b6cefb0bb4377eed6cc0262ba381ef9aa6b0890a2f3f120 done
#11 exporting attestation manifest sha256:f57fac51a3f910b087f5068dba9d8925ed4fca927964a7e27f91d94c494cb1ed
#11 exporting attestation manifest sha256:f57fac51a3f910b087f5068dba9d8925ed4fca927964a7e27f91d94c494cb1ed 0.1s done
#11 exporting manifest list sha256:2064b9511ff3c050ef95972987470cecd38df708d661351f82c7f497ebac24f8 0.0s done
#11 naming to docker.io/library/demo-api:1.0 done
#11 unpacking to docker.io/library/demo-api:1.0 0.0s done
#11 DONE 0.1s
=== 2. Création des réseaux ===
3b124914c2833e1b79b38161ef93b60f0bbf57c9b4b760d5526f57169b339455
deed369a37151d336bf39039278adde4c9f556a16f21c12f786c31476853a06e
=== 3. Démarrage de PostgreSQL sur demo_back ===
b4460acc87ec7a688d4d98ee3427c9680f60f7e9369a72694a2e0dc026fecb49
=== 4. Attente de PostgreSQL ===
PostgreSQL est prêt.
=== 5. Démarrage de l'API sur demo_front ===
02581e617cc8a8a86ce0c5b71d6eb6796766434e2b0f3af19a9f4283d84a7de8
=== 6. Connexion de l'API à demo_back ===
=== 7. Test DNS depuis l'API ===
172.25.0.2        demo-db  demo-db
=== 8. Test d'isolation depuis demo_front ===
nc: bad address 'demo-db'
SUCCÈS : demo-db est inaccessible depuis demo_front.
=== 9. Adresses IPv4 de PostgreSQL ===
demo_back : 172.25.0.2

=== 10. Adresses IPv4 de l'API ===
demo_back : 172.25.0.3
demo_front : 172.24.0.2

=== 11. Vérification de /products ===
ERREUR : /products ne répond pas correctement.
{"level":"info","msg":"demo-api started","port":3000,"version":"dev"}
{"level":"info","method":"GET","path":"/health","status":200,"ms":8}
{"level":"info","method":"GET","path":"/products","status":503,"ms":22}
{"level":"info","method":"GET","path":"/products","status":503,"ms":8}
{"level":"info","method":"GET","path":"/products","status":503,"ms":10}
{"level":"info","method":"GET","path":"/products","status":503,"ms":7}
{"level":"info","method":"GET","path":"/products","status":503,"ms":8}
{"level":"info","method":"GET","path":"/products","status":503,"ms":6}
{"level":"info","method":"GET","path":"/health","status":200,"ms":0}
{"level":"info","method":"GET","path":"/products","status":503,"ms":7}
{"level":"info","method":"GET","path":"/products","status":503,"ms":8}
{"level":"info","method":"GET","path":"/products","status":503,"ms":8}
{"level":"info","method":"GET","path":"/products","status":503,"ms":6}
{"level":"info","method":"GET","path":"/products","status":503,"ms":6}
{"level":"info","method":"GET","path":"/products","status":503,"ms":7}
{"level":"info","method":"GET","path":"/health","status":200,"ms":1}
{"level":"info","method":"GET","path":"/products","status":503,"ms":7}
{"level":"info","method":"GET","path":"/products","status":503,"ms":7}
{"level":"info","method":"GET","path":"/products","status":503,"ms":8}
{"level":"info","method":"GET","path":"/products","status":503,"ms":7}
{"level":"info","method":"GET","path":"/products","status":503,"ms":7}
{"level":"info","method":"GET","path":"/products","status":503,"ms":9}
{"level":"info","method":"GET","path":"/products","status":503,"ms":9}
{"level":"info","method":"GET","path":"/health","status":200,"ms":1}
{"level":"info","method":"GET","path":"/products","status":503,"ms":6}
{"level":"info","method":"GET","path":"/products","status":503,"ms":7}
{"level":"info","method":"GET","path":"/products","status":503,"ms":7}
{"level":"info","method":"GET","path":"/products","status":503,"ms":7}
{"level":"info","method":"GET","path":"/products","status":503,"ms":7}
{"level":"info","method":"GET","path":"/products","status":503,"ms":6}
{"level":"info","method":"GET","path":"/health","status":200,"ms":0}
{"level":"info","method":"GET","path":"/products","status":503,"ms":6}
{"level":"info","method":"GET","path":"/products","status":503,"ms":7}
{"level":"info","method":"GET","path":"/products","status":503,"ms":7}
{"level":"info","method":"GET","path":"/products","status":503,"ms":6}
{"level":"info","method":"GET","path":"/products","status":503,"ms":6}
The files belonging to this database system will be owned by user "postgres".
This user must also own the server process.

The database cluster will be initialized with locale "en_US.utf8".
The default database encoding has accordingly been set to "UTF8".
The default text search configuration will be set to "english".

Data page checksums are disabled.

fixing permissions on existing directory /var/lib/postgresql/data ... ok
creating subdirectories ... ok
selecting dynamic shared memory implementation ... posix
selecting default max_connections ... 100
selecting default shared_buffers ... 128MB
selecting default time zone ... UTC
creating configuration files ... ok
running bootstrap script ... ok
sh: locale: not found
2026-10-08 08:38:24.678 UTC [41] WARNING:  no usable system locales were found
performing post-bootstrap initialization ... ok
initdb: warning: enabling "trust" authentication for local connections
initdb: hint: You can change this by editing pg_hba.conf or using the option -A, or --auth-local and --auth-host, the next time you run initdb.
syncing data to disk ... ok


Success. You can now start the database server using:

    pg_ctl -D /var/lib/postgresql/data -l logfile start

waiting for server to start....2026-10-08 08:38:26.003 UTC [47] LOG:  starting PostgreSQL 16.15 on x86_64-pc-linux-musl, compiled by gcc (Alpine 15.2.0) 15.2.0, 64-bit
2026-10-08 08:38:26.007 UTC [47] LOG:  listening on Unix socket "/var/run/postgresql/.s.PGSQL.5432"
2026-10-08 08:38:26.016 UTC [50] LOG:  database system was shut down at 2026-10-08 08:38:25 UTC
2026-10-08 08:38:26.024 UTC [47] LOG:  database system is ready to accept connections
 done
server started
CREATE DATABASE


/usr/local/bin/docker-entrypoint.sh: ignoring /docker-entrypoint-initdb.d/*

waiting for server to shut down....2026-10-08 08:38:26.212 UTC [47] LOG:  received fast shutdown request
2026-10-08 08:38:26.216 UTC [47] LOG:  aborting any active transactions
2026-10-08 08:38:26.218 UTC [47] LOG:  background worker "logical replication launcher" (PID 53) exited with exit code 1
2026-10-08 08:38:26.218 UTC [48] LOG:  shutting down
2026-10-08 08:38:26.229 UTC [48] LOG:  checkpoint starting: shutdown immediate
2026-10-08 08:38:26.528 UTC [48] LOG:  checkpoint complete: wrote 926 buffers (5.7%); 0 WAL file(s) added, 0 removed, 0 recycled; write=0.023 s, sync=0.264 s, total=0.311 s; sync files=301, longest=0.037 s, average=0.001 s; distance=4283 kB, estimate=4283 kB; lsn=0/1925D58, redo lsn=0/1925D58
2026-10-08 08:38:26.535 UTC [47] LOG:  database system is shut down
 done
server stopped

PostgreSQL init process complete; ready for start up.

2026-10-08 08:38:26.648 UTC [1] LOG:  starting PostgreSQL 16.15 on x86_64-pc-linux-musl, compiled by gcc (Alpine 15.2.0) 15.2.0, 64-bit
2026-10-08 08:38:26.648 UTC [1] LOG:  listening on IPv4 address "0.0.0.0", port 5432
2026-10-08 08:38:26.648 UTC [1] LOG:  listening on IPv6 address "::", port 5432
2026-10-08 08:38:26.655 UTC [1] LOG:  listening on Unix socket "/var/run/postgresql/.s.PGSQL.5432"
2026-10-08 08:38:26.666 UTC [69] LOG:  database system was shut down at 2026-10-08 08:38:26 UTC
2026-10-08 08:38:26.673 UTC [1] LOG:  database system is ready to accept connections
2026-10-08 08:38:37.753 UTC [80] ERROR:  relation "products" does not exist at character 47
2026-10-08 08:38:37.753 UTC [80] STATEMENT:  SELECT id, name, price_cents, created_at FROM products ORDER BY id DESC LIMIT 100
2026-10-08 08:38:40.068 UTC [81] ERROR:  relation "products" does not exist at character 47
2026-10-08 08:38:40.068 UTC [81] STATEMENT:  SELECT id, name, price_cents, created_at FROM products ORDER BY id DESC LIMIT 100
2026-10-08 08:38:42.352 UTC [82] ERROR:  relation "products" does not exist at character 47
2026-10-08 08:38:42.352 UTC [82] STATEMENT:  SELECT id, name, price_cents, created_at FROM products ORDER BY id DESC LIMIT 100
2026-10-08 08:38:44.651 UTC [83] ERROR:  relation "products" does not exist at character 47
2026-10-08 08:38:44.651 UTC [83] STATEMENT:  SELECT id, name, price_cents, created_at FROM products ORDER BY id DESC LIMIT 100
2026-10-08 08:38:46.934 UTC [84] ERROR:  relation "products" does not exist at character 47
2026-10-08 08:38:46.934 UTC [84] STATEMENT:  SELECT id, name, price_cents, created_at FROM products ORDER BY id DESC LIMIT 100
2026-10-08 08:38:49.223 UTC [85] ERROR:  relation "products" does not exist at character 47
2026-10-08 08:38:49.223 UTC [85] STATEMENT:  SELECT id, name, price_cents, created_at FROM products ORDER BY id DESC LIMIT 100
2026-10-08 08:38:51.525 UTC [86] ERROR:  relation "products" does not exist at character 47
2026-10-08 08:38:51.525 UTC [86] STATEMENT:  SELECT id, name, price_cents, created_at FROM products ORDER BY id DESC LIMIT 100
2026-10-08 08:38:53.824 UTC [87] ERROR:  relation "products" does not exist at character 47
2026-10-08 08:38:53.824 UTC [87] STATEMENT:  SELECT id, name, price_cents, created_at FROM products ORDER BY id DESC LIMIT 100
2026-10-08 08:38:56.107 UTC [88] ERROR:  relation "products" does not exist at character 47
2026-10-08 08:38:56.107 UTC [88] STATEMENT:  SELECT id, name, price_cents, created_at FROM products ORDER BY id DESC LIMIT 100
2026-10-08 08:38:58.403 UTC [90] ERROR:  relation "products" does not exist at character 47
2026-10-08 08:38:58.403 UTC [90] STATEMENT:  SELECT id, name, price_cents, created_at FROM products ORDER BY id DESC LIMIT 100
2026-10-08 08:39:00.711 UTC [91] ERROR:  relation "products" does not exist at character 47
2026-10-08 08:39:00.711 UTC [91] STATEMENT:  SELECT id, name, price_cents, created_at FROM products ORDER BY id DESC LIMIT 100
2026-10-08 08:39:03.022 UTC [92] ERROR:  relation "products" does not exist at character 47
2026-10-08 08:39:03.022 UTC [92] STATEMENT:  SELECT id, name, price_cents, created_at FROM products ORDER BY id DESC LIMIT 100
2026-10-08 08:39:05.315 UTC [93] ERROR:  relation "products" does not exist at character 47
2026-10-08 08:39:05.315 UTC [93] STATEMENT:  SELECT id, name, price_cents, created_at FROM products ORDER BY id DESC LIMIT 100
2026-10-08 08:39:07.613 UTC [94] ERROR:  relation "products" does not exist at character 47
2026-10-08 08:39:07.613 UTC [94] STATEMENT:  SELECT id, name, price_cents, created_at FROM products ORDER BY id DESC LIMIT 100
2026-10-08 08:39:09.904 UTC [95] ERROR:  relation "products" does not exist at character 47
2026-10-08 08:39:09.904 UTC [95] STATEMENT:  SELECT id, name, price_cents, created_at FROM products ORDER BY id DESC LIMIT 100
2026-10-08 08:39:12.205 UTC [96] ERROR:  relation "products" does not exist at character 47
2026-10-08 08:39:12.205 UTC [96] STATEMENT:  SELECT id, name, price_cents, created_at FROM products ORDER BY id DESC LIMIT 100
2026-10-08 08:39:14.509 UTC [97] ERROR:  relation "products" does not exist at character 47
2026-10-08 08:39:14.509 UTC [97] STATEMENT:  SELECT id, name, price_cents, created_at FROM products ORDER BY id DESC LIMIT 100
2026-10-08 08:39:16.803 UTC [99] ERROR:  relation "products" does not exist at character 47
2026-10-08 08:39:16.803 UTC [99] STATEMENT:  SELECT id, name, price_cents, created_at FROM products ORDER BY id DESC LIMIT 100
2026-10-08 08:39:19.096 UTC [100] ERROR:  relation "products" does not exist at character 47
2026-10-08 08:39:19.096 UTC [100] STATEMENT:  SELECT id, name, price_cents, created_at FROM products ORDER BY id DESC LIMIT 100
2026-10-08 08:39:21.404 UTC [101] ERROR:  relation "products" does not exist at character 47
2026-10-08 08:39:21.404 UTC [101] STATEMENT:  SELECT id, name, price_cents, created_at FROM products ORDER BY id DESC LIMIT 100
2026-10-08 08:39:23.689 UTC [102] ERROR:  relation "products" does not exist at character 47
2026-10-08 08:39:23.689 UTC [102] STATEMENT:  SELECT id, name, price_cents, created_at FROM products ORDER BY id DESC LIMIT 100
2026-10-08 08:39:25.990 UTC [103] ERROR:  relation "products" does not exist at character 47
2026-10-08 08:39:25.990 UTC [103] STATEMENT:  SELECT id, name, price_cents, created_at FROM products ORDER BY id DESC LIMIT 100
2026-10-08 08:39:28.300 UTC [104] ERROR:  relation "products" does not exist at character 47
2026-10-08 08:39:28.300 UTC [104] STATEMENT:  SELECT id, name, price_cents, created_at FROM products ORDER BY id DESC LIMIT 100
2026-10-08 08:39:30.591 UTC [105] ERROR:  relation "products" does not exist at character 47
2026-10-08 08:39:30.591 UTC [105] STATEMENT:  SELECT id, name, price_cents, created_at FROM products ORDER BY id DESC LIMIT 100
2026-10-08 08:39:32.886 UTC [106] ERROR:  relation "products" does not exist at character 47
2026-10-08 08:39:32.886 UTC [106] STATEMENT:  SELECT id, name, price_cents, created_at FROM products ORDER BY id DESC LIMIT 100
2026-10-08 08:39:35.198 UTC [107] ERROR:  relation "products" does not exist at character 47
2026-10-08 08:39:35.198 UTC [107] STATEMENT:  SELECT id, name, price_cents, created_at FROM products ORDER BY id DESC LIMIT 100
2026-10-08 08:39:37.496 UTC [109] ERROR:  relation "products" does not exist at character 47
2026-10-08 08:39:37.496 UTC [109] STATEMENT:  SELECT id, name, price_cents, created_at FROM products ORDER BY id DESC LIMIT 100
2026-10-08 08:39:39.788 UTC [110] ERROR:  relation "products" does not exist at character 47
2026-10-08 08:39:39.788 UTC [110] STATEMENT:  SELECT id, name, price_cents, created_at FROM products ORDER BY id DESC LIMIT 100
2026-10-08 08:39:42.103 UTC [111] ERROR:  relation "products" does not exist at character 47
2026-10-08 08:39:42.103 UTC [111] STATEMENT:  SELECT id, name, price_cents, created_at FROM products ORDER BY id DESC LIMIT 100
2026-10-08 08:39:44.399 UTC [112] ERROR:  relation "products" does not exist at character 47
2026-10-08 08:39:44.399 UTC [112] STATEMENT:  SELECT id, name, price_cents, created_at FROM products ORDER BY id DESC LIMIT 100
=== Nettoyage ===

```


