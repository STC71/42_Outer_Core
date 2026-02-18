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
        if value and value.strip():  # Si no está vacío .strip() para eliminar espacios
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
    La Varianza es una medida de dispersión que indica cuánto varían los valores respecto a su media.
    Combinamos ambas varianzas para obtener una puntuación final.
    La desviación estándar mide la dispersión de los datos respecto a su media. 
    Si las desviaciones estándar son similares entre casas, indica que la dispersión de las puntuaciones es homogénea.
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
    
    # La varianza de las medias indica cuánto varían las medias de las puntuaciones entre las casas.
    # Sirve para evaluar si las casas tienen puntuaciones promedio similares 
    # (homogeneidad en el centro de la distribución).
    mean_of_means = sum(means) / len(means)
    variance_of_means = sum((m - mean_of_means) ** 2 for m in means) / len(means)
    
    # Varianza de las desviaciones estándar (qué tan diferentes son las dispersiónes entre casas)
    # Sirve para evaluar si las casas tienen una dispersión similar en sus puntuaciones 
    # (homogeneidad en la forma de la distribución).
    mean_of_stds = sum(stds) / len(stds)
    variance_of_stds = sum((s - mean_of_stds) ** 2 for s in stds) / len(stds)
    
    # Combinamos ambas varianzas para obtener una puntuación final de homogeneidad.
    # Normalizamos cada varianza dividiéndola por el cuadrado de su media para evitar 
    # que una varianza grande domine la puntuación final.
    # Si la media de medias es distinta de cero, normalizamos la varianza de las medias 
    # dividiéndola por el cuadrado de la media de las medias.
    # Si es igual a cero, dejamos la varianza sin normalizar para evitar división por cero.
    # Si la media de desviaciones estándar es distinta de cero, normalizamos la varianza de las desviaciones estándar 
    # dividiéndola por el cuadrado de la media de las desviaciones estándar.
    # Si es igual a cero, dejamos la varianza sin normalizar para evitar división por cero.
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
    """Graficar histogramas para todas las características numéricas, agrupadas por casa"""
    headers, data = read_csv(filename)
    
    # Obtener datos de casas
    houses, house_indices = get_house_data(data)
    
    if not houses:
        print("No se encontraron datos de casas en el conjunto de datos")
        return
    
    # Obtener features numéricas (excluir columnas no numéricas)
    excluded_columns = ['Index', 'Hogwarts House', 'First Name', 'Last Name', 
                       'Birthday', 'Best Hand']
    numerical_features = []
    
    for header in headers:
        if header not in excluded_columns and is_numerical_column(data[header]):
            numerical_features.append(header)
    
    if not numerical_features:
        print("No se encontraron características numéricas")
        return
    
    # Calcular puntuaciones de homogeneidad
    print("\n" + "="*80) 
    # Salto de línea más signo de igual para separar secciones. 
    # *80 es el número de caracteres para crear una línea completa.
    print("HOMOGENEITY ANALYSIS")
    print("="*80)
    print("\nAnalizando qué curso tiene la distribución más similar entre casas...")
    print("(Puntuación más baja = más homogéneo)\n")
    
    homogeneity_scores = {}     # Diccionario para almacenar puntuaciones de homogeneidad por característica
    
    for feature in numerical_features:
        house_distributions = {}
        # feature es el nombre de la característica que estamos analizando (por ejemplo, 'Arithmancy')
        # numerical_features es la lista de todas las características numéricas que hemos identificado en el conjunto de datos.
        # house_distributions es un diccionario que almacenará las puntuaciones de la característica actual para cada casa de Hogwarts.
        
        for house_name, indices in house_indices.items():
            values = []
            for idx in indices:
                val = parse_float(data[feature][idx])
                values.append(val)
            house_distributions[house_name] = values
        # Para cada casa, usando los índices de filas correspondientes, se extraen los valores de la característica actual,
        # guardándolos en values. Luego, asignan esta lista de valores al diccionario house_distributions bajo el nombre 
        # de la casa.
        # Al finalizar este bucle, house_distributions tendrá la siguiente estructura:
        # {
        #     'Gryffindor': [valores de la característica para estudiantes de Gryffindor],
        #     'Hufflepuff': [valores de la característica para estudiantes de Hufflepuff],
        #     'Ravenclaw': [valores de la característica para estudiantes de Ravenclaw],
        #     'Slytherin': [valores de la característica para estudiantes de Slytherin]
        # }
        # Cada lista de valores contiene las puntuaciones de la característica actual para los estudiantes de esa casa, 
        # convertidos a float (o None si no se pudieron convertir). 
        # Estos valores se utilizan posteriormente para calcular la puntuación de homogeneidad de la característica entre 
        # las casas.
        # En resumen, este bloque de código organiza los datos de la característica actual por casa, 
        # convirtiendo los valores a float y almacenándolos en el diccionario house_distributions para su análisis
        
        score = calculate_homogeneity_score(house_distributions)
        # La función calculate_homogeneity_score toma el diccionario house_distributions, 
        # que contiene las puntuaciones de la característica actual para cada casa,
        # y calcula una puntuación de homogeneidad que indica qué tan similar es la distribución de esa característica 
        # entre las casas.
        # El resultado se almacena en la variable score, que representa la puntuación de homogeneidad para 
        # la característica actual.
        homogeneity_scores[feature] = score
        # Finalmente, la puntuación de homogeneidad calculada para la característica actual se guarda en el diccionario homogeneity_scores, 
        # utilizando el nombre de la característica como clave. Esto permite comparar las puntuaciones de homogeneidad 
        # de todas las características numéricas y determinar cuál tiene la distribución más homogénea entre las casas de Hogwarts.
    
    # Ordenar características por puntuación de homogeneidad (de menor a mayor)
    sorted_features = sorted(homogeneity_scores.items(), key=lambda x: x[1])
    # sorted_features es una lista de tuplas (feature, score) ordenada por la puntuación de homogeneidad de menor a mayor.
    # Esto significa que la característica con la puntuación de homogeneidad más baja (más homogénea) estará al principio 
    # de la lista.
    # La función sorted toma el diccionario homogeneity_scores y lo convierte en una lista de tuplas, donde cada tupla 
    # contiene el nombre de la característica y su puntuación de homogeneidad. Luego, se ordena esta lista utilizando 
    # una función lambda que especifica que la clave de ordenación es la puntuación (x[1]).
    # La función lambda es una función anónima que se utiliza para extraer la puntuación de homogeneidad de cada tupla (x[1]) 
    # para ordenar la lista. Esta función viene de la biblioteca estándar de Python y es comúnmente utilizada para ordenar 
    # listas de tuplas o diccionarios por un valor específico.
    # Al ordenar por la puntuación de homogeneidad, podemos identificar fácilmente cuál característica tiene la distribución 
    # más homogénea entre las casas de Hogwarts, ya que estará al principio de la lista
    
    print(f"{'Característica':<30} {'Puntuación Homogeneidad':>20}")
    print("-" * 52)     # Línea de separación entre encabezados y datos. 52 veces el signo de menos.
    for feature, score in sorted_features:
        print(f"{feature:<30} {score:>20.6f}")
    
    most_homogeneous = sorted_features[0][0]
    print(f"\n{'='*80}")
    print(f"RESPUESTA: '¡{most_homogeneous}' tiene la distribución más homogénea!")
    print(f"{'='*80}\n")
    
    # Crear subplots
    # Los subplots son gráficos individuales que se organizan en una cuadrícula dentro de una figura más grande.
    # En este caso, se crean subplots para cada característica numérica, agrupados por casa, para visualizar las 
    # distribuciones de puntuaciones.
    # Para visualizar las distribuciones de puntuaciones de cada característica numérica por casa, se crean subplots 
    # utilizando Matplotlib.
    # n_features es el número total de características numéricas que se van a graficar. 
    # n_cols es el número de columnas que se desea en la cuadrícula de subplots (en este caso, 3). 
    # n_rows se calcula dividiendo el número de características por el número de columnas y redondeando hacia arriba 
    # para asegurarse de que haya suficientes filas.
    n_features = len(numerical_features)
    n_cols = 3
    n_rows = (n_features + n_cols - 1) // n_cols    # // es división entera, +n_cols-1 para redondear hacia arriba.
    
    fig, axes = plt.subplots(n_rows, n_cols, figsize=(15, 5 * n_rows))
    # fig, axes son los objetos que devuelve plt.subplots. fig es la figura principal que contiene todos los subplots,
    # y axes es una matriz de objetos de ejes (subplots) donde se dibujarán los histogramas.
    # La función plt.subplots se utiliza para crear una figura y una cuadrícula de subplots.
    # n_rows y n_cols especifican el número de filas y columnas en la cuadrícula de subplots, respectivamente. 
    # figsize define el tamaño de la figura en pulgadas (ancho, alto). 
    # En este caso, el ancho es fijo en 15 pulgadas, mientras que el alto depende del número de filas.
    # 5 * n_rows asegura que cada fila tenga suficiente espacio vertical para mostrar los histogramas de manera clara.
    fig.suptitle('Hogwarts Course Score Distributions by House', fontsize=16, y=0.995)
    # fig.suptitle establece un título general para toda la figura que contiene los subplots.
    # El título es 'Hogwarts Course Score Distributions by House', con un tamaño de fuente de 16 y una posición vertical 
    # ajustada con y=0.995 para que quede cerca de la parte superior de la figura sin superponerse con los subplots.
    
    # Convertir el array de ejes (axes) de matplotlib a una lista plana para facilitar el acceso, especialmente 
    # si n_rows es 1 (en ese caso, axes no es una matriz sino un solo objeto).
    if n_rows == 1:
        axes = [axes]   # Si solo hay una fila, convertir el objeto de eje único en una lista para mantener la consistencia.
    axes_flat = [ax for row in (axes if n_rows > 1 else [axes]) for ax in (row if n_rows > 1 else row)]
    # Esta línea aplanará la matriz de ejes (axes) en una lista plana (axes_flat) para facilitar el acceso a cada subplot,
    # independientemente de si hay una o varias filas.
    # La comprensión de listas recorre cada fila en axes (si n_rows > 1) o directamente axes (si n_rows == 1) y luego recorre 
    # cada eje (ax) dentro de esa fila, agregándolos a la lista axes_flat.
    # Esto asegura que cada subplot esté accesible a través de axes_flat[idx], donde idx es el índice de la característica 
    # que se está graficando.
    
    colors = {
        'Gryffindor': '#740001',
        'Hufflepuff': '#FFD800',
        'Ravenclaw': '#0E1A40',
        'Slytherin': '#1A472A'
    }
    # Este diccionario asigna un color específico a cada casa de Hogwarts para que los histogramas sean visualmente distintivos 
    # y fáciles de interpretar. Gryffindor es rojo oscuro, Hufflepuff es amarillo brillante, Ravenclaw es azul oscuro y 
    # Slytherin es verde oscuro.
    
    # Para cada característica numérica, se crea un histograma que muestra la distribución de las puntuaciones para cada 
    # casa de Hogwarts.
    for idx, feature in enumerate(numerical_features):
        ax = axes_flat[idx]
        # idx es el índice de la característica actual en la lista de características numéricas, y feature es el nombre de 
        # esa característica. enumerate se utiliza para obtener tanto el índice como el valor de cada característica mientras 
        # se itera sobre la lista numerical_features (es una función incorporada de Python que devuelve un iterador que produce 
        # pares de índice y valor). numerical_features es la lista de características numéricas que se han identificado en el 
        # conjunto de datos previamente en la función plot_histograms. ax es el objeto de eje (subplot) correspondiente a la 
        # característica actual, obtenido de la lista aplanada de ejes (axes_flat). 
        # Este es el subplot donde se dibujará el histograma para la característica actual.
        
        # Collect data for each house
        # Para cada casa, se recopilan los valores de la característica actual utilizando los índices de filas correspondientes.
        for house_name in sorted(houses.keys()):
            indices = house_indices[house_name]
            # Para cada casa, se obtienen los índices de las filas correspondientes a esa casa utilizando 
            # house_indices[house_name] que es un diccionario que mapea el nombre de la casa a una lista de índices de filas 
            # en el conjunto de datos. house_name es el nombre de la casa actual (por ejemplo, 'Gryffindor'), 
            # y indices es la lista de índices de filas para esa casa.
            values = [parse_float(data[feature][i]) for i in indices]
            # Para cada índice en indices, se extrae el valor de la característica actual (data[feature][i]) y se intenta 
            # convertir a float utilizando parse_float. [ especifica que se está creando una lista de valores.
            # Esto crea una lista de valores numéricos (o None si no se pudieron convertir) para la característica actual y 
            # la casa actual. Estos valores se almacenan en la variable values,
            values = [v for v in values if v is not None]
            # Se filtran los valores None para asegurarse de que solo se utilicen valores numéricos válidos en el histograma,
            # creando una nueva lista que solo contiene los valores que no son None.
            
            if values:
                color = colors.get(house_name, '#808080')
                # Se obtiene el color correspondiente a la casa actual del diccionario colors. 
                # Si la casa no está en el diccionario, se asigna un color gris por defecto ('#808080').
                ax.hist(values, bins=20, alpha=0.6, label=house_name, 
                       color=color, edgecolor='black', linewidth=0.5)
                # Se dibuja un histograma de los valores para la casa actual en el subplot ax utilizando ax.hist.
                # hist es una función de Matplotlib que crea un histograma a partir de los datos proporcionados.
                # values es la lista de valores numéricos para la característica actual y la casa actual. 
                # bins=20 especifica que el histograma tendrá 20 barras (bins).
                # alpha=0.6 establece la transparencia de las barras del histograma para que sean visibles las superposiciones 
                # entre casas.
                # label=house_name asigna una etiqueta al histograma para que aparezca en la leyenda.
                # color=color establece el color de las barras del histograma según la casa.
                # edgecolor='black' y linewidth=0.5 añaden un borde negro a las barras del histograma para mejorar su visibilidad.
        
        # Highlight most homogeneous
        if feature == most_homogeneous:
            ax.set_title(f'{feature}\n★ MOST HOMOGENEOUS ★', fontweight='bold', 
                        fontsize=10, color='red')
            # si la característica actual es la más homogénea, se establece un título especial con un asterisco rojo
        else:
            ax.set_title(feature, fontsize=10)
            # si no es la más homogénea, se establece el título normal de la característica
        
        ax.set_xlabel('Score', fontsize=8)          # se establece la etiqueta del eje x
        ax.set_ylabel('Frequency', fontsize=8)      # se establece la etiqueta del eje y
        ax.legend(fontsize=6, loc='upper right')    # se establece la leyenda con tamaño de fuente 6 y posición en la esquina superior derecha
        ax.grid(True, alpha=0.3)                    # se establece una cuadrícula con transparencia 0.3 para mejorar la legibilidad de los histogramas
    
    # Hide empty subplots
    for idx in range(len(numerical_features), len(axes_flat)):
        axes_flat[idx].set_visible(False)
    # Si hay subplots adicionales que no se utilizan (por ejemplo, si el número de características no es un múltiplo de n_cols),
    # se ocultan para que no aparezcan vacíos en la figura.
    # Se itera desde el índice del último subplot utilizado (len(numerical_features)) hasta el total de subplots disponibles 
    # (len(axes_flat)), y se establece set_visible(False) para cada uno de esos subplots, ocultándolos de la visualización.
    # len(numerical_features) es el número de características numéricas que se han graficado, y len(axes_flat) es el número 
    # total de subplots disponibles en la figura.
    # axes_flat[idx].set_visible(False) oculta el subplot en la posición idx, lo que es útil para mantener la presentación 
    # limpia cuando no se utilizan todos los subplots disponibles.
    
    plt.tight_layout()
    # tight_layout ajusta automáticamente el espaciado entre subplots para evitar solapamientos y asegurar que los títulos, 
    # etiquetas y leyendas sean legibles.
    plt.savefig('histogram_analysis.png', dpi=100, bbox_inches='tight')
    # savefig guarda la figura actual como un archivo de imagen. 'histogram_analysis.png' es el nombre del archivo, 
    # dpi=100 establece la resolución de la imagen, y bbox_inches='tight' ajusta el recorte de la figura para que 
    # se ajuste al contenido sin espacios en blanco innecesarios.
    print("Histograma guardado como 'histogram_analysis.png'")
    plt.show()      # Muestra la figura con los histogramas en pantalla


def main():
    """Main function"""
    if len(sys.argv) < 2:
        print("Uso: python histogram.py <dataset.csv>")
        print("Ejemplo: python histogram.py dataset_train.csv")
        sys.exit(1)
    # si no se proporciona un argumento de línea de comandos, se muestra un mensaje de uso y se termina el programa con un 
    # código de salida 1 (indica error).
    
    filename = sys.argv[1]      # se obtiene el nombre del archivo CSV del primer argumento de línea de comandos
    plot_histograms(filename)   # se llama a la función plot_histograms con el nombre del archivo para generar los histogramas


if __name__ == "__main__":
    main()  # Ejecutar función principal si se ejecuta como script
    # El bloque if __name__ == "__main__": asegura que la función main() solo se ejecute cuando el script 
    # se ejecute directamente, y no cuando se importe como módulo en otro script. Esto es una práctica común 
    # en Python para organizar el código y permitir la reutilización de funciones sin ejecutar el código 
    # principal automáticamente.
