# Quête 8 : Analyse de vulnérabilités avec Trivy

## 1. Analyse initiale

Commande utilisée :

```bash
thoma@LAPTOP-RTBPB5OG MINGW64 ~/OneDrive/Documents/Github Repositories/IAFRATE_thomas_demo-api (8--Docker---Analyse-de-vulnerabilite-avec-Trivy)
$ MSYS_NO_PATHCONV=1 docker run --rm \
  -v /var/run/docker.sock:/var/run/docker.sock \
  aquasec/trivy:latest image \
  --severity HIGH,CRITICAL \
  --ignore-unfixed \
  --scanners vuln \
```

Le scan a révélé plusieurs vulnérabilités de niveau HIGH et CRITICAL.

Rapport : [scan-avant.txt](./scan-avant.txt)

## 2. Corrections des vulnérabilités

Les modifications suivantes ont été réalisées :

- Mise à jour de l'image de base Docker de `node:22.11-alpine` vers `node:24-alpine`.
- Suppression de npm et des outils de développement inutiles dans l'image finale.
- Correction de la vulnérabilité `CVE-2026-90711` présente dans `proxy-addr`, en passant de la version `2.0.7` à une version corrigée.
- Reconstruction de l'image Docker après les corrections.

## 3. Analyse après correction

Commande utilisée :

```bash
thoma@LAPTOP-RTBPB5OG MINGW64 ~/OneDrive/Documents/Github Repositories/IAFRATE_thomas_demo-api (8--Docker---Analyse-de-vulnerabilite-avec-Trivy)
$ MSYS_NO_PATHCONV=1 docker run --rm \
  -v /var/run/docker.sock:/var/run/docker.sock \
  aquasec/trivy:latest image \
  --severity HIGH,CRITICAL \
  --ignore-unfixed \
  --scanners vuln \
  demo-api:multi 2>&1 | tee scan-apres.txt
```

Résultat final :

```text
Total: 0 (HIGH: 0, CRITICAL: 0)
```

Rapport : [scan-apres.txt](./scan-apres.txt)

## 4. Intégration GitHub Actions

Un workflow de sécurité a été ajouté dans `.github/workflows/ci.yml`.

Il permet de :

- Construire automatiquement l'image Docker lors d'un push.
- Analyser l'image avec Trivy.
- Détecter les vulnérabilités HIGH et CRITICAL.
- Faire échouer le pipeline si une vulnérabilité corrigible est détectée.

## 5. Preuves des exécutions GitHub Actions

### CI rouge : vulnérabilités détectées

[Voir l'exécution en échec](https://github.com/ynov-x-anthony/IAFRATE_thomas_demo-api/actions/runs/37773550626)

### CI verte : vulnérabilités corrigées

[Voir l'exécution réussie](https://github.com/ynov-x-anthony/IAFRATE_thomas_demo-api/actions/runs/37776849048)