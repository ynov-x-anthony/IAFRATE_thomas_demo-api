# Quête 9 : Microservices et déploiement continu

## 1. Création du microservice notifier

Un deuxième service métier nommé `notifier` a été ajouté au projet.

Il possède ses propres fichiers :

- `notifier/server.js`
- `notifier/package.json`
- `notifier/package-lock.json`
- `notifier/Dockerfile`

Le service expose deux routes :

- `GET /health` : vérification de son état.
- `POST /notify` : réception et affichage d'une notification dans les logs.

Son image Docker utilise un utilisateur non-root et un `HEALTHCHECK`.

## 2. Communication entre les services

Le fichier `compose.yml` a été modifié pour intégrer `notifier`.

Les services `api`, `db` et `notifier` communiquent sur le réseau interne `back`.

Le service `notifier` ne publie aucun port vers l'extérieur.

Après un `POST /products` réussi, l'API envoie une requête HTTP à `http://notifier:4000/notify`.

Cet appel est effectué en *best-effort* : si `notifier` est indisponible, la création du produit n'est pas bloquée.

### Test de création d'un produit

```bash
thoma@LAPTOP-RTBPB5OG MINGW64 ~/OneDrive/Documents/Github Repositories/IAFRATE_thomas_demo-api (9--Docker---Microservices-et-déploiement-continu)
$ curl -i -X POST http://localhost:8080/products \
  -H "Content-Type: application/json" \
  -d '{"name":"Clavier meca","price_cents":5900}'
HTTP/1.1 201 Created
X-Powered-By: Express
Content-Type: application/json; charset=utf-8
Content-Length: 89
ETag: W/"59-YcZlcaDYm8wdcYPNiTxsry4yzng"
Date: Fri, 09 Oct 2026 09:02:27 GMT
Connection: keep-alive
Keep-Alive: timeout=5

{"id":5,"name":"Clavier meca","price_cents":5900,"created_at":"2026-10-09T09:02:27.290Z"}
```

### Vérification des notifications

```bash
thoma@LAPTOP-RTBPB5OG MINGW64 ~/OneDrive/Documents/Github Repositories/IAFRATE_thomas_demo-api (9--Docker---Microservices-et-déploiement-continu)
$ docker compose logs --tail=10 notifier
notifier-1  | [notifier] démarré sur le port 4000
notifier-1  | [notifier] nouveau produit : {"name":"Clavier meca"}
```

## 3. Pipeline CI multi-images

Le workflow `.github/workflows/ci.yml` utilise une matrice :

```yaml
strategy:
  matrix:
    service: [api, notifier]
```

Pour chaque service, le pipeline :

1. Construit son image Docker.
2. Analyse les vulnérabilités HIGH et CRITICAL avec Trivy.

Les images sont versionnées séparément :

```text
ghcr.io/ynov-x-anthony/iafrate_thomas_demo-api/api:v1.5.0
ghcr.io/ynov-x-anthony/iafrate_thomas_demo-api/notifier:v1.5.0
```

## 4. Déploiement continu

Un job `deploy` a été ajouté au workflow.

Il dépend de la réussite des deux jobs de construction et d'analyse et s'exécute uniquement lors du push d'un tag commençant par `v`.

Le déploiement est simulé sur un runner GitHub Actions, conformément à l'option proposée dans l'énoncé. Il ne s'agit pas d'un hébergement permanent.

Le fichier `compose.deploy.yml` permet d'utiliser les images publiées sur GHCR.

Commandes de déploiement :

```bash
docker compose -f compose.yml -f compose.deploy.yml pull
docker compose -f compose.yml -f compose.deploy.yml up -d --no-build
```

## 5. Preuves GitHub Actions

Tag utilisé : `v1.5.0`

**Exécution GitHub Actions :**

[Lien Workflow 1.5.0](https://github.com/ynov-x-anthony/IAFRATE_thomas_demo-api/actions/runs/37912236466)

- `Build et scan - api` : réussi.
- `Build et scan - notifier` : réussi.
- `Deploiement automatique` : réussi.
