#!/usr/bin/env python3
"""
DSLR - histogram.py
Mostrar histograma para responder: ¿Qué curso de Hogwarts tiene una distribución
de puntuaciones homogénea entre las cuatro casas?

Una distribución homogénea significa que las puntuaciones están distribuidas
de forma similar en todas las casas (media, desviación estándar y forma similares).
"""

import sys  # Para manejo de argumentos y errores
import csv  # Para leer archivos CSV
import matplotlib.pyplot as plt  # Para crear gráficos


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
    """
    Leer archivo CSV y devolver encabezados y datos.
    filename: ruta al archivo CSV
    Retorna (headers, data)
    """
    try:  # Intentar abrir archivo
        with open(filename, 'r') as f:  # Abrir en modo lectura
            reader = csv.reader(f)  # Crear lector CSV
            headers = next(reader)  # Leer encabezados
            
            # Inicializar diccionario de datos
            data = {header: [] for header in headers}  # Dict comprehension
            
            # Leer todas las filas
            for row in reader:  # Para cada fila
                for i, value in enumerate(row):  # Para cada valor
                    if i < len(headers):  # Si índice válido
                        data[headers[i]].append(value)  # Añadir a columna
        
        return headers, data  # Retornar datos
    
    except FileNotFoundError:  # Si archivo no existe
        print(f"Error: Archivo '{filename}' no encontrado", file=sys.stderr)
        sys.exit(1)
    except Exception as e:  # Cualquier otro error
        print(f"Error leyendo archivo: {e}", file=sys.stderr)
        sys.exit(1)


def is_numerical_column(column_data):
    """
    Comprobar si una columna contiene datos numéricos.
    Intenta convertir el primer valor válido a float.
    """
    for value in column_data:  # Para cada valor
        if value and value.strip():  # Si no está vacío
            try:  # Intentar conversión
                float(value)  # Convertir a float
                return True  # Es numérica
            except ValueError:  # Si falla
                return False  # No es numérica
    return False  # Si no hay valores, no es numérica


def get_house_data(data, house_column='Hogwarts House'):
    """
    Organizar datos por casa de Hogwarts.
    Retorna diccionarios de casas e índices de filas por casa.
    """
    houses = {}  # Diccionario para datos por casa
    house_indices = {}  # Índices de filas por casa
    
    # Obtener todas las filas para cada casa
    for i, house in enumerate(data[house_column]):  # Para cada casa
        if house and house.strip():  # Si hay nombre de casa válido
            if house not in houses:  # Si es casa nueva
                houses[house] = []  # Inicializar lista
                house_indices[house] = []  # Inicializar índices
            house_indices[house].append(i)  # Añadir índice de fila
    
    return houses, house_indices  # Retornar datos organizados


def calculate_homogeneity_score(house_distributions):
    """
    Calcular puntuación de homogeneidad para una característica entre casas.
    Puntuación más baja = distribución más homogénea.
    
    Medimos:
    1. Varianza de medias entre casas
    2. Varianza de desviaciones estándar entre casas
    """
    if not house_distributions:  # Si no hay datos
        return float('inf')  # Retornar infinito (peor puntuación)
    
    means = []  # Lista de medias por casa
    stds = []  # Lista de desviaciones estándar por casa
    
    for house_name, values in house_distributions.items():
        clean_values = [v for v in values if v is not None]
        if len(clean_values) > 0:
            # Calculate mean
            mean = sum(clean_values) / len(clean_values)
            means.append(mean)
            
            # Calculate std
            if len(clean_values) > 1:
                variance = sum((x - mean) ** 2 for x in clean_values) / (len(clean_values) - 1)
                std = variance ** 0.5
                stds.append(std)
    
    if len(means) < 2 or len(stds) < 2:
        return float('inf')
    
    # Variance of means (how different are the averages across houses)
    mean_of_means = sum(means) / len(means)
    variance_of_means = sum((m - mean_of_means) ** 2 for m in means) / len(means)
    
    # Variance of stds (how different are the spreads across houses)
    mean_of_stds = sum(stds) / len(stds)
    variance_of_stds = sum((s - mean_of_stds) ** 2 for s in stds) / len(stds)
    
    # Combined score (normalized)
    if mean_of_means != 0:
        normalized_mean_var = variance_of_means / (mean_of_means ** 2)
    else:
        normalized_mean_var = variance_of_means
    
    if mean_of_stds != 0:
        normalized_std_var = variance_of_stds / (mean_of_stds ** 2)
    else:
        normalized_std_var = variance_of_stds
    
    return normalized_mean_var + normalized_std_var


def plot_histograms(filename):
    """Plot histograms for all numerical features, grouped by house"""
    headers, data = read_csv(filename)
    
    # Get house data
    houses, house_indices = get_house_data(data)
    
    if not houses:
        print("No se encontraron datos de casas en el conjunto de datos")
        return
    
    # Get numerical features (exclude Index and other non-course columns)
    excluded_columns = ['Index', 'Hogwarts House', 'First Name', 'Last Name', 
                       'Birthday', 'Best Hand']
    numerical_features = []
    
    for header in headers:
        if header not in excluded_columns and is_numerical_column(data[header]):
            numerical_features.append(header)
    
    if not numerical_features:
        print("No se encontraron características numéricas")
        return
    
    # Calculate homogeneity scores
    print("\n" + "="*80)
    print("HOMOGENEITY ANALYSIS")
    print("="*80)
    print("\nAnalizando qué curso tiene la distribución más similar entre casas...")
    print("(Puntuación más baja = más homogéneo)\n")
    
    homogeneity_scores = {}
    
    for feature in numerical_features:
        house_distributions = {}
        
        for house_name, indices in house_indices.items():
            values = []
            for idx in indices:
                val = parse_float(data[feature][idx])
                values.append(val)
            house_distributions[house_name] = values
        
        score = calculate_homogeneity_score(house_distributions)
        homogeneity_scores[feature] = score
    
    # Sort by homogeneity score
    sorted_features = sorted(homogeneity_scores.items(), key=lambda x: x[1])
    
    print(f"{'Característica':<30} {'Puntuación Homogeneidad':>20}")
    print("-" * 52)
    for feature, score in sorted_features:
        print(f"{feature:<30} {score:>20.6f}")
    
    most_homogeneous = sorted_features[0][0]
    print(f"\n{'='*80}")
    print(f"RESPUESTA: '¡{most_homogeneous}' tiene la distribución más homogénea!")
    print(f"{'='*80}\n")
    
    # Create subplots
    n_features = len(numerical_features)
    n_cols = 3
    n_rows = (n_features + n_cols - 1) // n_cols
    
    fig, axes = plt.subplots(n_rows, n_cols, figsize=(15, 5 * n_rows))
    fig.suptitle('Hogwarts Course Score Distributions by House', fontsize=16, y=0.995)
    
    # Flatten axes for easier iteration
    if n_rows == 1:
        axes = [axes]
    axes_flat = [ax for row in (axes if n_rows > 1 else [axes]) for ax in (row if n_rows > 1 else row)]
    
    colors = {
        'Gryffindor': '#740001',
        'Hufflepuff': '#FFD800',
        'Ravenclaw': '#0E1A40',
        'Slytherin': '#1A472A'
    }
    
    # Plot each feature
    for idx, feature in enumerate(numerical_features):
        ax = axes_flat[idx]
        
        # Collect data for each house
        for house_name in sorted(houses.keys()):
            indices = house_indices[house_name]
            values = [parse_float(data[feature][i]) for i in indices]
            values = [v for v in values if v is not None]
            
            if values:
                color = colors.get(house_name, '#808080')
                ax.hist(values, bins=20, alpha=0.6, label=house_name, 
                       color=color, edgecolor='black', linewidth=0.5)
        
        # Highlight most homogeneous
        if feature == most_homogeneous:
            ax.set_title(f'{feature}\n★ MOST HOMOGENEOUS ★', fontweight='bold', 
                        fontsize=10, color='red')
        else:
            ax.set_title(feature, fontsize=10)
        
        ax.set_xlabel('Score', fontsize=8)
        ax.set_ylabel('Frequency', fontsize=8)
        ax.legend(fontsize=6, loc='upper right')
        ax.grid(True, alpha=0.3)
    
    # Hide empty subplots
    for idx in range(len(numerical_features), len(axes_flat)):
        axes_flat[idx].set_visible(False)
    
    plt.tight_layout()
    plt.savefig('histogram_analysis.png', dpi=100, bbox_inches='tight')
    print("Histograma guardado como 'histogram_analysis.png'")
    plt.show()


def main():
    """Main function"""
    if len(sys.argv) < 2:
        print("Uso: python histogram.py <dataset.csv>")
        print("Ejemplo: python histogram.py dataset_train.csv")
        sys.exit(1)
    
    filename = sys.argv[1]
    plot_histograms(filename)


if __name__ == "__main__":
    main()
