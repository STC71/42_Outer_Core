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
    prices_norm, mean_price, std_price = normalize_data(prices)
    
    m = len(mileages_norm)
    theta0 = 0.0
    theta1 = 0.0
    
    print(f"Iniciando entrenamiento con {m} muestras...")
    print(f"Learning rate: {learning_rate}, Iteraciones: {iterations}")
    
    # Historial de MSE para análisis de convergencia
    mse_history = []
    
    # Gradiente descendente
    for iteration in range(iterations):
        # Calcular las sumas para ambos thetas
        sum_errors_theta0 = 0.0
        sum_errors_theta1 = 0.0
        
        for i in range(m):
            estimated = estimate_price(mileages_norm[i], theta0, theta1)
            error = estimated - prices_norm[i]
            
            sum_errors_theta0 += error
            sum_errors_theta1 += error * mileages_norm[i]
        
        # Actualizar simultáneamente theta0 y theta1
        tmp_theta0 = learning_rate * (sum_errors_theta0 / m)
        tmp_theta1 = learning_rate * (sum_errors_theta1 / m)
        
        theta0 -= tmp_theta0
        theta1 -= tmp_theta1
        
        # Calcular MSE en cada iteración
        mse = sum((estimate_price(mileages_norm[i], theta0, theta1) - prices_norm[i]) ** 2 
                 for i in range(m)) / m
        mse_history.append(mse)
        
        # Mostrar progreso cada 100 iteraciones
        if (iteration + 1) % 100 == 0 or iteration == 0:
            print(f"Iteración {iteration + 1}/{iterations} - MSE: {mse:.6f}")
    
    # Desnormalizar thetas
    theta0_final, theta1_final = denormalize_theta(
        theta0, theta1, mean_km, std_km, mean_price, std_price
    )
    
    return theta0_final, theta1_final, mse_history


def save_thetas(theta0, theta1, filename='thetas.txt'):
    """
    Guarda los parámetros theta0 y theta1 en un archivo.
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
    print(f"Datos cargados: {len(mileages)} muestras")
    print(f"Rango de kilometraje: {min(mileages):.0f} - {max(mileages):.0f} km")
    print(f"Rango de precios: {min(prices):.0f} - {max(prices):.0f}€\n")
    
    # Entrenar modelo
    theta0, theta1, mse_history = train_model(mileages, prices)
    
    # Guardar parámetros
    save_thetas(theta0, theta1)
    
    # Guardar historial de MSE para curva de aprendizaje (bonus)
    try:
        with open('mse_history.txt', 'w') as f:
            for mse in mse_history:
                f.write(f"{mse}\n")
        print(f"Historial de convergencia guardado en 'mse_history.txt'")
    except IOError:
        pass  # No es crítico
    
    print("\n¡Entrenamiento completado exitosamente!")


if __name__ == "__main__":
    main()
