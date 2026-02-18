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
    """
    Convertir cadena a float de forma segura.
    Retorna None si no es posible la conversión en lugar de lanzar excepción.
    value: cadena de texto a convertir
    Retorna float o None si no es convertible.
    """
    try:  # Intentar conversión
        return float(value)  # Convertir a float
    except (ValueError, TypeError):  # Si hay error de valor o tipo
        return None  # Retornar None en lugar de lanzar excepción


def read_csv(filename):
    """
    Leer archivo CSV y extraer encabezados y datos.
    filename: ruta al archivo CSV
    Retorna tupla (headers, data) donde:
    - headers: lista de nombres de columnas
    - data: diccionario {columna: [valores]}
    """
    try:  # Intentar abrir el archivo
        with open(filename, 'r') as f:  # Abrir en modo lectura
            reader = csv.reader(f)  # Crear lector CSV
            headers = next(reader)  # Leer primera fila (encabezados)
            # next() obtiene la siguiente línea del iterador
            
            # Inicializar estructura de datos: diccionario con listas vacías
            data = {header: [] for header in headers}  # Dict comprehension
            
            # Leer todas las filas del archivo
            for row in reader:  # Iterar sobre cada fila
                for i, value in enumerate(row):  # enumerate da (indice, valor)
                    if i < len(headers):  # Verificar índice válido
                        data[headers[i]].append(value)  # Añadir a columna correspondiente
        
        return headers, data
    
    except FileNotFoundError:  # Si el archivo no existe
        print(f"Error: Archivo '{filename}' no encontrado", file=sys.stderr)
        # file=sys.stderr redirige salida a error estándar
        sys.exit(1)  # Salir con código de error 1
    except Exception as e:  # Capturar cualquier otro error
        print(f"Error leyendo archivo: {e}", file=sys.stderr)
        sys.exit(1)  # Terminar programa con error


def is_numerical_column(column_data):
    """
    Verificar si una columna contiene datos numéricos.
    Intenta convertir el primer valor no vacío a float.
    column_data: lista de valores de una columna
    Retorna True si la columna es numérica, False en caso contrario.
    """
    for value in column_data:  # Iterar sobre valores de la columna
        if value and value.strip():  # Si el valor existe y no es solo espacios
            # value.strip() elimina espacios en blanco al inicio y final
            try:  # Intentar conversión
                float(value)  # Intentar convertir a float
                return True  # Si funciona, es columna numérica
            except ValueError:  # Si falla la conversión
                return False  # No es columna numérica
    return False  # Si no hay valores válidos, no es numérica


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
    # Filtrar valores None y emparejar x e y
    # zip() combina dos listas en pares: [(x1,y1), (x2,y2), ...]
    pairs = [(x, y) for x, y in zip(x_values, y_values) if x is not None and y is not None]
    # List comprehension que solo incluye pares donde ambos valores son válidos
    
    if len(pairs) < 2:  # Si no hay suficientes datos (mínimo 2 necesarios)
        return None  # No se puede calcular correlación
    
    x_clean = [p[0] for p in pairs]  # Lista de valores x válidos (primer elemento de cada par)
    y_clean = [p[1] for p in pairs]  # Lista de valores y válidos (segundo elemento de cada par)
    
    n = len(x_clean)  # Número de pares válidos para cálculo
    
    # Calcular medias (promedios) de ambas variables
    mean_x = sum(x_clean) / n  # Media de x: suma de todos los valores x / cantidad
    mean_y = sum(y_clean) / n  # Media de y: suma de todos los valores y / cantidad
    
    # Calcular covarianza (cómo varían juntas las dos variables) y desviaciones estándar
    # Covarianza: Σ((x - media_x) * (y - media_y))
    covariance = sum((x - mean_x) * (y - mean_y) for x, y in zip(x_clean, y_clean))
    # Para cada par (x,y), multiplicamos sus desviaciones respecto a sus medias
    
    std_x_sq = sum((x - mean_x) ** 2 for x in x_clean)  # Suma de cuadrados de desviaciones de x
    std_y_sq = sum((y - mean_y) ** 2 for y in y_clean)  # Suma de cuadrados de desviaciones de y
    # Estas son las varianzas no normalizadas (sin dividir por n)
    
    # Evitar división por cero (ocurre si alguna variable es constante)
    if std_x_sq == 0 or std_y_sq == 0:  # Si una variable no varía
        return None  # No se puede calcular correlación
    
    # Coeficiente de correlación de Pearson: covarianza / (desv_std_x * desv_std_y)
    # ** 0.5 es equivalente a raíz cuadrada
    correlation = covariance / (std_x_sq * std_y_sq) ** 0.5
    
    return correlation  # Retornar correlación


def find_most_similar_features(data, numerical_features):
    """
    Encontrar el par de características con mayor correlación absoluta.
    Mayor correlación (en valor absoluto) = características más similares.
    data: diccionario con los datos del CSV
    numerical_features: lista de nombres de columnas numéricas
    Retorna (mejor_par, máxima_correlación, todas_correlaciones)
    """
    max_correlation = 0  # Máxima correlación encontrada (en valor absoluto)
    best_pair = None  # Mejor par de características (tupla)
    
    correlations = []  # Lista para almacenar todas las correlaciones calculadas
    
    # Calcular correlación para todos los pares posibles de características
    for i, feature1 in enumerate(numerical_features):  # Para cada característica
        # numerical_features[i+1:] evita duplicados y auto-comparaciones
        for feature2 in numerical_features[i+1:]:  # Para cada característica posterior
            # Convertir valores de ambas características a float
            x_values = [parse_float(v) for v in data[feature1]]  # Lista de valores de feature1
            y_values = [parse_float(v) for v in data[feature2]]  # Lista de valores de feature2
            
            # Calcular coeficiente de correlación de Pearson
            corr = calculate_correlation(x_values, y_values)
            
            if corr is not None:  # Si se pudo calcular la correlación
                correlations.append((feature1, feature2, corr))  # Guardar resultado
                
                # Actualizar máximo si esta correlación es mayor (en valor absoluto)
                if abs(corr) > abs(max_correlation):  # abs() da valor absoluto
                    max_correlation = corr  # Actualizar máxima correlación
                    best_pair = (feature1, feature2)  # Actualizar mejor par
    
    return best_pair, max_correlation, correlations  # Retornar mejor par, su correlación y lista completa


def plot_scatter(filename):
    """
    Crear gráficos de dispersión para analizar similitud entre características.
    Identifica y visualiza las dos características más correlacionadas (más similares).
    filename: ruta al archivo CSV con los datos
    """
    headers, data = read_csv(filename)  # Leer datos del CSV
    
    # Obtener columna de casas para colorear puntos por casa
    house_column = 'Hogwarts House'  # Nombre de la columna de casas
    houses_list = data.get(house_column, [])  # Lista de casas (o vacía si no existe)
    # .get(key, default) retorna el valor o default si no existe
    
    # Obtener características numéricas (excluir columnas no numéricas)
    excluded_columns = ['Index', 'Hogwarts House', 'First Name', 'Last Name', 
                       'Birthday', 'Best Hand']  # Columnas a excluir del análisis
    numerical_features = []  # Lista para almacenar nombres de columnas numéricas
    
    for header in headers:  # Iterar sobre cada encabezado
        # Si la columna no está excluida y contiene datos numéricos
        if header not in excluded_columns and is_numerical_column(data[header]):
            numerical_features.append(header)  # Añadir a lista de características numéricas
    
    if len(numerical_features) < 2:  # Si hay menos de 2 características numéricas
        print("No hay suficientes características numéricas para comparación")
        return  # Salir de la función
    
    # Encontrar características más similares (mayor correlación)
    print("\n" + "="*80)  # Línea de separación
    print("ÁNLISIS DE SIMILITUD DE CARACTERÍSTICAS")
    print("="*80)
    print("\nCalculando correlaciones entre todos los pares de características...\n")
    
    # Buscar el mejor par de características y todas las correlaciones
    best_pair, max_corr, all_correlations = find_most_similar_features(data, numerical_features)
    
    if best_pair is None:  # Si no se pudieron calcular correlaciones
        print("No se pudieron encontrar características similares")
        return  # Salir de la función
    
    # Ordenar correlaciones por valor absoluto (de mayor a menor)
    # sorted() ordena la lista, key= especifica criterio de ordenación
    # lambda es función anónima: lambda x: abs(x[2]) toma el tercer elemento (correlación) y calcula su valor absoluto
    # reverse=True ordena de mayor a menor
    sorted_corr = sorted(all_correlations, key=lambda x: abs(x[2]), reverse=True)
    
    # Mostrar tabla de correlaciones
    print(f"{'Característica 1':<30} {'Característica 2':<30} {'Correlación':>15}")
    # f"" es f-string para formatear, <30 alinea a la izquierda con ancho 30, >15 alinea a la derecha con ancho 15
    print("-" * 77)  # Línea separadora de 77 caracteres
    for feat1, feat2, corr in sorted_corr[:10]:  # Mostrar top 10 correlaciones
        # [:10] toma los primeros 10 elementos de la lista
        print(f"{feat1:<30} {feat2:<30} {corr:>15.6f}")  # .6f formatea con 6 decimales
    
    # Mostrar respuesta destacada
    print(f"\n{'='*80}")
    print(f"RESPUESTA: '{best_pair[0]}' y '{best_pair[1]}'")
    print(f"Correlación: {max_corr:.6f}")
    print(f"{'='*80}\n")
    
    # Preparar datos del mejor par para graficar
    feature1, feature2 = best_pair  # Desempaquetar tupla con los nombres de las características
    
    # Convertir valores a float
    x_values = [parse_float(v) for v in data[feature1]]  # Valores de característica 1
    y_values = [parse_float(v) for v in data[feature2]]  # Valores de característica 2
    
    # Preparar colores por casa de Hogwarts
    colors = {
        'Gryffindor': '#740001',   # Rojo oscuro
        'Hufflepuff': '#FFD800',   # Amarillo dorado
        'Ravenclaw': '#0E1A40',    # Azul oscuro
        'Slytherin': '#1A472A'     # Verde oscuro
    }  # Diccionario que mapea nombre de casa a código de color hexadecimal
    
    # Crear lista de colores para cada punto según su casa
    point_colors = []  # Lista para almacenar color de cada punto
    for house in houses_list:  # Para cada casa en la lista
        if house and house.strip() in colors:  # Si existe y está en el diccionario
            point_colors.append(colors[house.strip()])  # Añadir color correspondiente
        else:  # Si no se reconoce la casa
            point_colors.append('#808080')  # Gris para casas desconocidas
    
    # Crear figura con 2 subplots (1 fila, 2 columnas)
    fig, (ax1, ax2) = plt.subplots(1, 2, figsize=(16, 6))
    # plt.subplots retorna figura y array de ejes
    # figsize=(ancho, alto) en pulgadas
    
    # Gráfico de dispersión principal con colores por casa
    for house in colors.keys():  # Para cada casa de Hogwarts
        house_x = []  # Lista para valores x de esta casa
        house_y = []  # Lista para valores y de esta casa
        # Filtrar puntos que pertenecen a esta casa y tienen valores válidos
        for i, h in enumerate(houses_list):  # Para cada estudiante con su índice
            # Si es de esta casa y ambos valores son válidos
            if h == house and x_values[i] is not None and y_values[i] is not None:
                house_x.append(x_values[i])  # Añadir valor x
                house_y.append(y_values[i])  # Añadir valor y
        
        if house_x:  # Si hay puntos para esta casa
            # Dibujar puntos de dispersión para esta casa
            ax1.scatter(house_x, house_y, c=colors[house], label=house, 
                       alpha=0.6, s=30, edgecolors='black', linewidth=0.5)
            # scatter() crea gráfico de dispersión
            # c= color, label= etiqueta para leyenda
            # alpha= transparencia (0-1), s= tamaño de puntos
            # edgecolors= color del borde, linewidth= grosor del borde
    
    # Configurar etiquetas y título del gráfico principal
    ax1.set_xlabel(feature1, fontsize=12)  # Etiqueta del eje x
    ax1.set_ylabel(feature2, fontsize=12)  # Etiqueta del eje y
    # set_title establece el título del subplot
    ax1.set_title(f'Most Similar Features\n{feature1} vs {feature2}\n'
                  f'Correlation: {max_corr:.4f}', fontsize=14, fontweight='bold')
    # \n crea salto de línea en el título
    # .4f formatea con 4 decimales, fontweight='bold' hace el texto en negrita
    ax1.legend()  # Mostrar leyenda con las casas
    ax1.grid(True, alpha=0.3)  # Mostrar cuadrícula con transparencia 0.3
    
    # Mostrar top 6 correlaciones adicionales (comentario informativo)
    top_6 = sorted_corr[1:7]  # Tomar elementos del índice 1 al 6 (saltamos el primero que ya mostramos)
    # [1:7] es slice que toma elementos desde índice 1 (inclusive) hasta 7 (exclusive)
    
    for idx, (feat1, feat2, corr) in enumerate(top_6):  # Iterar con índice
        row = idx // 3  # Calcular fila (división entera: 0,1,2 -> fila 0; 3,4,5 -> fila 1)
        col = idx % 3   # Calcular columna (resto de división: 0,1,2 se repite)
        
        # Podríamos mostrar esto en el segundo subplot como resumen
        # (actualmente solo mostramos tabla de texto)
    
    # Mostrar matriz de correlaciones como visualización de texto
    ax2.axis('off')  # Desactivar ejes del segundo subplot (no mostramos ejes x,y)
    
    # Preparar contenido de texto con top 10 correlaciones
    text_content = "Top 10 Feature Correlations:\n"  # Título
    text_content += "="*50 + "\n\n"  # Línea separadora
    
    # Construir lista de correlaciones con formato
    for i, (feat1, feat2, corr) in enumerate(sorted_corr[:10], 1):  # enumerate empieza en 1
        # enumerate(lista, start) permite especificar el número inicial
        # Truncar nombres de características si son demasiado largos
        f1 = feat1[:20] + "..." if len(feat1) > 20 else feat1  # Si >20 chars, truncar y añadir "..."
        f2 = feat2[:20] + "..." if len(feat2) > 20 else feat2  # Operador ternario: valor_si_true if condición else valor_si_false
        text_content += f"{i:2}. {f1} & {f2}\n"  # Número y nombres de características
        # :2 formatea con ancho 2 (alinea números)
        text_content += f"    Correlation: {corr:+.4f}\n\n"  # Correlación con signo (+ o -)
        # :+ fuerza mostrar signo positivo, .4f formatea con 4 decimales
    
    # Mostrar texto en el subplot 2
    ax2.text(0.1, 0.95, text_content, transform=ax2.transAxes,
            fontsize=10, verticalalignment='top', family='monospace',
            bbox=dict(boxstyle='round', facecolor='wheat', alpha=0.5))
    # text(x, y, texto, ...) coloca texto en posición (x,y)
    # transform=ax2.transAxes usa coordenadas relativas (0-1) en lugar de datos
    # verticalalignment='top' alinea texto desde arriba
    # family='monospace' usa fuente monoespaciada (caracteres mismo ancho)
    # bbox= caja alrededor del texto: boxstyle='round' esquinas redondeadas, facecolor= color de fondo, alpha= transparencia
    
    # Ajustar espaciado entre subplots automáticamente
    plt.tight_layout()  # Evita solapamiento de elementos
    # Guardar figura como archivo PNG
    plt.savefig('scatter_plot_analysis.png', dpi=100, bbox_inches='tight')
    # savefig() guarda la figura actual
    # dpi= resolución en puntos por pulgada (dots per inch)
    # bbox_inches='tight' ajusta el recorte para minimizar espacio en blanco
    print("Gráfico de dispersión guardado como 'scatter_plot_analysis.png'")
    plt.show()  # Mostrar gráfico en pantalla


def main():
    """
    Función principal del programa.
    Procesa argumentos de línea de comandos y ejecuta el análisis de dispersión.
    """
    if len(sys.argv) < 2:  # Si no se proporciona archivo como argumento
        # sys.argv es lista: [nombre_script, arg1, arg2, ...]
        print("Uso: python scatter_plot.py <dataset.csv>")
        print("Ejemplo: python scatter_plot.py dataset_train.csv")
        sys.exit(1)  # Salir con código de error
    
    filename = sys.argv[1]  # Obtener nombre de archivo del primer argumento
    plot_scatter(filename)  # Ejecutar análisis y visualización


if __name__ == "__main__":
    main()  # Ejecutar función principal solo si se ejecuta como script
    # __name__ == "__main__" es True solo cuando el archivo se ejecuta directamente
    # (no cuando se importa como módulo)
