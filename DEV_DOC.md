# DEV_DOC — Inception

Developer and contributor guide for the Inception project.

---

## Prerequisites

- Linux (Debian/Ubuntu or equivalent)
- Docker Engine (>= 24.x)
- docker compose plugin (>= 2.x) — `docker compose` (not `docker-compose`)
- `make`
- `/etc/hosts` entry:

```bash
echo "127.0.0.1 niclee.42.fr" | sudo tee -a /etc/hosts
```

---

## Project structure

```
inception/
├── Makefile
├── README.md
├── USER_DOC.md
├── DEV_DOC.md
└── srcs/
    ├── docker-compose.yml
    ├── .env
    ├── secrets/
    │   ├── db_password.txt
    │   ├── db_root_password.txt
    │   ├── wp_admin_password.txt
    │   └── wp_user_password.txt
    └── requirements/
        ├── nginx/
        │   ├── Dockerfile
        │   └── conf/nginx.conf
        ├── wordpress/
        │   ├── Dockerfile
        │   ├── conf/www.conf
        │   └── tools/wordpress.sh
        └── mariadb/
            ├── Dockerfile
            ├── conf/50-server.cnf
            └── tools/mariadb.sh
```

---

## Makefile usage

| Command | Description |
|---|---|
| `make` / `make all` | Create data directories, build images, start containers |
| `make stop` | Stop containers (data preserved) |
| `make start` | Restart stopped containers |
| `make down` | Stop and remove containers |
| `make clean` | `down` + remove all Docker images and unused volumes |
| `make fclean` | `clean` + delete host data directories (`~/data/`) |
| `make re` | Full rebuild from scratch (`fclean` + `all`) |

---

## docker compose commands

All commands must be run from the repository root or pass `-f srcs/docker-compose.yml`.

```bash
# Build and start
docker compose -f srcs/docker-compose.yml up --build -d

# Stop and remove containers
docker compose -f srcs/docker-compose.yml down

# Check status
docker compose -f srcs/docker-compose.yml ps

# View logs for a specific service
docker compose -f srcs/docker-compose.yml logs -f mariadb
docker compose -f srcs/docker-compose.yml logs -f wordpress
docker compose -f srcs/docker-compose.yml logs -f nginx
```

---

## Architecture

```
Browser (HTTPS:443)
       │
       ▼
   [NGINX container]
    - SSL termination (TLSv1.2/1.3, self-signed cert)
    - Serves static files from /var/www/html
    - Proxies PHP via FastCGI
       │
       ▼
 [WordPress container]  ←────────────────────────────────►  [MariaDB container]
  - php-fpm on port 9000                                      - MariaDB on port 3306
  - WP-CLI for setup                                          - Data in /var/lib/mysql
```

All containers share the `inception` bridge network. They communicate by service name (`mariadb`, `wordpress`, `nginx`).

---

## Services

### NGINX

- **Image base:** `debian:bookworm`
- **Port exposed:** `443` (host → container)
- **SSL:** self-signed certificate generated at build time with OpenSSL
- **Config:** `srcs/requirements/nginx/conf/nginx.conf`
- FastCGI passes `.php` requests to `wordpress:9000`

### WordPress

- **Image base:** `debian:bookworm`
- **Port:** `9000` (internal only, not exposed to host)
- **Runtime:** php-fpm 8.2
- **Setup:** WP-CLI downloads and installs WordPress on first start
- **Config:** `srcs/requirements/wordpress/conf/www.conf` (php-fpm pool)
- **Entrypoint:** `srcs/requirements/wordpress/tools/wordpress.sh`

### MariaDB

- **Image base:** `debian:bookworm`
- **Port:** `3306` internal / configurable host mapping in `docker-compose.yml`
- **Init:** `srcs/requirements/mariadb/tools/mariadb.sh` runs `mysql_install_db` on first start, creates the database and users
- **Config:** `srcs/requirements/mariadb/conf/50-server.cnf`
- Root uses `mysql_native_password` authentication

---

## Environment variables

All variables are in `srcs/.env`:

| Variable | Description |
|---|---|
| `MYSQL_DATABASE` | Name of the WordPress database |
| `MYSQL_USER` | WordPress database user |
| `MYSQL_HOST` | Hostname of MariaDB (= `mariadb`) |
| `WP_URL` | WordPress site URL |
| `WP_TITLE` | WordPress site title |
| `WP_ADMIN_USER` | WordPress admin username (must not contain "admin") |
| `WP_ADMIN_EMAIL` | WordPress admin email |
| `WP_USER` | Secondary WordPress user login |
| `WP_USER_EMAIL` | Secondary WordPress user email |
| `USER_LOGIN` | 42 login, used for volume paths |

---

## Data persistence

Volumes are mounted on the host at:

- `~/data/mariadb` → MariaDB database files
- `~/data/wordpress` → WordPress files (wp-config.php, uploads, themes...)

These directories are created by `make setup` and deleted by `make fclean`.

On VM reboot, data persists as long as these directories are not deleted. After `make start`, WordPress and MariaDB resume from the same state.

---

## Modify a service port

Example: change the MariaDB host port from 3306 to 3307.

1. Edit `srcs/docker-compose.yml`:
   ```yaml
   ports:
     - "3307:3306"
   ```
   The container internal port stays 3306. Only the host-side port changes.

2. Rebuild:
   ```bash
   make re
   ```

3. Verify:
   ```bash
   mysql -u root -p -h 127.0.0.1 -P 3307
   ```

> Note: changing the internal port also requires updating `50-server.cnf` and the nginx `fastcgi_pass` directive consistently.
