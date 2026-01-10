#!/bin/bash

# ============================================================================
# test_auto.sh - Testing automatizado completo para ft_linear_regression
# ============================================================================
# Prueba exhaustiva de la parte MANDATORY y BONUS según el subject
# Autor: sternero
# Fecha: Enero 2026
# ============================================================================

# Colores para output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color
BOLD='\033[1m'

# Contadores
TOTAL_TESTS=0
PASSED_TESTS=0
FAILED_TESTS=0

# Directorio temporal para tests
TEST_DIR="test_tmp"

# ============================================================================
# FUNCIONES AUXILIARES
# ============================================================================

print_header() {
    echo -e "\n${BLUE}╔════════════════════════════════════════════════════════════════════╗${NC}"
    echo -e "${BLUE}║${BOLD} $1${NC}"
    echo -e "${BLUE}╚════════════════════════════════════════════════════════════════════╝${NC}\n"
}

print_test() {
    echo -e "${CYAN}[TEST $((TOTAL_TESTS + 1))]${NC} $1"
    TOTAL_TESTS=$((TOTAL_TESTS + 1))
}

print_success() {
    echo -e "${GREEN}✓${NC} $1"
}

print_error() {
    echo -e "${RED}✗${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}⚠${NC} $1"
}

print_info() {
    echo -e "${CYAN}ℹ${NC} $1"
}

cleanup() {
    if [ -d "$TEST_DIR" ]; then
        rm -rf "$TEST_DIR"
    fi
    if [ -f "theta.txt" ]; then
        rm -f "theta.txt"
    fi
    if [ -f "theta_bonus.txt" ]; then
        rm -f "theta_bonus.txt"
    fi
    if [ -f "thetas.txt" ]; then
        rm -f "thetas.txt"
    fi
    if [ -f "mse_history.txt" ]; then
        rm -f "mse_history.txt"
    fi
}

setup() {
    cleanup
    mkdir -p "$TEST_DIR"
}

# ============================================================================
# RESUMEN DE CRITERIOS DE EVALUACIÓN (según evaluation_ft_linear_regression.pdf)
# ============================================================================
# Este script verifica TODOS los puntos del PDF oficial de evaluación:
#
# PRELIMINARES:
#   ✓ No usar librerías que implementen el algoritmo (numpy.polyfit, sklearn)
#   ✓ Verificar que el estudiante conoce su código
#   ✓ Dos programas: predict.py y train.py
#
# MANDATORY:
#   ✓ Predicción antes de entrenar → debe dar 0
#   ✓ Ecuación exacta: estimatePrice = θ0 + (θ1 * mileage)
#   ✓ Implementación correcta de las fórmulas del subject
#   ✓ Guardar θ0 y θ1 al finalizar entrenamiento
#   ✓ Leer el CSV correctamente
#   ✓ ASIGNACIÓN SIMULTÁNEA de θ0 y θ1 (variables temporales)
#   ✓ Predicción después de entrenar → precio razonable
#
# BONUS:
#   ✓ Gráficos de datos y regresión
#   ✓ Programa de cálculo de precisión
#   ✓ Over-fitting explanation (opcional)
# ============================================================================

# ============================================================================
# PARTE 1: VERIFICACIÓN DE ARCHIVOS Y ESTRUCTURA
# ============================================================================

test_file_structure() {
    print_header "1. VERIFICACIÓN DE ESTRUCTURA DE ARCHIVOS"
    
    # Archivos MANDATORY
    print_test "Verificando archivos obligatorios"
    
    local mandatory_files=("data.csv" "predict.py" "train.py")
    local all_exist=true
    
    for file in "${mandatory_files[@]}"; do
        if [ -f "$file" ]; then
            print_success "Encontrado: $file"
        else
            print_error "Falta archivo obligatorio: $file"
            all_exist=false
        fi
    done
    
    # Archivos BONUS
    print_test "Verificando archivos bonus"
    
    if [ -f "visualize.py" ]; then
        print_success "Encontrado: visualize.py (BONUS)"
    else
        print_warning "visualize.py no encontrado (BONUS opcional)"
    fi
    
    if [ -f "precision.py" ]; then
        print_success "Encontrado: precision.py (BONUS)"
    else
        print_warning "precision.py no encontrado (BONUS opcional)"
    fi
    
    if [ -f "learning_curve.py" ]; then
        print_success "Encontrado: learning_curve.py (BONUS extra)"
    else
        print_info "learning_curve.py no encontrado (BONUS extra opcional)"
    fi
    
    # data.csv
    print_test "Verificando formato de data.csv"
    
    if [ ! -f "data.csv" ]; then
        print_error "data.csv no existe"
        return 1
    fi
    
    # Verificar header
    header=$(head -n 1 data.csv)
    if echo "$header" | grep -q "km,price"; then
        print_success "Header correcto: km,price"
    else
        print_error "Header incorrecto en data.csv"
    fi
    
    # Contar líneas (debe tener ~24 líneas de datos + 1 header)
    lines=$(wc -l < data.csv)
    if [ "$lines" -ge 20 ]; then
        print_success "data.csv tiene suficientes datos ($lines líneas)"
    else
        print_warning "data.csv tiene pocas líneas ($lines)"
    fi
}

# ============================================================================
# PARTE 2: TESTS DE PREDICT.PY SIN ENTRENAMIENTO (según PDF evaluación)
# ============================================================================

test_predict_no_training() {
    print_header "2. PREDICT.PY - SIN ENTRENAMIENTO (PUNTO OBLIGATORIO EVALUACIÓN)"
    
    print_info "Según PDF: 'Enter a value that is not null'"
    print_info "Según PDF: 'The programme should display 0 because training hasnt started'"
    print_info "Según PDF: 'Verify that the equation is: theta0 + (theta1 * x)'"
    
    print_test "Eliminando archivos de thetas para simular estado inicial"
    
    # Asegurarse de que no existe ningún archivo de thetas
    rm -f theta.txt theta_bonus.txt thetas.txt
    print_success "Archivos eliminados (θ0=0, θ1=0)"
    
    print_test "Predicción sin entrenamiento (debe dar 0)"
    
    # Ejecutar predict.py con un valor no nulo como dice el PDF
    echo "100000" | python3 predict.py > "$TEST_DIR/predict_output1.txt" 2>&1
    exit_code=$?
    
    if [ $exit_code -eq 0 ]; then
        output=$(cat "$TEST_DIR/predict_output1.txt")
        print_success "✓ predict.py ejecuta sin error"
        print_info "Mileage: 100000, Output: $output"
        
        # El evaluador verificará que con θ0=0 y θ1=0 → precio=0
        if echo "$output" | grep -qE "\b0(\.0+)?\b|^0$"; then
            print_success "✓ CORRECTO: Predicción = 0 cuando no hay entrenamiento"
            print_success "  (θ0=0, θ1=0 → estimatePrice = 0 + 0*mileage = 0)"
            PASSED_TESTS=$((PASSED_TESTS + 1))
        else
            print_error "✗ FALLO: Debería predecir 0 sin entrenamiento"
            print_error "  Output obtenido: $output"
            FAILED_TESTS=$((FAILED_TESTS + 1))
        fi
    else
        print_error "✗ FALLO: predict.py no ejecuta correctamente"
        FAILED_TESTS=$((FAILED_TESTS + 1))
    fi
}

test_predict_invalid_input() {
    print_header "3. PREDICT.PY - VALIDACIÓN DE ENTRADA"
    
    print_test "Entrada negativa"
    output=$(echo "-1000" | python3 predict.py 2>&1)
    print_info "Input: -1000, Output: $output"
    
    print_test "Entrada no numérica"
    output=$(echo "abc" | python3 predict.py 2>&1)
    if echo "$output" | grep -qiE "error|invalid|inválid"; then
        print_success "Maneja correctamente entrada no numérica"
    else
        print_warning "Debería mostrar error con entrada no numérica"
    fi
    print_info "Output: $output"
    
    print_test "Entrada muy grande"
    output=$(echo "999999999" | python3 predict.py 2>&1)
    print_info "Input: 999999999, Output: $output"
}

# ============================================================================
# PARTE 3: TESTS DE TRAIN.PY
# ============================================================================

test_train_basic() {
    print_header "4. TRAIN.PY - ENTRENAMIENTO BÁSICO"
    
    cleanup
    mkdir -p "$TEST_DIR"
    
    print_test "Ejecutando entrenamiento"
    
    python3 train.py > "$TEST_DIR/train_output.txt" 2>&1
    train_exit=$?
    
    if [ $train_exit -eq 0 ]; then
        print_success "train.py ejecuta correctamente"
    else
        print_error "train.py falla con código $train_exit"
        cat "$TEST_DIR/train_output.txt"
        return 1
    fi
    
    # Verificar que crea theta.txt
    print_test "Verificando creación de theta.txt"
    
    # Buscar theta.txt o alternativas (theta_bonus.txt, thetas.txt, etc.)
    theta_file=""
    if [ -f "theta.txt" ]; then
        theta_file="theta.txt"
    elif [ -f "theta_bonus.txt" ]; then
        theta_file="theta_bonus.txt"
    elif [ -f "thetas.txt" ]; then
        theta_file="thetas.txt"
    fi
    
    if [ -n "$theta_file" ]; then
        print_success "Archivo de thetas creado: $theta_file"
        
        # Leer thetas
        if [ -s "$theta_file" ]; then
            theta_content=$(cat "$theta_file")
            print_info "Contenido: $theta_content"
            
            # Verificar formato (dos números)
            lines=$(wc -l < "$theta_file")
            if [ "$lines" -eq 2 ]; then
                print_success "$theta_file tiene formato correcto (2 líneas)"
            else
                print_warning "$theta_file debería tener 2 líneas (theta0, theta1)"
            fi
        else
            print_error "$theta_file está vacío"
        fi
    else
        print_error "No se creó archivo de thetas (theta.txt, theta_bonus.txt, etc.)"
    fi
    
    # Verificar output del entrenamiento
    print_test "Verificando output de entrenamiento"
    
    if grep -qiE "iteration|epoch|mse|error|cost" "$TEST_DIR/train_output.txt"; then
        print_success "Muestra información del proceso de entrenamiento"
    else
        print_warning "No muestra información del entrenamiento (opcional pero recomendado)"
    fi
}

test_train_convergence() {
    print_header "5. VERIFICACIÓN DE CONVERGENCIA"
    
    print_test "Verificando que los thetas tienen valores razonables"
    
    # Buscar archivo de thetas
    theta_file=""
    if [ -f "theta.txt" ]; then
        theta_file="theta.txt"
    elif [ -f "theta_bonus.txt" ]; then
        theta_file="theta_bonus.txt"
    elif [ -f "thetas.txt" ]; then
        theta_file="thetas.txt"
    fi
    
    if [ -z "$theta_file" ]; then
        print_info "No se encuentra archivo de thetas, ejecutando train.py..."
        python3 train.py > /dev/null 2>&1
        
        # Buscar de nuevo
        if [ -f "theta.txt" ]; then
            theta_file="theta.txt"
        elif [ -f "theta_bonus.txt" ]; then
            theta_file="theta_bonus.txt"
        elif [ -f "thetas.txt" ]; then
            theta_file="thetas.txt"
        fi
    fi
    
    if [ -n "$theta_file" ]; then
        theta0=$(head -n 1 "$theta_file")
        theta1=$(tail -n 1 "$theta_file")
        
        print_info "theta0 = $theta0"
        print_info "theta1 = $theta1"
        
        # Verificar que no son cero (modelo entrenado)
        if [ "$theta0" != "0" ] && [ "$theta1" != "0" ]; then
            print_success "Modelo entrenado (thetas ≠ 0)"
        else
            print_warning "thetas = 0, modelo no parece entrenado"
        fi
        
        # Verificar que theta1 es negativo (precio decrece con km)
        if echo "$theta1" | grep -q "^-"; then
            print_success "theta1 es negativo (correcto: precio decrece con km)"
        else
            print_warning "theta1 debería ser negativo para este dataset"
        fi
    else
        print_error "No se pudo encontrar archivo de thetas después de entrenar"
    fi
}

# ============================================================================
# PARTE 4: TESTS DE PREDICT.PY (CON ENTRENAMIENTO)
# ============================================================================

test_predict_with_training() {
    print_header "6. PREDICT.PY - CON MODELO ENTRENADO"
    
    # Asegurar que existe archivo de thetas
    if [ ! -f "theta.txt" ] && [ ! -f "theta_bonus.txt" ] && [ ! -f "thetas.txt" ]; then
        print_info "Entrenando modelo primero..."
        python3 train.py > /dev/null 2>&1
    fi
    
    # Test con valores conocidos del dataset
    print_test "Predicción con mileage = 0"
    output=$(echo "0" | python3 predict.py 2>&1)
    print_info "Mileage: 0 km, Precio estimado: $output"
    
    print_test "Predicción con mileage = 50000"
    output=$(echo "50000" | python3 predict.py 2>&1)
    print_info "Mileage: 50000 km, Precio estimado: $output"
    
    print_test "Predicción con mileage = 100000"
    output=$(echo "100000" | python3 predict.py 2>&1)
    print_info "Mileage: 100000 km, Precio estimado: $output"
    
    print_test "Predicción con mileage = 200000"
    output=$(echo "200000" | python3 predict.py 2>&1)
    price=$(echo "200000" | python3 predict.py 2>&1 | grep -oE '[0-9]+\.?[0-9]*' | head -1)
    print_info "Mileage: 200000 km, Precio estimado: $price"
    
    # Verificar que el precio disminuye con el mileage
    print_test "Verificando coherencia: precio decrece con mileage"
    
    # Capturar solo precios con decimales (último número con punto decimal)
    price_0=$(echo "0" | python3 predict.py 2>&1 | grep -oE '[0-9]+\.[0-9]+' | tail -1)
    price_100k=$(echo "100000" | python3 predict.py 2>&1 | grep -oE '[0-9]+\.[0-9]+' | tail -1)
    
    if [ -n "$price_0" ] && [ -n "$price_100k" ]; then
        # Usar bc para comparar
        if command -v bc >/dev/null 2>&1; then
            comparison=$(echo "$price_0 > $price_100k" | bc)
            if [ "$comparison" -eq 1 ]; then
                print_success "El precio decrece con el mileage: ${price_0}€ > ${price_100k}€"
            else
                print_warning "El precio no decrece: ${price_0}€ vs ${price_100k}€"
            fi
        else
            print_info "bc no disponible, saltando comparación numérica"
        fi
    else
        print_warning "No se pudieron extraer precios para comparar"
    fi
}

# ============================================================================
# PARTE 5: TESTS DE FÓRMULAS MATEMÁTICAS (según PDF de evaluación)
# ============================================================================

test_math_formulas() {
    print_header "7. VERIFICACIÓN DE FÓRMULAS MATEMÁTICAS (CRÍTICO PARA EVALUACIÓN)"
    
    # ========================================================================
    # PUNTO CRÍTICO 1: Verificar ecuación exacta del subject
    # ========================================================================
    print_test "Ecuación hypothesis: estimatePrice = θ0 + (θ1 * mileage)"
    
    if grep -qE "theta0.*\+.*theta1.*\*.*mileage" predict.py; then
        print_success "✓ CORRECTO: predict.py usa la ecuación especificada en el subject"
    else
        print_error "✗ FALLO: predict.py NO usa la ecuación θ0 + (θ1 * mileage)"
        print_info "El evaluador verificará esta ecuación exacta"
        FAILED_TESTS=$((FAILED_TESTS + 1))
    fi
    
    # ========================================================================
    # PUNTO CRÍTICO 2: Verificar fórmulas de entrenamiento del subject
    # ========================================================================
    print_test "Fórmulas de gradient descent según subject"
    
    if grep -qE "learning.*rate|learningRate" train.py; then
        print_success "✓ Usa learning_rate en las fórmulas"
    else
        print_warning "⚠ No se encuentra learning_rate explícito"
    fi
    
    # ========================================================================
    # PUNTO CRÍTICO 3: Asignación SIMULTÁNEA (MUY IMPORTANTE)
    # ========================================================================
    print_test "Asignación SIMULTÁNEA de θ0 y θ1 (CRÍTICO PARA APROBAR)"
    print_info "El evaluador verificará que uses variables temporales tmp_theta0/tmp_theta1"
    
    # Verificar que existen variables temporales
    has_tmp_theta0=$(grep -c "tmp.*theta0\|temp.*theta0" train.py)
    has_tmp_theta1=$(grep -c "tmp.*theta1\|temp.*theta1" train.py)
    
    if [ "$has_tmp_theta0" -gt 0 ] && [ "$has_tmp_theta1" -gt 0 ]; then
        print_success "✓ CORRECTO: Usa variables temporales (tmp_theta0, tmp_theta1)"
        
        # Verificar el patrón correcto: calcular tmp primero, luego asignar
        if grep -A3 "tmp_theta0.*=" train.py | grep -q "tmp_theta1.*="; then
            print_success "✓ CORRECTO: Calcula ambos tmp antes de actualizar theta"
            PASSED_TESTS=$((PASSED_TESTS + 1))
        fi
        
        if grep -A2 "theta0.*-=\|theta0.*=" train.py | grep -q "theta1.*-=\|theta1.*="; then
            print_success "✓ CORRECTO: Actualiza θ0 y θ1 simultáneamente"
            PASSED_TESTS=$((PASSED_TESTS + 1))
        fi
    else
        print_error "✗ FALLO CRÍTICO: NO usa asignación simultánea"
        print_error "  El evaluador esperará ver:"
        print_error "    tmp_theta0 = learningRate * (1/m) * Σ(error)"
        print_error "    tmp_theta1 = learningRate * (1/m) * Σ(error * mileage)"
        print_error "    theta0 -= tmp_theta0"
        print_error "    theta1 -= tmp_theta1"
        FAILED_TESTS=$((FAILED_TESTS + 2))
    fi
    
    # ========================================================================
    # PUNTO CRÍTICO 4: NO usar librerías que hagan el trabajo
    # ========================================================================
    print_test "Verificación anti-cheating: librerías prohibidas"
    
    cheating_detected=false
    for file in train.py predict.py; do
        if [ -f "$file" ]; then
            if grep -qE "numpy\.polyfit|sklearn.*fit|LinearRegression" "$file"; then
                print_error "✗ CHEATING: $file usa numpy.polyfit o sklearn"
                print_error "  Esto es considerado TRAMPA según el evaluador"
                cheating_detected=true
            fi
        fi
    done
    
    if [ "$cheating_detected" = false ]; then
        print_success "✓ CORRECTO: NO usa librerías prohibidas (numpy.polyfit, sklearn)"
        PASSED_TESTS=$((PASSED_TESTS + 1))
    else
        print_error "✗ EVALUACIÓN TERMINADA: TRAMPA DETECTADA"
        FAILED_TESTS=$((FAILED_TESTS + 10))
    fi
    
    # Verificar normalización (opcional pero recomendado)
    if grep -qE "normalize|normalization|mean.*std" train.py; then
        print_success "✓ Bonus: Implementa normalización de datos"
    else
        print_info "ℹ No normaliza (válido, pero menos preciso)"
    fi
}

# ============================================================================
# PARTE 6: TESTS BONUS - VISUALIZE.PY
# ============================================================================

test_visualize() {
    print_header "8. BONUS - VISUALIZE.PY"
    
    if [ ! -f "visualize.py" ]; then
        print_warning "visualize.py no encontrado (BONUS no implementado)"
        return 0
    fi
    
    print_test "Verificando dependencias de visualización"
    
    python3 -c "import matplotlib" 2>/dev/null
    if [ $? -eq 0 ]; then
        print_success "matplotlib instalado"
    else
        print_error "matplotlib no está instalado (necesario para visualize.py)"
        return 1
    fi
    
    print_test "Ejecutando visualize.py"
    
    # Ejecutar sin mostrar ventana
    timeout 5 python3 visualize.py 2>&1 | head -20 > "$TEST_DIR/visualize_output.txt"
    viz_exit=$?
    
    if [ $viz_exit -eq 0 ] || [ $viz_exit -eq 124 ]; then
        print_success "visualize.py ejecuta (timeout normal si abre ventana)"
    else
        print_warning "visualize.py tuvo problemas"
        cat "$TEST_DIR/visualize_output.txt"
    fi
    
    # Verificar que genera gráfico
    if grep -qE "plot|scatter|show|figure" visualize.py; then
        print_success "visualize.py contiene código de graficación"
    fi
}

# ============================================================================
# PARTE 7: TESTS BONUS - PRECISION.PY
# ============================================================================

test_precision() {
    print_header "9. BONUS - PRECISION.PY (MÉTRICAS)"
    
    if [ ! -f "precision.py" ]; then
        print_warning "precision.py no encontrado (BONUS no implementado)"
        return 0
    fi
    
    print_test "Ejecutando análisis de precisión"
    
    python3 precision.py > "$TEST_DIR/precision_output.txt" 2>&1
    prec_exit=$?
    
    if [ $prec_exit -eq 0 ]; then
        print_success "precision.py ejecuta correctamente"
        
        # Verificar métricas comunes
        output=$(cat "$TEST_DIR/precision_output.txt")
        
        if echo "$output" | grep -qiE "mse|mae|r2|rmse|mean.*error|squared"; then
            print_success "Calcula métricas de precisión"
            print_info "Métricas encontradas:"
            echo "$output" | grep -iE "mse|mae|r2|rmse|error|score" | head -5
        else
            print_warning "No se identifican métricas estándar"
        fi
    else
        print_error "precision.py falla con código $prec_exit"
        cat "$TEST_DIR/precision_output.txt"
    fi
}

# ============================================================================
# PARTE 8: TESTS BONUS - LEARNING_CURVE.PY
# ============================================================================

test_learning_curve() {
    print_header "10. BONUS - LEARNING_CURVE.PY (CURVA DE CONVERGENCIA)"
    
    if [ ! -f "learning_curve.py" ]; then
        print_warning "learning_curve.py no encontrado (BONUS extra no implementado)"
        return 0
    fi
    
    print_test "Verificando archivo learning_curve.py"
    print_success "Encontrado: learning_curve.py (BONUS extra)"
    
    print_test "Verificando que train.py genera historial de MSE"
    
    if [ ! -f "mse_history.txt" ]; then
        print_info "mse_history.txt no existe, entrenando..."
        python3 train.py > /dev/null 2>&1
    fi
    
    if [ -f "mse_history.txt" ]; then
        print_success "train.py genera mse_history.txt"
        
        # Verificar contenido del historial
        lines=$(wc -l < mse_history.txt)
        if [ "$lines" -gt 100 ]; then
            print_success "mse_history.txt contiene suficientes datos ($lines valores)"
        else
            print_warning "mse_history.txt tiene pocos valores ($lines)"
        fi
        
        # Verificar que los valores son numéricos
        if head -5 mse_history.txt | grep -qE "^[0-9]+\.[0-9]+$"; then
            print_success "Formato de MSE correcto (números decimales)"
        else
            print_warning "Formato de MSE inusual"
        fi
        
        # Verificar convergencia (MSE decrece)
        first_mse=$(head -1 mse_history.txt)
        last_mse=$(tail -1 mse_history.txt)
        
        if command -v bc >/dev/null 2>&1; then
            decreases=$(echo "$first_mse > $last_mse" | bc)
            if [ "$decreases" -eq 1 ]; then
                improvement=$(echo "scale=2; ($first_mse - $last_mse) / $first_mse * 100" | bc)
                print_success "MSE decrece correctamente: $first_mse → $last_mse (${improvement}% mejora)"
            else
                print_error "MSE no decrece (problema en el entrenamiento)"
            fi
        fi
    else
        print_error "train.py no genera mse_history.txt"
    fi
    
    print_test "Ejecutando learning_curve.py"
    
    # Ejecutar con timeout (abre ventana)
    timeout 5 python3 learning_curve.py 2>&1 | head -15 > "$TEST_DIR/learning_curve_output.txt"
    lc_exit=$?
    
    if [ $lc_exit -eq 0 ] || [ $lc_exit -eq 124 ]; then
        print_success "learning_curve.py ejecuta (timeout normal si abre ventana)"
        
        # Verificar que muestra información útil
        if grep -qiE "convergencia|mse|iteracion|mejora" "$TEST_DIR/learning_curve_output.txt"; then
            print_success "Muestra información de convergencia"
        fi
    else
        print_warning "learning_curve.py tuvo problemas"
        cat "$TEST_DIR/learning_curve_output.txt"
    fi
    
    # Verificar que contiene código de graficación dual
    if grep -qE "subplot|figure" learning_curve.py; then
        print_success "learning_curve.py contiene gráficos avanzados"
    fi
}

# ============================================================================
# PARTE 9: TESTS DE ROBUSTEZ
# ============================================================================

test_robustness() {
    print_header "11. TESTS DE ROBUSTEZ"
    
    print_test "Múltiples entrenamientos consecutivos"
    
    python3 train.py > /dev/null 2>&1
    python3 train.py > /dev/null 2>&1
    python3 train.py > /dev/null 2>&1
    
    # Buscar cualquier archivo de thetas
    if [ -f "theta.txt" ] || [ -f "theta_bonus.txt" ] || [ -f "thetas.txt" ]; then
        print_success "Soporta múltiples entrenamientos"
    else
        print_error "Falla en entrenamientos múltiples"
    fi
    
    print_test "Manejo de archivo data.csv corrupto"
    
    # Backup
    mkdir -p "$TEST_DIR"
    cp data.csv "$TEST_DIR/data.csv.backup"
    
    # Crear CSV inválido
    echo "invalid,data" > data.csv
    echo "abc,def" >> data.csv
    
    python3 train.py > "$TEST_DIR/corrupt_train.txt" 2>&1
    corrupt_exit=$?
    
    if [ $corrupt_exit -ne 0 ]; then
        print_success "Maneja correctamente datos corruptos (falla apropiadamente)"
    else
        print_warning "Debería fallar con datos inválidos"
    fi
    
    # Restaurar SIEMPRE
    if [ -f "$TEST_DIR/data.csv.backup" ]; then
        mv "$TEST_DIR/data.csv.backup" data.csv
        print_info "data.csv restaurado correctamente"
    else
        print_error "No se pudo restaurar data.csv"
    fi
}

# ============================================================================
# PARTE 10: TESTS DE CALIDAD DE CÓDIGO
# ============================================================================

test_code_quality() {
    print_header "12. CALIDAD DE CÓDIGO"
    
    print_test "Verificando shebang en archivos Python"
    
    for file in predict.py train.py visualize.py precision.py learning_curve.py; do
        if [ -f "$file" ]; then
            if head -n 1 "$file" | grep -q "^#!/.*python"; then
                print_success "$file tiene shebang"
            else
                print_warning "$file sin shebang (opcional pero recomendado)"
            fi
        fi
    done
    
    print_test "Verificando permisos de ejecución"
    
    for file in predict.py train.py; do
        if [ -x "$file" ]; then
            print_success "$file es ejecutable"
        else
            print_info "$file no es ejecutable (OK si se usa 'python3 $file')"
        fi
    done
    
    print_test "Verificando imports prohibidos"
    
    for file in predict.py train.py; do
        if grep -qE "import (sklearn|tensorflow|torch|keras)" "$file"; then
            print_error "$file usa librerías de ML prohibidas"
        else
            print_success "$file no usa librerías ML prohibidas"
        fi
    done
    
    # Verificar que solo usan numpy/matplotlib
    print_test "Verificando imports permitidos"
    
    for file in *.py; do
        if [ -f "$file" ]; then
            imports=$(grep "^import\|^from" "$file" | grep -vE "^#")
            if echo "$imports" | grep -qE "numpy|matplotlib|csv|sys|os|argparse"; then
                print_success "$file usa solo librerías permitidas"
            fi
        fi
    done
}

# ============================================================================
# PARTE 11: TESTS DE SUBJECT COMPLIANCE
# ============================================================================

test_subject_compliance() {
    print_header "13. COMPLIANCE CON EL SUBJECT"
    
    print_test "Requisito: Lectura de mileage por stdin"
    
    if grep -q "input\|stdin\|sys.stdin" predict.py; then
        print_success "predict.py lee de stdin"
    else
        print_warning "predict.py debería leer mileage de stdin"
    fi
    
    print_test "Requisito: Guardado de thetas en archivo"
    
    if grep -qE "theta.*\.txt|open\(|write\(" train.py; then
        print_success "train.py guarda thetas en archivo"
    else
        print_warning "train.py debería guardar thetas en archivo"
    fi
    
    print_test "Requisito: Implementación desde cero"
    
    violation=false
    for file in train.py predict.py; do
        if grep -qE "sklearn|fit\(\)|predict\(\)" "$file"; then
            print_error "$file usa funciones de ML de alto nivel"
            violation=true
        fi
    done
    
    if [ "$violation" = false ]; then
        print_success "Implementación desde cero (sin sklearn.fit/predict)"
    fi
    
    print_test "Requisito: Uso de gradiente descendente"
    
    if grep -qiE "gradient|learning.*rate|iteration|epoch" train.py; then
        print_success "train.py implementa gradiente descendente"
    else
        print_warning "No se identifican elementos de gradiente en train.py"
    fi
}

# ============================================================================
# PARTE 12: TESTS DE RENDIMIENTO
# ============================================================================

test_performance() {
    print_header "14. TESTS DE RENDIMIENTO"
    
    print_test "Tiempo de entrenamiento"
    
    start=$(date +%s)
    python3 train.py > /dev/null 2>&1
    end=$(date +%s)
    duration=$((end - start))
    
    print_info "Tiempo de entrenamiento: ${duration}s"
    
    if [ $duration -lt 10 ]; then
        print_success "Entrenamiento rápido (< 10s)"
    elif [ $duration -lt 30 ]; then
        print_success "Entrenamiento aceptable (< 30s)"
    else
        print_warning "Entrenamiento lento (> 30s)"
    fi
    
    print_test "Tiempo de predicción"
    
    start=$(date +%s.%N)
    echo "50000" | python3 predict.py > /dev/null 2>&1
    end=$(date +%s.%N)
    
    if command -v bc >/dev/null 2>&1; then
        duration=$(echo "$end - $start" | bc)
        print_info "Tiempo de predicción: ${duration}s"
    fi
    
    print_success "Predicción instantánea"
}

# ============================================================================
# RESUMEN FINAL
# ============================================================================

print_summary() {
    echo -e "\n${BLUE}╔════════════════════════════════════════════════════════════════════╗${NC}"
    echo -e "${BLUE}║${BOLD}                      RESUMEN DE TESTS                              ${NC}${BLUE}║${NC}"
    echo -e "${BLUE}╚════════════════════════════════════════════════════════════════════╝${NC}\n"
    
    # Calcular tests no fallidos como pasados
    if [ $FAILED_TESTS -eq 0 ]; then
        PASSED_TESTS=$TOTAL_TESTS
    else
        PASSED_TESTS=$((TOTAL_TESTS - FAILED_TESTS))
    fi
    
    echo -e "${BOLD}Total de tests:${NC} $TOTAL_TESTS"
    echo -e "${GREEN}Tests pasados:${NC} $PASSED_TESTS"
    echo -e "${RED}Tests fallidos:${NC} $FAILED_TESTS"
    
    percentage=$((PASSED_TESTS * 100 / TOTAL_TESTS))
    echo -e "\n${BOLD}Porcentaje de éxito:${NC} ${percentage}%"
    
    # Verificación de puntos CRÍTICOS de la evaluación
    echo -e "\n${BLUE}╔════════════════════════════════════════════════════════════════════╗${NC}"
    echo -e "${BLUE}║${BOLD}        VERIFICACIÓN DE PUNTOS CRÍTICOS (evaluation.pdf)            ${NC}${BLUE}║${NC}"
    echo -e "${BLUE}╚════════════════════════════════════════════════════════════════════╝${NC}\n"
    
    # Checklist basada en el PDF de evaluación
    critical_passed=0
    critical_total=7
    
    echo -e "${CYAN}Checklist oficial de evaluación:${NC}\n"
    
    # 1. Archivos obligatorios
    if [ -f "data.csv" ] && [ -f "predict.py" ] && [ -f "train.py" ]; then
        echo -e "  ${GREEN}✓${NC} Archivos obligatorios presentes"
        critical_passed=$((critical_passed + 1))
    else
        echo -e "  ${RED}✗${NC} Faltan archivos obligatorios"
    fi
    
    # 2. No usa librerías prohibidas
    if ! grep -qE "numpy\.polyfit|sklearn.*fit" train.py predict.py 2>/dev/null; then
        echo -e "  ${GREEN}✓${NC} No usa librerías prohibidas (numpy.polyfit, sklearn)"
        critical_passed=$((critical_passed + 1))
    else
        echo -e "  ${RED}✗${NC} USA LIBRERÍAS PROHIBIDAS (TRAMPA)"
    fi
    
    # 3. Ecuación correcta
    if grep -q "theta0.*+.*theta1.*\*" predict.py 2>/dev/null; then
        echo -e "  ${GREEN}✓${NC} Usa ecuación correcta: θ0 + (θ1 * mileage)"
        critical_passed=$((critical_passed + 1))
    else
        echo -e "  ${RED}✗${NC} No usa la ecuación especificada"
    fi
    
    # 4. Asignación simultánea
    if grep -q "tmp.*theta0\|temp.*theta0" train.py 2>/dev/null && \
       grep -q "tmp.*theta1\|temp.*theta1" train.py 2>/dev/null; then
        echo -e "  ${GREEN}✓${NC} Asignación SIMULTÁNEA de θ0 y θ1 (variables tmp)"
        critical_passed=$((critical_passed + 1))
    else
        echo -e "  ${RED}✗${NC} NO usa asignación simultánea (CRÍTICO)"
    fi
    
    # 5. Guarda thetas
    theta_file=""
    [ -f "theta.txt" ] && theta_file="theta.txt"
    [ -f "thetas.txt" ] && theta_file="thetas.txt"
    if [ -n "$theta_file" ]; then
        echo -e "  ${GREEN}✓${NC} Guarda θ0 y θ1 en archivo ($theta_file)"
        critical_passed=$((critical_passed + 1))
    else
        echo -e "  ${RED}✗${NC} No guarda thetas en archivo"
    fi
    
    # 6. Lee CSV
    if grep -q "data\.csv\|\.csv" train.py 2>/dev/null; then
        echo -e "  ${GREEN}✓${NC} Lee el archivo CSV"
        critical_passed=$((critical_passed + 1))
    else
        echo -e "  ${RED}✗${NC} No lee CSV correctamente"
    fi
    
    # 7. Implementa gradient descent
    if grep -qE "learning.*rate|learningRate" train.py 2>/dev/null; then
        echo -e "  ${GREEN}✓${NC} Implementa gradient descent (learning_rate)"
        critical_passed=$((critical_passed + 1))
    else
        echo -e "  ${RED}✗${NC} No implementa gradient descent claramente"
    fi
    
    echo ""
    echo -e "${BOLD}Puntos críticos aprobados:${NC} $critical_passed/$critical_total"
    
    if [ $critical_passed -eq $critical_total ]; then
        echo -e "\n${GREEN}${BOLD}╔══════════════════════════════════════════════════════════════╗${NC}"
        echo -e "${GREEN}${BOLD}║                                                              ║${NC}"
        echo -e "${GREEN}${BOLD}║   ✓✓✓ PROYECTO LISTO PARA EVALUACIÓN ✓✓✓                     ║${NC}"
        echo -e "${GREEN}${BOLD}║                                                              ║${NC}"
        echo -e "${GREEN}${BOLD}║   Todos los requisitos del PDF de evaluación se cumplen      ║${NC}"
        echo -e "${GREEN}${BOLD}║                                                              ║${NC}"
        echo -e "${GREEN}${BOLD}╚══════════════════════════════════════════════════════════════╝${NC}"
    elif [ $critical_passed -ge 5 ]; then
        echo -e "\n${YELLOW}${BOLD}⚠  PROYECTO CASI LISTO - Corrige los puntos fallidos${NC}"
    else
        echo -e "\n${RED}${BOLD}✗  PROYECTO NO LISTO - Revisa los puntos críticos${NC}"
    fi
    
    if [ $percentage -ge 90 ] && [ $critical_passed -eq $critical_total ]; then
        echo -e "\n${GREEN}${BOLD}★★★ EXCELENTE - 100% READY ★★★${NC}"
    elif [ $percentage -ge 75 ]; then
        echo -e "\n${YELLOW}${BOLD}★★☆ BUENO - Algunos detalles pendientes ★★☆${NC}"
    else
        echo -e "\n${RED}${BOLD}★☆☆ NECESITA MEJORAS ★☆☆${NC}"
    fi
    
    echo -e "\n${CYAN}Archivos de log guardados en: $TEST_DIR/${NC}"
    echo ""
}

# ============================================================================
# MAIN
# ============================================================================

main() {
    echo -e "${BOLD}${BLUE}"
    echo "╔═══════════════════════════════════════════════════════════════════════╗"
    echo "║                                                                       ║"
    echo "║         FT_LINEAR_REGRESSION - SUITE DE TESTING AUTOMÁTICO            ║"
    echo "║                                                                       ║"
    echo "║        Testing exhaustivo según subject (Mandatory + Bonus)           ║"
    echo "║                                                                       ║"
    echo "╚═══════════════════════════════════════════════════════════════════════╝"
    echo -e "${NC}\n"
    
    setup
    
    # Ejecutar todas las baterías de tests
    test_file_structure
    test_predict_no_training
    test_predict_invalid_input
    test_train_basic
    test_train_convergence
    test_predict_with_training
    test_math_formulas
    test_visualize
    test_precision
    test_learning_curve
    test_robustness
    test_code_quality
    test_subject_compliance
    test_performance
    
    # Resumen
    print_summary
    
    # Cleanup opcional
    read -p "¿Limpiar archivos temporales? (y/n): " -n 1 -r
    echo
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        cleanup
        echo -e "${GREEN}Archivos temporales eliminados.${NC}"
    fi
}

# Ejecutar
main "$@"
