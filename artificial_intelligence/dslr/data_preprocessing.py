#!/usr/bin/env python3
"""
DSLR - data_preprocessing.py
Utilidades de limpieza y preprocesamiento de datos para el proyecto DSLR.

Características:
- Manejar valores faltantes (NaN)
- Normalización de características (Min-Max y Z-score)
- Selección de características
- División de datos
"""

import csv  # Para leer y escribir archivos CSV
import sys  # Para manejo de errores y argumentos


def parse_float(value):
    """
    Convertir cadena a float de forma segura.
    Retorna None si no es posible la conversión.
    """
    try:  # Intentar conversión
        return float(value)
    except (ValueError, TypeError):  # Si hay error
        return None  # Retornar None


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
    """
    Verificar si una columna contiene datos numéricos.
    Intenta convertir el primer valor no vacío a float.
    """
    for value in column_data:  # Para cada valor
        if value and value.strip():  # Si no está vacío
            try:  # Intentar conversión
                float(value)  # Convertir a float
                return True  # Es numérica
            except ValueError:  # Si falla
                return False  # No es numérica
    return False  # Si no hay valores, no es numérica


def calculate_mean(values):
    """
    Calcular la media de valores numéricos, ignorando None.
    values: lista de valores que puede contener None
    Retorna la media o None si no hay valores válidos.
    """
    clean_values = [v for v in values if v is not None]  # Filtrar None
    if len(clean_values) == 0:  # Si no hay valores válidos
        return None  # Retornar None
    return sum(clean_values) / len(clean_values)  # Retornar promedio


def calculate_median(values):
    """
    Calcular la mediana de valores numéricos, ignorando None.
    La mediana es el valor central cuando los datos están ordenados.
    values: lista de valores que puede contener None
    Retorna la mediana o None si no hay valores válidos.
    """
    clean_values = [v for v in values if v is not None]  # Filtrar None
    if len(clean_values) == 0:  # Si no hay valores válidos
        return None  # Retornar None
    sorted_values = sorted(clean_values)  # Ordenar valores
    n = len(sorted_values)  # Número de valores
    if n % 2 == 0:  # Si es par
        # Mediana = promedio de los dos valores centrales
        return (sorted_values[n//2 - 1] + sorted_values[n//2]) / 2
    else:  # Si es impar
        return sorted_values[n//2]  # Mediana = valor central


def impute_missing_values(data, numerical_features, method='mean'):
    """
    Fill missing values with mean or median
    
    Args:
        data: Dictionary of column_name -> list of values
        numerical_features: List of numerical feature names
        method: 'mean' or 'median'
    
    Returns:
        Dictionary with imputed values
    """
    imputed_data = {}
    
    for feature in numerical_features:
        values = [parse_float(v) for v in data[feature]]
        
        # Calculate fill value
        if method == 'mean':
            fill_value = calculate_mean(values)
        elif method == 'median':
            fill_value = calculate_median(values)
        else:
            fill_value = 0.0
        
        # Impute missing values
        imputed_values = []
        for v in values:
            if v is None:
                imputed_values.append(fill_value)
            else:
                imputed_values.append(v)
        
        imputed_data[feature] = imputed_values
    
    return imputed_data


def normalize_minmax(values):
    """
    Min-Max normalization: scale values to [0, 1]
    normalized_value = (value - min) / (max - min)
    """
    clean_values = [v for v in values if v is not None]
    if len(clean_values) == 0:
        return values
    
    min_val = min(clean_values)
    max_val = max(clean_values)
    
    # Avoid division by zero
    if max_val == min_val:
        return [0.5 for _ in values]
    
    normalized = []
    for v in values:
        if v is None:
            normalized.append(None)
        else:
            normalized.append((v - min_val) / (max_val - min_val))
    
    return normalized, min_val, max_val


def normalize_zscore(values):
    """
    Z-score normalization: scale values to have mean=0 and std=1
    normalized_value = (value - mean) / std
    """
    clean_values = [v for v in values if v is not None]
    if len(clean_values) == 0:
        return values
    
    mean = sum(clean_values) / len(clean_values)
    
    # Calculate standard deviation
    variance = sum((v - mean) ** 2 for v in clean_values) / len(clean_values)
    std = variance ** 0.5
    
    # Avoid division by zero
    if std == 0:
        return [0.0 for _ in values]
    
    normalized = []
    for v in values:
        if v is None:
            normalized.append(None)
        else:
            normalized.append((v - mean) / std)
    
    return normalized, mean, std


def preprocess_data(filename, selected_features=None, normalization='minmax', 
                   imputation='mean'):
    """
    Complete preprocessing pipeline
    
    Args:
        filename: Path to CSV file
        selected_features: List of feature names to use (None = all numerical)
        normalization: 'minmax' or 'zscore'
        imputation: 'mean' or 'median'
    
    Returns:
        Dictionary with preprocessed data and metadata
    """
    headers, data = read_csv(filename)
    
    # Identify numerical features
    excluded_columns = ['Index', 'Hogwarts House', 'First Name', 'Last Name', 
                       'Birthday', 'Best Hand']
    
    all_numerical_features = []
    for header in headers:
        if header not in excluded_columns and is_numerical_column(data[header]):
            all_numerical_features.append(header)
    
    # Use selected features or all numerical features
    if selected_features is None:
        selected_features = all_numerical_features
    
    # Convert to float
    float_data = {}
    for feature in selected_features:
        float_data[feature] = [parse_float(v) for v in data[feature]]
    
    # Impute missing values
    imputed_data = impute_missing_values(float_data, selected_features, 
                                        method=imputation)
    
    # Normalize
    normalized_data = {}
    normalization_params = {}
    
    for feature in selected_features:
        if normalization == 'minmax':
            norm_values, min_val, max_val = normalize_minmax(imputed_data[feature])
            normalized_data[feature] = norm_values
            normalization_params[feature] = {'min': min_val, 'max': max_val}
        elif normalization == 'zscore':
            norm_values, mean, std = normalize_zscore(imputed_data[feature])
            normalized_data[feature] = norm_values
            normalization_params[feature] = {'mean': mean, 'std': std}
        else:
            normalized_data[feature] = imputed_data[feature]
            normalization_params[feature] = {}
    
    # Get labels (houses)
    labels = data.get('Hogwarts House', [])
    
    return {
        'features': normalized_data,
        'labels': labels,
        'feature_names': selected_features,
        'normalization_method': normalization,
        'normalization_params': normalization_params,
        'n_samples': len(labels)
    }


def save_preprocessed_data(preprocessed_data, output_filename):
    """Save preprocessed data to CSV file"""
    feature_names = preprocessed_data['feature_names']
    labels = preprocessed_data['labels']
    features = preprocessed_data['features']
    
    with open(output_filename, 'w', newline='') as f:
        writer = csv.writer(f)
        
        # Write header
        writer.writerow(['Hogwarts House'] + feature_names)
        
        # Write rows
        n_samples = preprocessed_data['n_samples']
        for i in range(n_samples):
            row = [labels[i]]
            for feature in feature_names:
                value = features[feature][i]
                row.append(f"{value:.6f}" if value is not None else "")
            writer.writerow(row)
    
    print(f"Datos preprocesados guardados en: {output_filename}")


def main():
    """Main function for testing preprocessing"""
    if len(sys.argv) < 2:
        print("Uso: python data_preprocessing.py <dataset.csv> [salida.csv]")
        print("Ejemplo: python data_preprocessing.py dataset_train.csv preprocessed_train.csv")
        sys.exit(1)
    
    filename = sys.argv[1]
    output_filename = sys.argv[2] if len(sys.argv) > 2 else 'preprocessed_data.csv'
    
    print("Preprocesando datos...")
    print(f"Entrada: {filename}")
    print(f"Normalización: minmax")
    print(f"Imputación: media")
    
    preprocessed = preprocess_data(filename, normalization='minmax', imputation='mean')
    
    print(f"\nCaracterísticas usadas ({len(preprocessed['feature_names'])}):") 
    for feat in preprocessed['feature_names']:
        print(f"  - {feat}")
    
    print(f"\nNúmero de muestras: {preprocessed['n_samples']}")
    
    save_preprocessed_data(preprocessed, output_filename)


if __name__ == "__main__":
    main()
