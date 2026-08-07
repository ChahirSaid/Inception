DATA_PATH	= /home/schahir/data

COMPOSE	= docker compose \
		-f srcs/docker-compose.yml \
		--env-file srcs/.env

all:
	@mkdir -p $(DATA_PATH)/mariadb
	@mkdir -p $(DATA_PATH)/wordpress
	$(COMPOSE) up -d --build

up: all

down:
	$(COMPOSE) down

clean:
	$(COMPOSE) down -v

fclean: clean
	docker system prune -af
	sudo rm -rf $(DATA_PATH)

re: fclean all

.PHONY: all down clean fclean re