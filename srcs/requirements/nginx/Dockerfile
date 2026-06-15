FROM debian:bookworm

RUN apt-get update -y && \
	apt-get install -y \
		nginx \
		openssl && \
	rm -rf /var/lib/apt/lists/*

# Generate a self-signed SSL certificate (TLSv1.2/1.3 required by subject)
RUN openssl req -x509 -nodes -days 365 \
	-newkey rsa:2048 \
	-keyout /etc/ssl/private/nginx.key \
	-out /etc/ssl/certs/nginx.crt \
	-subj "/C=FR/ST=IDF/L=Paris/O=42/CN=niclee.42.fr"

COPY conf/nginx.conf /etc/nginx/sites-available/default

EXPOSE 443

CMD ["nginx", "-g", "daemon off;"]
