#!/usr/bin/env python3
"""
DSLR - logreg_train.py
Entrenar un clasificador de regresión logística multiclase usando estrategia One-vs-All.

Usa Descenso de Gradiente por LOTES (parte obligatoria).
¡No se permite sklearn.linear_model!

Fórmulas matemáticas:
- Hipótesis: h(x) = sigmoid(θᵀx) donde sigmoid(z) = 1/(1 + e^(-z))
- Coste: J(θ) = -1/m Σ[y*log(h(x)) + (1-y)*log(1-h(x))]
- Gradiente: ∂J/∂θⱼ = 1/m Σ[(h(x) - y)*xⱼ]
"""

import sys  # Para argumentos de línea de comandos y manejo de errores
import csv  # Para leer archivos CSV con datos de entrenamiento
import pickle  # Para guardar el modelo entrenado en archivo binario


def parse_float(value):
    """
    Convertir cadena a float de forma segura.
    Si la conversión falla, retorna None en lugar de lanzar excepción.
    value: cadena a convertir
    Retorna float o None si no es convertible.
    """
    try:  # Intentar conversión
        return float(value)  # Convertir a float
    except (ValueError, TypeError):  # Si hay error de valor o tipo
        return None  # Retornar None en lugar de error


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
            
            # Inicializar diccionario con listas vacías para cada columna
            data = {header: [] for header in headers}  # Dict comprehension
            
            # Leer todas las filas restantes
            for row in reader:  # Cada fila después de encabezados
                for i, value in enumerate(row):  # enumerate da (indice, valor)
                    if i < len(headers):  # Verificar que no excede número de columnas
                        data[headers[i]].append(value)  # Añadir valor a columna
        
        return headers, data  # Retornar encabezados y datos
    
    except FileNotFoundError:  # Si archivo no existe
        print(f"Error: Archivo '{filename}' no encontrado", file=sys.stderr)
        sys.exit(1)  # Salir con error
    except Exception as e:  # Cualquier otro error
        print(f"Error leyendo archivo: {e}", file=sys.stderr)
        sys.exit(1)


def is_numerical_column(column_data):
    """
    Verificar si una columna contiene datos numéricos.
    Intenta convertir el primer valor no vacío a float.
    column_data: lista de valores de una columna
    Retorna True si es numérica, False en caso contrario.
    """
    for value in column_data:  # Iterar sobre valores
        if value and value.strip():  # Si hay valor y no es solo espacios
            try:  # Intentar conversión
                float(value)  # Intentar convertir a float
                return True  # Si funciona, es numérica
            except ValueError:  # Si falla
                return False  # No es numérica
    return False  # Si no hay valores válidos, no es numérica


# ============================================================================
# FUNCIONES MATEMÁTICAS (No se permite numpy/scipy!)
# ============================================================================

def sigmoid(z):
    """
    Función de activación sigmoide: g(z) = 1 / (1 + e^(-z))
    Transforma cualquier valor real a un rango entre 0 y 1.
    Se usa para obtener probabilidades en regresión logística.
    z: valor de entrada (puede ser cualquier número real)
    Retorna valor entre 0 y 1.
    Maneja overflow recortando z a rangos seguros.
    """
    # Recortar para evitar overflow en exponencial
    if z > 500:  # Si z es muy grande
        return 1.0  # sigmoid(∞) = 1
    elif z < -500:  # Si z es muy pequeño (muy negativo)
        return 0.0  # sigmoid(-∞) = 0
    
    try:  # Calcular sigmoid normalmente
        return 1.0 / (1.0 + (2.718281828459045 ** (-z)))  # e ≈ 2.718281828459045
        # Fórmula: 1 / (1 + e^(-z))
    except:  # Si hay cualquier error
        return 0.5  # Retornar valor medio seguro


def compute_cost(X, y, theta):
    """
    Calcular la función de coste de regresión logística.
    Fórmula: J(θ) = -1/m Σ[y*log(h(x)) + (1-y)*log(1-h(x))]
    Mide qué tan bien el modelo predice las etiquetas.
    
    Args:
        X: Matriz de características (cada fila es un ejemplo)
        y: Lista de etiquetas (0 o 1)
        theta: Vector de pesos
    
    Retorna:
        Valor del coste (menor coste = mejor ajuste)
    """
    m = len(y)  # Número de ejemplos de entrenamiento
    if m == 0:  # Si no hay ejemplos
        return 0.0  # Retornar coste 0
    
    total_cost = 0.0  # Inicializar coste total
    epsilon = 1e-15  # Valor pequeño para evitar log(0) = -infinito
    
    for i in range(m):  # Para cada ejemplo de entrenamiento
        # Calcular h = sigmoid(θᵀx)
        z = sum(theta[j] * X[i][j] for j in range(len(theta)))  # Producto punto θᵀx
        h = sigmoid(z)  # Aplicar función sigmoide para obtener probabilidad
        
        # Recortar h para evitar log(0)
        h = max(epsilon, min(1 - epsilon, h))  # Mantener h en [epsilon, 1-epsilon]
        
        # Añadir al coste: -[y*log(h) + (1-y)*log(1-h)]
        if y[i] == 1:  # Si la etiqueta es 1 (positiva)
            cost = -log_custom(h)  # Coste = -log(h)
        else:  # Si la etiqueta es 0 (negativa)
            cost = -log_custom(1 - h)  # Coste = -log(1-h)
        
        total_cost += cost  # Acumular coste
    
    return total_cost / m  # Retornar coste promedio


def log_custom(x):
    """
    Logaritmo natural usando aproximación de series de Taylor.
    Más preciso para valores cercanos a 1.
    x: valor positivo para calcular ln(x)
    Retorna logaritmo natural de x.
    """
    if x <= 0:  # Si x no es positivo
        return -1000.0  # Número negativo grande (ln de valor ≤ 0 no definido)
    if x == 1:  # ln(1) = 0
        return 0.0
    
    # Para x cercano a 1, usar serie de Taylor: ln(1+u) ≈ u - u²/2 + u³/3 - ...
    if 0.5 < x < 2.0:  # Rango donde la serie converge rápidamente
        u = x - 1  # Cambio de variable
        # Serie de Taylor hasta orden 5
        result = u - (u**2)/2 + (u**3)/3 - (u**4)/4 + (u**5)/5
        return result
    
    # Para otros valores, usar cambio de base y recursión
    if x > 2.0:  # Si x es grande
        # ln(x) = ln(x/e) + 1
        return log_custom(x / 2.718281828459045) + 1.0
    else:  # Si x es pequeño (< 0.5)
        # ln(x) = -ln(1/x)
        return -log_custom(1.0 / x)


def gradient_descent_batch(X, y, theta, learning_rate, num_iterations, verbose=False):
    """
    Descenso de Gradiente por LOTES - actualiza pesos usando TODOS los ejemplos.
    Algoritmo de optimización para minimizar la función de coste.
    En cada iteración, calcula el gradiente usando todos los datos.
    
    Args:
        X: Matriz de características (m x n) como lista de listas
        y: Etiquetas (m,) como lista
        theta: Pesos iniciales (n,) como lista
        learning_rate: Tasa de aprendizaje (alpha) - controla tamaño de paso
        num_iterations: Número de iteraciones de optimización
        verbose: Imprimir progreso durante entrenamiento
    
    Retorna:
        Theta optimizado, historial de coste
    """
    m = len(y)  # Número de ejemplos de entrenamiento
    n = len(theta)  # Número de parámetros (features + bias)
    cost_history = []  # Lista para almacenar historial de coste
    
    for iteration in range(num_iterations):  # Para cada iteración de entrenamiento
        # Calcular gradiente para todos los parámetros
        gradient = [0.0] * n  # Inicializar vector gradiente con ceros
        
        for i in range(m):  # Para cada ejemplo de entrenamiento
            # Calcular predicción: h = sigmoid(θᵀx)
            z = sum(theta[j] * X[i][j] for j in range(n))  # Producto punto
            h = sigmoid(z)  # Aplicar sigmoide para obtener probabilidad
            
            # Calcular error: (h - y)
            error = h - y[i]  # Diferencia entre predicción y valor real
            
            # Acumular gradiente: ∂J/∂θⱼ = (h - y) * xⱼ
            for j in range(n):  # Para cada parámetro
                gradient[j] += error * X[i][j]  # Acumular contribución al gradiente
        
        # Promediar gradiente sobre todos los ejemplos
        for j in range(n):  # Para cada parámetro
            gradient[j] /= m  # Dividir por número de ejemplos
        
        # Actualizar pesos: θⱼ := θⱼ - α * ∂J/∂θⱼ
        for j in range(n):  # Para cada parámetro
            theta[j] -= learning_rate * gradient[j]  # Paso del gradiente descendente
        
        # Calcular coste para monitoreo (cada 100 iteraciones)
        if iteration % 100 == 0 or iteration == num_iterations - 1:  # Cada 100 o última
            cost = compute_cost(X, y, theta)  # Calcular coste actual
            cost_history.append(cost)  # Guardar en historial
            
            if verbose and iteration % 500 == 0:  # Si verbose y cada 500 iteraciones
                print(f"  Iteración {iteration:5d}: Coste = {cost:.6f}")
    
    return theta, cost_history  # Retornar pesos optimizados e historial


# ============================================================================
# PREPROCESAMIENTO DE DATOS
# ============================================================================

def normalize_features(X):
    """
    Normalizar características usando normalización Z-score.
    Fórmula: x_norm = (x - media) / desviación_estándar
    Mejora la convergencia del gradiente descendente.
    Retorna X normalizado y parámetros (media, std) para cada feature.
    """
    if not X:  # Si X está vacío
        return X, []  # Retornar sin cambios
    
    m = len(X)  # Número de ejemplos
    n = len(X[0])  # Número de features
    
    # Calcular media y desviación estándar para cada feature
    params = []  # Lista para almacenar parámetros de normalización
    for j in range(n):  # Para cada feature
        # Saltar término de sesgo (primera columna de 1s)
        if j == 0:  # Si es la columna de bias
            params.append({'mean': 0, 'std': 1})  # No normalizar bias
            continue  # Continuar con siguiente feature
        
        # Calcular media
        col_sum = sum(X[i][j] for i in range(m))  # Suma de valores en columna j
        mean = col_sum / m  # Media = suma / número de ejemplos
        
        # Calcular desviación estándar
        variance = sum((X[i][j] - mean) ** 2 for i in range(m)) / m  # Varianza
        std = variance ** 0.5  # Desviación estándar = raíz de varianza
        
        params.append({'mean': mean, 'std': std})  # Guardar parámetros
    
    # Normalizar cada valor usando los parámetros calculados
    X_normalized = []  # Lista para matriz normalizada
    for i in range(m):  # Para cada ejemplo
        row = []  # Nueva fila normalizada
        for j in range(n):  # Para cada feature
            if j == 0 or params[j]['std'] == 0:  # Si es bias o std=0
                row.append(X[i][j])  # Mantener valor original
            else:  # Si es feature normalizable
                # Aplicar normalización Z-score: (x - media) / std
                normalized_val = (X[i][j] - params[j]['mean']) / params[j]['std']
                row.append(normalized_val)  # Añadir valor normalizado
        X_normalized.append(row)  # Añadir fila a matriz normalizada
    
    return X_normalized, params  # Retornar datos normalizados y parámetros


def prepare_data(filename, selected_features=None):
    """
    Preparar datos para entrenamiento desde archivo CSV.
    - Lee el archivo CSV
    - Filtra y selecciona features numéricas
    - Imputa valores faltantes con la media
    - Normaliza features
    - Crea etiquetas binarias para One-vs-All
    
    Args:
        filename: Ruta al archivo CSV con datos de entrenamiento
        selected_features: Lista de features a usar (None = autoselección)
    
    Retorna:
        X: Matriz de features normalizada
        y_dict: Diccionario de etiquetas binarias {casa: [0/1]}
        selected_features: Lista de features usadas
        houses: Lista de casas de Hogwarts
        normalization_params: Parámetros de normalización
    """
    headers, data = read_csv(filename)
    
    # Get numerical features
    excluded_columns = ['Index', 'Hogwarts House', 'First Name', 'Last Name', 
                       'Birthday', 'Best Hand']
    
    all_numerical_features = []
    for header in headers:
        if header not in excluded_columns and is_numerical_column(data[header]):
            all_numerical_features.append(header)
    
    # Use selected features or default best features
    if selected_features is None:
        # Default: use features that work well (determined from analysis)
        # These can be adjusted after running pair_plot analysis
        selected_features = all_numerical_features
    
    # Get unique houses
    houses = []
    for house in data['Hogwarts House']:
        if house and house.strip() and house not in houses:
            houses.append(house)
    houses = sorted(houses)
    
    print(f"\nClases encontradas: {houses}")
    print(f"Número de características: {len(selected_features)}")
    print(f"Características: {selected_features[:5]}..." if len(selected_features) > 5 else f"Características: {selected_features}")
    
    # Build feature matrix X (with imputation for missing values)
    X = []
    raw_labels = []
    
    # First pass: collect all values to compute means for imputation
    feature_means = {}
    for feature in selected_features:
        values = [parse_float(v) for v in data[feature]]
        clean_values = [v for v in values if v is not None]
        if clean_values:
            feature_means[feature] = sum(clean_values) / len(clean_values)
        else:
            feature_means[feature] = 0.0
    
    # Second pass: build feature matrix
    for i in range(len(data['Hogwarts House'])):
        house = data['Hogwarts House'][i]
        if not house or not house.strip():
            continue
        
        # Add bias term (1.0) as first feature
        row = [1.0]
        
        # Add other features
        skip_row = False
        for feature in selected_features:
            value = parse_float(data[feature][i])
            if value is None:
                # Impute with mean
                value = feature_means[feature]
            row.append(value)
        
        if not skip_row:
            X.append(row)
            raw_labels.append(house.strip())
    
    # Normalize features (except bias term)
    X_normalized, normalization_params = normalize_features(X)
    
    # Create binary labels for each house (One-vs-All)
    y_dict = {}
    for house in houses:
        y_dict[house] = [1 if label == house else 0 for label in raw_labels]
    
    print(f"Muestras de entrenamiento: {len(X_normalized)}")
    for house in houses:
        count = sum(y_dict[house])
        print(f"  {house}: {count} muestras")
    
    return X_normalized, y_dict, selected_features, houses, normalization_params


# ============================================================================
# TRAINING
# ============================================================================

def train_one_vs_all(X, y_dict, houses, learning_rate=0.1, num_iterations=1000, 
                     verbose=True):
    """
    Train One-vs-All logistic regression classifiers
    
    Args:
        X: Feature matrix
        y_dict: Dictionary of house -> binary labels
        houses: List of house names
        learning_rate: Learning rate
        num_iterations: Number of iterations
        verbose: Print progress
    
    Returns:
        Dictionary of house -> theta (weights)
    """
    n_features = len(X[0])
    theta_dict = {}
    
    print("\n" + "="*80)
    print("ENTRENANDO REGRESIÓN LOGÍSTICA (One-vs-All)")
    print("="*80)
    print(f"Tasa de aprendizaje: {learning_rate}")
    print(f"Iteraciones: {num_iterations}")
    print(f"Optimización: Descenso de Gradiente por Lotes")
    
    for house in houses:
        print(f"\nEntrenando clasificador para '{house}' vs Todos...")
        
        y = y_dict[house]
        
        # Initialize weights to zeros
        theta = [0.0] * n_features
        
        # Train using batch gradient descent
        theta_optimized, cost_history = gradient_descent_batch(
            X, y, theta, learning_rate, num_iterations, verbose=verbose
        )
        
        theta_dict[house] = theta_optimized
        
        if cost_history:
            print(f"  Coste final: {cost_history[-1]:.6f}")
    
    print("\n" + "="*80)
    print("ENTRENAMIENTO COMPLETADO")
    print("="*80)
    
    return theta_dict


def save_model(theta_dict, feature_names, houses, normalization_params, filename='weights.pkl'):
    """Save trained model to file"""
    model = {
        'theta_dict': theta_dict,
        'feature_names': feature_names,
        'houses': houses,
        'normalization_params': normalization_params,
        'algorithm': 'batch_gradient_descent'
    }
    
    with open(filename, 'wb') as f:
        pickle.dump(model, f)
    
    print(f"\nModelo guardado en: {filename}")


def main():
    """
    Función principal de entrenamiento.
    Lee argumentos de línea de comandos, prepara datos, entrena modelo y guarda pesos.
    """
    if len(sys.argv) < 2:  # Si no hay archivo de datos
        print("Uso: python logreg_train.py <dataset_train.csv> [tasa_aprendizaje] [iteraciones]")
        print("Ejemplo: python logreg_train.py dataset_train.csv 0.1 1000")
        sys.exit(1)  # Salir con error
    
    # Extraer argumentos de línea de comandos
    filename = sys.argv[1]  # Archivo de datos
    learning_rate = float(sys.argv[2]) if len(sys.argv) > 2 else 0.1  # Tasa aprendizaje
    num_iterations = int(sys.argv[3]) if len(sys.argv) > 3 else 1000  # Iteraciones
    
    print("="*80)
    print("DSLR - Entrenamiento de Regresión Logística")
    print("="*80)
    print(f"Conjunto de datos: {filename}")
    
    # Preparar datos (leer, preprocesar, normalizar)
    X, y_dict, feature_names, houses, normalization_params = prepare_data(filename)
    
    # Entrenar modelo (One-vs-All para clasificación multiclase)
    theta_dict = train_one_vs_all(X, y_dict, houses, learning_rate, num_iterations, 
                                  verbose=True)
    
    # Guardar modelo entrenado en archivo
    save_model(theta_dict, feature_names, houses, normalization_params, 'weights.pkl')
    
    print("\n¡Entrenamiento completo! Usa logreg_predict.py para hacer predicciones.")


if __name__ == "__main__":
    main()  # Ejecutar función principal si se ejecuta como script
    # __name__ == "__main__" es True solo cuando se ejecuta directamente
