#!/usr/bin/env python3
"""
DSLR - logreg_train_stochastic.py
BONUS: Entrenar usando Descenso de Gradiente Estocástico (SGD)

El GD Estocástico actualiza los pesos después de CADA ejemplo de entrenamiento, haciéndolo:
- Más rápido por iteración
- Más ruidoso (puede escapar de mínimos locales)
- Puede necesitar más iteraciones pero cada una es más barata
"""

import sys
import csv
import pickle
import random


# Importar funciones comunes de logreg_train
# Para una implementación real, estas estarían en un módulo compartido
def parse_float(value):
    """Convertir cadena a float de forma segura"""
    try:
        return float(value)
    except (ValueError, TypeError):
        return None


def sigmoid(z):
    """Función sigmoide"""
    if z > 500:
        return 1.0
    elif z < -500:
        return 0.0
    return 1.0 / (1.0 + (2.718281828459045 ** (-z)))


def log_custom(x):
    """Natural logarithm"""
    if x <= 0:
        return -1000.0
    if x == 1:
        return 0.0
    if 0.5 < x < 2.0:
        u = x - 1
        return u - (u**2)/2 + (u**3)/3 - (u**4)/4 + (u**5)/5
    if x > 2.0:
        return log_custom(x / 2.718281828459045) + 1.0
    return -log_custom(1.0 / x)


def compute_cost(X, y, theta):
    """Compute logistic regression cost"""
    m = len(y)
    if m == 0:
        return 0.0
    
    total_cost = 0.0
    epsilon = 1e-15
    
    for i in range(m):
        z = sum(theta[j] * X[i][j] for j in range(len(theta)))
        h = sigmoid(z)
        h = max(epsilon, min(1 - epsilon, h))
        
        if y[i] == 1:
            cost = -log_custom(h)
        else:
            cost = -log_custom(1 - h)
        
        total_cost += cost
    
    return total_cost / m


def gradient_descent_stochastic(X, y, theta, learning_rate, num_epochs, verbose=False):
    """
    STOCHASTIC Gradient Descent - updates weights after EACH example
    
    Args:
        X: Feature matrix
        y: Labels
        theta: Initial weights
        learning_rate: Learning rate
        num_epochs: Number of passes through the dataset
        verbose: Print progress
    
    Returns:
        Optimized theta, cost history
    """
    m = len(y)
    n = len(theta)
    cost_history = []
    
    # Create indices for shuffling
    indices = list(range(m))
    
    for epoch in range(num_epochs):
        # Shuffle data at beginning of each epoch
        random.shuffle(indices)
        
        # Update weights for each training example
        for idx in indices:
            i = indices[idx]
            
            # Compute prediction for single example
            z = sum(theta[j] * X[i][j] for j in range(n))
            h = sigmoid(z)
            
            # Error
            error = h - y[i]
            
            # Update weights immediately: θⱼ := θⱼ - α * (h - y) * xⱼ
            for j in range(n):
                theta[j] -= learning_rate * error * X[i][j]
        
        # Compute cost after each epoch for monitoring
        if epoch % 10 == 0 or epoch == num_epochs - 1:
            cost = compute_cost(X, y, theta)
            cost_history.append(cost)
            
            if verbose and epoch % 50 == 0:
                print(f"  Epoch {epoch:5d}: Cost = {cost:.6f}")
    
    return theta, cost_history


# Copy the rest of the necessary functions from logreg_train.py
# (read_csv, is_numerical_column, normalize_features, prepare_data, etc.)

def read_csv(filename):
    """Read CSV file"""
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


def is_numerical_column(column_data):
    """Check if column is numerical"""
    for value in column_data:
        if value and value.strip():
            try:
                float(value)
                return True
            except ValueError:
                return False
    return False


def normalize_features(X):
    """Normalize features using Z-score"""
    if not X:
        return X, []
    
    m = len(X)
    n = len(X[0])
    params = []
    
    for j in range(n):
        if j == 0:
            params.append({'mean': 0, 'std': 1})
            continue
        
        col_sum = sum(X[i][j] for i in range(m))
        mean = col_sum / m
        variance = sum((X[i][j] - mean) ** 2 for i in range(m)) / m
        std = variance ** 0.5
        params.append({'mean': mean, 'std': std})
    
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
    """Prepare data for training"""
    headers, data = read_csv(filename)
    
    excluded_columns = ['Index', 'Hogwarts House', 'First Name', 'Last Name', 
                       'Birthday', 'Best Hand']
    
    all_numerical_features = []
    for header in headers:
        if header not in excluded_columns and is_numerical_column(data[header]):
            all_numerical_features.append(header)
    
    if selected_features is None:
        selected_features = all_numerical_features
    
    houses = []
    for house in data['Hogwarts House']:
        if house and house.strip() and house not in houses:
            houses.append(house)
    houses = sorted(houses)
    
    print(f"\nClases: {houses}")
    print(f"Características: {len(selected_features)}")
    
    # Compute means for imputation
    feature_means = {}
    for feature in selected_features:
        values = [parse_float(v) for v in data[feature]]
        clean_values = [v for v in values if v is not None]
        if clean_values:
            feature_means[feature] = sum(clean_values) / len(clean_values)
        else:
            feature_means[feature] = 0.0
    
    # Build feature matrix
    X = []
    raw_labels = []
    
    for i in range(len(data['Hogwarts House'])):
        house = data['Hogwarts House'][i]
        if not house or not house.strip():
            continue
        
        row = [1.0]  # Bias term
        for feature in selected_features:
            value = parse_float(data[feature][i])
            if value is None:
                value = feature_means[feature]
            row.append(value)
        
        X.append(row)
        raw_labels.append(house.strip())
    
    X_normalized, normalization_params = normalize_features(X)
    
    y_dict = {}
    for house in houses:
        y_dict[house] = [1 if label == house else 0 for label in raw_labels]
    
    print(f"Muestras de entrenamiento: {len(X_normalized)}")
    return X_normalized, y_dict, selected_features, houses, normalization_params


def train_one_vs_all_sgd(X, y_dict, houses, learning_rate=0.01, num_epochs=100, 
                         verbose=True):
    """Train using Stochastic Gradient Descent"""
    n_features = len(X[0])
    theta_dict = {}
    
    print("\n" + "="*80)
    print("ENTRENANDO REGRESIÓN LOGÍSTICA (Uno-contra-Todos)")
    print("="*80)
    print(f"Tasa de aprendizaje: {learning_rate}")
    print(f"Épocas: {num_epochs}")
    print(f"Optimización: Descenso de Gradiente ESTOCÁSTICO (BONUS)")
    
    for house in houses:
        print(f"\nEntrenando clasificador para '{house}' vs Todas...")
        
        y = y_dict[house]
        theta = [0.0] * n_features
        
        theta_optimized, cost_history = gradient_descent_stochastic(
            X, y, theta, learning_rate, num_epochs, verbose=verbose
        )
        
        theta_dict[house] = theta_optimized
        
        if cost_history:
            print(f"  Coste final: {cost_history[-1]:.6f}")
    
    print("\n" + "="*80)
    print("ENTRENAMIENTO COMPLETADO")
    print("="*80)
    
    return theta_dict


def save_model(theta_dict, feature_names, houses, normalization_params, filename='weights_sgd.pkl'):
    """Save model"""
    model = {
        'theta_dict': theta_dict,
        'feature_names': feature_names,
        'houses': houses,
        'normalization_params': normalization_params,
        'algorithm': 'stochastic_gradient_descent'
    }
    
    with open(filename, 'wb') as f:
        pickle.dump(model, f)
    
    print(f"\nModelo guardado en: {filename}")


def main():
    """Main function"""
    if len(sys.argv) < 2:
        print("Uso: python logreg_train_stochastic.py <dataset_train.csv> [tasa_aprendizaje] [épocas]")
        print("Ejemplo: python logreg_train_stochastic.py dataset_train.csv 0.01 100")
        sys.exit(1)
    
    filename = sys.argv[1]
    learning_rate = float(sys.argv[2]) if len(sys.argv) > 2 else 0.01
    num_epochs = int(sys.argv[3]) if len(sys.argv) > 3 else 100
    
    print("="*80)
    print("DSLR - Entrenamiento con Descenso de Gradiente Estocástico (BONUS)")
    print("="*80)
    print(f"Conjunto de datos: {filename}")
    
    # Set random seed for reproducibility
    random.seed(42)
    
    X, y_dict, feature_names, houses, normalization_params = prepare_data(filename)
    
    theta_dict = train_one_vs_all_sgd(X, y_dict, houses, learning_rate, num_epochs, 
                                      verbose=True)
    
    save_model(theta_dict, feature_names, houses, normalization_params, 'weights_sgd.pkl')
    
    print("\nEntrenamiento completado! Usa logreg_predict.py con weights_sgd.pkl")


if __name__ == "__main__":
    main()
