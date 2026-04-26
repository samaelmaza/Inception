DATA_PATH = /home/sam/data

all:up

up:
	@echo "Creating volumes..."
	@mkdir -p $(DATA_PATH)/mariadb
	@mkdir -p $(DATA_PATH)/wordpress
	@echo "Starting the containers..."
	@docker compose -f srcs/docker-compose.yml up -d --build

down:
	@docker compose -f srcs/docker-compose.yml down

clean: down
	@echo "Deleting local files..."
	@sudo rm -rf $(DATA_PATH)/mariadb
	@sudo rm -rf $(DATA_PATH)/wordpress
	@echo "Cleaning Docker system..."
	@docker system prune -af

fclean: clean

re: fclean all

.PHONY: all up down clean fclean re
