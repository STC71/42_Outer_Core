#!/bin/bash

# ============================================================================
# evaluation.sh - Guía completa de evaluación según evaluation_ft_linear_regression.pdf
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
    read -p "Presiona Enter para continuar con el siguiente punto..."
    echo -e "${YELLOW}───────────────────────────────────────────────────────────────────${NC}\n"
}

# ============================================================================
# INTRODUCCIÓN
# ============================================================================

show_introduction() {
    clear
    echo -e "${BOLD}${BLUE}"
    echo "╔═══════════════════════════════════════════════════════════════════════╗"
    echo "║                                                                       ║"
    echo "║            FT_LINEAR_REGRESSION - GUÍA DE EVALUACIÓN 42               ║"
    echo "║                                                                       ║"
    echo "║        Basada en: evaluation_ft_linear_regression.pdf                 ║"
    echo "║                                                                       ║"
    echo "╚═══════════════════════════════════════════════════════════════════════╝"
    echo -e "${NC}\n"
    
    echo -e "${CYAN}Este script te guiará a través de la evaluación oficial de 42.${NC}"
    echo -e "${CYAN}Cada punto del PDF será verificado y explicado en detalle.${NC}\n"
    
    echo -e "${YELLOW}Reglas importantes:${NC}"
    echo -e "  • Sé cortés y respetuoso durante la evaluación"
    echo -e "  • Verifica que el trabajo esté en el repositorio Git"
    echo -e "  • No debe haber código malicioso"
    echo -e "  • Si hay trampa → nota final -42"
    echo -e "  • Si hay segfault o crash inesperado → nota final 0"
    
    pause_for_evaluator
}

# ============================================================================
# PRELIMINARES
# ============================================================================

check_preliminaries() {
    print_header "PRELIMINARES - Verificación inicial"
    
    # ========================================================================
    # PRELIMINAR 1: Verificar repositorio Git
    # ========================================================================
    print_section "1. Verificación del repositorio Git"
    
    show_translation "Check again that you are checking what is on the git repository"
    echo -e "${CYAN}   → Verifica nuevamente que estás revisando lo que hay en el repositorio git${NC}\n"
    
    print_check "Buscando repositorio Git..."
    if [ -d ".git" ]; then
        print_pass "Repositorio Git encontrado"
        print_info "Verifica que el contenido es el oficial y no hay aliases maliciosos"
    else
        print_info "No hay repositorio Git local (puede estar en Vogsphere)"
    fi
    
    pause_for_evaluator
    
    # ========================================================================
    # PRELIMINAR 2: Dos programas obligatorios
    # ========================================================================
    print_section "2. Verificación de programas obligatorios"
    
    show_translation "There should be 2 programs, one to predict the price and the other to train the model"
    echo -e "${CYAN}   → Debe haber 2 programas: uno para predecir el precio y otro para entrenar el modelo${NC}\n"
    
    print_check "Verificando existencia de programas..."
    
    local prelim_ok=true
    
    if [ -f "predict.py" ]; then
        print_pass "predict.py existe"
        print_file_reference "predict.py"
        print_info "Este programa predice el precio dado un kilometraje"
    else
        print_fail "predict.py NO EXISTE - Fallo crítico"
        prelim_ok=false
    fi
    
    echo ""
    
    if [ -f "train.py" ]; then
        print_pass "train.py existe"
        print_file_reference "train.py"
        print_info "Este programa entrena el modelo con los datos"
    else
        print_fail "train.py NO EXISTE - Fallo crítico"
        prelim_ok=false
    fi
    
    if [ "$prelim_ok" = true ]; then
        add_point
    else
        fail_point
        echo -e "\n${RED}${BOLD}⚠️  EVALUACIÓN DETENIDA: Faltan programas obligatorios${NC}"
        exit 1
    fi
    
    pause_for_evaluator
    
    # ========================================================================
    # PRELIMINAR 3: Anti-cheating - Librerías prohibidas
    # ========================================================================
    print_section "3. Verificación anti-trampa (CRÍTICO)"
    
    show_translation "Please check that if a library has been used by the student it is not already implemented in it."
    echo -e "${CYAN}   Si usa una librería que ya implementa el algoritmo → TRAMPA${NC}"
    show_translation "If it's the case, stop everything, push the cheat flag and stop the evaluation."
    echo -e "${CYAN}   → Si es el caso, detén todo, marca trampa y detén la evaluación.${NC}\n"
    
    print_check "Verificando librerías prohibidas (numpy.polyfit, sklearn.fit, etc.)..."
    
    local cheating=false
    
    echo -e "\n${YELLOW}Verificando predict.py:${NC}"
    if grep -qE "numpy\.polyfit|sklearn.*\.fit|LinearRegression" predict.py 2>/dev/null; then
        print_fail "predict.py USA LIBRERÍAS PROHIBIDAS"
        cheating=true
        print_file_reference "predict.py" "$(grep -n 'numpy\.polyfit\|sklearn.*\.fit\|LinearRegression' predict.py | cut -d: -f1)"
    else
        print_pass "predict.py NO usa librerías prohibidas"
    fi
    
    echo -e "\n${YELLOW}Verificando train.py:${NC}"
    if grep -qE "numpy\.polyfit|sklearn.*\.fit|LinearRegression" train.py 2>/dev/null; then
        print_fail "train.py USA LIBRERÍAS PROHIBIDAS"
        cheating=true
        print_file_reference "train.py" "$(grep -n 'numpy\.polyfit\|sklearn.*\.fit\|LinearRegression' train.py | cut -d: -f1)"
    else
        print_pass "train.py NO usa librerías prohibidas"
    fi
    
    if [ "$cheating" = true ]; then
        echo -e "\n${RED}${BOLD}═══════════════════════════════════════════════════════════${NC}"
        echo -e "${RED}${BOLD}   ⚠️  TRAMPA DETECTADA - EVALUACIÓN TERMINADA${NC}"
        echo -e "${RED}${BOLD}   NOTA FINAL: -42${NC}"
        echo -e "${RED}${BOLD}═══════════════════════════════════════════════════════════${NC}\n"
        exit 1
    else
        print_pass "NO se detectaron librerías prohibidas"
        add_point
    fi
    
    print_info "Librerías permitidas: matplotlib (solo para visualización), csv, math estándar"
    
    pause_for_evaluator
}

# ============================================================================
# MANDATORY PART
# ============================================================================

# ============================================================================
# PUNTO 1: Predicción ANTES del entrenamiento
# ============================================================================

check_prediction_before_training() {
    print_header "PARTE MANDATORY - PUNTO 1: Predicción sin entrenamiento"
    
    show_translation "Launch the prediction programme. It should ask you for a mileage: Enter a value that is not null"
    echo -e "${CYAN}   → Lanza el programa de predicción. Debe pedir un kilometraje: Introduce un valor no nulo${NC}"
    show_translation "The programme should display the result of its prediction and should print the value 0 because the training hasnt started."
    echo -e "${CYAN}   → El programa debe mostrar el resultado y debe imprimir el valor 0 porque el entrenamiento no ha empezado.${NC}"
    show_translation "Please verify that the equation is : theta0 + (theta1 * x)."
    echo -e "${CYAN}   → Por favor verifica que la ecuación es: theta0 + (theta1 * x)${NC}\n"
    
    # Eliminar archivo de thetas para simular sin entrenamiento
    print_check "Eliminando thetas.txt para simular estado sin entrenamiento..."
    rm -f theta.txt theta_bonus.txt thetas.txt 2>/dev/null
    print_pass "Archivos de thetas eliminados (θ0=0, θ1=0)"
    
    echo ""
    print_section "1A. Verificación de la ecuación en el código"
    
    print_check "Buscando la ecuación estimatePrice = θ0 + (θ1 * mileage) en predict.py..."
    
    if grep -n "theta0.*+.*theta1.*\*" predict.py > /dev/null 2>&1; then
        print_pass "Ecuación encontrada en predict.py"
        
        # Mostrar el código relevante
        local line_num=$(grep -n "theta0.*+.*theta1.*\*" predict.py | head -1 | cut -d: -f1)
        print_file_reference "predict.py" "Línea $line_num"
        local start=$((line_num - 2))
        local end=$((line_num + 2))
        print_code_snippet "predict.py" $start $end
        
        print_info "La ecuación θ0 + (θ1 * mileage) está correctamente implementada"
        add_point
    else
        print_fail "No se encuentra la ecuación especificada"
        fail_point
    fi
    
    pause_for_evaluator
    
    print_section "1B. Prueba práctica de predicción sin entrenamiento"
    
    print_check "Ejecutando predict.py con kilometraje = 100000..."
    echo -e "${YELLOW}Comando: echo '100000' | python3 predict.py${NC}\n"
    
    output=$(echo "100000" | python3 predict.py 2>&1)
    exit_code=$?
    
    if [ $exit_code -eq 0 ]; then
        print_pass "predict.py ejecuta correctamente"
        echo -e "\n${CYAN}Output del programa:${NC}"
        echo "$output"
        
        # Verificar que el output contiene 0
        if echo "$output" | grep -qE "\b0(\.0+)?\b|^0$"; then
            echo ""
            print_pass "Predicción = 0 (correcto cuando θ0=0 y θ1=0)"
            print_info "Explicación: estimatePrice(100000) = 0 + (0 * 100000) = 0"
            add_point
        else
            echo ""
            print_fail "La predicción NO es 0"
            print_info "Con θ0=0 y θ1=0, cualquier predicción debe ser 0"
            fail_point
        fi
    else
        print_fail "predict.py falló con código de error $exit_code"
        fail_point
    fi
    
    pause_for_evaluator
}

# ============================================================================
# PUNTO 2: Fase de entrenamiento
# ============================================================================

check_training_phase() {
    print_header "PARTE MANDATORY - PUNTO 2: Fase de entrenamiento"
    
    show_translation "Ask the student to show you its implementation of the linear regression algorithm."
    echo -e "${CYAN}   → Pide al estudiante que muestre su implementación del algoritmo de regresión lineal.${NC}"
    show_translation "Check that the function in the subject is well implemented and that the program save theta0 and theta1 at the end."
    echo -e "${CYAN}   → Verifica que la función del subject está bien implementada y que el programa guarda theta0 y theta1 al final.${NC}"
    show_translation "Don't forget that if you dont see the equation and you see numpy.polyfit or something that look like [...] It's that the student is cheating."
    echo -e "${CYAN}   → Si no ves la ecuación y ves numpy.polyfit → el estudiante está HACIENDO TRAMPA.${NC}\n"
    
    print_section "2A. Verificación de las fórmulas del subject"
    
    print_check "Buscando implementación de las fórmulas de gradiente descendente..."
    
    print_file_reference "train.py"
    
    # Verificar fórmula tmpθ0
    echo -e "\n${YELLOW}Fórmula 1: tmpθ0 = learningRate * (1/m) * Σ(error)${NC}"
    if grep -q "tmp.*theta0" train.py 2>/dev/null; then
        local line_num=$(grep -n "tmp.*theta0.*=" train.py | head -1 | cut -d: -f1)
        print_pass "tmpθ0 encontrado en línea $line_num"
        print_file_reference "train.py" "Línea $line_num"
        print_code_snippet "train.py" $((line_num - 1)) $((line_num + 1))
        add_point
    else
        print_fail "No se encuentra tmpθ0"
        fail_point
    fi
    
    # Verificar fórmula tmpθ1
    echo -e "\n${YELLOW}Fórmula 2: tmpθ1 = learningRate * (1/m) * Σ(error * mileage)${NC}"
    if grep -q "tmp.*theta1" train.py 2>/dev/null; then
        local line_num=$(grep -n "tmp.*theta1.*=" train.py | head -1 | cut -d: -f1)
        print_pass "tmpθ1 encontrado en línea $line_num"
        print_file_reference "train.py" "Línea $line_num"
        print_code_snippet "train.py" $((line_num - 1)) $((line_num + 1))
        add_point
    else
        print_fail "No se encuentra tmpθ1"
        fail_point
    fi
    
    pause_for_evaluator
    
    print_section "2B. Ejecución del entrenamiento"
    
    print_check "Ejecutando train.py..."
    echo -e "${YELLOW}Comando: python3 train.py${NC}\n"
    
    python3 train.py
    train_exit=$?
    
    if [ $train_exit -eq 0 ]; then
        print_pass "train.py ejecuta correctamente"
        add_point
    else
        print_fail "train.py falló con código $train_exit"
        fail_point
    fi
    
    pause_for_evaluator
    
    print_section "2C. Verificación de guardado de parámetros"
    
    print_check "Verificando que se guardaron θ0 y θ1..."
    
    local theta_file=""
    if [ -f "theta.txt" ]; then
        theta_file="theta.txt"
    elif [ -f "thetas.txt" ]; then
        theta_file="thetas.txt"
    elif [ -f "theta_bonus.txt" ]; then
        theta_file="theta_bonus.txt"
    fi
    
    if [ -n "$theta_file" ]; then
        print_pass "Archivo de thetas encontrado: $theta_file"
        print_file_reference "$theta_file"
        
        echo -e "\n${CYAN}Contenido de $theta_file:${NC}"
        cat "$theta_file"
        
        # Verificar que tiene 2 líneas
        local lines=$(wc -l < "$theta_file")
        echo ""
        if [ "$lines" -eq 2 ]; then
            print_pass "Formato correcto: 2 líneas (θ0 y θ1)"
            
            local theta0=$(head -n 1 "$theta_file")
            local theta1=$(tail -n 1 "$theta_file")
            
            print_info "θ0 = $theta0"
            print_info "θ1 = $theta1"
            
            # Verificar que no son cero
            if [ "$theta0" != "0" ] && [ "$theta1" != "0" ] && [ "$theta0" != "0.0" ] && [ "$theta1" != "0.0" ]; then
                print_pass "Los parámetros fueron entrenados (no son 0)"
                add_point
            else
                print_fail "Los parámetros siguen siendo 0"
                fail_point
            fi
        else
            print_fail "Formato incorrecto: debe tener 2 líneas"
            fail_point
        fi
    else
        print_fail "No se creó archivo de thetas"
        fail_point
    fi
    
    pause_for_evaluator
}

# ============================================================================
# PUNTO 3: Lectura del CSV
# ============================================================================

check_csv_reading() {
    print_header "PARTE MANDATORY - PUNTO 3: Lectura del CSV"
    
    show_translation "The training program should read the csv file and use it for training itself."
    echo -e "${CYAN}   → El programa de entrenamiento debe leer el archivo csv y usarlo para entrenarse.${NC}\n"
    
    print_check "Verificando que train.py lee data.csv..."
    
    if grep -q "data\.csv\|\.csv" train.py 2>/dev/null; then
        print_pass "train.py referencia a archivo CSV"
        
        local line_num=$(grep -n "data\.csv\|\.csv" train.py | head -1 | cut -d: -f1)
        print_file_reference "train.py" "Línea $line_num"
        print_code_snippet "train.py" $((line_num - 2)) $((line_num + 2))
        
        add_point
    else
        print_fail "No se encuentra referencia a CSV"
        fail_point
    fi
    
    print_check "Verificando que data.csv existe y tiene datos..."
    
    if [ -f "data.csv" ]; then
        print_pass "data.csv existe"
        
        local lines=$(wc -l < data.csv)
        print_info "Número de líneas en data.csv: $lines"
        
        echo -e "\n${CYAN}Primeras 3 líneas de data.csv:${NC}"
        head -n 3 data.csv
        
        if [ "$lines" -gt 1 ]; then
            print_pass "data.csv contiene datos"
            add_point
        else
            print_fail "data.csv está vacío"
            fail_point
        fi
    else
        print_fail "data.csv NO EXISTE"
        fail_point
    fi
    
    pause_for_evaluator
}

# ============================================================================
# PUNTO 4: Asignación simultánea (CRÍTICO)
# ============================================================================

check_simultaneous_assignment() {
    print_header "PARTE MANDATORY - PUNTO 4: Asignación simultánea (MUY IMPORTANTE)"
    
    show_translation "It's a bit complex: You should check that theta0 and theta1 are set simultaneously during the training phase."
    echo -e "${CYAN}   → Es un poco complejo: Debes verificar que theta0 y theta1 se establecen simultáneamente durante la fase de entrenamiento.${NC}"
    show_translation "For this verify that the result of the 2 equations during the training phase are saved in temporaries variable before setting theta0 and theta1 at the end of each loop."
    echo -e "${CYAN}   → Para esto verifica que el resultado de las 2 ecuaciones se guardan en variables temporales antes de establecer theta0 y theta1 al final de cada loop.${NC}\n"
    
    print_info "¿Por qué es importante?"
    echo -e "${YELLOW}   Si actualizas θ0 primero y luego θ1, el nuevo valor de θ0 afectará${NC}"
    echo -e "${YELLOW}   al cálculo de θ1, lo cual es INCORRECTO.${NC}"
    echo -e "${YELLOW}   Deben calcularse ambos con los valores ANTIGUOS de θ.${NC}\n"
    
    print_section "4A. Verificación de variables temporales"
    
    print_check "Buscando variables temporales tmp_theta0 y tmp_theta1..."
    
    local has_tmp0=false
    local has_tmp1=false
    
    if grep -q "tmp.*theta0\|temp.*theta0" train.py 2>/dev/null; then
        has_tmp0=true
        local line_num=$(grep -n "tmp.*theta0\|temp.*theta0" train.py | head -1 | cut -d: -f1)
        print_pass "tmp_theta0 encontrado en línea $line_num"
        print_file_reference "train.py" "Línea $line_num"
        print_code_snippet "train.py" $((line_num - 1)) $((line_num + 1))
    else
        print_fail "tmp_theta0 NO encontrado"
    fi
    
    echo ""
    
    if grep -q "tmp.*theta1\|temp.*theta1" train.py 2>/dev/null; then
        has_tmp1=true
        local line_num=$(grep -n "tmp.*theta1\|temp.*theta1" train.py | head -1 | cut -d: -f1)
        print_pass "tmp_theta1 encontrado en línea $line_num"
        print_file_reference "train.py" "Línea $line_num"
        print_code_snippet "train.py" $((line_num - 1)) $((line_num + 1))
    else
        print_fail "tmp_theta1 NO encontrado"
    fi
    
    if [ "$has_tmp0" = true ] && [ "$has_tmp1" = true ]; then
        echo ""
        print_pass "Ambas variables temporales existen"
        add_point
    else
        echo ""
        print_fail "FALLO CRÍTICO: No se usan variables temporales"
        print_info "Esto significa que NO hay asignación simultánea"
        fail_point
    fi
    
    pause_for_evaluator
    
    print_section "4B. Verificación de actualización simultánea"
    
    print_check "Verificando que θ0 y θ1 se actualizan juntos..."
    
    if grep -A2 "theta0.*-=\|theta0.*=" train.py | grep -q "theta1.*-=\|theta1.*="; then
        print_pass "θ0 y θ1 se actualizan consecutivamente"
        
        local line_num=$(grep -n "theta0.*-=\|theta0.*=" train.py | head -1 | cut -d: -f1)
        print_file_reference "train.py" "Líneas $line_num-$((line_num + 3))"
        print_code_snippet "train.py" $((line_num - 1)) $((line_num + 3))
        
        print_info "Patrón correcto:"
        echo -e "${GREEN}   1. Calcular tmp_theta0 con θ antiguos${NC}"
        echo -e "${GREEN}   2. Calcular tmp_theta1 con θ antiguos${NC}"
        echo -e "${GREEN}   3. Actualizar θ0 -= tmp_theta0${NC}"
        echo -e "${GREEN}   4. Actualizar θ1 -= tmp_theta1${NC}"
        
        add_point
    else
        print_fail "θ0 y θ1 NO se actualizan juntos"
        fail_point
    fi
    
    pause_for_evaluator
}

# ============================================================================
# PUNTO 5: Predicción DESPUÉS del entrenamiento
# ============================================================================

check_prediction_after_training() {
    print_header "PARTE MANDATORY - PUNTO 5: Predicción después del entrenamiento"
    
    show_translation "Relaunch the prediction program. Reenter the same mileage as before."
    echo -e "${CYAN}   → Relanza el programa de predicción. Introduce el mismo kilometraje que antes.${NC}"
    show_translation "This time it should give you a price. Enter a value from the csv file."
    echo -e "${CYAN}   → Esta vez debe darte un precio. Introduce un valor del archivo csv.${NC}"
    show_translation "The program should give you a price for each mileage. Is it following the csv prices?"
    echo -e "${CYAN}   → El programa debe darte un precio para cada kilometraje. ¿Sigue los precios del csv?${NC}"
    show_translation "The difference between the csv and the prediction is normal. If the price is exactly the same all the time, we are maybe in a case of over-fitting."
    echo -e "${CYAN}   → La diferencia entre el csv y la predicción es normal. Si el precio es exactamente igual siempre, quizás hay overfitting.${NC}\n"
    
    print_section "5A. Predicción con modelo entrenado"
    
    print_check "Ejecutando predict.py con kilometraje = 100000..."
    echo -e "${YELLOW}Comando: echo '100000' | python3 predict.py${NC}\n"
    
    output=$(echo "100000" | python3 predict.py 2>&1)
    exit_code=$?
    
    if [ $exit_code -eq 0 ]; then
        print_pass "predict.py ejecuta correctamente"
        echo -e "\n${CYAN}Output del programa:${NC}"
        echo "$output"
        
        # Verificar que NO es 0
        if ! echo "$output" | grep -qE "^\s*0(\.0+)?\s*$"; then
            echo ""
            print_pass "Predicción ≠ 0 (correcto, el modelo está entrenado)"
            add_point
        else
            echo ""
            print_fail "La predicción sigue siendo 0"
            print_info "Con un modelo entrenado, la predicción debería ser > 0"
            fail_point
        fi
    else
        print_fail "predict.py falló con código $exit_code"
        fail_point
    fi
    
    pause_for_evaluator
    
    print_section "5B. Prueba con valores del CSV"
    
    print_check "Probando con un valor real del CSV..."
    
    # Obtener un valor del CSV (línea 2, asumiendo que línea 1 es header)
    local csv_km=$(sed -n '2p' data.csv | cut -d',' -f1)
    local csv_price=$(sed -n '2p' data.csv | cut -d',' -f2)
    
    print_info "Del CSV: $csv_km km → $csv_price€"
    
    echo -e "\n${YELLOW}Comando: echo '$csv_km' | python3 predict.py${NC}\n"
    
    output=$(echo "$csv_km" | python3 predict.py 2>&1)
    
    echo -e "${CYAN}Output del programa:${NC}"
    echo "$output"
    
    echo ""
    print_info "Comparación:"
    echo -e "   ${CYAN}Precio real (CSV):${NC}  $csv_price€"
    echo -e "   ${CYAN}Precio predicho:${NC}    $(echo "$output" | grep -oE '[0-9]+(\.[0-9]+)?')"
    
    print_info "Una diferencia es normal y esperada (el modelo generaliza)"
    add_point
    
    pause_for_evaluator
}

# ============================================================================
# BONUS PART
# ============================================================================

check_bonus_features() {
    print_header "PARTE BONUS - Funcionalidades adicionales (hasta 5 puntos)"
    
    show_translation "Bonus: You can count 5 bonus max"
    echo -e "${CYAN}   → Puedes contar máximo 5 puntos bonus${NC}\n"
    
    print_info "Funcionalidades bonus del subject:"
    echo -e "   • Gráfico que muestra los datos"
    echo -e "   • Gráfico que muestra el resultado en el mismo gráfico"
    echo -e "   • Programa para obtener la precisión del algoritmo"
    echo -e "   • Otras mejoras...\n"
    
    # ========================================================================
    # BONUS 1: Visualización
    # ========================================================================
    print_section "BONUS 1: Visualización gráfica"
    
    print_check "Verificando si existe visualize.py..."
    
    if [ -f "visualize.py" ]; then
        print_pass "visualize.py existe"
        print_file_reference "visualize.py"
        
        print_info "Funcionalidad: Muestra gráfico con datos y línea de regresión"
        
        echo -e "\n${YELLOW}¿Quieres ejecutar la visualización? (s/n)${NC}"
        read -n 1 -r
        echo
        if [[ $REPLY =~ ^[Ss]$ ]]; then
            python3 visualize.py
        fi
        
        add_bonus_point
    else
        print_info "visualize.py no existe (opcional)"
    fi
    
    pause_for_evaluator
    
    # ========================================================================
    # BONUS 2: Cálculo de precisión
    # ========================================================================
    print_section "BONUS 2: Cálculo de precisión"
    
    print_check "Verificando si existe precision.py..."
    
    if [ -f "precision.py" ]; then
        print_pass "precision.py existe"
        print_file_reference "precision.py"
        
        print_info "Funcionalidad: Calcula métricas como R², MSE, RMSE, MAE"
        
        echo -e "\n${YELLOW}Ejecutando precision.py...${NC}\n"
        python3 precision.py
        
        add_bonus_point
    else
        print_info "precision.py no existe (opcional)"
    fi
    
    pause_for_evaluator
    
    # ========================================================================
    # BONUS 3: Curva de aprendizaje
    # ========================================================================
    print_section "BONUS 3: Curva de aprendizaje"
    
    print_check "Verificando si existe learning_curve.py..."
    
    if [ -f "learning_curve.py" ]; then
        print_pass "learning_curve.py existe"
        print_file_reference "learning_curve.py"
        
        print_info "Funcionalidad: Muestra cómo converge el MSE durante el entrenamiento"
        
        echo -e "\n${YELLOW}¿Quieres ejecutar la curva de aprendizaje? (s/n)${NC}"
        read -n 1 -r
        echo
        if [[ $REPLY =~ ^[Ss]$ ]]; then
            python3 learning_curve.py
        fi
        
        add_bonus_point
    else
        print_info "learning_curve.py no existe (opcional)"
    fi
    
    pause_for_evaluator
    
    # ========================================================================
    # BONUS 4: Makefile
    # ========================================================================
    print_section "BONUS 4: Makefile bien estructurado"
    
    print_check "Verificando si existe Makefile..."
    
    if [ -f "Makefile" ]; then
        print_pass "Makefile existe"
        print_file_reference "Makefile"
        
        print_info "Reglas disponibles:"
        make help 2>/dev/null || echo "  (ejecuta 'make help' para ver)"
        
        add_bonus_point
    else
        print_info "Makefile no existe (opcional)"
    fi
    
    pause_for_evaluator
    
    # ========================================================================
    # BONUS 5: Explicación de Overfitting
    # ========================================================================
    print_section "BONUS 5: Explicación de Overfitting (según evaluation.pdf)"
    
    show_translation "If the price is exactly the same all the time, we are maybe in a case of over-fitting."
    echo -e "${CYAN}   → Si el precio es exactamente el mismo todo el tiempo, quizás estemos ante un caso de overfitting.${NC}"
    show_translation "(a bonus point if the student can explain what it is)"
    echo -e "${CYAN}   → +1 punto bonus si el estudiante puede explicar qué es${NC}\n"
    
    print_info "Este bonus es CONCEPTUAL - se evalúa durante la defensa oral"
    echo -e ""
    
    print_check "Verificando si el estudiante tiene documentación sobre overfitting..."
    
    if grep -q -i "overfitting\|overfit\|sobreajuste\|sobrejuste" *.md 2>/dev/null; then
        print_pass "Documentación sobre overfitting encontrada"
        
        # Buscar en qué archivo está
        local doc_file=$(grep -l -i "overfitting\|overfit\|sobreajuste\|sobrejuste" *.md 2>/dev/null | head -n 1)
        if [ -n "$doc_file" ]; then
            print_file_reference "$doc_file"
            echo -e "${CYAN}📚 Consulta la documentación antes de la defensa${NC}"
        fi
    else
        print_info "No se encontró documentación escrita sobre overfitting"
        echo -e "${YELLOW}   Recomendación: Prepara la explicación antes de la defensa${NC}"
    fi
    
    echo -e "\n${BOLD}${MAGENTA}PREGUNTA ORAL AL EVALUADO:${NC}"
    echo -e "${CYAN}┌────────────────────────────────────────────────────────────────────┐${NC}"
    echo -e "${CYAN}│${NC} ${BOLD}\"¿Qué es el overfitting y cómo lo detectarías en este proyecto?\"${NC}"
    echo -e "${CYAN}└────────────────────────────────────────────────────────────────────┘${NC}\n"
    
    print_info "Respuesta esperada (resumen):"
    echo -e "   ${GREEN}✓${NC} El overfitting es cuando el modelo memoriza los datos en lugar de"
    echo -e "     aprender el patrón general"
    echo -e "   ${GREEN}✓${NC} Se detecta cuando el MSE es muy bajo en entrenamiento pero alto"
    echo -e "     en datos nuevos (pobre generalización)"
    echo -e "   ${GREEN}✓${NC} En regresión lineal simple es raro (solo 2 parámetros)"
    echo -e "   ${GREEN}✓${NC} Si MSE = 0 (predicciones exactas), sospechar overfitting"
    
    echo -e "\n${YELLOW}¿El estudiante pudo explicar correctamente el concepto? (s/n)${NC}"
    read -n 1 -r
    echo
    if [[ $REPLY =~ ^[Ss]$ ]]; then
        print_pass "El estudiante explica correctamente el overfitting"
        add_bonus_point
    else
        print_info "El estudiante no pudo explicar el overfitting (no suma punto)"
    fi
    
    pause_for_evaluator
}

# ============================================================================
# RESUMEN FINAL
# ============================================================================

show_final_summary() {
    clear
    print_header "RESUMEN FINAL DE LA EVALUACIÓN"
    
    echo -e "${BOLD}Puntos Obligatorios:${NC}"
    echo -e "  Total posible:  $TOTAL_POINTS puntos"
    echo -e "  Obtenidos:      ${GREEN}$POINTS_EARNED puntos${NC}"
    
    local percentage=$((POINTS_EARNED * 100 / TOTAL_POINTS))
    echo -e "  Porcentaje:     $percentage%"
    
    echo -e "\n${BOLD}Puntos Bonus:${NC}"
    echo -e "  Obtenidos:      ${CYAN}$BONUS_POINTS puntos${NC} (máximo 5)"
    
    echo -e "\n${BLUE}╔════════════════════════════════════════════════════════════════════╗${NC}"
    
    if [ $POINTS_EARNED -eq $TOTAL_POINTS ]; then
        echo -e "${GREEN}${BOLD}║                                                                    ║${NC}"
        echo -e "${GREEN}${BOLD}║         ✓✓✓ PARTE MANDATORY: 100% COMPLETA ✓✓✓                    ║${NC}"
        echo -e "${GREEN}${BOLD}║                                                                    ║${NC}"
        if [ $BONUS_POINTS -gt 0 ]; then
            echo -e "${CYAN}${BOLD}║         BONUS: +$BONUS_POINTS puntos adicionales                           ║${NC}"
            echo -e "${CYAN}${BOLD}║                                                                    ║${NC}"
        fi
        echo -e "${GREEN}${BOLD}║         PROYECTO APROBADO - EXCELENTE TRABAJO                      ║${NC}"
    elif [ $percentage -ge 75 ]; then
        echo -e "${YELLOW}${BOLD}║         PROYECTO CASI COMPLETO                                     ║${NC}"
        echo -e "${YELLOW}${BOLD}║         Revisa los puntos fallidos                                 ║${NC}"
    else
        echo -e "${RED}${BOLD}║         PROYECTO NO APROBADO                                       ║${NC}"
        echo -e "${RED}${BOLD}║         Revisa los requisitos obligatorios                         ║${NC}"
    fi
    
    echo -e "${BLUE}╚════════════════════════════════════════════════════════════════════╝${NC}\n"
    
    echo -e "${CYAN}Checklist de verificación:${NC}"
    echo -e "  ☐ El estudiante puede explicar su código"
    echo -e "  ☐ No hay funciones prohibidas"
    echo -e "  ☐ Las fórmulas están correctamente implementadas"
    echo -e "  ☐ La asignación de θ es simultánea"
    echo -e "  ☐ El programa lee correctamente el CSV"
    echo -e "  ☐ Las predicciones son razonables"
    
    echo -e "\n${YELLOW}Recuerda:${NC}"
    echo -e "  • Sé constructivo en tus comentarios"
    echo -e "  • Marca los flags apropiados en la plataforma"
    echo -e "  • Deja un comentario detallado sobre la evaluación"
    
    echo -e "\n${BOLD}¡Gracias por usar esta guía de evaluación!${NC}\n"
}

# ============================================================================
# MAIN
# ============================================================================

main() {
    show_introduction
    
    # PRELIMINARES
    check_preliminaries
    
    # MANDATORY PART
    check_prediction_before_training
    check_training_phase
    check_csv_reading
    check_simultaneous_assignment
    check_prediction_after_training
    
    # BONUS PART
    check_bonus_features
    
    # RESUMEN
    show_final_summary
}

# Ejecutar
main "$@"
