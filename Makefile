.DEFAULT_GOAL := help
PROJECT_DIR := $(CURDIR)

# pass arguments to the target
ARGS = $(shell echo $(MAKECMDGOALS) | sed -e 's/^[^ ]*$$//' | sed -e 's/^[^ ]* //g')

# 警告を無視する
%:
	@:

.PHONY: help
# ref: https://postd.cc/auto-documented-makefile/
help: ## Print help
	@awk -F '\n' -vRS='$(shell printf "#%.0s" {0..3}) ' \
		'{ \
			for(i=1; i<=NF; i++){ \
				if(NR==1) continue; \
				if(i==1) { \
					printf "[\033[33m%s\033[0m]\n", $$1; \
					continue \
				} \
				if($$i ~ /^[a-zA-Z].+:.*?##/){ \
					num = split($$i, res, ":.*?## "); \
					printf "\033[36mmake %-20s\033[0m %s\n", res[1], res[2] \
				} \
				if(i==NF) printf "\n" \
			} \
		}' \
		$(MAKEFILE_LIST)

#### General
up: ## Start all services
	docker compose up -d

up/service: ## Start service only db
	docker compose up -d db

ps:: ## Show running containers
	docker compose ps

stop: ## Stop all services
	docker compose stop

logf: ## Show logs
	docker compose logs -f $(ARGS)

#### App
app/test: ## Run RSpec
	bundle exec rspec $(ARGS)

app/lint: ## Run RuboCop
	bundle exec rubocop

app/lint/fix: ## Run RuboCop with auto-correct offenses
	bundle exec rubocop -A

#### APM
apm/all:
	apm install --no-policy && apm compile
#### AI
ai/test: ## Run RSpec via rtk (use ARGS="spec/path")
	mise exec -C $(PROJECT_DIR) -- rtk rspec $(ARGS)

ai/rake: ## Run rake
	mise exec -C $(PROJECT_DIR) -- bundle exec rake $(ARGS)


ai/lint: ## Run RuboCop via rtk
	mise exec -C $(PROJECT_DIR) -- rtk rubocop

ai/lint/fix: ## Run RuboCop with auto-correct offenses via rtk
	mise exec -C $(PROJECT_DIR) -- rtk rubocop -A
