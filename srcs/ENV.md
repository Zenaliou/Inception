# Variables d'environnement — `.env`

Le fichier `srcs/.env` est ignoré par git.  
Il contient toutes les variables **non-sensibles** du projet.

> **Les mots de passe ne sont pas ici.** Voir [secrets/README.md](secrets/README.md).

## Variables

### Host

| Variable | Valeur par défaut | Description |
|---|---|---|
| `USER_LOGIN` | `niclee` | Login 42, utilisé pour les chemins de volumes |
| `DOMAIN_NAME` | `niclee.42.fr` | Domaine du site |

### MariaDB

| Variable | Valeur par défaut | Description |
|---|---|---|
| `MYSQL_DATABASE` | `wordpress` | Nom de la base de données |
| `MYSQL_USER` | `wp_user` | Utilisateur de la base |
| `MYSQL_HOST` | `mariadb` | Nom du service (réseau Docker) |

### WordPress

| Variable | Description |
|---|---|
| `WP_URL` | URL complète du site (`https://niclee.42.fr`) |
| `WP_TITLE` | Titre du site |
| `WP_ADMIN_USER` | Login de l'administrateur WordPress |
| `WP_ADMIN_EMAIL` | Email de l'administrateur |
| `WP_USER` | Login du second utilisateur (rôle author) |
| `WP_USER_EMAIL` | Email du second utilisateur |

## Exemple de fichier `.env`

```env
USER_LOGIN=niclee
DOMAIN_NAME=niclee.42.fr

MYSQL_DATABASE=wordpress
MYSQL_USER=wp_user
MYSQL_HOST=mariadb

WP_URL=https://niclee.42.fr
WP_TITLE=Inception
WP_ADMIN_USER=niclee_admin
WP_ADMIN_EMAIL=admin@niclee.42.fr
WP_USER=niclee_editor
WP_USER_EMAIL=editor@niclee.42.fr
```
