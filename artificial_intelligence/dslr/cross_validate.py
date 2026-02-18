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
    La validación cruzada es crucial para evaluar el rendimiento del modelo
    en datos no vistos sin tocar el conjunto de prueba oficial.
    
    Args:
        X: Matriz de características
        y_dict: Diccionario casa -> etiquetas binarias
        houses: Lista de casas de Hogwarts
        train_ratio: Proporción de datos para entrenamiento (por defecto 0.8 = 80%)
    
    Returns:
        Tupla (X_train, X_val, y_train_dict, y_val_dict)
    """
    n_samples = len(X)  # Número total de ejemplos en el dataset
    indices = list(range(n_samples))  # Crear lista de índices [0, 1, 2, ..., n-1]
    random.shuffle(indices)  # Mezclar aleatoriamente para evitar sesgo
    # shuffle() modifica la lista in-place, mezclando los índices aleatoriamente
    
    # Calcular punto de división entre train y validation
    split_point = int(n_samples * train_ratio)  # Ejemplo: 800 si n=1000 y ratio=0.8
    train_indices = indices[:split_point]  # Primeros 80% para entrenamiento
    val_indices = indices[split_point:]  # Últimos 20% para validación
    # [:n] toma elementos desde inicio hasta n (exclusive)
    # [n:] toma elementos desde n hasta el final
    
    # Crear conjuntos de características usando índices seleccionados
    X_train = [X[i] for i in train_indices]  # Features de entrenamiento
    X_val = [X[i] for i in val_indices]  # Features de validación
    # List comprehension que selecciona filas según los índices
    
    # Dividir etiquetas para cada casa
    y_train_dict = {}  # Diccionario para etiquetas de entrenamiento
    y_val_dict = {}  # Diccionario para etiquetas de validación
    
    for house in houses:  # Para cada casa de Hogwarts
        # Seleccionar etiquetas según los índices de train y validation
        y_train_dict[house] = [y_dict[house][i] for i in train_indices]
        y_val_dict[house] = [y_dict[house][i] for i in val_indices]
    
    return X_train, X_val, y_train_dict, y_val_dict  # Retornar todos los conjuntos


def predict_one_vs_all(X, theta_dict, houses):
    """
    Hacer predicciones usando clasificadores One-vs-All.
    Para cada ejemplo, calcula la probabilidad de pertenecer a cada casa
    y selecciona la casa con mayor probabilidad.
    
    Args:
        X: Matriz de características (m x n)
        theta_dict: Diccionario casa -> vector de pesos
        houses: Lista de nombres de casas
    
    Returns:
        Lista de nombres de casas predichas
    """
    predictions = []  # Lista para almacenar predicciones
    
    for x in X:  # Para cada ejemplo en el conjunto de datos
        # Calcular probabilidad para cada casa
        probabilities = {}  # Diccionario: casa -> probabilidad
        for house in houses:  # Para cada casa de Hogwarts
            theta = theta_dict[house]  # Obtener vector de pesos de esta casa
            # Calcular z = θᵀx (producto punto entre pesos y características)
            z = sum(theta[j] * x[j] for j in range(len(theta)))  # Suma de productos
            # Aplicar función sigmoide para obtener probabilidad
            prob = sigmoid(z)  # Convierte z a valor entre 0 y 1
            probabilities[house] = prob  # Guardar probabilidad
        
        # Predecir la casa con la probabilidad más alta
        predicted_house = max(probabilities, key=probabilities.get)
        # max(..., key=func) encuentra la clave con el valor máximo según func
        # probabilities.get obtiene el valor (probabilidad) asociado a cada casa
        predictions.append(predicted_house)  # Añadir predicción a la lista
    
    return predictions  # Retornar lista de predicciones


def calculate_accuracy(predictions, y_dict, houses):
    """
    Calcular la precisión (accuracy) de las predicciones.
    Precisión = (número de predicciones correctas) / (total de predicciones) * 100
    
    Args:
        predictions: Lista de casas predichas
        y_dict: Diccionario casa -> etiquetas binarias
        houses: Lista de nombres de casas
    
    Returns:
        Tupla (accuracy, correct, total)
    """
    # Convertir y_dict (formato One-vs-All) a etiquetas reales
    n_samples = len(predictions)  # Número de predicciones
    actual_labels = []  # Lista para etiquetas verdaderas
    
    # Para cada muestra, encontrar qué casa tiene etiqueta 1
    for i in range(n_samples):  # Para cada ejemplo
        for house in houses:  # Revisar cada casa
            if y_dict[house][i] == 1:  # Si la etiqueta es 1 para esta casa
                actual_labels.append(house)  # Esta es la casa verdadera
                break  # Salir del bucle (solo una casa puede ser 1)
    
    # Contar predicciones correctas
    # zip combina predictions y actual_labels en pares: [(pred1, actual1), (pred2, actual2), ...]
    correct = sum(1 for pred, actual in zip(predictions, actual_labels) if pred == actual)
    # sum() cuenta cuántos pares tienen predicción igual a etiqueta real
    # La expresión `1 for ... if pred == actual` genera un 1 por cada coincidencia
    
    # Calcular porcentaje de precisión
    accuracy = (correct / n_samples * 100) if n_samples > 0 else 0.0
    # Dividir correctas por total y multiplicar por 100 para obtener porcentaje
    
    return accuracy, correct, n_samples  # Retornar precisión, aciertos y total


def main():
    """
    Función principal de validación cruzada.
    Divide datos, entrena el modelo y evalúa su rendimiento en datos no vistos.
    """
    if len(sys.argv) < 2:  # Si no se proporciona archivo
        print("Uso: python cross_validate.py <dataset_train.csv> [ratio_entrenamiento]")
        print("Ejemplo: python cross_validate.py dataset_train.csv 0.8")
        sys.exit(1)  # Salir con error
    
    # Extraer argumentos
    filename = sys.argv[1]  # Archivo de datos de entrenamiento
    # Usar ratio del argumento o 0.8 por defecto (80% train, 20% validation)
    train_ratio = float(sys.argv[2]) if len(sys.argv) > 2 else 0.8
    
    # Mostrar información inicial
    print("="*80)
    print("DSLR - Validación Cruzada")
    print("="*80)
    print(f"Conjunto de datos: {filename}")
    print(f"División Train/Val: {train_ratio*100:.0f}% / {(1-train_ratio)*100:.0f}%")
    # .0f formatea como entero (0 decimales)
    
    # Establecer semilla para reproducibilidad
    random.seed(42)  # Usar semilla fija para obtener mismos resultados
    # Esto hace que random.shuffle produzca la misma secuencia cada vez
    
    # Importar funciones de entrenamiento (versión simplificada)
    from logreg_train import prepare_data, train_one_vs_all
    # Reutilizamos funciones del script de entrenamiento
    
    # Preparar conjunto de datos completo
    X, y_dict, feature_names, houses, normalization_params = prepare_data(filename)
    
    # Dividir en conjuntos de entrenamiento y validación
    print("\nDividiendo datos...")
    X_train, X_val, y_train_dict, y_val_dict = split_data(X, y_dict, houses, train_ratio)
    
    # Mostrar tamaños de los conjuntos
    print(f"Muestras de entrenamiento: {len(X_train)}")
    print(f"Muestras de validación: {len(X_val)}")
    
    # Entrenar con conjunto de entrenamiento
    print("\nEntrenando con conjunto de entrenamiento...")
    theta_dict = train_one_vs_all(X_train, y_train_dict, houses, 
                                  learning_rate=0.1, num_iterations=1000, 
                                  verbose=False)
    # verbose=False para no imprimir progreso detallado
    
    # Predecir en conjunto de validación (datos que el modelo no ha visto)
    print("\nEvaluando con conjunto de validación...")
    predictions = predict_one_vs_all(X_val, theta_dict, houses)
    
    # Calcular precisión (qué porcentaje de predicciones son correctas)
    accuracy, correct, total = calculate_accuracy(predictions, y_val_dict, houses)
    
    # Mostrar resultados
    print("\n" + "="*80)
    print("RESULTADOS DE VALIDACIÓN")
    print("="*80)
    print(f"\nPrecisión: {accuracy:.2f}%")  # Porcentaje con 2 decimales
    print(f"Correctas: {correct} / {total}")  # Aciertos sobre total
    
    # Verificar si cumple el requisito de precisión >= 98%
    if accuracy >= 98.0:  # Si precisión es suficiente
        print(f"\n✓ APROBADO: Precisión >= 98%")
    else:  # Si precisión es insuficiente
        print(f"\n✗ FALLADO: Precisión < 98% (necesita mejorar)")
        # Sugerencias: ajustar hyperparámetros, añadir más features, más iteraciones
    
    print("\n" + "="*80)


if __name__ == "__main__":
    main()  # Ejecutar función principal si se ejecuta como script
    # __name__ == "__main__" es True solo cuando el archivo se ejecuta directamente
