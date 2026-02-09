#!/usr/bin/env python3
"""
DSLR - describe.py
Descripción estadística de características numéricas en el dataset.
¡NO se permite pandas.describe() ni funciones similares!

Todas las estadísticas deben implementarse desde cero.
"""

import sys  # Para manejar argumentos de línea de comandos y salidas de error
import csv  # Para leer archivos CSV


def ft_count(data):
    """
    Contar valores no-NaN (no nulos) en los datos.
    data: lista que puede contener valores numéricos o None
    Retorna el número de valores válidos (no None) como float.
    """
    count = 0  # Inicializar contador
    for value in data:  # Iterar sobre cada valor en la lista
        if value is not None:  # Si el valor no es None
            count += 1  # Incrementar el contador
    return float(count)  # Retornar el conteo como float


def ft_sum(data):
    """
    Calcular la suma de todos los valores no-NaN en los datos.
    data: lista de valores numéricos que puede contener None
    Retorna la suma total de valores válidos como float.
    """
    total = 0.0  # Inicializar suma total
    for value in data:  # Iterar sobre cada valor
        if value is not None:  # Solo sumar valores válidos
            total += value  # Acumular el valor
    return total  # Retornar la suma total


def ft_mean(data):
    """
    Calcular la media (promedio) de los datos.
    La media es la suma de todos los valores dividida por el número de valores.
    data: lista de valores numéricos
    Retorna la media como float o None si no hay datos.
    """
    count = ft_count(data)  # Obtener el número de valores válidos
    if count == 0:  # Si no hay valores válidos
        return None  # Retornar None
    return ft_sum(data) / count  # Retornar suma dividida por cantidad


def ft_variance(data, mean=None):
    """
    Calcular la varianza de los datos.
    La varianza mide qué tan dispersos están los datos respecto a la media.
    Usa n-1 en el denominador (varianza muestral) para estimador insesgado.
    data: lista de valores numéricos
    mean: media precalculada (opcional)
    Retorna la varianza como float o None si no hay suficientes datos.
    """
    if mean is None:  # Si no se proporciona la media
        mean = ft_mean(data)  # Calcularla
    if mean is None:  # Si no hay datos para calcular media
        return None  # Retornar None
    
    count = 0  # Contador de valores válidos
    sum_squared_diff = 0.0  # Suma de diferencias al cuadrado
    
    for value in data:  # Iterar sobre cada valor
        if value is not None:  # Solo procesar valores válidos
            sum_squared_diff += (value - mean) ** 2  # Acumular (valor - media)²
            count += 1  # Incrementar contador
    
    if count == 0:  # Si no hay valores válidos
        return None  # Retornar None
    
    # Varianza muestral: usa n-1 en denominador para estimador insesgado
    return sum_squared_diff / (count - 1) if count > 1 else 0.0


def ft_std(data, mean=None):
    """
    Calcular la desviación estándar de los datos.
    La desviación estándar es la raíz cuadrada de la varianza.
    Mide la dispersión promedio de los datos respecto a la media.
    data: lista de valores numéricos
    mean: media precalculada (opcional)
    Retorna la desviación estándar como float o None si no hay datos.
    """
    variance = ft_variance(data, mean)  # Calcular varianza
    if variance is None:  # Si no hay varianza calculable
        return None  # Retornar None
    return variance ** 0.5  # Retornar raíz cuadrada de varianza (** 0.5 = sqrt)


def ft_min(data):
    """
    Encontrar el valor mínimo en los datos.
    data: lista de valores numéricos
    Retorna el valor mínimo como float o None si no hay datos.
    """
    min_val = None  # Inicializar valor mínimo
    for value in data:  # Iterar sobre cada valor
        if value is not None:  # Solo considerar valores válidos
            if min_val is None or value < min_val:  # Si es el primero o menor que el actual
                min_val = value  # Actualizar mínimo
    return min_val  # Retornar el valor mínimo encontrado


def ft_max(data):
    """
    Encontrar el valor máximo en los datos.
    data: lista de valores numéricos
    Retorna el valor máximo como float o None si no hay datos.
    """
    max_val = None  # Inicializar valor máximo
    for value in data:  # Iterar sobre cada valor
        if value is not None:  # Solo considerar valores válidos
            if max_val is None or value > max_val:  # Si es el primero o mayor que el actual
                max_val = value  # Actualizar máximo
    return max_val  # Retornar el valor máximo encontrado


def ft_percentile(data, percentile):
    """
    Calcular el percentil de los datos (valor entre 0 y 100).
    El percentil indica el valor por debajo del cual cae un porcentaje de los datos.
    Por ejemplo, el percentil 25 es el valor por debajo del cual está el 25% de los datos.
    Usa interpolación lineal entre rangos más cercanos para mayor precisión.
    data: lista de valores numéricos
    percentile: valor entre 0 y 100
    Retorna el valor del percentil o None si no hay datos.
    """
    # Filtrar valores None y ordenar
    clean_data = [x for x in data if x is not None]  # Crear lista sin valores None
    if len(clean_data) == 0:  # Si no hay datos válidos
        return None  # Retornar None
    
    # Ordenar datos de menor a mayor
    sorted_data = sorted(clean_data)  # sorted() ordena la lista
    n = len(sorted_data)  # Número de elementos
    
    # Calcular posición del percentil en la lista ordenada
    pos = (percentile / 100.0) * (n - 1)  # Fórmula: pos = (p/100) * (n-1)
    
    # Obtener índices inferior y superior para interpolación
    lower_idx = int(pos)  # Índice inferior (parte entera)
    upper_idx = lower_idx + 1  # Índice superior (siguiente posición)
    
    # Si la posición es exactamente un índice, devolver ese valor
    if pos == lower_idx:  # Si pos es un número entero
        return sorted_data[lower_idx]  # Retornar el valor en esa posición
    
    # Si el índice superior está fuera de límites, devolver último valor
    if upper_idx >= n:  # Si upper_idx excede el tamaño de la lista
        return sorted_data[-1]  # Retornar el último elemento
    
    # Interpolación lineal entre los dos valores más cercanos
    fraction = pos - lower_idx  # Fracción decimal entre los dos índices
    # Fórmula: valor = valor_inferior + fracción * (valor_superior - valor_inferior)
    return sorted_data[lower_idx] + fraction * (sorted_data[upper_idx] - sorted_data[lower_idx])


def ft_median(data):
    """
    Calcular la mediana de los datos (percentil 50).
    La mediana es el valor central que divide los datos en dos mitades iguales.
    data: lista de valores numéricos
    Retorna la mediana como float o None si no hay datos.
    """
    return ft_percentile(data, 50.0)  # La mediana es el percentil 50


def ft_quartile_1(data):
    """
    Calcular el primer cuartil Q1 (percentil 25).
    El 25% de los datos está por debajo de este valor.
    data: lista de valores numéricos
    Retorna Q1 como float o None si no hay datos.
    """
    return ft_percentile(data, 25.0)  # Q1 es el percentil 25


def ft_quartile_3(data):
    """
    Calcular el tercer cuartil Q3 (percentil 75).
    El 75% de los datos está por debajo de este valor.
    data: lista de valores numéricos
    Retorna Q3 como float o None si no hay datos.
    """
    return ft_percentile(data, 75.0)  # Q3 es el percentil 75


# ============================================================================
# BONUS: Estadísticas adicionales para análisis más profundo
# ============================================================================

def ft_range(data):
    """
    Calcular el rango de los datos (máximo - mínimo).
    El rango indica la amplitud total de los datos.
    data: lista de valores numéricos
    Retorna el rango como float o None si no hay datos.
    """
    min_val = ft_min(data)  # Obtener valor mínimo
    max_val = ft_max(data)  # Obtener valor máximo
    if min_val is None or max_val is None:  # Si no hay suficientes datos
        return None  # Retornar None
    return max_val - min_val  # Retornar diferencia máx - mín


def ft_iqr(data):
    """
    Calcular el Rango Intercuartílico (IQR = Q3 - Q1).
    El IQR mide la dispersión del 50% central de los datos.
    Es útil para detectar outliers (valores atípicos).
    data: lista de valores numéricos
    Retorna el IQR como float o None si no hay datos.
    """
    q1 = ft_quartile_1(data)  # Obtener primer cuartil
    q3 = ft_quartile_3(data)  # Obtener tercer cuartil
    if q1 is None or q3 is None:  # Si no hay suficientes datos
        return None  # Retornar None
    return q3 - q1  # Retornar diferencia Q3 - Q1


def ft_mode(data):
    """
    Calcular la moda (valor más frecuente) - BONUS.
    La moda es el valor que aparece con mayor frecuencia en el conjunto de datos.
    data: lista de valores numéricos
    Retorna la moda como float o None si no hay datos.
    """
    clean_data = [x for x in data if x is not None]  # Filtrar valores None
    if len(clean_data) == 0:  # Si no hay datos válidos
        return None  # Retornar None
    
    frequency = {}  # Diccionario para contar frecuencias
    for value in clean_data:  # Iterar sobre cada valor
        # Redondear para evitar problemas con punto flotante
        rounded = round(value, 6)  # Redondear a 6 decimales
        frequency[rounded] = frequency.get(rounded, 0) + 1  # Incrementar contador
        # .get(key, default) retorna el valor o default si no existe la clave
    
    max_freq = max(frequency.values())  # Encontrar la frecuencia máxima
    # Retornar el primer valor con frecuencia máxima
    for value, freq in frequency.items():  # Iterar sobre diccionario
        if freq == max_freq:  # Si tiene la frecuencia máxima
            return value  # Retornar ese valor
    return None  # Si no se encuentra, retornar None


def ft_skewness(data):
    """
    Calcular la asimetría (skewness) de los datos - BONUS.
    Mide cuánto se desvía la distribución de ser simétrica.
    - Asimetría > 0: cola más larga hacia la derecha (valores altos)
    - Asimetría < 0: cola más larga hacia la izquierda (valores bajos)
    - Asimetría ≈ 0: distribución simétrica (como distribución normal)
    data: lista de valores numéricos
    Retorna la asimetría como float o None si no hay datos.
    """
    mean = ft_mean(data)  # Calcular media
    std = ft_std(data)  # Calcular desviación estándar
    if mean is None or std is None or std == 0:  # Si no hay datos o std es cero
        return None  # Retornar None
    
    n = 0  # Contador de valores válidos
    sum_cubed = 0.0  # Suma de diferencias al cubo normalizadas
    
    for value in data:  # Iterar sobre cada valor
        if value is not None:  # Solo procesar valores válidos
            # Fórmula: suma de [(x - media) / std]³
            sum_cubed += ((value - mean) / std) ** 3  # Elevar al cubo
            n += 1  # Incrementar contador
    
    if n == 0:  # Si no hay valores válidos
        return None  # Retornar None
    
    return sum_cubed / n  # Retornar promedio de cubos normalizados


def ft_kurtosis(data):
    """
    Calcular la curtosis de los datos - BONUS.
    Mide el "grosor" de las colas de la distribución.
    - Curtosis > 0: colas más pesadas que distribución normal (más outliers)
    - Curtosis < 0: colas más ligeras que distribución normal (menos outliers)
    - Curtosis ≈ 0: similar a distribución normal
    Usa exceso de curtosis (resta 3 para baseline de distribución normal).
    data: lista de valores numéricos
    Retorna la curtosis como float o None si no hay datos.
    """
    mean = ft_mean(data)  # Calcular media
    std = ft_std(data)  # Calcular desviación estándar
    if mean is None or std is None or std == 0:  # Si no hay datos o std es cero
        return None  # Retornar None
    
    n = 0  # Contador de valores válidos
    sum_fourth = 0.0  # Suma de diferencias a la cuarta potencia normalizadas
    
    for value in data:  # Iterar sobre cada valor
        if value is not None:  # Solo procesar valores válidos
            # Fórmula: suma de [(x - media) / std]⁴
            sum_fourth += ((value - mean) / std) ** 4  # Elevar a la cuarta potencia
            n += 1  # Incrementar contador
    
    if n == 0:  # Si no hay valores válidos
        return None  # Retornar None
    
    # Exceso de curtosis: restar 3 para baseline de distribución normal
    return (sum_fourth / n) - 3  # Retornar curtosis ajustada


def parse_float(value):
    """
    Convertir una cadena a float de forma segura.
    Si la conversión no es posible, retorna None en lugar de error.
    value: cadena de texto a convertir
    Retorna el valor como float o None si no es convertible.
    """
    try:  # Intentar convertir
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
        with open(filename, 'r') as f:  # Abrir en modo lectura, 'f' es el objeto archivo
            reader = csv.reader(f)  # Crear lector CSV
            headers = next(reader)  # Leer primera fila (encabezados)
            # next() obtiene la siguiente línea del iterador
            
            # Inicializar estructura de datos: diccionario con listas vacías
            data = {header: [] for header in headers}  # List comprehension para crear dict
            # {k: v for k in lista} crea diccionario iterando sobre lista
            
            # Leer todas las filas del archivo
            for row in reader:  # Iterar sobre cada fila después de encabezados
                for i, value in enumerate(row):  # enumerate da (indice, valor)
                    if i < len(headers):  # Verificar que no excede número de columnas
                        data[headers[i]].append(value)  # Añadir valor a columna correspondiente
        
        return headers, data  # Retornar encabezados y datos
    
    except FileNotFoundError:  # Si el archivo no existe
        print(f"Error: Archivo '{filename}' no encontrado", file=sys.stderr)
        # file=sys.stderr redirige salida a error estándar en lugar de stdout
        sys.exit(1)  # Salir con código de error 1
    except Exception as e:  # Capturar cualquier otro error
        print(f"Error leyendo archivo: {e}", file=sys.stderr)
        sys.exit(1)


def is_numerical_column(column_data):
    """
    Verificar si una columna contiene datos numéricos.
    Intenta convertir el primer valor no vacío a float.
    column_data: lista de valores de una columna
    Retorna True si la columna es numérica, False en caso contrario.
    """
    # Intentar convertir el primer valor no vacío
    for value in column_data:  # Iterar sobre valores de la columna
        if value and value.strip():  # Si el valor existe y no es solo espacios
            # value.strip() elimina espacios en blanco al inicio y final
            try:  # Intentar conversión
                float(value)  # Intentar convertir a float
                return True  # Si funciona, es columna numérica
            except ValueError:  # Si falla la conversión
                return False  # No es columna numérica
    return False  # Si no hay valores válidos, no es numérica


def describe(filename, bonus=True):
    """
    Mostrar descripción estadística de características numéricas.
    Calcula y muestra estadísticas descriptivas para cada columna numérica del CSV.
    
    Args:
        filename: Ruta al archivo CSV
        bonus: Incluir estadísticas bonus (rango, IQR, asimetría, curtosis)
    """
    headers, data = read_csv(filename)  # Leer datos del archivo CSV
    
    # Filtrar columnas numéricas y convertir valores a float
    numerical_data = {}  # Diccionario para almacenar datos numéricos
    for header in headers:  # Iterar sobre cada columna
        if is_numerical_column(data[header]):  # Si la columna es numérica
            # Convertir todos los valores a float usando parse_float
            numerical_data[header] = [parse_float(x) for x in data[header]]
            # List comprehension que aplica parse_float a cada valor
    
    if not numerical_data:  # Si no hay columnas numéricas
        print("No se encontraron características numéricas en el conjunto de datos")
        return  # Salir de la función
    
    # Calcular estadísticas para cada columna
    stats = {}  # Diccionario para almacenar todas las estadísticas
    # Lista de nombres de estadísticas a calcular (parte obligatoria)
    stat_names = ['Recuento', 'Media', 'Desv.Est', 'Mín', '25%', '50%', '75%', 'Máx']
    
    # Añadir estadísticas bonus si está activado
    if bonus:  # Si se solicitan estadísticas adicionales
        stat_names.extend(['Rango', 'RIC', 'Asimetría', 'Curtosis'])
        # .extend() añade elementos de una lista a otra lista
    
    # Inicializar diccionarios para cada estadística
    for stat in stat_names:  # Crear entrada en stats para cada estadística
        stats[stat] = {}  # Cada estadística tendrá valores para cada columna
    
    # Calcular todas las estadísticas para cada columna numérica
    for column, values in numerical_data.items():  # Iterar sobre cada columna numérica
        mean = ft_mean(values)  # Calcular media (usada en varias estadísticas)
        
        # Estadísticas básicas obligatorias
        stats['Recuento'][column] = ft_count(values)  # Número de valores válidos
        stats['Media'][column] = mean  # Promedio de los valores
        stats['Desv.Est'][column] = ft_std(values, mean)  # Desviación estándar
        stats['Mín'][column] = ft_min(values)  # Valor mínimo
        stats['25%'][column] = ft_quartile_1(values)  # Primer cuartil (Q1)
        stats['50%'][column] = ft_median(values)  # Mediana (Q2)
        stats['75%'][column] = ft_quartile_3(values)  # Tercer cuartil (Q3)
        stats['Máx'][column] = ft_max(values)  # Valor máximo
        
        # Estadísticas bonus adicionales
        if bonus:  # Si se solicitan estadísticas bonus
            stats['Rango'][column] = ft_range(values)  # Rango (máx - mín)
            stats['RIC'][column] = ft_iqr(values)  # Rango intercuartílico (Q3 - Q1)
            stats['Asimetría'][column] = ft_skewness(values)  # Asimetría de distribución
            stats['Curtosis'][column] = ft_kurtosis(values)  # Curtosis (grosor colas)
    
    # Mostrar resultados en formato tabular
    # Imprimir fila de encabezados
    col_width = 16  # Ancho de cada columna en caracteres
    print(f"{'':14}", end='')  # Espacio inicial para nombres de estadísticas
    # f"" es f-string para formatear cadenas
    # end='' evita salto de línea al final del print
    for column in numerical_data.keys():  # Iterar sobre nombres de columnas
        # Truncar nombres de columnas largos para que quepan en el ancho
        col_name = column[:col_width-2] if len(column) > col_width-2 else column
        # [:n] toma los primeros n caracteres de la cadena
        print(f"{col_name:>{col_width}}", end='')  # Alinear a la derecha
        # :> alinea a la derecha, :< alinearía a la izquierda
    print()  # Salto de línea al final de encabezados
    
    # Imprimir cada fila de estadísticas
    for stat in stat_names:  # Iterar sobre cada tipo de estadística
        print(f"{stat:14}", end='')  # Imprimir nombre de estadística (ancho fijo 14)
        for column in numerical_data.keys():  # Iterar sobre cada columna
            value = stats[stat][column]  # Obtener valor de estadística para esta columna
            if value is None:  # Si no hay valor (datos insuficientes)
                print(f"{'NaN':>{col_width}}", end='')  # Mostrar NaN
            else:  # Si hay valor válido
                print(f"{value:>{col_width}.6f}", end='')  # Mostrar con 6 decimales
                # .6f formatea como float con 6 decimales
        print()  # Salto de línea al final de cada fila


def main():
    """
    Función principal del programa.
    Procesa argumentos de línea de comandos y ejecuta el análisis estadístico.
    """
    if len(sys.argv) < 2:  # Si no se proporciona archivo como argumento
        # sys.argv es lista de argumentos: [nombre_script, arg1, arg2, ...]
        print("Uso: python describe.py <dataset.csv>")
        print("Ejemplo: python describe.py dataset_train.csv")
        sys.exit(1)  # Salir con código de error
    
    filename = sys.argv[1]  # Obtener nombre de archivo del primer argumento
    
    # Verificar si se solicitó la opción bonus
    bonus = '--bonus' in sys.argv or '-b' in sys.argv
    # 'in' verifica si un elemento está en una lista
    
    describe(filename, bonus=True)  # Mostrar siempre estadísticas bonus


if __name__ == "__main__":
    main()  # Ejecutar función principal solo si se ejecuta como script
    # __name__ == "__main__" es True solo cuando el archivo se ejecuta directamente
    # no cuando se importa como módulo
