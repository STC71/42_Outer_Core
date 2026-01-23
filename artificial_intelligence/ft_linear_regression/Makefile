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
LEARNING_CURVE = learning_curve.py
TEST = test_auto.sh

# Files
THETAS = thetas.txt
DATA = data.csv

.PHONY: all train predict visualize precision test eval evaluation clean fclean re help bonus

# Default target is help
.DEFAULT_GOAL := help

all:
	@echo "$(BLUE)╔══════════════════════════════════════════════════════════════════════════╗$(NC)"
	@echo "$(BLUE)║     FT_LINEAR_REGRESSION - EJECUCIÓN COMPLETA - sternero - 42 Málaga     ║$(NC)"
	@echo "$(BLUE)╚══════════════════════════════════════════════════════════════════════════╝$(NC)"
	@echo ""
	@echo "$(GREEN)📋 Este comando ejecutará el proyecto completo:$(NC)"
	@echo "   1️⃣  Limpieza de archivos previos"
	@echo "   2️⃣  Entrenamiento del modelo"
	@echo "   3️⃣  Demostración con predicciones"
	@echo "   4️⃣  Cálculo de precisión"
	@echo "   5️⃣  Ejecución de tests"
	@echo ""
	@printf "$(YELLOW)¿Continuar? (s/n): $(NC)"; \
	read answer; \
	if [ "$$answer" = "s" ] || [ "$$answer" = "S" ]; then \
		echo ""; \
		echo "$(BLUE)═══════════════════════════════════════════════════════════$(NC)"; \
		echo "$(GREEN)🧹 PASO 1/5: Limpieza$(NC)"; \
		echo "$(BLUE)═══════════════════════════════════════════════════════════$(NC)"; \
		$(MAKE) fclean; \
		echo ""; \
		echo "$(BLUE)═══════════════════════════════════════════════════════════$(NC)"; \
		echo "$(GREEN)🎓 PASO 2/5: Entrenamiento del modelo$(NC)"; \
		echo "$(BLUE)═══════════════════════════════════════════════════════════$(NC)"; \
		$(MAKE) train; \
		echo ""; \
		echo "$(BLUE)═══════════════════════════════════════════════════════════$(NC)"; \
		echo "$(GREEN)🔮 PASO 3/5: Demostración de predicciones$(NC)"; \
		echo "$(BLUE)═══════════════════════════════════════════════════════════$(NC)"; \
		$(MAKE) demo-silent; \
		echo ""; \
		echo "$(BLUE)═══════════════════════════════════════════════════════════$(NC)"; \
		echo "$(GREEN)📊 PASO 4/5: Cálculo de precisión$(NC)"; \
		echo "$(BLUE)═══════════════════════════════════════════════════════════$(NC)"; \
		$(MAKE) precision; \
		echo ""; \
		echo "$(BLUE)═══════════════════════════════════════════════════════════$(NC)"; \
		echo "$(GREEN)✅ PASO 5/5: Suite de pruebas$(NC)"; \
		echo "$(BLUE)═══════════════════════════════════════════════════════════$(NC)"; \
		$(MAKE) test; \
		echo ""; \
		echo "$(GREEN)╔════════════════════════════════════════════════════════════╗$(NC)"; \
		echo "$(GREEN)║              ✨ EJECUCIÓN COMPLETADA ✨                    ║$(NC)"; \
		echo "$(GREEN)╚════════════════════════════════════════════════════════════╝$(NC)"; \
	else \
		echo "$(YELLOW)Operación cancelada.$(NC)"; \
	fi

bonus:
	@echo "$(BLUE)╔══════════════════════════════════════════════════════════════════════╗$(NC)"
	@echo "$(BLUE)║     FT_LINEAR_REGRESSION - BONUS FEATURES - sternero - 42 Málaga     ║$(NC)"
	@echo "$(BLUE)╚══════════════════════════════════════════════════════════════════════╝$(NC)"
	@echo ""
	@echo "$(GREEN)✨ Este comando ejecutará las funcionalidades bonus:$(NC)"
	@echo "   📊 Cálculo de precisión (R², MSE, RMSE, MAE)"
	@echo "   📈 Visualización gráfica de la regresión"
	@echo ""
	@if [ ! -f $(THETAS) ]; then \
		echo "$(YELLOW)⚠️  No hay modelo entrenado.$(NC)"; \
		printf "$(YELLOW)¿Entrenar ahora? (s/n): $(NC)"; \
		read answer; \
		if [ "$$answer" = "s" ] || [ "$$answer" = "S" ]; then \
			echo ""; \
			$(MAKE) train; \
			echo ""; \
		else \
			echo "$(RED)No se pueden ejecutar los bonus sin modelo.$(NC)"; \
			exit 1; \
		fi; \
	fi
	@printf "$(YELLOW)¿Continuar? (s/n): $(NC)"; \
	read answer; \
	if [ "$$answer" = "s" ] || [ "$$answer" = "S" ]; then \
		echo ""; \
		echo "$(BLUE)═══════════════════════════════════════════════════════════$(NC)"; \
		echo "$(GREEN)📊 BONUS 1/3: Cálculo de precisión$(NC)"; \
		echo "$(BLUE)═══════════════════════════════════════════════════════════$(NC)"; \
		$(MAKE) precision; \
		echo ""; \
		echo "$(BLUE)═══════════════════════════════════════════════════════════$(NC)"; \
		echo "$(GREEN)📈 BONUS 2/3: Visualización gráfica$(NC)"; \
		echo "$(BLUE)═══════════════════════════════════════════════════════════$(NC)"; \
		$(MAKE) visualize; \
		echo ""; \
		echo "$(BLUE)═══════════════════════════════════════════════════════════$(NC)"; \
		echo "$(GREEN)📉 BONUS 3/3: Curva de aprendizaje$(NC)"; \
		echo "$(BLUE)═══════════════════════════════════════════════════════════$(NC)"; \
		$(MAKE) learning_curve; \
		echo ""; \
		echo "$(GREEN)╔════════════════════════════════════════════════════════════╗$(NC)"; \
		echo "$(GREEN)║           ✨ BONUS COMPLETADOS ✨                          ║$(NC)"; \
		echo "$(GREEN)╚════════════════════════════════════════════════════════════╝$(NC)"; \
	else \
		echo "$(YELLOW)Operación cancelada.$(NC)"; \
	fi

help:
	@echo "$(BLUE)╔════════════════════════════════════════════════════════════════════════╗$(NC)"
	@echo "$(BLUE)║     FT_LINEAR_REGRESSION - AYUDA Y COMANDOS - sternero - 42 Málaga     ║$(NC)"
	@echo "$(BLUE)╚════════════════════════════════════════════════════════════════════════╝$(NC)"
	@echo ""
	@echo "$(GREEN)📚 COMANDOS PRINCIPALES:$(NC)"
	@echo "  $(YELLOW)make all$(NC)        - Ejecuta el proyecto completo (recomendado)"
	@echo "  $(YELLOW)make help$(NC)       - Muestra esta ayuda"
	@echo "  $(YELLOW)make bonus$(NC)      - Ejecuta funcionalidades bonus"
	@echo ""
	@echo "$(GREEN)🎯 COMANDOS BÁSICOS:$(NC)"
	@echo "  $(YELLOW)make train$(NC)      - Entrena el modelo con data.csv"
	@echo "  $(YELLOW)make predict$(NC)    - Ejecuta predicción interactiva"
	@echo "  $(YELLOW)make test$(NC)       - Ejecuta suite de pruebas"
	@echo ""
	@echo "$(GREEN)✨ COMANDOS BONUS:$(NC)"
	@echo "  $(YELLOW)make precision$(NC)       - Calcula métricas (R², MSE, RMSE, MAE, MAPE)"
	@echo "  $(YELLOW)make visualize$(NC)       - Muestra gráfico de regresión"
	@echo "  $(YELLOW)make learning_curve$(NC)  - Curva de convergencia del algoritmo"
	@echo ""
	@echo "$(GREEN)🔧 COMANDOS DE MANTENIMIENTO:$(NC)"
	@echo "  $(YELLOW)make clean$(NC)      - Elimina archivo de thetas"
	@echo "  $(YELLOW)make fclean$(NC)     - Limpieza completa (pyc, cache)"
	@echo "  $(YELLOW)make re$(NC)         - Re-entrena desde cero (fclean + train)"
	@echo "  $(YELLOW)make install$(NC)    - Instala dependencias (matplotlib)"
	@echo ""
	@echo "$(GREEN)🎬 COMANDOS DEMOSTRACIÓN:$(NC)"
	@echo "  $(YELLOW)make demo$(NC)       - Demostración con predicciones ejemplo"
	@echo "  $(YELLOW)make evaluation$(NC) - Simulación completa de evaluación 42"
	@echo ""
	@echo "$(BLUE)════════════════════════════════════════════════════════════$(NC)"
	@echo "$(GREEN)💡 Tip: Para empezar, ejecuta '$(YELLOW)make all$(GREEN)'$(NC)"
	@echo "$(GREEN)💡 Para evaluar, ejecuta '$(YELLOW)make evaluation$(GREEN)'$(NC)"
	@echo "$(BLUE)════════════════════════════════════════════════════════════$(NC)"
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

learning_curve:
	@if [ ! -f mse_history.txt ]; then \
		echo "$(RED)Error: No existe historial de entrenamiento.$(NC)"; \
		echo "$(YELLOW)Ejecuta 'make train' primero.$(NC)"; \
		exit 1; \
	fi
	@echo "$(GREEN)Generando curva de aprendizaje...$(NC)"
	@$(PYTHON) $(LEARNING_CURVE)

precision:
	@if [ ! -f $(THETAS) ]; then \
		echo "$(RED)Error: No hay modelo entrenado.$(NC)"; \
		echo "$(YELLOW)Ejecuta 'make train' primero.$(NC)"; \
		exit 1; \
	fi
	@echo "$(GREEN)Calculando precisión...$(NC)"
	@$(PYTHON) $(PRECISION)

test:
	@echo "$(GREEN)Ejecutando suite de pruebas automáticas...$(NC)"
	@chmod +x $(TEST)
	@./$(TEST)

eval:
	@echo "$(BLUE)Iniciando simulación de evaluación 42...$(NC)"
	@chmod +x evaluation.sh
	@./evaluation.sh

evaluation:
	@echo "$(BLUE)╔════════════════════════════════════════════════════════════════════════╗$(NC)"
	@echo "$(BLUE)║      FT_LINEAR_REGRESSION - PREPARACIÓN EVALUACIÓN 42 - sternero       ║$(NC)"
	@echo "$(BLUE)╚════════════════════════════════════════════════════════════════════════╝$(NC)"
	@echo ""
	@echo "$(GREEN)📋 Esta demostración simula la evaluación 42:$(NC)"
	@echo "   ✅ Verificación de requisitos obligatorios"
	@echo "   ✅ Demostración de funcionalidad"
	@echo "   ✅ Explicación de conceptos clave"
	@echo "   ✅ Validación de bonus"
	@echo ""
	@printf "$(YELLOW)¿Iniciar demostración de evaluación? (s/n): $(NC)"; \
	read answer; \
	if [ "$$answer" = "s" ] || [ "$$answer" = "S" ]; then \
		echo ""; \
		echo "$(BLUE)════════════════════════════════════════════════════════════$(NC)"; \
		echo "$(GREEN)📝 PARTE 1/5: VERIFICACIÓN PRELIMINAR$(NC)"; \
		echo "$(BLUE)════════════════════════════════════════════════════════════$(NC)"; \
		echo "$(YELLOW)Verificando estructura del proyecto...$(NC)"; \
		[ -f $(TRAIN) ] && echo "  ✓ train.py presente" || echo "  ✗ train.py falta"; \
		[ -f $(PREDICT) ] && echo "  ✓ predict.py presente" || echo "  ✗ predict.py falta"; \
		[ -f $(DATA) ] && echo "  ✓ data.csv presente" || echo "  ✗ data.csv falta"; \
		echo "$(YELLOW)Verificando librerías prohibidas...$(NC)"; \
		! grep -q "sklearn\|polyfit" $(TRAIN) $(PREDICT) && echo "  ✓ No usa librerías prohibidas" || echo "  ✗ Usa librerías prohibidas"; \
		echo ""; \
		echo "$(BLUE)════════════════════════════════════════════════════════════$(NC)"; \
		echo "$(GREEN)📝 PARTE 2/5: PREDICCIÓN SIN ENTRENAR$(NC)"; \
		echo "$(BLUE)════════════════════════════════════════════════════════════$(NC)"; \
		echo "$(YELLOW)Probando predicción antes de entrenar (debe dar ~0)...$(NC)"; \
		$(MAKE) clean > /dev/null 2>&1; \
		echo "100000" | $(PYTHON) $(PREDICT) 2>/dev/null || echo "  ⚠️  Sin modelo: OK"; \
		echo ""; \
		echo "$(BLUE)════════════════════════════════════════════════════════════$(NC)"; \
		echo "$(GREEN)📝 PARTE 3/5: ENTRENAMIENTO$(NC)"; \
		echo "$(BLUE)════════════════════════════════════════════════════════════$(NC)"; \
		$(MAKE) train; \
		if [ -f $(THETAS) ]; then \
			echo "$(GREEN)  ✓ Archivo $(THETAS) creado correctamente$(NC)"; \
			echo "$(YELLOW)  Parámetros entrenados:$(NC)"; \
			cat $(THETAS) | head -2 | awk '{print "    θ" NR-1 " = " $$1}'; \
		else \
			echo "$(RED)  ✗ No se creó el archivo de thetas$(NC)"; \
		fi; \
		echo ""; \
		echo "$(BLUE)════════════════════════════════════════════════════════════$(NC)"; \
		echo "$(GREEN)📝 PARTE 4/5: DEMOSTRACIÓN DE PREDICCIONES$(NC)"; \
		echo "$(BLUE)════════════════════════════════════════════════════════════$(NC)"; \
		echo "$(YELLOW)Predicciones con modelo entrenado:$(NC)"; \
		echo ""; \
		echo "  🚗 Coche con 50,000 km:"; \
		echo "50000" | $(PYTHON) $(PREDICT) | grep -A1 "Precio" || true; \
		echo ""; \
		echo "  🚗 Coche con 100,000 km:"; \
		echo "100000" | $(PYTHON) $(PREDICT) | grep -A1 "Precio" || true; \
		echo ""; \
		echo "  🚗 Coche con 150,000 km:"; \
		echo "150000" | $(PYTHON) $(PREDICT) | grep -A1 "Precio" || true; \
		echo ""; \
		echo "$(BLUE)════════════════════════════════════════════════════════════$(NC)"; \
		echo "$(GREEN)📝 PARTE 5/5: MÉTRICAS Y BONUS$(NC)"; \
		echo "$(BLUE)════════════════════════════════════════════════════════════$(NC)"; \
		$(MAKE) precision; \
		echo ""; \
		echo "$(YELLOW)Bonus disponibles:$(NC)"; \
		[ -f $(VISUALIZE) ] && echo "  ✓ visualize.py (gráfico de regresión)" || echo "  ✗ visualize.py"; \
		[ -f $(PRECISION) ] && echo "  ✓ precision.py (métricas R², MSE, etc.)" || echo "  ✗ precision.py"; \
		[ -f $(LEARNING_CURVE) ] && echo "  ✓ learning_curve.py (curva convergencia)" || echo "  ✗ learning_curve.py"; \
		echo ""; \
		echo "$(GREEN)╔════════════════════════════════════════════════════════════╗$(NC)"; \
		echo "$(GREEN)║     ✨ DEMOSTRACIÓN COMPLETA - LISTO PARA EVALUAR ✨      ║$(NC)"; \
		echo "$(GREEN)╚════════════════════════════════════════════════════════════╝$(NC)"; \
		echo ""; \
		echo "$(BLUE)💡 CONCEPTOS CLAVE PARA LA DEFENSA:$(NC)"; \
		echo "   • θ₀ = Intersección (precio a 0 km)"; \
		echo "   • θ₁ = Pendiente (cambio de precio por km)"; \
		echo "   • MSE = Error cuadrático medio (métrica de error)"; \
		echo "   • Gradiente Descendente = Algoritmo de optimización"; \
		echo "   • Learning Rate = Tamaño del paso en cada iteración"; \
		echo "   • Normalización = Escalado de datos para convergencia"; \
		echo ""; \
		printf "$(YELLOW)¿Mostrar gráficos bonus? (s/n): $(NC)"; \
		read show_bonus; \
		if [ "$$show_bonus" = "s" ] || [ "$$show_bonus" = "S" ]; then \
			$(MAKE) bonus; \
		fi; \
	else \
		echo "$(YELLOW)Demostración cancelada.$(NC)"; \
	fi

install:
	@echo "$(GREEN)Instalando dependencias...$(NC)"
	@pip install matplotlib
	@echo "$(GREEN)✓ matplotlib instalado$(NC)"

clean:
	@echo "$(GREEN)Limpiando archivos generados...$(NC)"
	@if [ -f $(THETAS) ]; then \
		rm -f $(THETAS); \
		echo "$(YELLOW)✓ $(THETAS) eliminado$(NC)"; \
	fi
	@if [ -f mse_history.txt ]; then \
		rm -f mse_history.txt; \
		echo "$(YELLOW)✓ mse_history.txt eliminado$(NC)"; \
	fi

fclean: clean
	@find . -type f -name "*.pyc" -delete
	@find . -type d -name "__pycache__" -delete
	@if [ -d test_tmp ]; then \
		rm -rf test_tmp; \
		echo "$(YELLOW)✓ test_tmp eliminado$(NC)"; \
	fi
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

demo-silent:
	@echo "50000" | $(PYTHON) $(PREDICT)
	@echo ""
	@echo "100000" | $(PYTHON) $(PREDICT)
	@echo ""
	@echo "150000" | $(PYTHON) $(PREDICT)

.PHONY: demo install demo-silent
