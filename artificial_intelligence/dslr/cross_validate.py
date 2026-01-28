#!/usr/bin/env python3
"""
DSLR - cross_validate.py
Realizar validación cruzada en datos de entrenamiento para estimar precisión.

Ya que el conjunto de prueba no tiene etiquetas, dividimos los datos de entrenamiento para validar.
"""

import sys
import random
import pickle


def parse_float(value):
    """Convertir cadena a float de forma segura"""
    try:
        return float(value)
    except (ValueError, TypeError):
        return None


def read_csv(filename):
    """Leer archivo CSV"""
    import csv
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


def sigmoid(z):
    """Sigmoid function"""
    if z > 500:
        return 1.0
    elif z < -500:
        return 0.0
    return 1.0 / (1.0 + (2.718281828459045 ** (-z)))


def split_data(X, y_dict, houses, train_ratio=0.8):
    """Split data into train and validation sets"""
    n_samples = len(X)
    indices = list(range(n_samples))
    random.shuffle(indices)
    
    split_point = int(n_samples * train_ratio)
    train_indices = indices[:split_point]
    val_indices = indices[split_point:]
    
    X_train = [X[i] for i in train_indices]
    X_val = [X[i] for i in val_indices]
    
    y_train_dict = {}
    y_val_dict = {}
    
    for house in houses:
        y_train_dict[house] = [y_dict[house][i] for i in train_indices]
        y_val_dict[house] = [y_dict[house][i] for i in val_indices]
    
    return X_train, X_val, y_train_dict, y_val_dict


def predict_one_vs_all(X, theta_dict, houses):
    """Make predictions"""
    predictions = []
    
    for x in X:
        probabilities = {}
        for house in houses:
            theta = theta_dict[house]
            z = sum(theta[j] * x[j] for j in range(len(theta)))
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
