# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━ LAYOUT ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

DEFAULT			= \033[0m
CYAN			= \033[1;36m


# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━ VARIABLES ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

COMPOSE		= docker compose -f srcs/docker-compose.yml
DATA_PATH	= $(or $(shell sed -n 's/^DATA_PATH=//p' srcs/.env 2>/dev/null),/home/yassabda/data)
DOMAIN		= $(shell sed -n 's/^DOMAIN_NAME=//p' srcs/.env 2>/dev/null)


# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━ RULES ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

all: dirs
	@test -f srcs/.env || { printf "missing srcs/.env (cp srcs/.env.example srcs/.env)"; exit 1; }
	@$(COMPOSE) up -d --build
	@printf "Inception running: https://$(DOMAIN)"

dirs:
	@mkdir -p $(DATA_PATH)/wordpress $(DATA_PATH)/mariadb

up: dirs
	@$(COMPOSE) up -d

down:
	@$(COMPOSE) down

status:
	@$(COMPOSE) ps

logs:
	@$(COMPOSE) logs -f

check:
	@$(COMPOSE) config -q && printf "compose file valid"

clean:
	@$(COMPOSE) down --rmi all --remove-orphans

fclean:
	@$(COMPOSE) down --rmi all --volumes --remove-orphans
	@test -n "$(DATA_PATH)" && sudo rm -rf "$(DATA_PATH)"

re: fclean all

help:
	@printf "Usage: make [target]\n"
	@printf "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\n"
	@printf "  $(CYAN)all$(DEFAULT)      Build images and start the stack\n"
	@printf "  $(CYAN)up$(DEFAULT)       Start existing images\n"
	@printf "  $(CYAN)down$(DEFAULT)     Stop and remove containers/network\n"
	@printf "  $(CYAN)status$(DEFAULT)   Show container status\n"
	@printf "  $(CYAN)logs$(DEFAULT)     Follow service logs\n"
	@printf "  $(CYAN)check$(DEFAULT)    Validate the compose file\n"
	@printf "  $(CYAN)clean$(DEFAULT)    Stop and remove containers and images\n"
	@printf "  $(CYAN)fclean$(DEFAULT)   clean + volumes and host data (destructive)\n"
	@printf "  $(CYAN)re$(DEFAULT)       fclean then all\n"
	@printf "  $(CYAN)help$(DEFAULT)     Show this help\n"

.PHONY: all dirs up down status logs check clean fclean re help
