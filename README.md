*This project has been created as part of the 42 curriculum by niclee*

---

## Description

Inception is a system administration project from the 42 curriculum. It consists of setting up a small infrastructure using Docker and docker compose, composed of three services running in separate containers:

- **NGINX** — reverse proxy with SSL/TLS (TLSv1.2/1.3), the only entry point (port 443)
- **WordPress** — CMS with php-fpm, served by NGINX via FastCGI
- **MariaDB** — relational database storing WordPress data

Each service runs in its own container, built from a custom Dockerfile based on `debian:bookworm`. The containers communicate via a dedicated Docker network. Data is persisted using Docker volumes mounted on the host.

---

## Instructions

### Requirements

- Docker and docker compose installed
- `make` available
- The host must have `/etc/hosts` configured with `niclee.42.fr` pointing to `127.0.0.1`

```bash
echo "127.0.0.1 niclee.42.fr" | sudo tee -a /etc/hosts
```

### Start the project

```bash
make
```

This will:
1. Create the data directories on the host (`~/data/mariadb`, `~/data/wordpress`)
2. Build all Docker images
3. Start all containers in detached mode

### Stop the project

```bash
make stop
```

### Full reset (removes volumes and data)

```bash
make fclean
```

### Access the website

Open `https://niclee.42.fr` in your browser. A self-signed certificate warning may appear — this is expected.

---

## Resources

### AI usage

GitHub Copilot (Claude Sonnet) was used during this project for:

- Debugging MariaDB authentication issues (unix_socket vs mysql_native_password)
- Understanding the difference between container-internal ports and host-mapped ports in docker compose
- Generating documentation structure

All code was written, reviewed and understood by the author. AI was used as an assistant, not as a replacement for understanding.

### References

- [Docker documentation](https://docs.docker.com/)
- [docker compose documentation](https://docs.docker.com/compose/)
- [MariaDB documentation](https://mariadb.com/kb/en/)
- [WordPress WP-CLI documentation](https://wp-cli.org/)
- [NGINX documentation](https://nginx.org/en/docs/)
- [php-fpm documentation](https://www.php.net/manual/en/install.fpm.php)
