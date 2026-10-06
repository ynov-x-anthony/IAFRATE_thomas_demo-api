# Challenge Docker

## Sortie de \dt

```text
         List of relations
 Schema |   Name   | Type  | Owner
--------+----------+-------+-------
 public | products | table | demo
(1 row)
```

## Sortie de SELECT * FROM products;

```text
 id |     name     | price_cents
----+--------------+-------------
  1 | Sticker Démo |         150
(1 row)
```

## 3 dernières lignes de docker logs demo-db

```text
2026-10-06 12:54:58.916 UTC [1] LOG:  listening on Unix socket "/var/run/postgresql/.s.PGSQL.5432"
2026-10-06 12:54:58.927 UTC [57] LOG:  database system was shut down at 2026-10-06 12:54:58 UTC
2026-10-06 12:54:58.938 UTC [1] LOG:  database system is ready to accept connections
```

### 1. Lancement du conteneur PostgreSQL

```powershell
PS C:\Users\thoma\Documents\Github Repositories\IAFRATE_thomas_demo-api> docker run -d --name demo-db -e POSTGRES_USER=demo -e POSTGRES_PASSWORD=demo -e POSTGRES_DB=demo postgres:16-alpine
d077945d63b5f1ffe23270b784d3cd6acdd82503c46f24795e6d0179328fe0c2
PS C:\Users\thoma\Documents\Github Repositories\IAFRATE_thomas_demo-api> docker ps
CONTAINER ID   IMAGE                COMMAND                  CREATED         STATUS         PORTS                       NAMES
d077945d63b5   postgres:16-alpine   "docker-entrypoint.s…"   7 seconds ago   Up 6 seconds   5432/tcp                    demo-db
dfbe14022ba3   mongo:6.0            "docker-entrypoint.s…"   15 months ago   Up 6 hours     0.0.0.0:27017->27017/tcp   mongo-standalone
```

### 2. Connexion au CLI PostgreSQL (psql) et manipulation des données

```powershell
PS C:\Users\thoma\Documents\Github Repositories\IAFRATE_thomas_demo-api> docker exec -it demo-db psql -U demo -d demo
psql (16.15)
```

```sql
demo=# CREATE TABLE products (id serial primary key, name text, price_cents int);
CREATE TABLE

demo=# INSERT INTO products (name, price_cents) VALUES ('Sticker Démo', 150);
INSERT 0 1

demo=# \dt
         List of relations
 Schema |   Name   | Type  | Owner
--------+----------+-------+-------
 public | products | table | demo
(1 row)

demo=# SELECT * FROM products;
 id |     name     | price_cents
----+--------------+-------------
  1 | Sticker Démo |         150
(1 row)

demo=# \q
```

### 3. Vérification des journaux PostgreSQL

```powershell
PS C:\Users\thoma\Documents\Github Repositories\IAFRATE_thomas_demo-api> docker logs --tail 3 demo-db
2026-10-06 12:54:58.916 UTC [1] LOG:  listening on Unix socket "/var/run/postgresql/.s.PGSQL.5432"
2026-10-06 12:54:58.927 UTC [57] LOG:  database system was shut down at 2026-10-06 12:54:58 UTC
2026-10-06 12:54:58.938 UTC [1] LOG:  database system is ready to accept connections
```
