.PHONY: help build up down restart logs clean install test

# Colors for output
BLUE := \033[0;34m
GREEN := \033[0;32m
YELLOW := \033[1;33m
NC := \033[0m # No Color

help: ## Show this help message
	@echo "$(BLUE)Camagru - Available Commands$(NC)"
	@echo ""
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | awk 'BEGIN {FS = ":.*?## "}; {printf "$(GREEN)%-15s$(NC) %s\n", $$1, $$2}'

build: ## Build Docker containers
	@echo "$(BLUE)Building containers...$(NC)"
	docker-compose build

up: ## Start the application
	@echo "$(GREEN)Starting Camagru...$(NC)"
	docker-compose up -d
	@echo "$(GREEN)Application running at http://localhost:8080$(NC)"
	@echo "$(YELLOW)PHPMyAdmin at http://localhost:8081$(NC)"

down: ## Stop the application
	@echo "$(YELLOW)Stopping Camagru...$(NC)"
	docker-compose down

restart: down up ## Restart the application

logs: ## Show application logs
	docker-compose logs -f

clean: ## Remove containers, volumes, and generated files
	@echo "$(YELLOW)Cleaning up...$(NC)"
	docker-compose down -v
	rm -rf public/uploads/images/*
	@echo "$(GREEN)Cleanup complete$(NC)"

install: ## Initial setup (copy .env and build)
	@echo "$(BLUE)Setting up Camagru...$(NC)"
	@if [ ! -f .env ]; then \
		cp .env.example .env; \
		echo "$(GREEN).env file created$(NC)"; \
		echo "$(YELLOW)Please edit .env with your settings before continuing$(NC)"; \
	else \
		echo "$(YELLOW).env file already exists$(NC)"; \
	fi
	@echo "$(BLUE)Building containers...$(NC)"
	docker-compose build
	@echo "$(GREEN)Setup complete! Run 'make up' to start the application$(NC)"

test: ## Run basic tests
	@echo "$(BLUE)Running tests...$(NC)"
	@echo "$(GREEN)✓ Checking Docker...$(NC)"
	@docker --version
	@echo "$(GREEN)✓ Checking Docker Compose...$(NC)"
	@docker-compose --version
	@echo "$(GREEN)✓ Checking containers...$(NC)"
	@docker-compose ps

db: ## Access MySQL CLI
	@echo "$(BLUE)Accessing MySQL...$(NC)"
	docker-compose exec db mysql -u root -p

shell: ## Access web container shell
	@echo "$(BLUE)Accessing container shell...$(NC)"
	docker-compose exec web bash

status: ## Show container status
	@echo "$(BLUE)Container Status:$(NC)"
	@docker-compose ps
