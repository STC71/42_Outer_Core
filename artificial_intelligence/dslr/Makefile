# Makefile para DSLR - Data Science × Regresión Logística

# Colores
GREEN = \033[0;32m
YELLOW = \033[1;33m
RED = \033[0;31m
BLUE = \033[0;34m
NC = \033[0m # Sin Color

# Intérprete Python
PYTHON = python3

# Archivos de datos
TRAIN_DATA = dataset_train.csv
TEST_DATA = dataset_test.csv

# Archivos de modelo
WEIGHTS_BATCH = weights.pkl
WEIGHTS_SGD = weights_sgd.pkl
WEIGHTS_MINIBATCH = weights_minibatch.pkl

# Archivos de salida
PREDICTIONS_BATCH = houses.csv
PREDICTIONS_SGD = houses_sgd.csv
PREDICTIONS_MINIBATCH = houses_minibatch.csv

# Hiperparámetros por defecto
LEARNING_RATE = 0.1
ITERATIONS = 1000
EPOCHS_SGD = 100
EPOCHS_MINIBATCH = 100
BATCH_SIZE = 32

.PHONY: all clean fclean re help describe visualize train predict evaluate \
        train_sgd train_minibatch test bonus

# Target por defecto
all: help

help:
	@echo "$(BLUE)================================================================================$(NC)"
	@echo "$(BLUE)  DSLR - Data Science × Regresión Logística$(NC)"
	@echo "$(BLUE)================================================================================$(NC)"
	@echo ""
	@echo "$(YELLOW)Targets disponibles:$(NC)"
	@echo ""
	@echo "  $(GREEN)describe$(NC)        - Mostrar descripción estadística de datos de entrenamiento"
	@echo "  $(GREEN)visualize$(NC)       - Generar todos los gráficos de visualización"
	@echo "  $(GREEN)train$(NC)           - Entrenar modelo usando Descenso de Gradiente por Lotes"
	@echo "  $(GREEN)predict$(NC)         - Hacer predicciones en datos de prueba"
	@echo "  $(GREEN)evaluate$(NC)        - Evaluar precisión de predicciones"
	@echo "  $(GREEN)test$(NC)            - Ejecutar pipeline completo (entrenar + predecir + evaluar)"
	@echo ""
	@echo "$(YELLOW)Targets bonus:$(NC)"
	@echo ""
	@echo "  $(GREEN)train_sgd$(NC)       - Entrenar usando Descenso de Gradiente Estocástico (BONUS)"
	@echo "  $(GREEN)train_minibatch$(NC) - Entrenar usando Descenso de Gradiente Mini-Batch (BONUS)"
	@echo "  $(GREEN)bonus$(NC)           - Ejecutar todas las implementaciones bonus"
	@echo ""
	@echo "$(YELLOW)Targets de utilidad:$(NC)"
	@echo ""
	@echo "  $(GREEN)clean$(NC)           - Eliminar archivos generados (predicciones, gráficos)"
	@echo "  $(GREEN)fclean$(NC)          - Eliminar todos los archivos generados incluidos modelos"
	@echo "  $(GREEN)re$(NC)              - Limpiar y ejecutar pipeline completo"
	@echo "  $(GREEN)help$(NC)            - Mostrar este mensaje de ayuda"
	@echo ""
	@echo "$(BLUE)================================================================================$(NC)"

# ============================================================================
# PARTE OBLIGATORIA
# ============================================================================

describe:
	@echo "$(YELLOW)Ejecutando análisis estadístico...$(NC)"
	@$(PYTHON) describe.py $(TRAIN_DATA)

visualize:
	@echo "$(YELLOW)Generando visualizaciones...$(NC)"
	@echo "  - Análisis de histograma..."
	@$(PYTHON) histogram.py $(TRAIN_DATA)
	@echo "  - Análisis de gráfico de dispersión..."
	@$(PYTHON) scatter_plot.py $(TRAIN_DATA)
	@echo "  - Matriz de pares..."
	@$(PYTHON) pair_plot.py $(TRAIN_DATA)
	@echo "$(GREEN)✓ Visualizaciones completadas$(NC)"

train:
	@echo "$(YELLOW)Entrenando Regresión Logística (Descenso de Gradiente por Lotes)...$(NC)"
	@$(PYTHON) logreg_train.py $(TRAIN_DATA) $(LEARNING_RATE) $(ITERATIONS)
	@echo "$(GREEN)✓ Entrenamiento completo: $(WEIGHTS_BATCH)$(NC)"

predict: $(WEIGHTS_BATCH)
	@echo "$(YELLOW)Haciendo predicciones...$(NC)"
	@$(PYTHON) logreg_predict.py $(TEST_DATA) $(WEIGHTS_BATCH) $(PREDICTIONS_BATCH)
	@echo "$(GREEN)✓ Predicciones guardadas: $(PREDICTIONS_BATCH)$(NC)"

evaluate: $(PREDICTIONS_BATCH)
	@echo "$(YELLOW)Evaluando rendimiento del modelo...$(NC)"
	@$(PYTHON) evaluate.py $(PREDICTIONS_BATCH) $(TEST_DATA)

test: train predict evaluate
	@echo ""
	@echo "$(GREEN)================================================================================$(NC)"
	@echo "$(GREEN)  PARTE OBLIGATORIA COMPLETADA$(NC)"
	@echo "$(GREEN)================================================================================$(NC)"

# ============================================================================
# PARTE BONUS
# ============================================================================

train_sgd:
	@echo "$(YELLOW)Entrenando con Descenso de Gradiente Estocástico (BONUS)...$(NC)"
	@$(PYTHON) logreg_train_stochastic.py $(TRAIN_DATA) 0.01 $(EPOCHS_SGD)
	@echo "$(GREEN)✓ Entrenamiento SGD completo: $(WEIGHTS_SGD)$(NC)"

predict_sgd: $(WEIGHTS_SGD)
	@echo "$(YELLOW)Haciendo predicciones con modelo SGD...$(NC)"
	@$(PYTHON) logreg_predict.py $(TEST_DATA) $(WEIGHTS_SGD) $(PREDICTIONS_SGD)
	@echo "$(GREEN)✓ Predicciones SGD guardadas: $(PREDICTIONS_SGD)$(NC)"

evaluate_sgd: $(PREDICTIONS_SGD)
	@echo "$(YELLOW)Evaluando modelo SGD...$(NC)"
	@$(PYTHON) evaluate.py $(PREDICTIONS_SGD) $(TEST_DATA)

train_minibatch:
	@echo "$(YELLOW)Entrenando con Descenso de Gradiente Mini-Batch (BONUS)...$(NC)"
	@$(PYTHON) logreg_train_minibatch.py $(TRAIN_DATA) $(LEARNING_RATE) $(EPOCHS_MINIBATCH) $(BATCH_SIZE)
	@echo "$(GREEN)✓ Entrenamiento Mini-Batch completo: $(WEIGHTS_MINIBATCH)$(NC)"

predict_minibatch: $(WEIGHTS_MINIBATCH)
	@echo "$(YELLOW)Haciendo predicciones con modelo Mini-Batch...$(NC)"
	@$(PYTHON) logreg_predict.py $(TEST_DATA) $(WEIGHTS_MINIBATCH) $(PREDICTIONS_MINIBATCH)
	@echo "$(GREEN)✓ Predicciones Mini-Batch guardadas: $(PREDICTIONS_MINIBATCH)$(NC)"

evaluate_minibatch: $(PREDICTIONS_MINIBATCH)
	@echo "$(YELLOW)Evaluando modelo Mini-Batch...$(NC)"
	@$(PYTHON) evaluate.py $(PREDICTIONS_MINIBATCH) $(TEST_DATA)

bonus: test train_sgd predict_sgd evaluate_sgd train_minibatch predict_minibatch evaluate_minibatch
	@echo ""
	@echo "$(GREEN)================================================================================$(NC)"
	@echo "$(GREEN)  PARTE BONUS COMPLETADA$(NC)"
	@echo "$(GREEN)================================================================================$(NC)"
	@echo ""
	@echo "$(BLUE)Comparación de Modelos:$(NC)"
	@echo "  1. Descenso de Gradiente por Lotes : $(PREDICTIONS_BATCH)"
	@echo "  2. GD Estocástico (BONUS)           : $(PREDICTIONS_SGD)"
	@echo "  3. GD Mini-Batch (BONUS)            : $(PREDICTIONS_MINIBATCH)"
	@echo ""

# ============================================================================
# UTILIDADES
# ============================================================================

clean:
	@echo "$(YELLOW)Limpiando archivos generados...$(NC)"
	@rm -f $(PREDICTIONS_BATCH) $(PREDICTIONS_SGD) $(PREDICTIONS_MINIBATCH)
	@rm -f histogram_analysis.png scatter_plot_analysis.png pair_plot.png
	@rm -f preprocessed_data.csv
	@find . -type f -name "*.pyc" -delete
	@find . -type d -name "__pycache__" -delete
	@echo "$(GREEN)✓ Limpieza completa$(NC)"

fclean: clean
	@echo "$(YELLOW)Eliminando pesos de modelos...$(NC)"
	@rm -f $(WEIGHTS_BATCH) $(WEIGHTS_SGD) $(WEIGHTS_MINIBATCH)
	@echo "$(GREEN)✓ Limpieza completa total$(NC)"

re: fclean test
	@echo "$(GREEN)✓ Proyecto reconstruido$(NC)"

# ============================================================================
# TARGETS AVANZADOS
# ============================================================================

# Prueba rápida con parámetros personalizados
quick_test:
	@echo "$(YELLOW)Prueba rápida (menos iteraciones)...$(NC)"
	@$(PYTHON) logreg_train.py $(TRAIN_DATA) 0.1 500
	@$(PYTHON) logreg_predict.py $(TEST_DATA) $(WEIGHTS_BATCH) $(PREDICTIONS_BATCH)
	@$(PYTHON) evaluate.py $(PREDICTIONS_BATCH) $(TEST_DATA)

# Verificar integridad de datos
check_data:
	@echo "$(YELLOW)Verificando archivos de datos...$(NC)"
	@if [ -f "$(TRAIN_DATA)" ]; then \
		echo "$(GREEN)✓ Datos de entrenamiento encontrados$(NC)"; \
		wc -l $(TRAIN_DATA); \
	else \
		echo "$(RED)✗ Datos de entrenamiento no encontrados$(NC)"; \
	fi
	@if [ -f "$(TEST_DATA)" ]; then \
		echo "$(GREEN)✓ Datos de prueba encontrados$(NC)"; \
		wc -l $(TEST_DATA); \
	else \
		echo "$(RED)✗ Datos de prueba no encontrados$(NC)"; \
	fi

# Hacer scripts ejecutables
chmod:
	@chmod +x *.py
	@chmod +x test_pipeline.sh
	@echo "$(GREEN)✓ Los scripts ahora son ejecutables$(NC)"

.PHONY: quick_test check_data chmod
