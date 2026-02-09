#!/usr/bin/env python3
"""
DSLR - logreg_predict.py
Predecir asignaciones de casas de Hogwarts usando modelo de regresión logística entrenado.

Carga los pesos del entrenamiento y aplica clasificación One-vs-All.
Genera predicciones en houses.csv en el formato requerido.
"""

import sys  # Para argumentos de línea de comandos y manejo de errores
import csv  # Para leer archivos CSV y escribir predicciones
import pickle  # Para cargar el modelo entrenado desde archivo binario


def parse_float(value):
    """
    Convertir cadena a float de forma segura.
    Si la conversión falla, retorna None en lugar de error.
    value: cadena a convertir
    Retorna float o None si no es convertible.
    """
    try:  # Intentar conversión
        return float(value)  # Convertir a float
    except (ValueError, TypeError):  # Si hay error
        return None  # Retornar None


def read_csv(filename):
    """
    Leer archivo CSV y devolver encabezados y datos.
    filename: ruta al archivo CSV
    Retorna tupla (headers, data):
    - headers: lista de nombres de columnas
    - data: diccionario {columna: [valores]}
    """
    try:  # Intentar abrir archivo
        with open(filename, 'r') as f:  # Abrir en modo lectura
            reader = csv.reader(f)  # Crear lector CSV
            headers = next(reader)  # Leer primera fila (encabezados)
            
            # Inicializar diccionario con listas vacías
            data = {header: [] for header in headers}  # Dict comprehension
            
            # Leer todas las filas restantes
            for row in reader:  # Para cada fila
                for i, value in enumerate(row):  # Para cada valor en la fila
                    if i < len(headers):  # Si no excede número de columnas
                        data[headers[i]].append(value)  # Añadir a columna correspondiente
        
        return headers, data  # Retornar encabezados y datos
    
    except FileNotFoundError:  # Si archivo no existe
        print(f"Error: Archivo '{filename}' no encontrado", file=sys.stderr)
        sys.exit(1)  # Salir con error
    except Exception as e:  # Cualquier otro error
        print(f"Error leyendo archivo: {e}", file=sys.stderr)
        sys.exit(1)


def sigmoid(z):
    """
    Función de activación sigmoide: g(z) = 1 / (1 + e^(-z))
    Transforma cualquier valor a un rango entre 0 y 1 (probabilidad).
    z: valor de entrada
    Retorna valor entre 0 y 1.
    """
    if z > 500:  # Si z es muy grande, evitar overflow
        return 1.0  # sigmoid(∞) = 1
    elif z < -500:  # Si z es muy negativo
        return 0.0  # sigmoid(-∞) = 0
    
    try:  # Calcular sigmoid normalmente
        return 1.0 / (1.0 + (2.718281828459045 ** (-z)))  # e ≈ 2.718...
    except:  # Si hay error
        return 0.5  # Retornar valor medio seguro


def load_model(filename='weights.pkl'):
    """
    Cargar modelo entrenado desde archivo.
    filename: ruta al archivo con pesos del modelo
    Retorna diccionario con modelo (pesos, features, casas, parámetros).
    """
    try:  # Intentar cargar modelo
        with open(filename, 'rb') as f:  # Abrir en modo lectura binaria
            model = pickle.load(f)  # Deserializar modelo con pickle
        return model  # Retornar modelo cargado
    except FileNotFoundError:  # Si archivo no existe
        print(f"Error: Archivo de modelo '{filename}' no encontrado", file=sys.stderr)
        print("Por favor entrena el modelo primero usando logreg_train.py", file=sys.stderr)
        sys.exit(1)  # Salir con error
    except Exception as e:  # Cualquier otro error
        print(f"Error cargando modelo: {e}", file=sys.stderr)
        sys.exit(1)


def prepare_test_data(filename, feature_names, normalization_params):
    """
    Preparar datos de prueba usando el mismo preprocesamiento que en entrenamiento.
    - Lee archivo CSV de prueba
    - Imputa valores faltantes con medias del entrenamiento
    - Normaliza usando parámetros del entrenamiento
    
    Args:
        filename: Ruta al CSV de prueba
        feature_names: Lista de nombres de features (del entrenamiento)
        normalization_params: Parámetros de normalización del entrenamiento
    
    Retorna:
        X: Matriz de features con término de sesgo
        indices: Índices originales de las filas del dataset
    """
    headers, data = read_csv(filename)
    
    # Compute means for imputation (from training data params)
    feature_means = {}
    for i, feature in enumerate(feature_names):
        if i + 1 < len(normalization_params):  # +1 because of bias term
            params = normalization_params[i + 1]
            feature_means[feature] = params['mean']
        else:
            feature_means[feature] = 0.0
    
    # Build feature matrix
    X = []
    indices = []
    
    for i in range(len(data.get('Index', data[headers[0]]))):
        # Add bias term
        row = [1.0]
        
        # Add features in same order as training
        for feature in feature_names:
            if feature in data:
                value = parse_float(data[feature][i])
                if value is None:
                    # Impute with mean from training
                    value = feature_means.get(feature, 0.0)
            else:
                value = 0.0
            
            row.append(value)
        
        X.append(row)
        
        # Store original index
        if 'Index' in data:
            indices.append(data['Index'][i])
        else:
            indices.append(str(i))
    
    # Normalize using training parameters
    X_normalized = []
    for i in range(len(X)):
        row = []
        for j in range(len(X[i])):
            if j == 0:  # Bias term
                row.append(X[i][j])
            elif j < len(normalization_params):
                params = normalization_params[j]
                if params['std'] == 0:
                    row.append(X[i][j])
                else:
                    normalized_val = (X[i][j] - params['mean']) / params['std']
                    row.append(normalized_val)
            else:
                row.append(X[i][j])
        X_normalized.append(row)
    
    return X_normalized, indices


def predict_one_vs_all(X, theta_dict, houses):
    """
    Make predictions using One-vs-All strategy
    
    For each sample, compute probability for each house and pick the highest
    
    Args:
        X: Feature matrix
        theta_dict: Dictionary of house -> weights
        houses: List of house names
    
    Returns:
        List of predicted house names
    """
    predictions = []
    
    for x in X:
        # Compute probability for each house
        probabilities = {}
        
        for house in houses:
            theta = theta_dict[house]
            
            # Compute z = θᵀx
            z = sum(theta[j] * x[j] for j in range(len(theta)))
            
            # Compute probability = sigmoid(z)
            prob = sigmoid(z)
            probabilities[house] = prob
        
        # Predict house with highest probability
        predicted_house = max(probabilities, key=probabilities.get)
        predictions.append(predicted_house)
    
    return predictions


def save_predictions(predictions, indices, output_filename='houses.csv'):
    """
    Save predictions to CSV file in required format
    
    Format:
    Index,Hogwarts House
    0,Gryffindor
    1,Hufflepuff
    ...
    """
    with open(output_filename, 'w', newline='') as f:
        writer = csv.writer(f)
        
        # Write header
        writer.writerow(['Index', 'Hogwarts House'])
        
        # Write predictions
        for idx, house in zip(indices, predictions):
            writer.writerow([idx, house])
    
    print(f"Predicciones guardadas en: {output_filename}")


def main():
    """Main prediction function"""
    if len(sys.argv) < 2:
        print("Uso: python logreg_predict.py <dataset_test.csv> [weights.pkl] [salida.csv]")
        print("Ejemplo: python logreg_predict.py dataset_test.csv weights.pkl houses.csv")
        sys.exit(1)
    
    test_filename = sys.argv[1]
    weights_filename = sys.argv[2] if len(sys.argv) > 2 else 'weights.pkl'
    output_filename = sys.argv[3] if len(sys.argv) > 3 else 'houses.csv'
    
    print("="*80)
    print("DSLR - Predicción de Regresión Logística")
    print("="*80)
    print(f"Dataset de prueba: {test_filename}")
    print(f"Pesos del modelo: {weights_filename}")
    
    # Load model
    print("\nCargando modelo entrenado...")
    model = load_model(weights_filename)
    
    theta_dict = model['theta_dict']
    feature_names = model['feature_names']
    houses = model['houses']
    normalization_params = model['normalization_params']
    
    print(f"¡Modelo cargado exitosamente!")
    print(f"Clases: {houses}")
    print(f"Características: {len(feature_names)}")
    print(f"Algoritmo: {model.get('algorithm', 'batch_gradient_descent')}")
    
    # Prepare test data
    print("\nPreparando datos de prueba...")
    X_test, indices = prepare_test_data(test_filename, feature_names, normalization_params)
    print(f"Muestras de prueba: {len(X_test)}")
    
    # Make predictions
    print("\nHaciendo predicciones...")
    predictions = predict_one_vs_all(X_test, theta_dict, houses)
    
    # Show prediction distribution
    print("\nDistribución de predicciones:")
    for house in houses:
        count = predictions.count(house)
        percentage = (count / len(predictions)) * 100 if predictions else 0
        print(f"  {house}: {count} ({percentage:.1f}%)")
    
    # Save predictions
    print()
    save_predictions(predictions, indices, output_filename)
    
    print("\n" + "="*80)
    print("PREDICCIÓN COMPLETADA")
    print("="*80)


if __name__ == "__main__":
    main()
