# Grille de correction — Inception

---

## Avant de commencer

Commande à lancer avant toute évaluation :

```bash
docker stop $(docker ps -qa); docker rm $(docker ps -qa); \
docker rmi -f $(docker images -qa); docker volume rm $(docker volume ls -q); \
docker network rm $(docker network ls -q) 2>/dev/null
```

---

## General instructions — checklist

| # | Vérification | Réponse |
|---|---|---|
| 1 | Le dossier `srcs/` est à la racine du dépôt | ✅ oui |
| 2 | Un `Makefile` est à la racine du dépôt | ✅ oui |
| 3 | Pas de `network: host` ni de `links:` dans `docker-compose.yml` | ✅ oui |
| 4 | Une section `networks:` est présente dans `docker-compose.yml` | ✅ oui |
| 5 | Pas de `--link` dans le Makefile ou les scripts | ✅ oui |
| 6 | Pas de `tail -f`, `sleep infinity`, `tail -f /dev/null` dans les Dockerfiles/scripts | ✅ oui |
| 7 | Pas de `bash` ou `sh` en ENTRYPOINT hors lancement de script | ✅ oui |
| 8 | Les containers sont buildés depuis Debian bookworm (penultimate stable) | ✅ oui — `FROM debian:bookworm` |
| 9 | Aucun script ne fait de boucle infinie | ✅ oui |

---

## Mandatory part

---

### 1. Activity overview — questions à répondre

#### Comment Docker et docker compose fonctionnent ?
- **Docker** : crée des containers isolés à partir d'images définies dans des Dockerfiles. Chaque container tourne comme un processus isolé avec son propre filesystem.
- **docker compose** : orchestrateur qui lit un fichier `docker-compose.yml` pour démarrer, relier et configurer plusieurs containers en une seule commande.

#### Différence entre une image utilisée avec/sans docker compose ?
- L'image est la même. docker compose ajoute la gestion des dépendances entre services, des volumes, des networks et des variables d'environnement de manière déclarative. Sans compose, tout doit être fait manuellement avec `docker run`.

#### Avantage de Docker vs VMs ?
- Les containers partagent le kernel de l'hôte → moins de ressources, démarrage quasi-instantané, portabilité. Les VMs virtualisent tout le matériel → plus lourdes mais plus isolées.

#### Pertinence de la structure de répertoires ?
- `srcs/` regroupe toute la configuration applicative (compose, secrets, requirements). Chaque service a son propre dossier avec Dockerfile, conf et scripts. Cela respecte la séparation des responsabilités et facilite la maintenance.

---

### 2. README check

```
README.md est à la racine du dépôt.
```

Vérifications :
- Première ligne : *This project has been created as part of the 42 curriculum by niclee*
- Sections présentes : **Description**, **Instructions**, **Resources** (usage de l'IA)

---

### 3. Documentation check

```
USER_DOC.md et DEV_DOC.md sont à la racine du dépôt.
```

- **USER_DOC.md** : comment démarrer/arrêter le stack, accéder au site, gérer les credentials, vérifications basiques.
- **DEV_DOC.md** : prérequis, setup, usage du Makefile, commandes docker compose, persistance des données.

---

### 4. Simple setup

```bash
# Lancer le projet
make

# Vérifier que 443 fonctionne
curl -k https://niclee.42.fr

# Vérifier que 80 ne fonctionne PAS
curl http://niclee.42.fr  # doit échouer / timeout
```

- Ouvrir `https://niclee.42.fr` → page WordPress affichée (pas la page d'installation)
- Certificat SSL/TLS présent (auto-signé, warning normal)
- `http://niclee.42.fr` inaccessible

---

### 5. Docker Basics

```bash
# Voir les containers
docker compose -f srcs/docker-compose.yml ps

# Vérifier les images
docker images
```

| Vérification | Réponse |
|---|---|
| Un Dockerfile par service (nginx, wordpress, mariadb) | ✅ oui |
| Pas d'images ready-made / DockerHub interdites | ✅ images buildées localement |
| `FROM debian:bookworm` dans chaque Dockerfile | ✅ oui |
| Nom de l'image = nom du service | ✅ oui |
| Pas de crash au démarrage | vérifier avec `docker compose ps` |
docker 
---

### 6. Docker Network

```bash
docker network ls
# → doit afficher le réseau "inception"
```

**Explication docker-network** : un réseau virtuel interne qui permet aux containers de communiquer entre eux par leur nom de service (ex: `wordpress` peut joindre `mariadb` via le hostname `mariadb`). Ici le réseau s'appelle `inception` avec le driver `bridge`.

---

### 7. NGINX avec SSL/TLS

```bash
docker compose -f srcs/docker-compose.yml ps nginx
```

- Dockerfile présent : `srcs/requirements/nginx/Dockerfile`
- Accès HTTP (port 80) impossible ✅
- Accès HTTPS `https://niclee.42.fr` → WordPress affiché ✅
- Certificat TLS v1.2 ou v1.3 :

```bash
openssl s_client -connect niclee.42.fr:443 2>/dev/null | grep Protocol
# → TLSv1.2 ou TLSv1.3
```

---

### 8. WordPress + php-fpm + volume

```bash
docker compose -f srcs/docker-compose.yml ps wordpress
docker volume ls
docker volume inspect inception_wordpress
# → "Mountpoint" doit contenir /home/niclee/data/wordpress
```

| Vérification | Action |
|---|---|
| Pas de NGINX dans le Dockerfile wordpress | ✅ vérifié |
| Volume monté sur `/home/niclee/data/` | vérifier avec inspect |
| Ajouter un commentaire avec un user WordPress | le faire en direct |
| Se connecter en admin (username sans "admin") | se connecter sur `https://niclee.42.fr/wp-admin` |
| Modifier une page depuis le dashboard et vérifier sur le site | le faire en direct |

---

### 9. MariaDB + volume

```bash
docker compose -f srcs/docker-compose.yml ps mariadb
docker volume ls
docker volume inspect inception_mariadb
# → "Mountpoint" doit contenir /home/niclee/data/mariadb
```

**Se connecter à la base de données :**

```bash
docker exec -it mariadb mysql -u root -p -h 127.0.0.1
# password : root_secure_pass_42

# Vérifier que la base n'est pas vide
SHOW DATABASES;
USE wordpress;
SHOW TABLES;
```

---

### 10. Persistance

1. Éteindre la VM et la redémarrer
2. Relancer : `make`
3. Aller sur `https://niclee.42.fr`
4. Les modifications WordPress faites précédemment doivent toujours être là ✅

---

### 11. Configuration modification

**Exemple : changer le port de MariaDB**

1. Modifier `docker-compose.yml` → `ports: "3307:3306"`
2. `make re`
3. Vérifier :

```bash
docker compose -f srcs/docker-compose.yml ps
mysql -u root -p -h 127.0.0.1 -P 3307
```

Le service doit rester fonctionnel après le changement de port.

---
