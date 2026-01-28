#!/usr/bin/env python3
"""
DSLR - describe.py
Descripción estadística de características numéricas en el dataset.
¡NO se permite pandas.describe() ni funciones similares!

Todas las estadísticas deben implementarse desde cero.
"""

import sys
import csv


def ft_count(data):
    """Contar valores no-NaN"""
    count = 0
    for value in data:
        if value is not None:
            count += 1
    return float(count)


def ft_sum(data):
    """Suma de todos los valores no-NaN"""
    total = 0.0
    for value in data:
        if value is not None:
            total += value
    return total


def ft_mean(data):
    """Calcular media (promedio) de los datos"""
    count = ft_count(data)
    if count == 0:
        return None
    return ft_sum(data) / count


def ft_variance(data, mean=None):
    """Calcular varianza de los datos"""
    if mean is None:
        mean = ft_mean(data)
    if mean is None:
        return None
    
    count = 0
    sum_squared_diff = 0.0
    
    for value in data:
        if value is not None:
            sum_squared_diff += (value - mean) ** 2
            count += 1
    
    if count == 0:
        return None
    
    # Varianza muestral (denominador n-1 para estimador insesgado)
    return sum_squared_diff / (count - 1) if count > 1 else 0.0


def ft_std(data, mean=None):
    """Calcular desviación estándar de los datos"""
    variance = ft_variance(data, mean)
    if variance is None:
        return None
    return variance ** 0.5


def ft_min(data):
    """Encontrar valor mínimo"""
    min_val = None
    for value in data:
        if value is not None:
            if min_val is None or value < min_val:
                min_val = value
    return min_val


def ft_max(data):
    """Encontrar valor máximo"""
    max_val = None
    for value in data:
        if value is not None:
            if max_val is None or value > max_val:
                max_val = value
    return max_val


def ft_percentile(data, percentile):
    """
    Calcular percentil de los datos (0-100)
    Usa interpolación lineal entre rangos más cercanos
    """
    # Filtrar valores None y ordenar
    clean_data = [x for x in data if x is not None]
    if len(clean_data) == 0:
        return None
    
    # Ordenar datos
    sorted_data = sorted(clean_data)
    n = len(sorted_data)
    
    # Calcular posición
    pos = (percentile / 100.0) * (n - 1)
    
    # Obtener índices inferior y superior
    lower_idx = int(pos)
    upper_idx = lower_idx + 1
    
    # Si la posición es exactamente un índice, devolver ese valor
    if pos == lower_idx:
        return sorted_data[lower_idx]
    
    # Si el índice superior está fuera de límites, devolver último valor
    if upper_idx >= n:
        return sorted_data[-1]
    
    # Interpolación lineal
    fraction = pos - lower_idx
    return sorted_data[lower_idx] + fraction * (sorted_data[upper_idx] - sorted_data[lower_idx])


def ft_median(data):
    """Calcular mediana (percentil 50)"""
    return ft_percentile(data, 50.0)


def ft_quartile_1(data):
    """Calcular primer cuartil (percentil 25)"""
    return ft_percentile(data, 25.0)


def ft_quartile_3(data):
    """Calcular tercer cuartil (percentil 75)"""
    return ft_percentile(data, 75.0)


# BONUS: Estadísticas adicionales
def ft_range(data):
    """Calcular rango (max - min)"""
    min_val = ft_min(data)
    max_val = ft_max(data)
    if min_val is None or max_val is None:
        return None
    return max_val - min_val


def ft_iqr(data):
    """Calcular Rango Intercuartílico (Q3 - Q1)"""
    q1 = ft_quartile_1(data)
    q3 = ft_quartile_3(data)
    if q1 is None or q3 is None:
        return None
    return q3 - q1


def ft_mode(data):
    """Calculate mode (most frequent value) - BONUS"""
    clean_data = [x for x in data if x is not None]
    if len(clean_data) == 0:
        return None
    
    frequency = {}
    for value in clean_data:
        # Round to avoid floating point issues
        rounded = round(value, 6)
        frequency[rounded] = frequency.get(rounded, 0) + 1
    
    max_freq = max(frequency.values())
    # Return the first value with maximum frequency
    for value, freq in frequency.items():
        if freq == max_freq:
            return value
    return None


def ft_skewness(data):
    """Calculate skewness (measure of asymmetry) - BONUS"""
    mean = ft_mean(data)
    std = ft_std(data)
    if mean is None or std is None or std == 0:
        return None
    
    n = 0
    sum_cubed = 0.0
    
    for value in data:
        if value is not None:
            sum_cubed += ((value - mean) / std) ** 3
            n += 1
    
    if n == 0:
        return None
    
    return sum_cubed / n


def ft_kurtosis(data):
    """Calculate kurtosis (measure of tailedness) - BONUS"""
    mean = ft_mean(data)
    std = ft_std(data)
    if mean is None or std is None or std == 0:
        return None
    
    n = 0
    sum_fourth = 0.0
    
    for value in data:
        if value is not None:
            sum_fourth += ((value - mean) / std) ** 4
            n += 1
    
    if n == 0:
        return None
    
    # Excess kurtosis (subtract 3 for normal distribution baseline)
    return (sum_fourth / n) - 3


def parse_float(value):
    """Safely parse a string to float, return None if not possible"""
    try:
        return float(value)
    except (ValueError, TypeError):
        return None


def read_csv(filename):
    """Read CSV file and extract numerical columns"""
    try:
        with open(filename, 'r') as f:
            reader = csv.reader(f)
            headers = next(reader)
            
            # Initialize data structure
            data = {header: [] for header in headers}
            
            # Read all rows
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
    # Try to convert first non-empty value
    for value in column_data:
        if value and value.strip():
            try:
                float(value)
                return True
            except ValueError:
                return False
    return False


def describe(filename, bonus=True):
    """
    Display statistical description of numerical features
    
    Args:
        filename: Path to CSV file
        bonus: Include bonus statistics
    """
    headers, data = read_csv(filename)
    
    # Filter numerical columns and convert to floats
    numerical_data = {}
    for header in headers:
        if is_numerical_column(data[header]):
            numerical_data[header] = [parse_float(x) for x in data[header]]
    
    if not numerical_data:
        print("No se encontraron características numéricas en el conjunto de datos")
        return
    
    # Calculate statistics for each column
    stats = {}
    stat_names = ['Recuento', 'Media', 'Desv.Est', 'Mín', '25%', '50%', '75%', 'Máx']
    
    # Add bonus statistics
    if bonus:
        stat_names.extend(['Rango', 'RIC', 'Asimetría', 'Curtosis'])
    
    for stat in stat_names:
        stats[stat] = {}
    
    for column, values in numerical_data.items():
        mean = ft_mean(values)
        
        stats['Count'][column] = ft_count(values)
        stats['Mean'][column] = mean
        stats['Std'][column] = ft_std(values, mean)
        stats['Min'][column] = ft_min(values)
        stats['25%'][column] = ft_quartile_1(values)
        stats['50%'][column] = ft_median(values)
        stats['75%'][column] = ft_quartile_3(values)
        stats['Max'][column] = ft_max(values)
        
        if bonus:
            stats['Range'][column] = ft_range(values)
            stats['IQR'][column] = ft_iqr(values)
            stats['Skewness'][column] = ft_skewness(values)
            stats['Kurtosis'][column] = ft_kurtosis(values)
    
    # Display results
    # Print header
    col_width = 16
    print(f"{'':14}", end='')
    for column in numerical_data.keys():
        # Truncate long column names
        col_name = column[:col_width-2] if len(column) > col_width-2 else column
        print(f"{col_name:>{col_width}}", end='')
    print()
    
    # Print each statistic row
    for stat in stat_names:
        print(f"{stat:14}", end='')
        for column in numerical_data.keys():
            value = stats[stat][column]
            if value is None:
                print(f"{'NaN':>{col_width}}", end='')
            else:
                print(f"{value:>{col_width}.6f}", end='')
        print()


def main():
    """Main function"""
    if len(sys.argv) < 2:
        print("Uso: python describe.py <dataset.csv>")
        print("Ejemplo: python describe.py dataset_train.csv")
        sys.exit(1)
    
    filename = sys.argv[1]
    
    # Check if bonus flag is provided
    bonus = '--bonus' in sys.argv or '-b' in sys.argv
    
    describe(filename, bonus=True)  # Always show bonus stats


if __name__ == "__main__":
    main()
