# USER_DOC — Inception

User and administrator guide for the Inception stack.

---

## Start / Stop the stack

### Start

```bash
cd ~/inception/inception
make
```

Wait until all containers are running. You can verify with:

```bash
docker compose -f srcs/docker-compose.yml ps
```

All three services (`nginx`, `wordpress`, `mariadb`) must show status `Up`.

### Stop (keep data)

```bash
make stop
```

### Restart

```bash
make start
```

### Full reset (destroys all data)

```bash
make fclean
make
```

---

## Access the website

### Public website

Open your browser and go to:

```
https://niclee.42.fr
```

A self-signed certificate warning may appear — click "Accept the risk and continue" (Firefox) or "Advanced > Proceed" (Chrome).

HTTP access (`http://niclee.42.fr`) is not available by design.

### Admin panel

```
https://niclee.42.fr/wp-admin
```

Log in with the administrator credentials (see credentials section below).

---

## Manage credentials

All passwords are stored in the `srcs/secrets/` folder as plain text files:

| File | Content |
|---|---|
| `srcs/secrets/db_password.txt` | WordPress database user password |
| `srcs/secrets/db_root_password.txt` | MariaDB root password |
| `srcs/secrets/wp_admin_password.txt` | WordPress admin password |
| `srcs/secrets/wp_user_password.txt` | WordPress secondary user password |

To change a password, edit the corresponding file then run `make re` to rebuild.

Environment variables (usernames, database name, URLs) are in `srcs/.env`.

---

## Basic checks

### Check all containers are running

```bash
docker compose -f srcs/docker-compose.yml ps
```

### Check NGINX is serving HTTPS

```bash
curl -k https://niclee.42.fr
```

Should return WordPress HTML content.

### Check TLS version

```bash
openssl s_client -connect niclee.42.fr:443 2>/dev/null | grep Protocol
```

Should return `TLSv1.2` or `TLSv1.3`.

### Check volumes exist and are mounted correctly

```bash
docker volume inspect inception_wordpress
docker volume inspect inception_mariadb
```

The `Mountpoint` field should point to `/home/niclee/data/wordpress` and `/home/niclee/data/mariadb`.

### Connect to the database

```bash
docker exec -it mariadb mysql -u root -p -h 127.0.0.1
# Enter password from srcs/secrets/db_root_password.txt
```

```sql
SHOW DATABASES;
USE wordpress;
SHOW TABLES;
```

### View container logs

```bash
docker logs nginx
docker logs wordpress
docker logs mariadb
```
