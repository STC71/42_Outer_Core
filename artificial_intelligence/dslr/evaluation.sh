#!/bin/bash

# ============================================================================
# evaluation.sh - Guía completa de evaluación para DSLR
# ============================================================================
# Este script simula la evaluación de 42 punto por punto
# Muestra exactamente qué archivos y líneas implementan cada requisito
# Autor: sternero
# Fecha: Enero 2026
# ============================================================================

# Colores para output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
MAGENTA='\033[0;35m'
NC='\033[0m' # No Color
BOLD='\033[1m'

# Contador de puntos
POINTS_EARNED=0
TOTAL_POINTS=0
BONUS_POINTS=0

# ============================================================================
# FUNCIONES AUXILIARES
# ============================================================================

print_header() {
    echo -e "\n${BLUE}╔════════════════════════════════════════════════════════════════════╗${NC}"
    echo -e "${BLUE}║${BOLD} $1${NC}"
    echo -e "${BLUE}╚════════════════════════════════════════════════════════════════════╝${NC}\n"
}

print_section() {
    echo -e "\n${CYAN}┌────────────────────────────────────────────────────────────────────┐${NC}"
    echo -e "${CYAN}│${BOLD} $1${NC}"
    echo -e "${CYAN}└────────────────────────────────────────────────────────────────────┘${NC}\n"
}

print_requirement() {
    echo -e "${MAGENTA}📋 REQUISITO:${NC} ${BOLD}$1${NC}"
}

print_check() {
    echo -e "${CYAN}🔍 Verificando:${NC} $1"
}

print_pass() {
    echo -e "${GREEN}✓ APROBADO:${NC} $1"
}

print_fail() {
    echo -e "${RED}✗ FALLO:${NC} $1"
}

print_info() {
    echo -e "${YELLOW}ℹ INFO:${NC} $1"
}

print_file_reference() {
    echo -e "${CYAN}📄 Archivo:${NC} ${BOLD}$1${NC}"
    if [ -n "$2" ]; then
        echo -e "${CYAN}📍 Líneas:${NC} $2"
    fi
}

print_code_snippet() {
    local file=$1
    local start=$2
    local end=$3
    echo -e "${YELLOW}╭─── Código relevante:${NC}"
    sed -n "${start},${end}p" "$file" | while IFS= read -r line; do
        echo -e "${YELLOW}│${NC} $line"
    done
    echo -e "${YELLOW}╰───${NC}"
}

show_translation() {
    echo -e "${MAGENTA}🌐 Traducción del PDF:${NC}"
    echo -e "   $1"
}

add_point() {
    POINTS_EARNED=$((POINTS_EARNED + 1))
    TOTAL_POINTS=$((TOTAL_POINTS + 1))
}

add_bonus_point() {
    BONUS_POINTS=$((BONUS_POINTS + 1))
}

fail_point() {
    TOTAL_POINTS=$((TOTAL_POINTS + 1))
}

pause_for_evaluator() {
    echo -e "\n${YELLOW}───────────────────────────────────────────────────────────────────${NC}"
    read -p "Presiona ENTER para continuar..."
    echo -e "${YELLOW}───────────────────────────────────────────────────────────────────${NC}\n"
}

ask_to_continue() {
    echo -e "\n${BLUE}╔════════════════════════════════════════════════════════════════════╗${NC}"
    echo -e "${BLUE}║${BOLD} ¿Deseas continuar con la siguiente sección de evaluación?        ${NC}${BLUE}║${NC}"
    echo -e "${BLUE}╚════════════════════════════════════════════════════════════════════╝${NC}"
    read -p "$(echo -e ${CYAN}Continuar? [S/n]: ${NC})" response
    
    if [[ "$response" =~ ^[Nn] ]]; then
        print_header "EVALUACIÓN PAUSADA POR EL EVALUADOR"
        echo -e "${YELLOW}Puedes reanudar en cualquier momento ejecutando el script de nuevo.${NC}\n"
        exit 0
    fi
    echo ""
}

ask_conceptual_question() {
    local question="$1"
    local explanation="$2"
    local points=$3
    
    echo -e "\n${MAGENTA}╔════════════════════════════════════════════════════════════════════╗${NC}"
    echo -e "${MAGENTA}║${BOLD} PREGUNTA CONCEPTUAL                                                ${NC}${MAGENTA}║${NC}"
    echo -e "${MAGENTA}╚════════════════════════════════════════════════════════════════════╝${NC}"
    echo -e "\n${CYAN}Pregunta al estudiante:${NC}"
    echo -e "${BOLD}$question${NC}\n"
    
    echo -e "${YELLOW}ℹ Respuesta esperada:${NC}"
    echo -e "$explanation\n"
    
    read -p "$(echo -e ${GREEN}¿El estudiante respondió correctamente? [S/n]: ${NC})" response
    
    if [[ "$response" =~ ^[Nn] ]]; then
        print_fail "Respuesta incorrecta o insuficiente"
        fail_point
        return 1
    else
        print_pass "Respuesta correcta"
        add_point
        return 0
    fi
}

# ============================================================================
# INICIO DE EVALUACIÓN
# ============================================================================

clear
print_header "DSLR - Data Science × Logistic Regression - Guía de Evaluación"

echo -e "${CYAN}Esta guía te ayudará a evaluar el proyecto DSLR paso por paso.${NC}"
echo -e "${CYAN}Se verificarán todos los requisitos del subject y se mostrará${NC}"
echo -e "${CYAN}dónde se implementa cada parte en el código.${NC}\n"

pause_for_evaluator

# ============================================================================
# PARTE 1: PRELIMINARES
# ============================================================================

print_header "PARTE 1: PRELIMINARES"

# 1.1 - Verificar archivos requeridos
print_section "1.1 - Verificación de Archivos Requeridos"
print_requirement "Verificar que existen todos los archivos obligatorios"

required_files=(
    "describe.py"
    "histogram.py"
    "scatter_plot.py"
    "pair_plot.py"
    "logreg_train.py"
    "logreg_predict.py"
    "dataset_train.csv"
    "dataset_test.csv"
)

all_files_exist=true
for file in "${required_files[@]}"; do
    if [ -f "$file" ]; then
        print_pass "Encontrado: $file"
    else
        print_fail "Falta: $file"
        all_files_exist=false
    fi
done

if [ "$all_files_exist" = true ]; then
    add_point
    print_pass "Todos los archivos requeridos están presentes"
else
    fail_point
    print_fail "Faltan archivos obligatorios"
fi

pause_for_evaluator

# 1.2 - Verificar librerías prohibidas
print_section "1.2 - Verificación de Librerías"
print_requirement "No se deben usar librerías que implementen el algoritmo completo"
show_translation "No usar sklearn para regresión logística, no usar métodos de pandas DataFrame"

echo -e "${CYAN}Verificando imports en logreg_train.py...${NC}"
print_file_reference "logreg_train.py"

if grep -q "from sklearn" logreg_train.py || grep -q "import sklearn" logreg_train.py; then
    print_fail "Se detectó uso de sklearn en logreg_train.py"
    fail_point
else
    print_pass "No se usa sklearn en logreg_train.py"
    add_point
fi

if grep -q "\.fit(" logreg_train.py || grep -q "\.predict(" logreg_train.py 2>/dev/null; then
    print_warning "Se detectaron métodos .fit() o .predict() - verificar que no sean de sklearn"
fi

ask_to_continue

# ============================================================================
# PARTE 2: DATA Analysis (Parte Obligatoria 1)
# ============================================================================

print_header "PARTE 2: DATA ANALYSIS"

# 2.1 - describe.py
print_section "2.1 - describe.py: Análisis Estadístico"
print_requirement "Implementar describe.py que muestre estadísticas como pandas.describe()"
show_translation "Debe mostrar: Count, Mean, Std, Min, 25%, 50%, 75%, Max para cada característica numérica"

print_file_reference "describe.py"
print_check "Ejecutando describe.py..."

if python3 describe.py dataset_train.csv > /dev/null 2>&1; then
    print_pass "describe.py se ejecuta correctamente"
    add_point
    
    echo -e "\n${CYAN}Mostrando salida de describe.py:${NC}"
    python3 describe.py dataset_train.csv | head -20
    
    print_info "Verificar manualmente que se muestran todas las métricas estadísticas"
else
    print_fail "Error al ejecutar describe.py"
    fail_point
fi

pause_for_evaluator

# 2.1.1 - Preguntas conceptuales sobre estadísticas (según PDF de evaluación)
print_section "2.1.1 - Preguntas Conceptuales: Nociones Estadísticas"
print_requirement "Verificar comprensión de conceptos estadísticos básicos"
show_translation "Ask the assessed student to explain: What is the average (mean)? What is the standard deviation (std)? What is a quartile (25% - 50% - 75%)?"

print_info "El PDF de evaluación indica: 1 respuesta correcta = 1 punto, 2 correctas = 3 puntos, 3 correctas = 5 puntos"
echo ""

# Pregunta 1: Media
ask_conceptual_question \
    "¿Qué es la media (average/mean)?" \
    "La media es la suma de todos los valores dividida por el número de valores.\nFórmula: μ = (Σ xi) / n\nEs una medida de tendencia central que representa el valor promedio del conjunto de datos."

# Pregunta 2: Desviación estándar
ask_conceptual_question \
    "¿Qué es la desviación estándar (standard deviation)?" \
    "La desviación estándar mide la dispersión de los datos respecto a la media.\nIndica cuánto se alejan típicamente los valores del promedio.\nFórmula: σ = √(Σ(xi - μ)² / n)\nValores altos indican mayor dispersión, valores bajos indican datos más agrupados."

# Pregunta 3: Cuartiles
ask_conceptual_question \
    "¿Qué es un cuartil (quartile)? Específicamente 25%, 50% y 75%?" \
    "Los cuartiles dividen el conjunto de datos ordenado en 4 partes iguales:\n- 25% (Q1): El 25% de los datos están por debajo de este valor\n- 50% (Q2): La mediana, el 50% de los datos están por debajo\n- 75% (Q3): El 75% de los datos están por debajo de este valor\nSon útiles para entender la distribución de los datos."

ask_to_continue

# 2.2 - Histogram
print_section "2.2 - histogram.py: Distribución Homogénea"
print_requirement "¿Qué curso de Hogwarts tiene una distribución de notas homogénea entre las 4 casas?"
show_translation "El histograma debe ayudar a responder esta pregunta"

print_file_reference "histogram.py"
print_check "Ejecutando histogram.py..."

if python3 histogram.py dataset_train.csv > /dev/null 2>&1; then
    print_pass "histogram.py genera gráficos correctamente"
    add_point
    
    print_info "Respuesta esperada: Care of Magical Creatures"
    print_info "Verificar que el gráfico muestre distribuciones por casa"
else
    print_fail "Error al ejecutar histogram.py"
    fail_point
fi

ask_to_continue

# 2.3 - Scatter Plot
print_section "2.3 - scatter_plot.py: Características Similares"
print_requirement "¿Qué dos características son similares?"
show_translation "El scatter plot debe mostrar correlaciones entre características"

print_file_reference "scatter_plot.py"
print_check "Ejecutando scatter_plot.py..."

if python3 scatter_plot.py dataset_train.csv > /dev/null 2>&1; then
    print_pass "scatter_plot.py genera gráficos correctamente"
    add_point
    
    print_info "Respuesta esperada: Astronomy y Defense Against the Dark Arts"
    print_info "Verificar que muestre correlación entre características"
else
    print_fail "Error al ejecutar scatter_plot.py"
    fail_point
fi

ask_to_continue

# 2.4 - Pair Plot
print_section "2.4 - pair_plot.py: Matriz de Correlación"
print_requirement "Generar pair plot para todas las características"
show_translation "Debe mostrar matriz de gráficos de todas las combinaciones de características"

print_file_reference "pair_plot.py"
print_check "Ejecutando pair_plot.py..."

if python3 pair_plot.py dataset_train.csv > /dev/null 2>&1; then
    print_pass "pair_plot.py genera matriz de correlación correctamente"
    add_point
    
    print_info "Verificar que se muestren todas las características en una matriz"
    print_info "Cada casa debe tener un color diferente"
else
    print_fail "Error al ejecutar pair_plot.py"
    fail_point
fi

ask_to_continue

# ============================================================================
# PARTE 3: LOGISTIC REGRESSION (Parte Obligatoria 2)
# ============================================================================

print_header "PARTE 3: LOGISTIC REGRESSION"

# 3.0 - Preguntas conceptuales sobre Logistic Regression (según PDF)
print_section "3.0 - Preguntas Conceptuales: Logistic Regression"
print_requirement "Verificar comprensión de regresión logística"
show_translation "Before launching any program, ask the assessed student how the logistic regression works. [...] how logistic regression works compared to linear regression, point in normalising the data, what's the one-vs-all method."

print_info "El evaluador debe verificar que el estudiante comprende estos conceptos clave"
echo ""

# Pregunta 1: Logistic Regression vs Linear Regression
ask_conceptual_question \
    "¿Cómo funciona la regresión logística comparada con la regresión lineal?" \
    "Regresión Lineal: Predice valores continuos (y = θ₀ + θ₁x)\nRegresión Logística: Predice probabilidades entre 0 y 1 usando la función sigmoide\n- Aplica sigmoid a la salida lineal: h(x) = σ(θᵀx) donde σ(z) = 1/(1+e⁻ᶻ)\n- Se usa para CLASIFICACIÓN, no regresión\n- La función de coste es logarítmica (log loss), no error cuadrático medio"

# Pregunta 2: Normalización de datos
ask_conceptual_question \
    "¿Por qué es importante normalizar los datos en regresión logística?" \
    "La normalización es importante porque:\n- Características con diferentes escalas pueden dominar el aprendizaje\n- Acelera la convergencia del gradient descent\n- Evita problemas numéricos (overflow/underflow)\n- Hace que todas las características contribuyan equitativamente\nMétodos comunes: Min-Max scaling o Z-score normalization (μ=0, σ=1)"

# Pregunta 3: One-vs-All (OvA)
ask_conceptual_question \
    "¿Qué es el método One-vs-All (One-vs-Rest) para clasificación multiclase?" \
    "One-vs-All es una estrategia para usar clasificadores binarios en problemas multiclase:\n- Para K clases, se entrenan K clasificadores binarios\n- Cada clasificador distingue una clase vs todas las demás\n- Ejemplo con 4 casas: entrena 4 modelos (Gryffindor vs resto, Hufflepuff vs resto, etc.)\n- Predicción: elegir la clase cuyo clasificador da la mayor probabilidad\n- Alternativa: One-vs-One (entrenar K*(K-1)/2 clasificadores)"

ask_to_continue

# 3.1 - Entrenamiento
print_section "3.1 - logreg_train.py: Entrenamiento del Modelo"
print_requirement "Implementar regresión logística multiclase One-vs-All"
show_translation "Debe entrenar un clasificador para cada casa usando gradient descent"

print_file_reference "logreg_train.py"
print_check "Entrenando modelo..."

if python3 logreg_train.py dataset_train.csv 0.1 1000 > /dev/null 2>&1; then
    print_pass "Entrenamiento completado exitosamente"
    add_point
    
    if [ -f "weights.pkl" ]; then
        print_pass "Archivo weights.pkl generado correctamente"
        add_point
    else
        print_fail "No se generó weights.pkl"
        fail_point
    fi
else
    print_fail "Error durante el entrenamiento"
    fail_point
fi

print_info "Verificar que se implemente:"
echo -e "  - Función sigmoide: σ(z) = 1/(1 + e^(-z))"
echo -e "  - Función de coste: J(θ) = -1/m Σ[y*log(h) + (1-y)*log(1-h)]"
echo -e "  - Gradient descent: θ := θ - α * (1/m) * X^T * (h - y)"

ask_to_continue

# 3.2 - Predicción
print_section "3.2 - logreg_predict.py: Predicción"
print_requirement "Predecir las casas para dataset_test.csv"
show_translation "Debe cargar los pesos y generar houses.csv con las predicciones"

print_file_reference "logreg_predict.py"
print_check "Generando predicciones..."

if [ -f "weights.pkl" ]; then
    if python3 logreg_predict.py dataset_test.csv weights.pkl houses.csv > /dev/null 2>&1; then
        print_pass "Predicciones generadas correctamente"
        add_point
        
        if [ -f "houses.csv" ]; then
            print_pass "Archivo houses.csv creado"
            add_point
            
            line_count=$(wc -l < houses.csv)
            print_info "Número de predicciones: $line_count"
        else
            print_fail "No se generó houses.csv"
            fail_point
        fi
    else
        print_fail "Error al generar predicciones"
        fail_point
    fi
else
    print_fail "No existe weights.pkl - ejecutar entrenamiento primero"
    fail_point
fi

ask_to_continue

# 3.3 - Evaluación de Precisión
print_section "3.3 - Evaluación de Precisión"
print_requirement "El modelo debe alcanzar al menos 98% de precisión"

if [ -f "houses.csv" ] && [ -f "evaluate.py" ]; then
    print_check "Evaluando precisión del modelo..."
    
    accuracy_output=$(python3 evaluate.py houses.csv dataset_test.csv 2>&1)
    
    if [ $? -eq 0 ]; then
        echo -e "\n${CYAN}Resultado de la evaluación:${NC}"
        echo "$accuracy_output"
        
        # Intentar extraer la precisión
        accuracy=$(echo "$accuracy_output" | grep -oP 'Accuracy|Precisión.*?(\d+\.\d+)%' | grep -oP '\d+\.\d+' | head -1)
        
        if [ -n "$accuracy" ]; then
            print_info "Precisión obtenida: ${accuracy}%"
            
            if (( $(echo "$accuracy >= 98.0" | bc -l) )); then
                print_pass "✓ Precisión ≥ 98% - EXCELENTE"
                add_point
            else
                print_warning "Precisión < 98% - revisar el modelo"
                fail_point
            fi
        else
            print_info "Verificar manualmente la precisión en la salida anterior"
        fi
    else
        print_warning "Error al ejecutar evaluate.py"
    fi
else
    print_warning "Faltan archivos para evaluar (houses.csv o evaluate.py)"
fi

ask_to_continue

# ============================================================================
# PARTE 4: BONUS
# ============================================================================

print_header "PARTE 4: BONUS (Opcional)"

# 4.1 - Implementaciones adicionales de gradient descent
print_section "4.1 - Implementaciones Bonus de Gradient Descent"

bonus_implementations=(
    "logreg_train_stochastic.py:Stochastic Gradient Descent"
    "logreg_train_minibatch.py:Mini-Batch Gradient Descent"
)

for impl in "${bonus_implementations[@]}"; do
    IFS=':' read -r file desc <<< "$impl"
    
    if [ -f "$file" ]; then
        print_check "Verificando $desc ($file)..."
        
        if python3 "$file" dataset_train.csv 0.01 100 > /dev/null 2>&1; then
            print_pass "$desc implementado correctamente"
            add_bonus_point
        else
            print_warning "$desc encontrado pero falla al ejecutar"
        fi
    fi
done

# 4.2 - Análisis estadístico extendido
print_section "4.2 - Estadísticas Adicionales en describe.py"

if grep -q "mode\|Mode\|MODE" describe.py 2>/dev/null; then
    print_pass "Implementa estadísticas adicionales (moda, rango, etc.)"
    add_bonus_point
fi

# 4.3 - Validación cruzada
if [ -f "cross_validate.py" ]; then
    print_pass "Implementa validación cruzada (cross_validate.py)"
    add_bonus_point
fi

# 4.4 - Visualizaciones adicionales
if [ -f "learning_curve.py" ]; then
    print_pass "Implementa curvas de aprendizaje"
    add_bonus_point
fi

pause_for_evaluator

# ============================================================================
# RESUMEN FINAL
# ============================================================================

print_header "RESUMEN DE EVALUACIÓN"

echo -e "${CYAN}╔════════════════════════════════════════════════════════════════════╗${NC}"
echo -e "${CYAN}║${BOLD}                      PUNTUACIÓN FINAL                              ${NC}${CYAN}║${NC}"
echo -e "${CYAN}╠════════════════════════════════════════════════════════════════════╣${NC}"
echo -e "${CYAN}║${NC} Puntos Obligatorios: ${BOLD}$POINTS_EARNED${NC} / ${BOLD}$TOTAL_POINTS${NC}                                  ${CYAN}║${NC}"
echo -e "${CYAN}║${NC} Puntos Bonus:        ${BOLD}$BONUS_POINTS${NC}                                            ${CYAN}║${NC}"
echo -e "${CYAN}╚════════════════════════════════════════════════════════════════════╝${NC}"

# Calcular porcentaje
if [ $TOTAL_POINTS -gt 0 ]; then
    percentage=$((POINTS_EARNED * 100 / TOTAL_POINTS))
    echo -e "\n${CYAN}Porcentaje de requisitos cumplidos: ${BOLD}${percentage}%${NC}"
fi

echo -e "\n${YELLOW}Checklist de evaluación:${NC}"
echo -e "  ${GREEN}✓${NC} Todos los archivos obligatorios presentes"
echo -e "  ${GREEN}✓${NC} No se usan librerías prohibidas"
echo -e "  ${GREEN}✓${NC} describe.py implementado correctamente"
echo -e "  ${GREEN}✓${NC} Preguntas conceptuales sobre estadísticas"
echo -e "  ${GREEN}✓${NC} Visualizaciones (histogram, scatter_plot, pair_plot)"
echo -e "  ${GREEN}✓${NC} Preguntas conceptuales sobre logistic regression"
echo -e "  ${GREEN}✓${NC} logreg_train.py entrena el modelo"
echo -e "  ${GREEN}✓${NC} logreg_predict.py genera predicciones"
echo -e "  ${GREEN}✓${NC} Precisión ≥ 98%"

if [ $BONUS_POINTS -gt 0 ]; then
    echo -e "\n${MAGENTA}Bonus implementados: $BONUS_POINTS${NC}"
fi

echo -e "\n${BLUE}═══════════════════════════════════════════════════════════════════${NC}"
echo -e "${BOLD}Para más detalles, revisar el código manualmente con el evaluado.${NC}"
echo -e "${BLUE}═══════════════════════════════════════════════════════════════════${NC}\n"

# Recomendación final
if [ $POINTS_EARNED -eq $TOTAL_POINTS ] && [ $POINTS_EARNED -gt 0 ]; then
    echo -e "${GREEN}${BOLD}✓ TODOS LOS REQUISITOS OBLIGATORIOS CUMPLIDOS${NC}"
    echo -e "${GREEN}El proyecto puede ser VALIDADO${NC}\n"
elif [ $percentage -ge 75 ]; then
    echo -e "${YELLOW}⚠ CASI TODOS LOS REQUISITOS CUMPLIDOS${NC}"
    echo -e "${YELLOW}Revisar los puntos fallidos antes de validar${NC}\n"
else
    echo -e "${RED}✗ FALTAN REQUISITOS IMPORTANTES${NC}"
    echo -e "${RED}El proyecto necesita más trabajo${NC}\n"
fi
