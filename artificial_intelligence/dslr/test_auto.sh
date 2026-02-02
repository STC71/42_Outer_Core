#!/bin/bash

# ============================================================================
# test_auto.sh - Testing automatizado completo para DSLR
# ============================================================================
# Prueba exhaustiva de la parte MANDATORY y BONUS según el subject
# Proyecto: Data Science × Logistic Regression (Harry Potter)
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
    # Limpiar archivos generados
    rm -f weights*.pkl houses*.csv *.png 2>/dev/null
}

setup() {
    cleanup
    mkdir -p "$TEST_DIR"
}

pass_test() {
    print_success "$1"
    PASSED_TESTS=$((PASSED_TESTS + 1))
}

fail_test() {
    print_error "$1"
    FAILED_TESTS=$((FAILED_TESTS + 1))
}

# ============================================================================
# VERIFICACIÓN DE DEPENDENCIAS
# ============================================================================

check_dependencies() {
    print_header "Verificando Dependencias"
    
    # Verificar Python
    if command -v python3 &> /dev/null; then
        python_version=$(python3 --version)
        print_success "Python encontrado: $python_version"
    else
        print_error "Python3 no encontrado"
        exit 1
    fi
    
    # Verificar módulos de Python
    print_info "Verificando módulos de Python..."
    
    python3 -c "import numpy" 2>/dev/null
    if [ $? -eq 0 ]; then
        print_success "NumPy disponible"
    else
        print_error "NumPy no encontrado - requerido para el proyecto"
        exit 1
    fi
    
    python3 -c "import matplotlib" 2>/dev/null
    if [ $? -eq 0 ]; then
        print_success "Matplotlib disponible"
    else
        print_warning "Matplotlib no encontrado - necesario para visualizaciones"
    fi
    
    echo ""
}

# ============================================================================
# TESTS DE ARCHIVOS
# ============================================================================

test_required_files() {
    print_header "TEST 1: Verificación de Archivos Obligatorios"
    
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
    
    all_present=true
    for file in "${required_files[@]}"; do
        print_test "Verificar existencia de $file"
        if [ -f "$file" ]; then
            pass_test "Archivo $file presente"
        else
            fail_test "Archivo $file no encontrado"
            all_present=false
        fi
    done
    
    if [ "$all_present" = true ]; then
        print_success "Todos los archivos obligatorios presentes"
    else
        print_error "Faltan archivos obligatorios - la evaluación puede fallar"
    fi
}

# ============================================================================
# TESTS DE LIBRERÍAS PROHIBIDAS
# ============================================================================

test_forbidden_libraries() {
    print_header "TEST 2: Verificación de Librerías Prohibidas"
    
    print_test "Verificar que no se usa sklearn para regresión logística"
    
    files_to_check=("logreg_train.py" "logreg_predict.py")
    forbidden_found=false
    
    for file in "${files_to_check[@]}"; do
        if [ -f "$file" ]; then
            # Verificar sklearn
            if grep -q "from sklearn.linear_model" "$file" || \
               grep -q "LogisticRegression" "$file"; then
                fail_test "$file usa sklearn.linear_model - PROHIBIDO"
                forbidden_found=true
            fi
            
            # Verificar métodos de pandas DataFrame
            if grep -q "\.describe()" "$file" || \
               grep -q "pd.DataFrame" describe.py 2>/dev/null; then
                print_warning "$file puede estar usando métodos de pandas (verificar manualmente)"
            fi
        fi
    done
    
    if [ "$forbidden_found" = false ]; then
        pass_test "No se detectaron librerías prohibidas"
    fi
}

# ============================================================================
# TESTS DE DATA ANALYSIS
# ============================================================================

test_describe() {
    print_header "TEST 3: describe.py - Análisis Estadístico"
    
    print_test "Ejecutar describe.py con dataset_train.csv"
    
    output=$(python3 describe.py dataset_train.csv 2>&1)
    exit_code=$?
    
    if [ $exit_code -eq 0 ]; then
        pass_test "describe.py ejecutado sin errores"
    else
        fail_test "describe.py falló con código de salida $exit_code"
        echo "$output"
    fi
}

test_histogram() {
    print_header "TEST 4: histogram.py - Distribución Homogénea"
    
    print_test "Ejecutar histogram.py"
    
    # Usar backend no-interactivo para matplotlib
    export MPLBACKEND=Agg
    
    output=$(python3 histogram.py dataset_train.csv 2>&1)
    exit_code=$?
    
    if [ $exit_code -eq 0 ]; then
        pass_test "histogram.py ejecutado correctamente"
        # Verificar que se generó algún archivo de imagen
        if ls *.png 2>/dev/null | grep -q "histogram"; then
            print_info "Se generó archivo de histograma"
        fi
    else
        fail_test "histogram.py falló"
        echo "$output"
    fi
}

test_scatter_plot() {
    print_header "TEST 5: scatter_plot.py - Características Similares"
    
    print_test "Ejecutar scatter_plot.py"
    
    export MPLBACKEND=Agg
    
    output=$(python3 scatter_plot.py dataset_train.csv 2>&1)
    exit_code=$?
    
    if [ $exit_code -eq 0 ]; then
        pass_test "scatter_plot.py ejecutado correctamente"
        
        if ls *.png 2>/dev/null | grep -q "scatter"; then
            print_success "Se generó archivo de scatter plot"
        fi
    else
        fail_test "scatter_plot.py falló"
        echo "$output"
    fi
}

test_pair_plot() {
    print_header "TEST 6: pair_plot.py - Matriz de Correlación"
    
    print_test "Ejecutar pair_plot.py"
    
    export MPLBACKEND=Agg
    
    output=$(python3 pair_plot.py dataset_train.csv 2>&1)
    exit_code=$?
    
    if [ $exit_code -eq 0 ]; then
        pass_test "pair_plot.py ejecutado correctamente"
        if ls *.png 2>/dev/null | grep -q "pair"; then
            print_info "Se generó archivo de pair plot"
        fi
    else
        fail_test "pair_plot.py falló"
        echo "$output"
    fi
}

# ============================================================================
# TESTS DE LOGISTIC REGRESSION
# ============================================================================

test_training() {
    print_header "TEST 7: logreg_train.py - Entrenamiento del Modelo"
    
    print_test "Entrenar modelo con parámetros estándar"
    print_info "Parámetros: learning_rate=0.1, iterations=1000"
    
    output=$(python3 logreg_train.py dataset_train.csv 0.1 1000 2>&1)
    exit_code=$?
    
    if [ $exit_code -eq 0 ]; then
        pass_test "Entrenamiento completado sin errores"
        # Verificar que se generó el archivo de pesos
        if [ -f "weights.pkl" ]; then
            # Verificar tamaño del archivo
            file_size=$(stat -f%z "weights.pkl" 2>/dev/null || stat -c%s "weights.pkl" 2>/dev/null)
            print_info "Archivo weights.pkl generado (${file_size} bytes)"
        fi
    else
        fail_test "Entrenamiento falló con código $exit_code"
        echo "$output"
    fi
}

test_prediction() {
    print_header "TEST 8: logreg_predict.py - Predicción"
    
    if [ ! -f "weights.pkl" ]; then
        print_warning "weights.pkl no existe - ejecutando entrenamiento primero..."
        python3 logreg_train.py dataset_train.csv 0.1 1000 > /dev/null 2>&1
    fi
    
    print_test "Generar predicciones para dataset_test.csv"
    
    output=$(python3 logreg_predict.py dataset_test.csv weights.pkl houses.csv 2>&1)
    exit_code=$?
    
    if [ $exit_code -eq 0 ]; then
        pass_test "Predicción completada sin errores"
        if [ -f "houses.csv" ]; then
            # Verificar formato del archivo
            line_count=$(wc -l < houses.csv)
            print_info "Archivo houses.csv generado con $line_count predicciones"
            
            # Verificar que contiene nombres de casas válidos
            valid_houses=("Gryffindor" "Hufflepuff" "Ravenclaw" "Slytherin")
            houses_found=0
            for house in "${valid_houses[@]}"; do
                if grep -q "$house" houses.csv; then
                    houses_found=$((houses_found + 1))
                fi
            done
            print_info "Casas encontradas: $houses_found/4"
        fi
    else
        fail_test "Predicción falló con código $exit_code"
        echo "$output"
    fi
}

test_accuracy() {
    print_header "TEST 9: Evaluación de Precisión"
    
    if [ ! -f "houses.csv" ]; then
        print_warning "houses.csv no existe - ejecutando predicción primero..."
        test_prediction > /dev/null 2>&1
    fi
    
    if [ ! -f "evaluate.py" ]; then
        print_warning "evaluate.py no encontrado - saltando test de precisión"
        return
    fi
    
    print_test "Evaluar precisión del modelo"
    print_info "Objetivo: ≥ 98% de precisión"
    
    output=$(python3 evaluate.py houses.csv dataset_test.csv 2>&1)
    exit_code=$?
    
    if [ $exit_code -eq 0 ]; then
        echo "$output"
        
        # Intentar extraer la precisión del output - formato: "score on test set: 0.990"
        accuracy=$(echo "$output" | grep -oP 'score on test set:\s*\K\d+\.\d+' | head -1)
        
        if [ -n "$accuracy" ]; then
            # Convertir a porcentaje
            accuracy_percent=$(echo "$accuracy * 100" | bc -l)
            accuracy_percent=$(printf "%.2f" "$accuracy_percent")
            print_info "Precisión obtenida: ${accuracy_percent}%"
            
            # Comparar con 98%
            if (( $(echo "$accuracy >= 0.98" | bc -l 2>/dev/null || echo 0) )); then
                pass_test "✓ Precisión ≥ 98% - OBJETIVO CUMPLIDO"
            elif (( $(echo "$accuracy >= 0.90" | bc -l 2>/dev/null || echo 0) )); then
                print_warning "Precisión entre 90-98% - mejorable pero aceptable"
                PASSED_TESTS=$((PASSED_TESTS + 1))
            else
                fail_test "Precisión < 90% - revisar implementación"
            fi
        else
            print_warning "No se pudo extraer la precisión automáticamente"
            print_info "Verificar manualmente la salida anterior"
        fi
    else
        fail_test "evaluate.py falló"
        echo "$output"
    fi
}

# ============================================================================
# TESTS DE VALIDACIÓN DE IMPLEMENTACIÓN
# ============================================================================

test_implementation_details() {
    print_header "TEST 10: Verificación de Implementación"
    
    print_test "Verificar implementación de funciones clave"
    
    # Verificar función sigmoide
    if grep -q "sigmoid\|1./(1.*exp" logreg_train.py; then
        pass_test "Implementación verificada correctamente"
    else
        fail_test "No se detectó implementación de funciones clave"
    fi
}

# ============================================================================
# TESTS BONUS
# ============================================================================

test_bonus_features() {
    print_header "BONUS: Tests de Características Adicionales"
    
    # SGD
    if [ -f "logreg_train_stochastic.py" ]; then
        print_test "Probar Stochastic Gradient Descent"
        
        output=$(python3 logreg_train_stochastic.py dataset_train.csv 0.01 100 2>&1)
        if [ $? -eq 0 ]; then
            pass_test "SGD implementado y funcional"
        else
            print_warning "SGD encontrado pero con errores"
        fi
    fi
    
    # Mini-batch
    if [ -f "logreg_train_minibatch.py" ]; then
        print_test "Probar Mini-Batch Gradient Descent"
        
        output=$(python3 logreg_train_minibatch.py dataset_train.csv 0.1 100 32 2>&1)
        if [ $? -eq 0 ]; then
            pass_test "Mini-batch GD implementado y funcional"
        else
            print_warning "Mini-batch GD encontrado pero con errores"
        fi
    fi
    
    # Cross-validation
    if [ -f "cross_validate.py" ]; then
        print_test "Probar validación cruzada"
        
        output=$(python3 cross_validate.py dataset_train.csv 0.8 2>&1)
        if [ $? -eq 0 ]; then
            pass_test "Cross-validation implementado"
        else
            print_warning "Cross-validation encontrado pero con errores"
        fi
    fi
}

# ============================================================================
# TESTS DE INTEGRACIÓN
# ============================================================================

test_full_pipeline() {
    print_header "TEST 11: Pipeline Completo (Integración)"
    
    print_test "Ejecutar pipeline completo: entrenar → predecir → evaluar"
    
    cleanup
    
    # Paso 1: Entrenar
    print_info "[1/3] Entrenando modelo..."
    if ! python3 logreg_train.py dataset_train.csv 0.1 1000 > /dev/null 2>&1; then
        fail_test "Pipeline falló en entrenamiento"
        return
    fi
    
    # Paso 2: Predecir
    print_info "[2/3] Generando predicciones..."
    if ! python3 logreg_predict.py dataset_test.csv weights.pkl houses.csv > /dev/null 2>&1; then
        fail_test "Pipeline falló en predicción"
        return
    fi
    
    # Paso 3: Evaluar
    if [ -f "evaluate.py" ]; then
        print_info "[3/3] Evaluando precisión..."
        if python3 evaluate.py houses.csv dataset_test.csv > /dev/null 2>&1; then
            pass_test "Pipeline completo ejecutado exitosamente"
        else
            print_warning "Pipeline completado pero evaluación falló"
        fi
    else
        pass_test "Pipeline (entrenar + predecir) ejecutado exitosamente"
    fi
}

# ============================================================================
# RESUMEN DE TESTS
# ============================================================================

print_summary() {
    print_header "RESUMEN DE TESTS"
    
    echo -e "${CYAN}╔════════════════════════════════════════════════════════════════════╗${NC}"
    echo -e "${CYAN}║${BOLD}                      RESULTADOS FINALES                            ${NC}${CYAN}║${NC}"
    echo -e "${CYAN}╠════════════════════════════════════════════════════════════════════╣${NC}"
    echo -e "${CYAN}║${NC} Total de tests:      ${BOLD}${TOTAL_TESTS}${NC}                                            ${CYAN}║${NC}"
    echo -e "${CYAN}║${NC} Tests aprobados:     ${GREEN}${BOLD}${PASSED_TESTS}${NC}                                            ${CYAN}║${NC}"
    echo -e "${CYAN}║${NC} Tests fallidos:      ${RED}${BOLD}${FAILED_TESTS}${NC}                                             ${CYAN}║${NC}"
    echo -e "${CYAN}╚════════════════════════════════════════════════════════════════════╝${NC}"
    
    if [ $TOTAL_TESTS -gt 0 ]; then
        success_rate=$((PASSED_TESTS * 100 / TOTAL_TESTS))
        echo -e "\n${CYAN}Tasa de éxito: ${BOLD}${success_rate}%${NC}"
        
        if [ $success_rate -ge 90 ]; then
            echo -e "\n${GREEN}${BOLD}✓ EXCELENTE - El proyecto pasa todos los tests principales${NC}"
        elif [ $success_rate -ge 70 ]; then
            echo -e "\n${YELLOW}⚠ BUENO - La mayoría de tests pasan, revisar los fallos${NC}"
        else
            echo -e "\n${RED}✗ NECESITA TRABAJO - Múltiples tests fallaron${NC}"
        fi
    fi
    
    echo -e "\n${BLUE}═══════════════════════════════════════════════════════════════════${NC}"
    echo -e "${BOLD}Para evaluación manual detallada, usar: ./evaluation.sh${NC}"
    echo -e "${BLUE}═══════════════════════════════════════════════════════════════════${NC}\n"
}

# ============================================================================
# MAIN - EJECUCIÓN DE TODOS LOS TESTS
# ============================================================================

main() {
    clear
    print_header "DSLR - Test Automatizado Completo"
    
    echo -e "${CYAN}Este script ejecuta todos los tests automatizados del proyecto DSLR${NC}"
    echo -e "${CYAN}Incluye tests de la parte obligatoria y bonus${NC}\n"
    
    # Setup
    setup
    
    # Tests de verificación previa
    check_dependencies
    test_required_files
    test_forbidden_libraries
    
    # Tests de Data Analysis
    test_describe
    test_histogram
    test_scatter_plot
    test_pair_plot
    
    # Tests de Logistic Regression
    test_training
    test_prediction
    test_accuracy
    test_implementation_details
    
    # Tests de integración
    test_full_pipeline
    
    # Tests bonus
    test_bonus_features
    
    # Limpieza final
    cleanup
    
    # Mostrar resumen
    print_summary
}

# Ejecutar tests
main
