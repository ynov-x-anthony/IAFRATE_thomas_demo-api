# Quête 03 - Dockerfile et sécurité

## 1. Repository GitHub

https://github.com/ynov-x-anthony/IAFRATE_thomas_demo-api

Dockerfile sécurisé : `api/Dockerfile`

L'image utilise `node:22.11-alpine`, un utilisateur non privilégié (`USER node`), des instructions `COPY --chown=node:node` et un `HEALTHCHECK` sur `/health`.

## 2. Commande de lancement sécurisée

```powershell
PS C:\Users\thoma\OneDrive\Documents\Github Repositories\IAFRATE_thomas_demo-api> docker run -d --name api -p 8080:3000 `
>>   --read-only `
>>   --tmpfs /tmp:size=16m `
>>   --cap-drop ALL `
>>   --security-opt no-new-privileges `
>>   --pids-limit 200 `
>>   --memory 256m `
>>   --cpus 1 `
>>   --network demo_net `
>>   -e PGHOST=demo-db `
>>   demo-api:hardened
a0525aa3821ba354ff3a48bfbc10802c0e3f9c044c434a1e05e133eabe2da70a
```

## 3. Preuve de l'utilisateur non-root

```powershell
PS C:\Users\thoma\OneDrive\Documents\Github Repositories\IAFRATE_thomas_demo-api> docker run --rm demo-api:hardened id
uid=1000(node) gid=1000(node) groups=1000(node)
```

## 4. Test du HEALTHCHECK

Commande :

```powershell
PS C:\Users\thoma\OneDrive\Documents\Github Repositories\IAFRATE_thomas_demo-api> curl.exe -s http://localhost:8080/health
{"status":"UP"}   
```

## 5. Test du système de fichiers en lecture seule

Commande :

```powershell
PS C:\Users\thoma\OneDrive\Documents\Github Repositories\IAFRATE_thomas_demo-api> docker exec api sh -c 'touch /app/x 2>&1 || echo "rootfs read-only OK"'
touch: /app/x: Read-only file system
rootfs                               
```

## 6. Vérification des protections Docker

Commande :

```powershell
PS C:\Users\thoma\OneDrive\Documents\Github Repositories\IAFRATE_thomas_demo-api> docker inspect -f 'readonly={{.HostConfig.ReadonlyRootfs}} capdrop={{.HostConfig.CapDrop}}' api                   
readonly=true capdrop=[ALL]
```
