# Colors
GREEN = \033[0;32m
YELLOW = \033[0;33m
RED = \033[0;31m
BLUE = \033[0;34m
NC = \033[0m

# Python
PYTHON = python3

# Programs
TRAIN = train.py
PREDICT = predict.py
VISUALIZE = visualize.py
PRECISION = precision.py
TEST = test_project.py

# Files
THETAS = thetas.txt
DATA = data.csv

.PHONY: all train predict visualize precision test clean fclean re help

# Default target is help
all: help

help:
	@echo "$(BLUE)========================================$(NC)"
	@echo "$(BLUE)  FT_LINEAR_REGRESSION - MAKEFILE$(NC)"
	@echo "$(BLUE)========================================$(NC)"
	@echo ""
	@echo "$(GREEN)Comandos disponibles:$(NC)"
	@echo "  $(YELLOW)make train$(NC)      - Entrena el modelo"
	@echo "  $(YELLOW)make predict$(NC)    - Ejecuta predicción interactiva"
	@echo "  $(YELLOW)make visualize$(NC)  - Muestra visualización (bonus)"
	@echo "  $(YELLOW)make precision$(NC)  - Calcula precisión (bonus)"
	@echo "  $(YELLOW)make test$(NC)       - Ejecuta suite de pruebas"
	@echo "  $(YELLOW)make clean$(NC)      - Elimina archivo de thetas"
	@echo "  $(YELLOW)make fclean$(NC)     - Limpieza completa"
	@echo "  $(YELLOW)make re$(NC)         - Re-entrena desde cero"
	@echo "  $(YELLOW)make install$(NC)    - Instala dependencias (matplotlib)"
	@echo ""

train:
	@echo "$(GREEN)Entrenando modelo...$(NC)"
	@$(PYTHON) $(TRAIN)

predict:
	@if [ ! -f $(THETAS) ]; then \
		echo "$(RED)Error: No hay modelo entrenado.$(NC)"; \
		echo "$(YELLOW)Ejecuta 'make train' primero.$(NC)"; \
		exit 1; \
	fi
	@echo "$(GREEN)Ejecutando predicción...$(NC)"
	@$(PYTHON) $(PREDICT)

visualize:
	@if [ ! -f $(THETAS) ]; then \
		echo "$(YELLOW)Advertencia: No hay modelo entrenado. Mostrando con valores por defecto.$(NC)"; \
	fi
	@echo "$(GREEN)Generando visualización...$(NC)"
	@$(PYTHON) $(VISUALIZE)

precision:
	@if [ ! -f $(THETAS) ]; then \
		echo "$(RED)Error: No hay modelo entrenado.$(NC)"; \
		echo "$(YELLOW)Ejecuta 'make train' primero.$(NC)"; \
		exit 1; \
	fi
	@echo "$(GREEN)Calculando precisión...$(NC)"
	@$(PYTHON) $(PRECISION)

test:
	@echo "$(GREEN)Ejecutando suite de pruebas...$(NC)"
	@chmod +x $(TEST)
	@$(PYTHON) $(TEST)

install:
	@echo "$(GREEN)Instalando dependencias...$(NC)"
	@pip install matplotlib
	@echo "$(GREEN)✓ matplotlib instalado$(NC)"

clean:
	@if [ -f $(THETAS) ]; then \
		rm -f $(THETAS); \
		echo "$(YELLOW)✓ $(THETAS) eliminado$(NC)"; \
	else \
		echo "$(YELLOW)Nada que limpiar$(NC)"; \
	fi

fclean: clean
	@find . -type f -name "*.pyc" -delete
	@find . -type d -name "__pycache__" -delete
	@echo "$(YELLOW)✓ Limpieza completa realizada$(NC)"

re: fclean train
	@echo "$(GREEN)✓ Modelo re-entrenado desde cero$(NC)"

# Comandos adicionales útiles
demo: train
	@echo "$(GREEN)Ejecutando demostración...$(NC)"
	@echo ""
	@echo "$(BLUE)=== Predicción 1: 50,000 km ===$(NC)"
	@echo "50000" | $(PYTHON) $(PREDICT)
	@echo ""
	@echo "$(BLUE)=== Predicción 2: 100,000 km ===$(NC)"
	@echo "100000" | $(PYTHON) $(PREDICT)
	@echo ""
	@echo "$(BLUE)=== Predicción 3: 150,000 km ===$(NC)"
	@echo "150000" | $(PYTHON) $(PREDICT)
	@echo ""
	@$(MAKE) precision

.PHONY: demo install
