COMPOSE_FILE = srcs/docker-compose.yml
DATA_DIR = /home/$(shell whoami)/data
COMPOSE = docker compose

all: setup
	$(COMPOSE) -f $(COMPOSE_FILE) up --build -d

setup:
	@mkdir -p $(DATA_DIR)/wordpress
	@mkdir -p $(DATA_DIR)/mariadb

down:
	$(COMPOSE) -f $(COMPOSE_FILE) down

stop:
	$(COMPOSE) -f $(COMPOSE_FILE) stop

start:
	$(COMPOSE) -f $(COMPOSE_FILE) start

clean: down
	docker system prune -af
	docker volume prune -f

fclean: clean
	sudo rm -rf $(DATA_DIR)

re: fclean all

.PHONY: all setup down stop start clean fclean re
