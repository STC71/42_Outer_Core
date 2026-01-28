#!/bin/bash
# DSLR - Script de prueba para ejecutar el pipeline completo

echo "================================================================================"
echo "DSLR - Prueba de Pipeline Completo"
echo "================================================================================"

# Colores
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m' # Sin Color

# Verificar que existen los archivos de dataset
if [ ! -f "dataset_train.csv" ]; then
    echo -e "${RED}Error: dataset_train.csv no encontrado${NC}"
    exit 1
fi

if [ ! -f "dataset_test.csv" ]; then
    echo -e "${RED}Error: dataset_test.csv no encontrado${NC}"
    exit 1
fi

echo ""
echo -e "${YELLOW}Paso 1: Análisis Estadístico${NC}"
echo "--------------------------------------------------------------------------------"
python3 describe.py dataset_train.csv

echo ""
echo -e "${YELLOW}Paso 2: Visualización de Datos (omitido en prueba automatizada)${NC}"
echo "--------------------------------------------------------------------------------"
echo "Para ejecutar visualizaciones manualmente:"
echo "  python3 histogram.py dataset_train.csv"
echo "  python3 scatter_plot.py dataset_train.csv"
echo "  python3 pair_plot.py dataset_train.csv"

echo ""
echo -e "${YELLOW}Paso 3: Entrenamiento con Descenso de Gradiente por Lotes${NC}"
echo "--------------------------------------------------------------------------------"
python3 logreg_train.py dataset_train.csv 0.1 1000

echo ""
echo -e "${YELLOW}Paso 4: Haciendo Predicciones${NC}"
echo "--------------------------------------------------------------------------------"
python3 logreg_predict.py dataset_test.csv weights.pkl houses.csv

echo ""
echo -e "${YELLOW}Paso 5: Evaluación${NC}"
echo "--------------------------------------------------------------------------------"
python3 evaluate.py houses.csv dataset_test.csv

echo ""
echo -e "${YELLOW}BONUS: Entrenamiento con Descenso de Gradiente Estocástico${NC}"
echo "--------------------------------------------------------------------------------"
python3 logreg_train_stochastic.py dataset_train.csv 0.01 100

echo ""
echo -e "${YELLOW}BONUS: Predicción con modelo SGD${NC}"
echo "--------------------------------------------------------------------------------"
python3 logreg_predict.py dataset_test.csv weights_sgd.pkl houses_sgd.csv

echo ""
echo -e "${YELLOW}BONUS: Evaluación del modelo SGD${NC}"
echo "--------------------------------------------------------------------------------"
python3 evaluate.py houses_sgd.csv dataset_test.csv

echo ""
echo -e "${YELLOW}BONUS: Entrenamiento con Descenso de Gradiente Mini-Batch${NC}"
echo "--------------------------------------------------------------------------------"
python3 logreg_train_minibatch.py dataset_train.csv 0.1 100 32

echo ""
echo -e "${YELLOW}BONUS: Predicción con modelo Mini-Batch${NC}"
echo "--------------------------------------------------------------------------------"
python3 logreg_predict.py dataset_test.csv weights_minibatch.pkl houses_minibatch.csv

echo ""
echo -e "${YELLOW}BONUS: Evaluación del modelo Mini-Batch${NC}"
echo "--------------------------------------------------------------------------------"
python3 evaluate.py houses_minibatch.csv dataset_test.csv

echo ""
echo "================================================================================"
echo -e "${GREEN}PIPELINE COMPLETADO${NC}"
echo "================================================================================"
echo ""
echo "Archivos generados:"
echo "  - weights.pkl (modelo GD por Lotes)"
echo "  - weights_sgd.pkl (modelo GD Estocástico - BONUS)"
echo "  - weights_minibatch.pkl (modelo GD Mini-Batch - BONUS)"
echo "  - houses.csv (predicciones GD por Lotes)"
echo "  - houses_sgd.csv (predicciones SGD)"
echo "  - houses_minibatch.csv (predicciones Mini-Batch)"
echo "  - histogram_analysis.png (si se ejecutó visualización)"
echo "  - scatter_plot_analysis.png (si se ejecutó visualización)"
echo "  - pair_plot.png (si se ejecutó visualización)"
echo ""
