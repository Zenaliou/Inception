FROM debian:bookworm

# Installation de MariaDB
RUN	apt-get update && apt-get install -y \
	mariadb-server \
	&& rm -rf /var/lib/apt/lists/* \
	&& rm -rf /var/lib/mysql/*

# Copier la config MariaDB custom
COPY conf/50-server.cnf /etc/mysql/mariadb.conf.d/50-server.cnf

# Copier le script d'initiaslisation
COPY tools/mariadb.sh /mariadb.sh
RUN chmod +x /mariadb.sh

EXPOSE 3306

# Le script mariadb.sh lance MariaDB en foreground a la fin
CMD ["/mariadb.sh"]