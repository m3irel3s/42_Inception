#==============================================================================#
#                                FLAGS & COMMANDS                              #
#==============================================================================#

DC          = docker-compose
DC_FILE     = ./srcs/docker-compose.yml

#==============================================================================#
#                                     RULES                                    #
#==============================================================================#

all: up

up:
	$(DC) -f $(DC_FILE) up -d --build

down:
	$(DC) -f $(DC_FILE) down

re: down up

logs:
	$(DC) -f $(DC_FILE) logs -f

ps:
	$(DC) -f $(DC_FILE) ps

nginx:
	$(DC) -f $(DC_FILE) build --no-cache nginx
	$(DC) -f $(DC_FILE) up -d nginx

wordpress:
	$(DC) -f $(DC_FILE) build --no-cache wordpress
	$(DC) -f $(DC_FILE) up -d wordpress

mariadb:
	$(DC) -f $(DC_FILE) build --no-cache mariadb
	$(DC) -f $(DC_FILE) up -d mariadb

clean: down
	$(DC) -f $(DC_FILE) rm -f
	docker volume prune -f
	docker network prune -f

fclean: clean
	docker system prune -af --volumes

.PHONY: all up down re logs ps clean fclean