#!/usr/bin/env python3
"""
Programa de entrenamiento para regresión lineal.
Implementa el algoritmo de gradiente descendente para encontrar
los parámetros theta0 y theta1 óptimos.
Utiliza los datos de 'data.csv' para el entrenamiento.
"""

import csv  # Para manejar archivos CSV, como 'data.csv'
import sys  # Para manejar errores y salir del programa, si es necesario.


def load_data(filename):
    """
    def: es la palabra clave para definir una función en Python
    load_data: es el nombre de la función que carga los datos desde un archivo CSV
    filename: es el parámetro que representa el nombre del archivo CSV a cargar
    Luego entonces:
    Carga los datos del archivo CSV, pasado como argumento 'filename', ej: python3 train.py data.csv
    Retorna dos listas: kilometrajes y precios.
    """
    mileages = []   # Lista para almacenar los kilometrajes
    prices = []     # Lista para almacenar los precios
    
    try:            # Intentar abrir y leer el archivo
        with open(filename, 'r') as f:      
        # Abrir en modo lectura. 'f' es el objeto archivo, variable que representa el archivo abierto.
            reader = csv.DictReader(f)
            # Crear un lector de CSV que interpreta cada fila como un diccionario
            for row in reader:              
            # Iterar sobre cada fila rowm, en reader (que es el objeto que contiene las filas del archivo CSV)
                mileages.append(float(row['km']))   
                # Agregar el kilometraje convertido a float a la lista mileages
                prices.append(float(row['price']))  
                # Agregar el precio convertido a float a la lista prices    
        
        if len(mileages) == 0:      # Verificar si no se cargaron datos
            raise ValueError("El archivo está vacío")
            # raise: lanzar una excepción
            # ValueError: tipo de excepción que indica un valor incorrecto
        
        return mileages, prices     # Retornar las listas de kilometrajes y precios
    
    except FileNotFoundError:
    # Manejar el error si el archivo no se encuentra
        print(f"Error: No se encuentra el archivo '{filename}'")
        # f es para formatear cadenas, permite insertar variables dentro de cadenas
        # en nuestra caso, permite insertar el valor de filename (el nombre del archivo)
        sys.exit(1)     # Salir del programa con código de error 1
    except (ValueError, KeyError) as e:
    # Manejar errores de formato o claves faltantes en el CSV
    # ValueError: si hay un valor incorrecto en el archivo
    # KeyError: si falta una clave esperada en el archivo CSV (como 'km' o 'price')
    # 'as e': asigna la excepción capturada a la variable 'e' para su uso posterior
        print(f"Error al leer datos: {e}")
        sys.exit(1)


def estimate_price(mileage, theta0, theta1):
    """
    def: define una función en Python llamada estimate_price que
    calcula el precio estimado usando la función lineal:
    estimatePrice(mileage) = theta0 + (theta1 * mileage)
    donde theta0 representa la intersección con el eje Y o sea el precio base,
    y theta1 representa la pendiente de la línea o sea el cambio en el precio
    por cada unidad de cambio en el kilometraje.
    el eje x representa el kilometraje (mileage)
    el eje y representa el precio (price)
    Retorna el precio estimado para un kilometraje dado.
    """
    return theta0 + (theta1 * mileage)


def normalize_data(data):
    """
    Normaliza los datos para mejorar la convergencia del gradiente descendente.
    Retorna los datos normalizados, la media y la desviación estándar.
    """
    mean = sum(data) / len(data)
    # Calcular la media de los datos.
    # mean = suma de todos los elementos en data / el número de elementos en data (len(data))
    
    # Calcular desviación estándar
    variance = sum((x - mean) ** 2 for x in data) / len(data)
    # o sea la varianza es igual a la suma de las diferencias al cuadrado
    # for x in data: para cada elemento x en la lista data
    # luego dividir entre el número de elementos en data (len(data))
    std = variance ** 0.5   # calcular la desviación estándar, std
    # dice cuánto se alejan, en promedio, los datos de su valor central (la media)
    # ¿Qué tan dispersos o esparcidos están mis números?
    # std es igual a la raíz cuadrada de la varianza. 0.5 = 1/2 = raíz cuadrada.
    
    # Evitar división por cero
    if std == 0:
        std = 1
    
    normalized = [(x - mean) / std for x in data]
    # Normalizar cada dato restando la media y dividiendo por la desviación estándar
    
    return normalized, mean, std
    # Retorna la lista de datos normalizados, la media y la desviación estándar


def denormalize_theta(theta0_norm, theta1_norm, mean_x, std_x, mean_y, std_y):
    """
    Desnormaliza los parámetros theta para usarlos con datos originales,
    o sea, sin normalizar después del entrenamiento.
    Los parametros fueron normalizdos en la función train_model (siguiente función)
    Retorna theta0 y theta1 desnormalizados.
    """
    theta1 = theta1_norm * (std_y / std_x)
    """
    Ajustar theta1 según las desviaciones estándar de y y x
    x está en unidad normalizada, y también y está en unidad normalizada.
    theta1_norm mide ¿cuánto cambia y normalizado por cada cambio en x normalizado?
    Al multiplicar por (std_y / std_x), convertimos ese cambio a la escala original de y y x.
    Así volvemos a la escala original de precios y kilometrajes.
    Ejemplo simplificado:
    Si std_x = 1000 km y std_y = 5000€:
    - En espacio normalizado, theta1_norm = -0.5 significa "por cada desv. estándar 
        de km, el precio baja 0.5 desv. estándar"
    - En espacio original: theta1 = -0.5 × (5000/1000) = -2.5 €/km
    Esto permite usar theta1 con datos sin normalizar en predict.py.
    """
    theta0 = mean_y - (theta1 * mean_x)
    """
    Ajustar theta0 para que la línea pase por el punto (mean_x, mean_y)
    mean_x es el kilometraje promedio en los datos originales
    mean_y es el precio promedio en los datos originales
    Al calcular theta0 así, aseguramos que la línea de regresión
    pase por el punto medio de los datos originales.
    Esto permite usar theta0 con datos sin normalizar en predict.py.
    Ejemplo simplificado:
    Si mean_x = 100000 km y mean_y = 6000 €
    Entonces theta0 = 6000 - (-0.02 * 100000) = 6000 + 2000 = 8000 €
    Esto significa que cuando el kilometraje es 0 km, el precio estimado es 8000 €.
    8000 € es el precio base estimado para un coche nuevo (0 km).
    8000 € es la intersección con el eje Y en el espacio original de precios y kilometrajes.
    Esto garantiza que cuando se predice con 100000 km, se obtiene ...
    8000 + (-0.02 * 100000) = 6000 €, justo la media de los precios originales.
    """
    return theta0, theta1

def train_model(mileages, prices, learning_rate=0.1, iterations=1000):
    """
    Entrena el modelo usando gradiente descendente.
    Gradiante descendiente: algoritmo de optimización para minimizar una función,
    o sea encontrar sus valores mínimos, el punto más bajo de la curva (mínimo global).
    En este caso, minimiza el error cuadrático medio (MSE) entre las predicciones
    del modelo y los precios reales.
    
    Implementa las fórmulas especificadas:
    tmpθ0 = learningRate * (1/m) * Σ(estimatePrice(mileage[i]) - price[i])
    tmpθ1 = learningRate * (1/m) * Σ((estimatePrice(mileage[i]) - price[i]) * mileage[i])
    """
    # Normalizar datos para mejor convergencia
    mileages_norm, mean_km, std_km = normalize_data(mileages)
    """
    Esta línea anterior es equivalente a hacer:
    resultado = normalize_data(mileages)
    mileages_norm = resultado[0]
    mean_km = resultado[1]
    std_km = resultado[2]
    donde:
    mileages_norm es la lista de kilometrajes normalizados
    mean_km es la media de los kilometrajes originales guardada para desnormalizar luego
    std_km es la desviación estándar de los kilometrajes originales guardada para desnormalizar luego
    normalize_data: función definida anteriormente que normaliza los datos
    En resumen, esta línea normaliza los kilometrajes para que tengan media 0 y desviación estándar 1.
    Esto ayuda a que el gradiente descendente converja más rápido y de manera más estable
    """
    prices_norm, mean_price, std_price = normalize_data(prices)
    """
    Similar a la normalización de kilometrajes, pero para los precios.
    prices_norm es la lista de precios normalizados
    mean_price es la media de los precios originales
    std_price es la desviación estándar de los precios originales
    """
    
    m = len(mileages_norm)  # Número de muestras de entrenamiento, o sea, número de datos en mileages_norm y prices_norm
    theta0 = 0.0            # Inicializar theta0 que representa la intersección con el eje Y
    theta1 = 0.0            # Inicializar theta1 que representa la pendiente de la línea 
    
    print(f"Iniciando entrenamiento con {m} muestras...")
    print(f"Learning rate: {learning_rate}, Iteraciones: {iterations}")
    
    # Historial de MSE para análisis de convergencia
    mse_history = []
    """
    mse_history: lista para almacenar el error cuadrático medio (MSE)
    en cada iteración del gradiente descendente.
    Esto es útil para analizar cómo el modelo mejora con el tiempo.
    """
    
    # Gradiente descendente
    for iteration in range(iterations):
        """
        iteration: variable que representa el número de la iteración actual
        range(iterations): genera una secuencia de números desde 0 hasta iterations-1
        ejemplo: se generan números 0, 1, 2, ..., iterations-1
        o sea, si iterations es 1000, se generan números del 0 al 999
        range(iterations) viene de la función incorporada range() de Python e iterations 
        es el número total de iteraciones definido en los parámetros de la función train_model.
        El bucle for se ejecuta 'iterations' veces para actualizar los parámetros theta0 y theta1.
        """
        # Calcular las sumas para ambos thetas
        sum_errors_theta0 = 0.0
        sum_errors_theta1 = 0.0
        
        for i in range(m):
            """
            Iterar sobre cada muestra de entrenamiento
            m es el número total de muestras de entrenamiento y viene de la línea: 180
            m = len(mileages_norm)
            o sea, el número de datos en mileages_norm y prices_norm
            0 <= i < m
            0, 1, 2, ..., m-1
            0 es la primera muestra, m-1 es la última muestra
            """
            estimated = estimate_price(mileages_norm[i], theta0, theta1)
            """
            Calcular el precio estimado para el kilometraje normalizado actual
            estimate_price: función definida anteriormente que calcula el precio estimado
            mileages_norm[i]: el kilometraje normalizado de la muestra i
            theta0 = el valor actual que representa la intersección con el eje Y
            theta1 = el valor actual que representa la pendiente de la línea
            estimated: el precio estimado por el modelo para la muestra i
            """
            error = estimated - prices_norm[i]
            """
            Calcular el error entre el precio estimado y el precio normalizado real
            estimated: el precio estimado por el modelo para la muestra i
            prices_norm[i]: el precio normalizado real de la muestra i
            error: la diferencia entre el precio estimado y el real
            Se utiliza para actualizar los parámetros thetas
            """
            
            sum_errors_theta0 += error
            """
            Acumular el error para theta0
            sum_errors_theta0: suma acumulada de errores para theta0
            error: el error calculado para la muestra i
            """
            sum_errors_theta1 += error * mileages_norm[i]
            """
            Acumular el error ponderado por el kilometraje normalizado para theta1
            sum_errors_theta1: suma acumulada de errores ponderados para theta1
            error * mileages_norm[i]: el error multiplicado por el kilometraje 
            normalizado de la muestra i
            """
        
        # Actualizar simultáneamente theta0 y theta1
        tmp_theta0 = learning_rate * (sum_errors_theta0 / m)
        """
        Calcular la actualización para theta0
        learning_rate: tasa de aprendizaje que controla el tamaño del paso en cada 
        actualización de los parámetros thetas
        La tasa de aprendizaje es un hiperparámetro que define qué tan grande es el paso
        en la dirección del gradiente (pendiente de la función de error) 
        sum_errors_theta0 / m: promedio del error acumulado para theta0
        tmp_theta0: el valor que se restará de theta0 para actualizarlo
        """
        tmp_theta1 = learning_rate * (sum_errors_theta1 / m)
        """
        Calcular la actualización para theta1
        learning_rate: tasa de aprendizaje que controla el tamaño del paso en cada 
        actualización de los parámetros thetas
        sum_errors_theta1 / m: promedio del error acumulado ponderado para theta1
        tmp_theta1: el valor que se restará de theta1 para actualizarlo
        """
        
        theta0 -= tmp_theta0
        """
        Actualizar theta0 restando la actualización calculada
        theta0: el valor actual que representa la intersección con el eje Y
        tmp_theta0: el valor que se restará de theta0 para actualizarlo
        Así, theta0 se mueve en la dirección que reduce el error.
        """
        theta1 -= tmp_theta1
        """
        Actualizar theta1 restando la actualización calculada
        theta1: el valor actual que representa la pendiente de la línea
        tmp_theta1: el valor que se restará de theta1 para actualizarlo
        Así, theta1 se mueve en la dirección que reduce el error.
        """
        
        # Calcular MSE en cada iteración
        mse = sum((estimate_price(mileages_norm[i], theta0, theta1) - prices_norm[i]) ** 2 
                 for i in range(m)) / m
        """
        Calcular el error cuadrático medio (MSE) en cada iteración
        estimate_price(mileages_norm[i], theta0, theta1): precio estimado para la muestra i
        prices_norm[i]: precio real normalizado para la muestra i
        (estimate_price(...) - prices_norm[i]) ** 2: error al cuadrado para la muestra i
        sum(... for i in range(m)): suma de los errores al cuadrado para todas las muestras
        m: número total de muestras
        mse: promedio del error cuadrático medio para la iteración actual
        """
        mse_history.append(mse)
        """
        Agregar el MSE calculado al historial para seguimiento
        mse_history: lista que almacena el MSE de cada iteración
        append es un método de listas en Python que agrega un elemento al final de la lista
        mse: error cuadrático medio calculado en la iteración actual
        Esto permite analizar cómo el MSE disminuye con el tiempo,
        indicando que el modelo está aprendiendo y mejorando.
        """
        
        # Mostrar progreso cada 100 iteraciones
        if (iteration + 1) % 100 == 0 or iteration == 0:
            print(f"Iteración {iteration + 1}/{iterations} - MSE: {mse:.6f}")
        """
        Si la iteración actual más 1 es múltiplo de 100, o si es la primera iteración,
        entonces imprimir el progreso del entrenamiento.
        iteration + 1: se suma 1 porque las iteraciones comienzan en 0
        % 100 == 0: verifica si es múltiplo de 100
        MSE: el error cuadrático medio calculado en la iteración actual
        .6f: formato para mostrar el MSE con 6 decimales
        """
    
    # Desnormalizar thetas
    theta0_final, theta1_final = denormalize_theta(
        theta0, theta1, mean_km, std_km, mean_price, std_price
    )
    """
    Desnormalizar los parámetros theta0 y theta1 para usarlos con datos originales
    theta0 y theta1: el valor final de theta0 y theta1 en espacio normalizado
    mean_km: media de los kilometrajes originales
    std_km: desviación estándar de los kilometrajes originales
    mean_price: media de los precios originales
    std_price: desviación estándar de los precios originales
    theta0_final y theta1_final: el valor desnormalizado de theta0 y theta1 
    para usar con datos originales de kilometrajes y precios
    denormalize_theta: función definida anteriormente que desnormaliza los parámetros thetas

    """
    
    return theta0_final, theta1_final, mse_history
    """
    Retornar los parámetros desnormalizados y el historial de MSE
    """


def save_thetas(theta0, theta1, filename='thetas.txt'):
    """
    Guarda los parámetros theta0 y theta1 en un archivo.
    save thetas: nombre de la función que guarda los parámetros thetas
    filename: nombre del archivo donde se guardarán los parámetros thetas
    Por defecto, el archivo se llama 'thetas.txt' pero se puede cambiar 
    pasando otro nombre como argumento.
    
    try es una construcción de manejo de excepciones en Python
    que permite intentar ejecutar un bloque de código y capturar
    cualquier excepción que pueda ocurrir durante su ejecución.
    Si ocurre una excepción, si algo sale mal, el flujo del programa
    se transfiere al bloque except correspondiente para manejar el error.
    En este caso, se intenta abrir un archivo y escribir los parámetros thetas en él.
    Si ocurre un error al abrir o escribir en el archivo, se captura la excepción
    y se maneja en el bloque except, que imprime un mensaje de error y sale del programa.
    """
    try:
        with open(filename, 'w') as f:
            f.write(f"{theta0}\n")
            f.write(f"{theta1}\n")
        print(f"\nParámetros guardados en '{filename}'")
        print(f"θ0 = {theta0}")
        print(f"θ1 = {theta1}")
    except IOError as e:
        print(f"Error al guardar thetas: {e}")
        sys.exit(1)


def main():
    """
    Función principal que carga datos, entrena el modelo y guarda los parámetros.
    """
    # Cargar datos
    print("Cargando datos desde 'data.csv'...")
    mileages, prices = load_data('data.csv')
    # load_data: función definida al principio que carga los datos desde un archivo CSV
    print(f"Datos cargados: {len(mileages)} muestras")
    # len(): función incorporada en Python que retorna el número de elementos en una lista
    print(f"Rango de kilometraje: {min(mileages):.0f} - {max(mileages):.0f} km")
    # min() y max() son funciones incorporadas en Python que retornan el valor mínimo y máximo de una lista
    print(f"Rango de precios: {min(prices):.0f} - {max(prices):.0f}€\n")
    
    # Entrenar modelo
    theta0, theta1, mse_history = train_model(mileages, prices)
    """
    train_model: función definida anteriormente que entrena el modelo
    mileages: lista de kilometrajes cargados desde el archivo CSV
    prices: lista de precios cargados desde el archivo CSV
    theta0: parámetro que representa la intersección con el eje Y
    theta1: parámetro que representa la pendiente de la línea
    mse_history: historial del error cuadrático medio (MSE) durante el entrenamiento
    cuyo uso es opcional, para análisis de convergencia (bonus)
    """
    
    # Guardar parámetros
    # Guardar parámetros theta0 y theta1 en archivo 'thetas.txt'
    save_thetas(theta0, theta1)
    
    # Guardar historial de MSE para curva de aprendizaje (bonus)
    # El bucle for itera sobre cada valor de mse en la lista mse_history
    # mse_history: lista que contiene el historial del error cuadrático medio (MSE)
    # en cada iteración del entrenamiento
    # f.write(f"{mse}\n"): escribe cada valor de mse en una nueva línea del archivo 
    # 'mse_history.txt'. Cuando se llega al final de la lista, el bucle termina y
    # el archivo se cierra automáticamente al salir del bloque with.
    try:
        with open('mse_history.txt', 'w') as f:
            for mse in mse_history:
                f.write(f"{mse}\n")
        print(f"Historial de convergencia guardado en 'mse_history.txt'")
    except IOError:
        # Manejar errores de entrada/salida al guardar el historial de MSE
        # Si ocurre un error al abrir o escribir en el archivo,
        # simplemente se ignora porque no es crítico para el funcionamiento del programa.
        pass
    
    print("\n¡Entrenamiento completado exitosamente!")


# Punto de entrada del programa. Si este archivo se ejecuta directamente,
# se llama a la función main().
# __name__: variable especial en Python que indica el nombre del módulo actual.
# Si el archivo se ejecuta directamente, __name__ es igual a "__main__".
# Esto permite que el código dentro del bloque if se ejecute solo cuando
# el archivo se ejecuta directamente, y no cuando se importa como un módulo en otro archivo.
if __name__ == "__main__":
    main()
