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

import sys  # Para argumentos y manejo de errores
import csv  # Para leer archivos CSV
import matplotlib.pyplot as plt  # Para crear gráficos
import matplotlib.patches as mpatches  # Para leyendas personalizadas


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
        
        return headers, data  # Retornar encabezados y datos
    
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
    Intenta convertir primer valor válido a float.
    """
    for value in column_data:  # Para cada valor
        if value and value.strip():  # Si no está vacío
            try:  # Intentar conversión
                float(value)  # Convertir a float
                return True  # Es numérica
            except ValueError:  # Si falla
                return False  # No es numérica
    return False  # Si no hay valores, no es numérica


def plot_pair_plot(filename):
    """
    Crear gráfico de pares para todas las características numéricas.
    Matriz de scatter plots que muestra relaciones entre todas las features.
    Ayuda a identificar qué features son útiles para clasificación.
    """
    headers, data = read_csv(filename)  # Leer datos del CSV
    
    # Obtener columna de casas de Hogwarts para colorear por casa
    house_column = 'Hogwarts House'  # Nombre de columna con casas
    houses_list = data.get(house_column, [])  # Lista de casas por estudiante
    # .get(key, default) retorna el valor o default si no existe la clave
    
    # Obtener características numéricas (seleccionar cursos más relevantes)
    # Excluir columnas que no son numéricas o no son útiles para clasificación
    excluded_columns = ['Index', 'Hogwarts House', 'First Name', 'Last Name', 
                       'Birthday', 'Best Hand']  # Columnas no numéricas a excluir
    
    # Filtrar solo columnas numéricas que no estén excluidas
    all_numerical_features = []  # Lista para todas las características numéricas
    for header in headers:  # Iterar sobre cada encabezado
        # Si no está excluida y es numérica
        if header not in excluded_columns and is_numerical_column(data[header]):
            all_numerical_features.append(header)  # Añadir a lista
    
    # Seleccionar un subconjunto de características para mejor visualización
    # Mostrar las primeras 8 características más importantes basadas en nombres de cursos
    selected_features = all_numerical_features[:8]  # Tomar primeros 8 elementos
    # [:8] es slice que toma elementos desde el inicio hasta el índice 8 (exclusive)
    
    if len(selected_features) < 2:  # Si hay menos de 2 características
        print("No hay suficientes características numéricas")
        return  # Salir de la función
    
    # Mostrar información de análisis
    print("\n" + "="*80)  # Línea separadora
    print("ÁNLISIS DE GRÁFICOS PAREADOS")  # Título
    print("="*80)
    print(f"\nCaracterísticas visualizadas ({len(selected_features)}):")
    # f-string permite interpolar variables en cadenas
    for i, feat in enumerate(selected_features, 1):  # enumerate con inicio en 1
        print(f"  {i}. {feat}")  # Imprimir número y nombre de característica
    
    # Preparar datos: convertir valores a float
    feature_data = {}  # Diccionario para almacenar datos numéricos
    for feature in selected_features:  # Para cada característica seleccionada
        # Convertir todos los valores a float
        values = [parse_float(v) for v in data[feature]]  # List comprehension
        feature_data[feature] = values  # Guardar en diccionario
    
    # Definir colores por casa de Hogwarts
    colors = {
        'Gryffindor': '#740001',   # Rojo oscuro
        'Hufflepuff': '#FFD800',   # Amarillo dorado  
        'Ravenclaw': '#0E1A40',    # Azul oscuro
        'Slytherin': '#1A472A'     # Verde oscuro
    }  # Diccionario que mapea nombre de casa a código de color hexadecimal
    
    # Crear figura con cuadrícula de subplots (matriz n x n)
    n_features = len(selected_features)  # Número de características
    # Crear matriz de subplots: n_features filas x n_features columnas
    fig, axes = plt.subplots(n_features, n_features, figsize=(20, 20))
    # figsize=(ancho, alto) en pulgadas
    # axes será un array 2D de objetos de ejes
    fig.suptitle('Pair Plot - Feature Relationships by House', fontsize=20, y=0.995)
    # suptitle establece título general para toda la figura
    # y=0.995 ajusta posición vertical del título
    
    # Graficar cada combinación de características
    for i, feature_y in enumerate(selected_features):  # Para cada característica en eje Y
        for j, feature_x in enumerate(selected_features):  # Para cada característica en eje X
            ax = axes[i][j]  # Obtener subplot en posición (i, j)
            
            if i == j:  # Si estamos en la diagonal (misma característica en x e y)
                # Diagonal: mostrar distribución (histograma) de la característica
                # Esto muestra cómo se distribuyen los valores de esa característica
                for house in colors.keys():  # Para cada casa de Hogwarts
                    house_values = []  # Lista para valores de esta casa
                    # Filtrar valores que pertenecen a esta casa
                    for idx, h in enumerate(houses_list):  # Para cada estudiante
                        if h == house:  # Si pertenece a esta casa
                            val = feature_data[feature_y][idx]  # Obtener valor de la característica
                            if val is not None:  # Solo si es válido
                                house_values.append(val)  # Añadir a lista
                    
                    if house_values:  # Si hay valores para esta casa
                        # Crear histograma
                        ax.hist(house_values, bins=15, alpha=0.5, 
                               color=colors[house], edgecolor='black', linewidth=0.3)
                        # bins=15: número de barras en histograma
                        # alpha=0.5: transparencia para ver superposiciones
                        # edgecolor= color del borde de las barras
                
                # Etiqueta en diagonal (nombre de la característica)
                ax.set_ylabel(feature_y[:15], fontsize=8, rotation=0, 
                            ha='right', va='center')
                # [:15] trunca el nombre a 15 caracteres
                # rotation=0 mantiene el texto horizontal
                # ha='right' alinea horizontalmente a la derecha
                # va='center' alinea verticalmente al centro
                
            else:  # Fuera de la diagonal (diferentes características en x e y)
                # Off-diagonal: gráfico de dispersión (scatter plot)
                # Muestra relación entre dos características diferentes
                for house in colors.keys():  # Para cada casa de Hogwarts
                    house_x = []  # Lista para valores x de esta casa
                    house_y = []  # Lista para valores y de esta casa
                    # Filtrar puntos que pertenecen a esta casa y tienen valores válidos
                    for idx, h in enumerate(houses_list):  # Para cada estudiante
                        if h == house:  # Si pertenece a esta casa
                            x_val = feature_data[feature_x][idx]  # Valor en eje x
                            y_val = feature_data[feature_y][idx]  # Valor en eje y
                            # Solo incluir si ambos valores son válidos
                            if x_val is not None and y_val is not None:
                                house_x.append(x_val)  # Añadir x
                                house_y.append(y_val)  # Añadir y
                    
                    if house_x:  # Si hay puntos para esta casa
                        # Crear gráfico de dispersión
                        ax.scatter(house_x, house_y, c=colors[house], 
                                 alpha=0.4, s=1, rasterized=True)
                        # alpha=0.4: transparencia para ver superposiciones
                        # s=1: tamaño pequeño de puntos (para muchos datos)
                        # rasterized=True: optimiza renderizado para archivos grandes
            
            # Eliminar etiquetas de ejes para apariencia más limpia
            # Solo mostrar etiquetas en bordes externos de la matriz
            if j > 0:  # Si no es la primera columna
                ax.set_ylabel('')  # No mostrar etiqueta en eje y
            if i < n_features - 1:  # Si no es la última fila
                ax.set_xlabel('')  # No mostrar etiqueta en eje x
            
            # Establecer etiqueta de x solo en la fila inferior
            if i == n_features - 1:  # Si es la última fila
                # Mostrar nombre de característica truncado y rotado
                ax.set_xlabel(feature_x[:15], fontsize=8, rotation=45, ha='right')
                # rotation=45: rotar texto 45 grados para mejor legibilidad
                # ha='right': alinear a la derecha
            
            # Reducir tamaño de etiquetas de los ticks (números en ejes)
            ax.tick_params(labelsize=6)  # Tamaño de fuente 6 para ticks
            ax.grid(True, alpha=0.2)  # Mostrar cuadrícula con transparencia 0.2
    
    # Crear leyenda con parches de colores para cada casa
    # mpatches.Patch crea un rectángulo de color para la leyenda
    legend_elements = [mpatches.Patch(facecolor=colors[house], 
                                     edgecolor='black', label=house) 
                      for house in sorted(colors.keys())]
    # List comprehension que crea un Patch por cada casa
    # sorted() ordena los nombres de casas alfabéticamente
    fig.legend(handles=legend_elements, loc='upper right', 
              fontsize=12, framealpha=0.9)
    # handles= elementos a mostrar en leyenda
    # loc= ubicación de la leyenda
    # framealpha= transparencia del fondo de la leyenda
    
    # Ajustar espaciado entre subplots automáticamente
    plt.tight_layout()  # Evita solapamiento de elementos
    # Guardar figura como archivo PNG
    plt.savefig('pair_plot.png', dpi=100, bbox_inches='tight')
    # dpi= resolución en puntos por pulgada
    # bbox_inches='tight' ajusta recorte para minimizar espacio en blanco
    print(f"\n{'='*80}")
    print("Pair plot saved as 'pair_plot.png'")
    print(f"{'='*80}\n")
    
    # Mostrar recomendaciones basadas en el análisis visual
    print("\nCARACTERÍSTICAS RECOMENDADAS PARA REGRESIÓN LOGÍSTICA:")
    print("-" * 80)
    print("\nBasado en el análisis de gráficos pareados, busca características que:")
    print("  1. Muestren separación clara entre casas (grupos distintos)")
    # Separación clara indica que la característica es útil para distinguir casas
    print("  2. Tengan baja correlación entre sí (patrones de dispersión diversos)")
    # Baja correlación evita redundancia en la información
    print("  3. Tengan buena varianza (distribución amplia en la diagonal)")
    # Buena varianza indica que la característica tiene información útil
    print("\nCaracterísticas sugeridas a considerar:")
    print("  - Características que muestran agrupación distinta de casas en dispersión")
    print("  - Características con distribuciones bimodales/multimodales en diagonal")
    # Bimodal/multimodal = múltiples picos en el histograma, indica grupos distintos
    print("  - Evitar características altamente correlacionadas (patrones lineales)")
    # Patrones lineales en scatter plots indican alta correlación
    print(f"\n{'='*80}\n")
    
    plt.show()  # Mostrar gráfico en pantalla


def main():
    """
    Función principal del programa.
    Procesa argumentos de línea de comandos y ejecuta el análisis de pares.
    """
    if len(sys.argv) < 2:  # Si no se proporciona archivo como argumento
        # sys.argv es lista: [nombre_script, arg1, arg2, ...]
        print("Uso: python pair_plot.py <dataset.csv>")
        print("Ejemplo: python pair_plot.py dataset_train.csv")
        sys.exit(1)  # Salir con código de error
    
    filename = sys.argv[1]  # Obtener nombre de archivo del primer argumento
    plot_pair_plot(filename)  # Ejecutar análisis y visualización


if __name__ == "__main__":
    main()  # Ejecutar función principal solo si se ejecuta como script
    # __name__ == "__main__" es True solo cuando el archivo se ejecuta directamente
    # (no cuando se importa como módulo)
