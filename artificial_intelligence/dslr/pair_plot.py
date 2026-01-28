#!/usr/bin/env python3
"""
DSLR - pair_plot.py
Mostrar diagrama de pares (matriz de gráficos de dispersión) para visualizar todas las relaciones entre características.
Esto ayuda a decidir qué características usar para la regresión logística.

Buenas características para clasificación deben:
1. Mostrar separación clara entre casas
2. Tener baja correlación entre ellas (evitar redundancia)
3. Tener varianza suficiente
"""

import sys
import csv
import matplotlib.pyplot as plt
import matplotlib.patches as mpatches


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


def plot_pair_plot(filename):
    """Create pair plot for all numerical features"""
    headers, data = read_csv(filename)
    
    # Get house data
    house_column = 'Hogwarts House'
    houses_list = data.get(house_column, [])
    
    # Get numerical features (select most relevant courses)
    excluded_columns = ['Index', 'Hogwarts House', 'First Name', 'Last Name', 
                       'Birthday', 'Best Hand']
    
    all_numerical_features = []
    for header in headers:
        if header not in excluded_columns and is_numerical_column(data[header]):
            all_numerical_features.append(header)
    
    # Select a subset of features for better visualization
    # We'll show the most important ones based on course names
    selected_features = all_numerical_features[:8]  # Show first 8 features
    
    if len(selected_features) < 2:
        print("No hay suficientes características numéricas")
        return
    
    print("\n" + "="*80)
    print("ÁNLISIS DE GRÁFICOS PAREADOS")
    print("="*80)
    print(f"\nCaracterísticas visualizadas ({len(selected_features)}):")
    for i, feat in enumerate(selected_features, 1):
        print(f"  {i}. {feat}")
    
    # Prepare data
    feature_data = {}
    for feature in selected_features:
        values = [parse_float(v) for v in data[feature]]
        feature_data[feature] = values
    
    # House colors
    colors = {
        'Gryffindor': '#740001',
        'Hufflepuff': '#FFD800',
        'Ravenclaw': '#0E1A40',
        'Slytherin': '#1A472A'
    }
    
    # Create figure
    n_features = len(selected_features)
    fig, axes = plt.subplots(n_features, n_features, figsize=(20, 20))
    fig.suptitle('Pair Plot - Feature Relationships by House', fontsize=20, y=0.995)
    
    # Plot each combination
    for i, feature_y in enumerate(selected_features):
        for j, feature_x in enumerate(selected_features):
            ax = axes[i][j]
            
            if i == j:
                # Diagonal: show distribution (histogram)
                for house in colors.keys():
                    house_values = []
                    for idx, h in enumerate(houses_list):
                        if h == house:
                            val = feature_data[feature_y][idx]
                            if val is not None:
                                house_values.append(val)
                    
                    if house_values:
                        ax.hist(house_values, bins=15, alpha=0.5, 
                               color=colors[house], edgecolor='black', linewidth=0.3)
                
                # Label on diagonal
                ax.set_ylabel(feature_y[:15], fontsize=8, rotation=0, 
                            ha='right', va='center')
                
            else:
                # Off-diagonal: scatter plot
                for house in colors.keys():
                    house_x = []
                    house_y = []
                    for idx, h in enumerate(houses_list):
                        if h == house:
                            x_val = feature_data[feature_x][idx]
                            y_val = feature_data[feature_y][idx]
                            if x_val is not None and y_val is not None:
                                house_x.append(x_val)
                                house_y.append(y_val)
                    
                    if house_x:
                        ax.scatter(house_x, house_y, c=colors[house], 
                                 alpha=0.4, s=1, rasterized=True)
            
            # Remove tick labels for cleaner look
            if j > 0:
                ax.set_ylabel('')
            if i < n_features - 1:
                ax.set_xlabel('')
            
            # Set x label only on bottom row
            if i == n_features - 1:
                ax.set_xlabel(feature_x[:15], fontsize=8, rotation=45, ha='right')
            
            # Reduce tick labels
            ax.tick_params(labelsize=6)
            ax.grid(True, alpha=0.2)
    
    # Create legend
    legend_elements = [mpatches.Patch(facecolor=colors[house], 
                                     edgecolor='black', label=house) 
                      for house in sorted(colors.keys())]
    fig.legend(handles=legend_elements, loc='upper right', 
              fontsize=12, framealpha=0.9)
    
    plt.tight_layout()
    plt.savefig('pair_plot.png', dpi=100, bbox_inches='tight')
    print(f"\n{'='*80}")
    print("Pair plot saved as 'pair_plot.png'")
    print(f"{'='*80}\n")
    
    print("\nCARACTERÍSTICAS RECOMENDADAS PARA REGRESIÓN LOGÍSTICA:")
    print("-" * 80)
    print("\nBasado en el análisis de gráficos pareados, busca características que:")
    print("  1. Muestren separación clara entre casas (grupos distintos)")
    print("  2. Tengan baja correlación entre sí (patrones de dispersión diversos)")
    print("  3. Tengan buena varianza (distribución amplia en la diagonal)")
    print("\nCaracterísticas sugeridas a considerar:")
    print("  - Características que muestran agrupación distinta de casas en dispersión")
    print("  - Características con distribuciones bimodales/multimodales en diagonal")
    print("  - Evitar características altamente correlacionadas (patrones lineales)")
    print(f"\n{'='*80}\n")
    
    plt.show()


def main():
    """Main function"""
    if len(sys.argv) < 2:
        print("Uso: python pair_plot.py <dataset.csv>")
        print("Ejemplo: python pair_plot.py dataset_train.csv")
        sys.exit(1)
    
    filename = sys.argv[1]
    plot_pair_plot(filename)


if __name__ == "__main__":
    main()
