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
    headers, data = read_csv(filename)  # Leer encabezados y datos del CSV
    
    # Calcular medias para imputación (usando parámetros del entrenamiento)
    # La imputación debe usar las mismas medias que se usaron durante el entrenamiento
    feature_means = {}  # Diccionario: feature -> media
    for i, feature in enumerate(feature_names):  # Para cada feature del modelo
        # +1 porque el primer elemento de normalization_params es el bias (que no se normaliza)
        if i + 1 < len(normalization_params):  # Si hay parámetros disponibles
            params = normalization_params[i + 1]  # Obtener parámetros de esta feature
            feature_means[feature] = params['mean']  # Usar media del entrenamiento
        else:  # Si no hay parámetros
            feature_means[feature] = 0.0  # Usar 0 como valor por defecto
    
    # Construir matriz de características
    X = []  # Matriz de features
    indices = []  # Lista de índices originales
    
    # Procesar cada fila del dataset de prueba
    for i in range(len(data.get('Index', data[headers[0]]))):
        # Comenzar con término de sesgo (bias) = 1.0
        # El bias es necesario para que el modelo pueda hacer predicciones
        row = [1.0]  # Primer elemento es el bias
        
        # Añadir features en el MISMO orden que durante el entrenamiento
        # El orden es crucial para que los pesos se apliquen correctamente
        for feature in feature_names:  # Para cada feature del modelo
            if feature in data:  # Si la feature existe en los datos de prueba
                value = parse_float(data[feature][i])  # Convertir a float
                if value is None:  # Si el valor está faltante
                    # Imputar con la media del entrenamiento
                    value = feature_means.get(feature, 0.0)
            else:  # Si la feature no existe en el dataset
                value = 0.0  # Usar 0 como valor por defecto
            
            row.append(value)  # Añadir valor a la fila
        
        X.append(row)  # Añadir fila completa a la matriz
        
        # Almacenar índice original de la fila
        if 'Index' in data:  # Si hay columna de índices
            indices.append(data['Index'][i])  # Usar índice del CSV
        else:  # Si no hay columna de índices
            indices.append(str(i))  # Usar índice numérico
    
    # Normalizar usando los parámetros del entrenamiento
    # CRUCIAL: Usar los mismos parámetros que se usaron para normalizar los datos de entrenamiento
    # Si usamos diferentes parámetros, las predicciones serán incorrectas
    X_normalized = []  # Lista para matriz normalizada
    for i in range(len(X)):  # Para cada ejemplo
        row = []  # Nueva fila normalizada
        for j in range(len(X[i])):  # Para cada feature
            if j == 0:  # Si es el término de sesgo (bias)
                row.append(X[i][j])  # No normalizar bias (siempre es 1.0)
            elif j < len(normalization_params):  # Si hay parámetros disponibles
                params = normalization_params[j]  # Obtener parámetros
                if params['std'] == 0:  # Si desviación estándar es 0
                    row.append(X[i][j])  # No normalizar (evitar división por 0)
                else:  # Si se puede normalizar
                    # Aplicar normalización Z-score: (x - media) / std
                    normalized_val = (X[i][j] - params['mean']) / params['std']
                    row.append(normalized_val)  # Añadir valor normalizado
            else:  # Si no hay parámetros para esta feature
                row.append(X[i][j])  # Mantener valor original
        X_normalized.append(row)  # Añadir fila normalizada a matriz
    
    return X_normalized, indices  # Retornar matriz normalizada e índices


def predict_one_vs_all(X, theta_dict, houses):
    """
    Hacer predicciones usando estrategia One-vs-All.
    Para cada muestra, calcular probabilidad de pertenecer a cada casa y elegir la más alta.
    Esto implementa clasificación multiclase usando múltiples clasificadores binarios.
    
    Args:
        X: Matriz de características (m x n) normalizada
        theta_dict: Diccionario casa -> vector de pesos
        houses: Lista de nombres de casas de Hogwarts
    
    Returns:
        Lista de nombres de casas predichas (una por cada muestra en X)
    """
    predictions = []  # Lista para almacenar predicciones
    
    for x in X:  # Para cada muestra de prueba
        # Calcular probabilidad de pertenecer a cada casa
        probabilities = {}  # Diccionario: casa -> probabilidad
        
        for house in houses:  # Para cada casa de Hogwarts
            theta = theta_dict[house]  # Obtener pesos de este clasificador
            
            # Calcular z = θᵀx (producto punto de pesos y features)
            # Esto es la combinación lineal de las features ponderadas por los pesos
            z = sum(theta[j] * x[j] for j in range(len(theta)))  # Producto punto
            # sum() calcula θ0*x0 + θ1*x1 + ... + θn*xn
            
            # Calcular probabilidad = sigmoid(z)
            # sigmoid transforma z (que puede ser cualquier número) a un valor entre 0 y 1
            prob = sigmoid(z)  # Aplicar función sigmoide
            probabilities[house] = prob  # Guardar probabilidad para esta casa
        
        # Predecir la casa con mayor probabilidad
        # max(..., key=...) encuentra la casa con el valor más alto en el diccionario
        predicted_house = max(probabilities, key=probabilities.get)
        # probabilities.get obtiene el valor (probabilidad) asociado a cada clave (casa)
        predictions.append(predicted_house)  # Añadir predicción a la lista
    
    return predictions  # Retornar lista de predicciones


def save_predictions(predictions, indices, output_filename='houses.csv'):
    """
    Guardar predicciones en archivo CSV en el formato requerido.
    El formato debe ser: Index, Hogwarts House
    
    Args:
        predictions: Lista de casas predichas
        indices: Lista de índices originales de las muestras
        output_filename: Nombre del archivo de salida
    
    Formato del archivo:
    Index,Hogwarts House
    0,Gryffindor
    1,Hufflepuff
    ...
    """
    with open(output_filename, 'w', newline='') as f:  # Abrir en modo escritura
        # newline='' previene líneas en blanco adicionales en Windows
        writer = csv.writer(f)  # Crear escritor CSV
        
        # Escribir encabezados
        writer.writerow(['Index', 'Hogwarts House'])  # Primera fila
        
        # Escribir predicciones (una por fila)
        for idx, house in zip(indices, predictions):  # zip combina dos listas en pares
            writer.writerow([idx, house])  # Escribir fila con índice y predicción
    
    print(f"Predicciones guardadas en: {output_filename}")  # Confirmar guardado


def main():
    """
    Función principal de predicción.
    Lee argumentos, carga modelo, prepara datos de prueba, hace predicciones y guarda resultados.
    """
    if len(sys.argv) < 2:  # Si no se proporciona archivo de prueba
        print("Uso: python logreg_predict.py <dataset_test.csv> [weights.pkl] [salida.csv]")
        print("Ejemplo: python logreg_predict.py dataset_test.csv weights.pkl houses.csv")
        sys.exit(1)  #  con error
    
    # Extraer argumentos de línea de comandos
    test_filename = sys.argv[1]  # Archivo con datos de prueba
    weights_filename = sys.argv[2] if len(sys.argv) > 2 else 'weights.pkl'  # Archivo del modelo
    output_filename = sys.argv[3] if len(sys.argv) > 3 else 'houses.csv'  # Archivo de salida
    # Operador ternario: valor_si_true if condición else valor_si_false
    
    # Mostrar información inicial
    print("="*80)
    print("DSLR - Predicción de Regresión Logística")
    print("="*80)
    print(f"Dataset de prueba: {test_filename}")
    print(f"Pesos del modelo: {weights_filename}")
    
    # Cargar modelo entrenado desde archivo
    print("\nCargando modelo entrenado...")
    model = load_model(weights_filename)  # Cargar modelo usando pickle
    
    # Extraer componentes del modelo
    theta_dict = model['theta_dict']  # Diccionario con pesos de cada clasificador
    feature_names = model['feature_names']  # Nombres de las características usadas
    houses = model['houses']  # Nombres de las casas de Hogwarts
    normalization_params = model['normalization_params']  # Parámetros de normalización
    
    # Mostrar información del modelo cargado
    print(f"¡Modelo cargado exitosamente!")
    print(f"Clases: {houses}")  # Mostrar casas que puede predecir
    print(f"Características: {len(feature_names)}")  # Número de features
    print(f"Algoritmo: {model.get('algorithm', 'batch_gradient_descent')}")  # Algoritmo usado
    # .get(key, default) retorna el valor o default si la clave no existe
    
    # Preparar datos de prueba con el mismo preprocesamiento del entrenamiento
    print("\nPreparando datos de prueba...")
    X_test, indices = prepare_test_data(test_filename, feature_names, normalization_params)
    print(f"Muestras de prueba: {len(X_test)}")  # Mostrar cantidad de ejemplos
    
    # Hacer predicciones usando el modelo One-vs-All
    print("\nHaciendo predicciones...")
    predictions = predict_one_vs_all(X_test, theta_dict, houses)
    
    # Mostrar distribución de predicciones (cuántos estudiantes en cada casa)
    print("\nDistribución de predicciones:")
    for house in houses:  # Para cada casa
        count = predictions.count(house)  # Contar cuántos fueron asignados a esta casa
        # Calcular porcentaje
        percentage = (count / len(predictions)) * 100 if predictions else 0
        print(f"  {house}: {count} ({percentage:.1f}%)")  # Mostrar conteo y porcentaje
        # .1f formatea con 1 decimal
    
    # Guardar predicciones en archivo CSV
    print()  # Línea en blanco
    save_predictions(predictions, indices, output_filename)
    
    # Mostrar mensaje de finalización
    print("\n" + "="*80)
    print("PREDICCIÓN COMPLETADA")
    print("="*80)


if __name__ == "__main__":
    main()  # Ejecutar función principal si se ejecuta como script
    # __name__ == "__main__" es True solo cuando el archivo se ejecuta directamente
