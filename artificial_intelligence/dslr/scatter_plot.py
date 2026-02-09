#!/usr/bin/env python3
"""
DSLR - scatter_plot.py
Mostrar gráfico de dispersión para responder: ¿Cuáles son las dos características que son similares?

Características similares mostrarán una fuerte correlación lineal (positiva o negativa).
"""

import sys  # Para argumentos y manejo de errores
import csv  # Para leer archivos CSV  
import matplotlib.pyplot as plt  # Para crear gráficos


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
    """Comprobar si una columna contiene datos numéricos"""
    for value in column_data:
        if value and value.strip():
            try:
                float(value)
                return True
            except ValueError:
                return False
    return False


def calculate_correlation(x_values, y_values):
    """
    Calcular coeficiente de correlación de Pearson entre dos variables.
    ¡No se permite numpy o pandas!
    
    Fórmula: r = Σ((x - media_x)(y - media_y)) / sqrt(Σ(x - media_x)² * Σ(y - media_y)²)
    
    Retorna valor entre -1 y 1:
    - 1: correlación positiva perfecta
    - 0: sin correlación
    - -1: correlación negativa perfecta
    """
    # Filtrar valores None
    pairs = [(x, y) for x, y in zip(x_values, y_values) if x is not None and y is not None]
    
    if len(pairs) < 2:  # Si no hay suficientes datos
        return None  # No se puede calcular correlación
    
    x_clean = [p[0] for p in pairs]  # Lista de valores x válidos
    y_clean = [p[1] for p in pairs]  # Lista de valores y válidos
    
    n = len(x_clean)  # Número de pares válidos
    
    # Calcular medias
    mean_x = sum(x_clean) / n  # Media de x
    mean_y = sum(y_clean) / n  # Media de y
    
    # Calcular covarianza y desviaciones estándar
    covariance = sum((x - mean_x) * (y - mean_y) for x, y in zip(x_clean, y_clean))
    
    std_x_sq = sum((x - mean_x) ** 2 for x in x_clean)  # Suma de cuadrados x
    std_y_sq = sum((y - mean_y) ** 2 for y in y_clean)  # Suma de cuadrados y
    
    # Evitar división por cero
    if std_x_sq == 0 or std_y_sq == 0:  # Si alguna variable es constante
        return None  # No hay correlación
    
    # Coeficiente de correlación de Pearson
    correlation = covariance / (std_x_sq * std_y_sq) ** 0.5
    
    return correlation  # Retornar correlación


def find_most_similar_features(data, numerical_features):
    """
    Encontrar el par de características con mayor correlación absoluta.
    Mayor correlación = características más similares.
    """
    max_correlation = 0  # Máxima correlación encontrada
    best_pair = None  # Mejor par de features
    
    correlations = []
    
    # Calculate correlation for all pairs
    for i, feature1 in enumerate(numerical_features):
        for feature2 in numerical_features[i+1:]:
            x_values = [parse_float(v) for v in data[feature1]]
            y_values = [parse_float(v) for v in data[feature2]]
            
            corr = calculate_correlation(x_values, y_values)
            
            if corr is not None:
                correlations.append((feature1, feature2, corr))
                
                if abs(corr) > abs(max_correlation):
                    max_correlation = corr
                    best_pair = (feature1, feature2)
    
    return best_pair, max_correlation, correlations


def plot_scatter(filename):
    """Plot scatter plots for feature pairs"""
    headers, data = read_csv(filename)
    
    # Get house data for coloring
    house_column = 'Hogwarts House'
    houses_list = data.get(house_column, [])
    
    # Get numerical features
    excluded_columns = ['Index', 'Hogwarts House', 'First Name', 'Last Name', 
                       'Birthday', 'Best Hand']
    numerical_features = []
    
    for header in headers:
        if header not in excluded_columns and is_numerical_column(data[header]):
            numerical_features.append(header)
    
    if len(numerical_features) < 2:
        print("No hay suficientes características numéricas para comparación")
        return
    
    # Find most similar features
    print("\n" + "="*80)
    print("ÁNLISIS DE SIMILITUD DE CARACTERÍSTICAS")
    print("="*80)
    print("\nCalculando correlaciones entre todos los pares de características...\n")
    
    best_pair, max_corr, all_correlations = find_most_similar_features(data, numerical_features)
    
    if best_pair is None:
        print("No se pudieron encontrar características similares")
        return
    
    # Sort correlations by absolute value
    sorted_corr = sorted(all_correlations, key=lambda x: abs(x[2]), reverse=True)
    
    print(f"{'Característica 1':<30} {'Característica 2':<30} {'Correlación':>15}")
    print("-" * 77)
    for feat1, feat2, corr in sorted_corr[:10]:
        print(f"{feat1:<30} {feat2:<30} {corr:>15.6f}")
    
    print(f"\n{'='*80}")
    print(f"RESPUESTA: '{best_pair[0]}' y '{best_pair[1]}'")
    print(f"Correlación: {max_corr:.6f}")
    print(f"{'='*80}\n")
    
    # Plot the most similar pair
    feature1, feature2 = best_pair
    
    x_values = [parse_float(v) for v in data[feature1]]
    y_values = [parse_float(v) for v in data[feature2]]
    
    # Prepare colors by house
    colors = {
        'Gryffindor': '#740001',
        'Hufflepuff': '#FFD800',
        'Ravenclaw': '#0E1A40',
        'Slytherin': '#1A472A'
    }
    
    point_colors = []
    for house in houses_list:
        if house and house.strip() in colors:
            point_colors.append(colors[house.strip()])
        else:
            point_colors.append('#808080')  # Gray for unknown
    
    # Create scatter plot
    fig, (ax1, ax2) = plt.subplots(1, 2, figsize=(16, 6))
    
    # Main scatter plot with house colors
    for house in colors.keys():
        house_x = []
        house_y = []
        for i, h in enumerate(houses_list):
            if h == house and x_values[i] is not None and y_values[i] is not None:
                house_x.append(x_values[i])
                house_y.append(y_values[i])
        
        if house_x:
            ax1.scatter(house_x, house_y, c=colors[house], label=house, 
                       alpha=0.6, s=30, edgecolors='black', linewidth=0.5)
    
    ax1.set_xlabel(feature1, fontsize=12)
    ax1.set_ylabel(feature2, fontsize=12)
    ax1.set_title(f'Most Similar Features\n{feature1} vs {feature2}\n'
                  f'Correlation: {max_corr:.4f}', fontsize=14, fontweight='bold')
    ax1.legend()
    ax1.grid(True, alpha=0.3)
    
    # Also show top 6 correlations as small multiples
    top_6 = sorted_corr[1:7]  # Skip the first one since we already showed it
    
    for idx, (feat1, feat2, corr) in enumerate(top_6):
        row = idx // 3
        col = idx % 3
        
        # We'll just show this in the second subplot as a summary
    
    # Show correlation matrix visualization
    ax2.axis('off')
    
    # Display top correlations as text
    text_content = "Top 10 Feature Correlations:\n"
    text_content += "="*50 + "\n\n"
    
    for i, (feat1, feat2, corr) in enumerate(sorted_corr[:10], 1):
        # Truncate feature names if too long
        f1 = feat1[:20] + "..." if len(feat1) > 20 else feat1
        f2 = feat2[:20] + "..." if len(feat2) > 20 else feat2
        text_content += f"{i:2}. {f1} & {f2}\n"
        text_content += f"    Correlation: {corr:+.4f}\n\n"
    
    ax2.text(0.1, 0.95, text_content, transform=ax2.transAxes,
            fontsize=10, verticalalignment='top', family='monospace',
            bbox=dict(boxstyle='round', facecolor='wheat', alpha=0.5))
    
    plt.tight_layout()
    plt.savefig('scatter_plot_analysis.png', dpi=100, bbox_inches='tight')
    print("Gráfico de dispersión guardado como 'scatter_plot_analysis.png'")
    plt.show()


def main():
    """Main function"""
    if len(sys.argv) < 2:
        print("Uso: python scatter_plot.py <dataset.csv>")
        print("Ejemplo: python scatter_plot.py dataset_train.csv")
        sys.exit(1)
    
    filename = sys.argv[1]
    plot_scatter(filename)


if __name__ == "__main__":
    main()
