#!/usr/bin/env python3
"""
DSLR - cross_validate.py
Realizar validación cruzada en datos de entrenamiento para estimar precisión.

Ya que el conjunto de prueba no tiene etiquetas, dividimos los datos de entrenamiento para validar.
"""

import sys  # Para manejo de errores
import random  # Para mezclar datos aleatoriamente
import pickle  # Para cargar modelo guardado


def parse_float(value):
    """
    Convertir cadena a float de forma segura.
    Retorna None si no es posible.
    """
    try:  # Intentar conversión
        return float(value)
    except (ValueError, TypeError):  # Si hay error
        return None  # Retornar None


def read_csv(filename):
    """
    Leer archivo CSV y retornar encabezados y datos.
    filename: ruta al archivo CSV
    Retorna tupla (headers, data).
    """
    import csv  # Importar módulo csv
    try:  # Intentar abrir archivo
        with open(filename, 'r') as f:  # Abrir en lectura
            reader = csv.reader(f)  # Crear lector
            headers = next(reader)  # Leer encabezados
            data = {header: [] for header in headers}  # Inicializar dict
            for row in reader:  # Para cada fila
                for i, value in enumerate(row):  # Para cada valor
                    if i < len(headers):  # Si índice válido
                        data[headers[i]].append(value)  # Añadir valor
        return headers, data  # Retornar datos
    except FileNotFoundError:  # Si archivo no existe
        print(f"Error: Archivo '{filename}' no encontrado", file=sys.stderr)
        sys.exit(1)  # Salir con error


def sigmoid(z):
    """
    Función sigmoide: g(z) = 1 / (1 + e^(-z))
    Transforma valores a rango [0, 1].
    """
    if z > 500:  # Evitar overflow
        return 1.0  # sigmoid(∞) = 1
    elif z < -500:  # Evitar underflow
        return 0.0  # sigmoid(-∞) = 0
    return 1.0 / (1.0 + (2.718281828459045 ** (-z)))  # Calcular sigmoid


def split_data(X, y_dict, houses, train_ratio=0.8):
    """
    Dividir datos en conjuntos de entrenamiento y validación.
    train_ratio: proporción para entrenamiento (por defecto 80%)
    Retorna X_train, X_val, y_train_dict, y_val_dict.
    """
    n_samples = len(X)  # Número total de ejemplos
    indices = list(range(n_samples))  # Lista de índices
    random.shuffle(indices)  # Mezclar aleatoriamente
    
    split_point = int(n_samples * train_ratio)  # Punto de división
    train_indices = indices[:split_point]  # Índices de entrenamiento
    val_indices = indices[split_point:]  # Índices de validación
    
    X_train = [X[i] for i in train_indices]  # Features de entrenamiento
    X_val = [X[i] for i in val_indices]  # Features de validación
    
    y_train_dict = {}  # Etiquetas de entrenamiento por casa
    y_val_dict = {}  # Etiquetas de validación por casa
    
    for house in houses:  # Para cada casa
        y_train_dict[house] = [y_dict[house][i] for i in train_indices]
        y_val_dict[house] = [y_dict[house][i] for i in val_indices]
    
    return X_train, X_val, y_train_dict, y_val_dict  # Retornar splits


def predict_one_vs_all(X, theta_dict, houses):
    """
    Hacer predicciones usando clasificadores One-vs-All.
    Para cada ejemplo, calcula probabilidad para cada casa y elige la máxima.
    Retorna lista de predicciones.
    """
    predictions = []  # Lista para almacenar predicciones
    
    for x in X:  # Para cada ejemplo
        probabilities = {}  # Diccionario de probabilidades por casa
        for house in houses:  # Para cada casa
            theta = theta_dict[house]  # Obtener pesos de esta casa
            z = sum(theta[j] * x[j] for j in range(len(theta)))  # Calcular z = θᵀx
            prob = sigmoid(z)
            probabilities[house] = prob
        
        predicted_house = max(probabilities, key=probabilities.get)
        predictions.append(predicted_house)
    
    return predictions


def calculate_accuracy(predictions, y_dict, houses):
    """Calculate accuracy from predictions"""
    # Convert y_dict to actual labels
    n_samples = len(predictions)
    actual_labels = []
    
    for i in range(n_samples):
        for house in houses:
            if y_dict[house][i] == 1:
                actual_labels.append(house)
                break
    
    correct = sum(1 for pred, actual in zip(predictions, actual_labels) if pred == actual)
    accuracy = (correct / n_samples * 100) if n_samples > 0 else 0.0
    
    return accuracy, correct, n_samples


def main():
    """Main cross-validation function"""
    if len(sys.argv) < 2:
        print("Uso: python cross_validate.py <dataset_train.csv> [ratio_entrenamiento]")
        print("Ejemplo: python cross_validate.py dataset_train.csv 0.8")
        sys.exit(1)
    
    filename = sys.argv[1]
    train_ratio = float(sys.argv[2]) if len(sys.argv) > 2 else 0.8
    
    print("="*80)
    print("DSLR - Validación Cruzada")
    print("="*80)
    print(f"Conjunto de datos: {filename}")
    print(f"División Train/Val: {train_ratio*100:.0f}% / {(1-train_ratio)*100:.0f}%")
    
    # Set seed for reproducibility
    random.seed(42)
    
    # Import training functions (simplified version)
    from logreg_train import prepare_data, train_one_vs_all
    
    # Prepare full dataset
    X, y_dict, feature_names, houses, normalization_params = prepare_data(filename)
    
    # Split into train and validation
    print("\nDividiendo datos...")
    X_train, X_val, y_train_dict, y_val_dict = split_data(X, y_dict, houses, train_ratio)
    
    print(f"Muestras de entrenamiento: {len(X_train)}")
    print(f"Muestras de validación: {len(X_val)}")
    
    # Train on training set
    print("\nEntrenando con conjunto de entrenamiento...")
    theta_dict = train_one_vs_all(X_train, y_train_dict, houses, 
                                  learning_rate=0.1, num_iterations=1000, 
                                  verbose=False)
    
    # Predict on validation set
    print("\nEvaluando con conjunto de validación...")
    predictions = predict_one_vs_all(X_val, theta_dict, houses)
    
    # Calculate accuracy
    accuracy, correct, total = calculate_accuracy(predictions, y_val_dict, houses)
    
    print("\n" + "="*80)
    print("RESULTADOS DE VALIDACIÓN")
    print("="*80)
    print(f"\nPrecisión: {accuracy:.2f}%")
    print(f"Correctas: {correct} / {total}")
    
    if accuracy >= 98.0:
        print(f"\n✓ APROBADO: Precisión >= 98%")
    else:
        print(f"\n✗ FALLADO: Precisión < 98% (necesita mejorar)")
    
    print("\n" + "="*80)


if __name__ == "__main__":
    main()
