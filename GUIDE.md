# Guide Inception — De zéro à la soutenance

## 1. C'est quoi concrètement ?

Tu vas faire tourner **WordPress** (un site web) en utilisant 3 programmes qui tournent chacun dans leur **conteneur Docker** :

```
Internet → [NGINX] → [WordPress/PHP] → [MariaDB]
             (web)      (le site)       (la base de données)
```

Tout ça est orchestré par **docker-compose**, un outil qui lit un fichier `.yml` et démarre tous les conteneurs en une commande.

---

## 2. Les concepts clés à comprendre

### Docker (en 5 minutes)

| Concept       | Analogie             | Explication                                  |
|---------------|----------------------|----------------------------------------------|
| **Image**     | Recette de cuisine   | Instructions pour créer un environnement     |
| **Dockerfile**| La recette écrite    | Fichier que tu écris pour créer une image    |
| **Conteneur** | Le plat cuisiné      | Image en cours d'exécution                   |
| **Volume**    | Disque dur partagé   | Données persistées entre les redémarrages    |
| **Network**   | Câble réseau         | Permet aux conteneurs de se parler           |

### Un Dockerfile basique

```dockerfile
FROM debian:bookworm           # image de base
RUN apt-get install -y nginx   # installe des paquets
COPY conf/nginx.conf /etc/     # copie ta config
CMD ["nginx", "-g", "daemon off;"]  # démarre le service
```

---

## 3. Les 3 services expliqués

### NGINX
- C'est le **serveur web** — il reçoit les requêtes HTTPS (port 443)
- Il sert les fichiers statiques et **transmet** les requêtes PHP à WordPress
- Il a un **certificat SSL** auto-signé généré avec `openssl`
- C'est le **seul** point d'entrée depuis l'extérieur

### WordPress + PHP-FPM
- WordPress est le CMS (le site)
- PHP-FPM exécute le code PHP de WordPress
- Il **ne tourne pas dans le même conteneur** que NGINX
- NGINX lui parle via le protocole **FastCGI** (port 9000)

### MariaDB
- C'est la **base de données** (compatible MySQL)
- WordPress y stocke articles, utilisateurs, paramètres...
- NGINX n'y touche jamais directement

---

## 4. Comment ils communiquent ?

```
[ NGINX :443 ] --FastCGI:9000--> [ WordPress :9000 ]
                                         |
                                   MySQL:3306
                                         |
                                   [ MariaDB :3306 ]
```

Ils sont sur le même **réseau Docker** (`docker network`).
Ils se joignent par leur **nom de service** (ex: `mariadb`, `wordpress`).

---

## 5. Ordre de construction recommandé

### Étape 1 — MariaDB
La plus simple. Tu dois :
1. Partir de `debian:bookworm`
2. Installer `mariadb-server`
3. Créer la base de données, l'utilisateur, le mot de passe via un script shell
4. Démarrer avec `mysqld`

### Étape 2 — WordPress
1. Partir de `debian:bookworm`
2. Installer `php-fpm` + les extensions PHP nécessaires
3. Télécharger WordPress avec `wp-cli`
4. Le configurer pour se connecter à MariaDB (via variables d'env)
5. Démarrer `php-fpm` sur le port 9000

### Étape 3 — NGINX
1. Partir de `debian:bookworm`
2. Installer `nginx` + `openssl`
3. Générer un certificat SSL auto-signé
4. Écrire la config pour écouter en HTTPS et proxy vers WordPress
5. Démarrer avec `nginx -g "daemon off;"`

### Étape 4 — docker-compose.yml
Tout assembler : services, volumes, networks, variables d'env

### Étape 5 — Makefile
Commandes pratiques : `make`, `make down`, `make clean`, `make re`...

---

## 6. Le `.env` — variables d'environnement

Toutes les infos sensibles dans ce fichier. **Jamais dans les Dockerfiles.**

```env
DOMAIN_NAME=login.42.fr

MYSQL_DATABASE=wordpress
MYSQL_USER=wpuser
MYSQL_PASSWORD=monmotdepasse
MYSQL_ROOT_PASSWORD=rootpass

WP_ADMIN_USER=admin
WP_ADMIN_PASS=adminpass
WP_ADMIN_EMAIL=admin@login.42.fr
WP_USER=user
WP_USER_PASS=userpass
WP_USER_EMAIL=user@login.42.fr
```

> Remplace `login` par ton login 42.

---

## 7. Structure finale du projet

```
Inception/
├── Makefile
└── srcs/
    ├── .env
    ├── docker-compose.yml
    └── requirements/
        ├── nginx/
        │   ├── Dockerfile
        │   └── conf/
        │       └── nginx.conf
        ├── wordpress/
        │   ├── Dockerfile
        │   └── conf/
        │       └── wp-setup.sh
        └── mariadb/
            ├── Dockerfile
            └── conf/
                └── init.sh
```

---

## 8. Les pièges classiques

- ❌ Ne pas utiliser `nginx:latest` ou `mariadb:latest` — tu dois écrire ton propre Dockerfile basé sur debian ou alpine
- ❌ Oublier `daemon off` pour NGINX — sinon le conteneur s'arrête immédiatement
- ❌ Ne pas gérer l'ordre de démarrage — WordPress doit attendre que MariaDB soit prêt
- ❌ Pas de `network: host`, pas de `--link`
- ❌ Mettre des mots de passe dans les Dockerfiles
- ✅ TLSv1.2 ou TLSv1.3 **uniquement** dans la config NGINX
- ✅ Les volumes doivent être dans `/home/<login>/data/` sur la VM
- ✅ Les conteneurs doivent redémarrer automatiquement (`restart: always`)

---

## 9. Commandes Docker utiles

```bash
# Construire et démarrer tous les conteneurs
docker-compose up --build

# Arrêter les conteneurs
docker-compose down

# Voir les conteneurs qui tournent
docker ps

# Voir les logs d'un service
docker logs nginx

# Entrer dans un conteneur
docker exec -it nginx bash

# Voir les volumes
docker volume ls

# Voir les réseaux
docker network ls
```

---

## 10. Plan d'attaque

```
[ ] Comprendre Docker (30 min de tutos)
[ ] Écrire et tester le Dockerfile MariaDB
[ ] Écrire et tester le Dockerfile WordPress
[ ] Écrire et tester le Dockerfile NGINX
[ ] Écrire le docker-compose.yml
[ ] Écrire le .env
[ ] Écrire le Makefile
[ ] Tester l'ensemble avec make
[ ] Vérifier que https://login.42.fr fonctionne
[ ] Vérifier la persistance (redémarrer et vérifier les données)
```
