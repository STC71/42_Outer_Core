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

import sys
import csv
import pickle


def parse_float(value):
    """Convertir cadena a float de forma segura, devolver None si no es posible"""
    try:
        return float(value)
    except (ValueError, TypeError):
        return None


def read_csv(filename):
    """Leer archivo CSV y devolver encabezados y datos"""
    try:
        with open(filename, 'r') as f:
            reader = csv.reader(f)
            headers = next(reader)
            
            data = {header: [] for header in headers}
            
            for row in reader:
                for i, value in enumerate(row):
                    if i < len(headers):
                        data[headers[i]].append(value)
        
        return headers, data
    
    except FileNotFoundError:
        print(f"Error: Archivo '{filename}' no encontrado", file=sys.stderr)
        sys.exit(1)
    except Exception as e:
        print(f"Error leyendo archivo: {e}", file=sys.stderr)
        sys.exit(1)


def is_numerical_column(column_data):
    """Check if a column contains numerical data"""
    for value in column_data:
        if value and value.strip():
            try:
                float(value)
                return True
            except ValueError:
                return False
    return False


# ============================================================================
# MATHEMATICAL FUNCTIONS (No numpy/scipy allowed!)
# ============================================================================

def sigmoid(z):
    """
    Sigmoid activation function: g(z) = 1 / (1 + e^(-z))
    Handles overflow by clipping z
    """
    # Clip to avoid overflow
    if z > 500:
        return 1.0
    elif z < -500:
        return 0.0
    
    try:
        return 1.0 / (1.0 + (2.718281828459045 ** (-z)))  # e ≈ 2.718281828459045
    except:
        return 0.5


def compute_cost(X, y, theta):
    """
    Compute logistic regression cost function
    J(θ) = -1/m Σ[y*log(h(x)) + (1-y)*log(1-h(x))]
    
    Args:
        X: List of feature vectors (each row is a sample)
        y: List of labels (0 or 1)
        theta: Weight vector
    
    Returns:
        Cost value
    """
    m = len(y)
    if m == 0:
        return 0.0
    
    total_cost = 0.0
    epsilon = 1e-15  # Small value to avoid log(0)
    
    for i in range(m):
        # Compute h = sigmoid(θᵀx)
        z = sum(theta[j] * X[i][j] for j in range(len(theta)))
        h = sigmoid(z)
        
        # Clip h to avoid log(0)
        h = max(epsilon, min(1 - epsilon, h))
        
        # Add to cost: -[y*log(h) + (1-y)*log(1-h)]
        if y[i] == 1:
            cost = -log_custom(h)
        else:
            cost = -log_custom(1 - h)
        
        total_cost += cost
    
    return total_cost / m


def log_custom(x):
    """
    Natural logarithm using Taylor series approximation
    More accurate for values close to 1
    """
    if x <= 0:
        return -1000.0  # Large negative number
    if x == 1:
        return 0.0
    
    # For x close to 1, use Taylor series: ln(1+u) ≈ u - u²/2 + u³/3 - ...
    if 0.5 < x < 2.0:
        u = x - 1
        result = u - (u**2)/2 + (u**3)/3 - (u**4)/4 + (u**5)/5
        return result
    
    # For other values, use change of base and recursion
    if x > 2.0:
        return log_custom(x / 2.718281828459045) + 1.0
    else:
        return -log_custom(1.0 / x)


def gradient_descent_batch(X, y, theta, learning_rate, num_iterations, verbose=False):
    """
    BATCH Gradient Descent - updates weights using ALL training examples
    
    Args:
        X: Feature matrix (m x n) as list of lists
        y: Labels (m,) as list
        theta: Initial weights (n,) as list
        learning_rate: Learning rate (alpha)
        num_iterations: Number of iterations
        verbose: Print progress
    
    Returns:
        Optimized theta, cost history
    """
    m = len(y)
    n = len(theta)
    cost_history = []
    
    for iteration in range(num_iterations):
        # Compute gradient for all parameters
        gradient = [0.0] * n
        
        for i in range(m):
            # Compute prediction: h = sigmoid(θᵀx)
            z = sum(theta[j] * X[i][j] for j in range(n))
            h = sigmoid(z)
            
            # Error: (h - y)
            error = h - y[i]
            
            # Accumulate gradient: ∂J/∂θⱼ = (h - y) * xⱼ
            for j in range(n):
                gradient[j] += error * X[i][j]
        
        # Average gradient
        for j in range(n):
            gradient[j] /= m
        
        # Update weights: θⱼ := θⱼ - α * ∂J/∂θⱼ
        for j in range(n):
            theta[j] -= learning_rate * gradient[j]
        
        # Compute cost for monitoring
        if iteration % 100 == 0 or iteration == num_iterations - 1:
            cost = compute_cost(X, y, theta)
            cost_history.append(cost)
            
            if verbose and iteration % 500 == 0:
                print(f"  Iteration {iteration:5d}: Cost = {cost:.6f}")
    
    return theta, cost_history


# ============================================================================
# DATA PREPROCESSING
# ============================================================================

def normalize_features(X):
    """
    Normalize features using Z-score normalization
    Returns normalized X and parameters (mean, std) for each feature
    """
    if not X:
        return X, []
    
    m = len(X)
    n = len(X[0])
    
    # Calculate mean and std for each feature
    params = []
    for j in range(n):
        # Skip bias term (first column of 1s)
        if j == 0:
            params.append({'mean': 0, 'std': 1})
            continue
        
        # Calculate mean
        col_sum = sum(X[i][j] for i in range(m))
        mean = col_sum / m
        
        # Calculate std
        variance = sum((X[i][j] - mean) ** 2 for i in range(m)) / m
        std = variance ** 0.5
        
        params.append({'mean': mean, 'std': std})
    
    # Normalize
    X_normalized = []
    for i in range(m):
        row = []
        for j in range(n):
            if j == 0 or params[j]['std'] == 0:
                row.append(X[i][j])
            else:
                normalized_val = (X[i][j] - params[j]['mean']) / params[j]['std']
                row.append(normalized_val)
        X_normalized.append(row)
    
    return X_normalized, params


def prepare_data(filename, selected_features=None):
    """
    Load and prepare data for training
    
    Returns:
        X: Feature matrix with bias term
        y_dict: Dictionary of house -> binary labels
        feature_names: List of feature names used
        houses: List of unique houses
        normalization_params: Parameters for denormalization
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
    """Main training function"""
    if len(sys.argv) < 2:
        print("Uso: python logreg_train.py <dataset_train.csv> [tasa_aprendizaje] [iteraciones]")
        print("Ejemplo: python logreg_train.py dataset_train.csv 0.1 1000")
        sys.exit(1)
    
    filename = sys.argv[1]
    learning_rate = float(sys.argv[2]) if len(sys.argv) > 2 else 0.1
    num_iterations = int(sys.argv[3]) if len(sys.argv) > 3 else 1000
    
    print("="*80)
    print("DSLR - Entrenamiento de Regresión Logística")
    print("="*80)
    print(f"Conjunto de datos: {filename}")
    
    # Prepare data
    X, y_dict, feature_names, houses, normalization_params = prepare_data(filename)
    
    # Train model
    theta_dict = train_one_vs_all(X, y_dict, houses, learning_rate, num_iterations, 
                                  verbose=True)
    
    # Save model
    save_model(theta_dict, feature_names, houses, normalization_params, 'weights.pkl')
    
    print("\n¡Entrenamiento completo! Usa logreg_predict.py para hacer predicciones.")


if __name__ == "__main__":
    main()
