#!/usr/bin/env python3
"""
Programa bonus para calcular la precisión del modelo.
Calcula métricas como R², MSE, RMSE y MAE.
Utiliza los datos de 'data.csv' y los parámetros guardados en 'thetas.txt'.
"""

import csv      # Para manejar archivos CSV
import sys      # Para manejar la salida y errores del sistema
import os       # Para verificar la existencia de archivos


def load_data(filename):
    """
    Carga los datos del archivo CSV.
    """
    mileages = []       # Lista para almacenar los kilometrajes, inicialmente vacía
    prices = []         # Lista para almacenar los precios, inicialmente vacía
    
    try:
        with open(filename, 'r') as f:
            reader = csv.DictReader(f)
            for row in reader:
                mileages.append(float(row['km']))
                prices.append(float(row['price']))
        return mileages, prices
        """
        Abre el archivo CSV en modo lectura y lo apoda como 'f'.
        Usa csv.DictReader para leer el archivo como un diccionario.
        DicktReader es una clase de la biblioteca csv que permite leer archivos CSV
        y acceder a los valores de cada fila mediante los nombres de las columnas.
        Itera sobre cada fila del archivo:
        - Convierte el valor de la columna 'km' a float y lo añade a la lista mileages.
        - Convierte el valor de la columna 'price' a float y lo añade a la lista prices.
        Retorna las listas mileages y prices.
        """
    except FileNotFoundError:
        print(f"Error: No se encuentra el archivo '{filename}'")
        sys.exit(1)
    except (ValueError, KeyError) as e:
        print(f"Error al leer datos: {e}")
        sys.exit(1)
        """
        Si el archivo no se encuentra, imprime un mensaje de error y termina el programa.
        Si ocurre un error al convertir los datos (como problemas de conversión de tipos 
        o claves faltantes), imprime un mensaje de error y termina el programa.
        e contiene la descripción del error ocurrido.
        """


def load_thetas(filename='thetas.txt'):
    """
    Carga los parámetros theta0 y theta1.
    """
    if not os.path.exists(filename):
        print(f"Error: No se encuentra '{filename}'.")
        print("Ejecuta 'python3 train.py' primero para entrenar el modelo.")
        sys.exit(1)
    """
    Si no existe el archivo 'thetas.txt', imprime un mensaje de error indicando que
    se debe ejecutar el script de entrenamiento primero, y termina el programa.
    """
    
    try:
        with open(filename, 'r') as f:
            lines = f.readlines()
            theta0 = float(lines[0].strip())
            theta1 = float(lines[1].strip())
            return theta0, theta1
        """
        Abre el archivo 'thetas.txt' en modo lectura y lo apoda como 'f'.
        Lee todas las líneas del archivo y las almacena en la lista 'lines'.
        Convierte la primera línea en un float y la asigna a theta0.
        Convierte la segunda línea en un float y la asigna a theta1.
        strip() elimina cualquier espacio en blanco o caracteres de nueva línea.
        Retorna los valores de theta0 y theta1.
        """
    except (IOError, ValueError, IndexError) as e:
        print(f"Error al leer thetas: {e}")
        sys.exit(1)
        """
        Si ocurre un error al leer el archivo (como problemas de E/S, conversión de tipos 
        o índice fuera de rango), imprime un mensaje de error y termina el programa.
        e contiene la descripción del error ocurrido.
        """


def estimate_price(mileage, theta0, theta1):
    """
    Calcula el precio estimado.
    """
    return theta0 + (theta1 * mileage)
    """
    Calcula el precio estimado usando la función lineal:
    estimatePrice(mileage) = theta0 + (theta1 * mileage)
    """


def calculate_metrics(mileages, actual_prices, theta0, theta1):
    """
    Calcula varias métricas de precisión del modelo.
    
    Métricas:
    - R² (Coeficiente de determinación): Mide qué tan bien el modelo explica la varianza.
        La varianza es una medida estadística que indica qué tan dispersos están los datos
        con respecto a su media. Un R² de 1 indica una predicción perfecta, mientras que 
        un R² de 0 indica que el modelo no es mejor que simplemente usar la media.
        Lo ideal es tener un R² cercano a 1, pero no llegar a 1 exactamente, ya que podría
        indicar sobreajuste (overfitting).
    - MSE (Error Cuadrático Medio): Promedio de los errores al cuadrado.
        Sirve para medir la precisión del modelo. Un MSE más bajo indica un mejor ajuste del 
        modelo a los datos. Se calcula como la media de los cuadrados de las diferencias 
        entre los valores predichos por el modelo y los valores reales observados. 
        Un MSE de 0 indica una predicción perfecta, pero en la práctica, siempre habrá algún 
        error.
        Se eleva al cuadrado para penalizar más los errores grandes y evitar que los errores
        positivos y negativos se cancelen entre sí al convertir los negativos en positivos.
    - RMSE (Raíz del MSE): MSE en la misma escala que los datos
        Se utiliza para interpretar el error en las mismas unidades que los datos originales.
        Un RMSE más bajo indica un mejor ajuste del modelo a los datos. Al igual que el MSE,
        un RMSE de 0 indica una predicción perfecta.
        La raiz cuadrada se toma para devolver el error a la misma escala que los datos 
        originales, lo que facilita su interpretación. Por ejemplo, si los precios están en 
        euros, el RMSE también estará en euros.
    - MAE (Error Absoluto Medio): Promedio de los errores absolutos
        Mide la magnitud promedio de los errores en las predicciones, sin considerar su 
        dirección.
        Un MAE más bajo indica un mejor ajuste del modelo a los datos. Al igual que el MSE y 
        RMSE, un MAE de 0 indica una predicción perfecta.
        Se utiliza el valor absoluto para evitar que los errores positivos y negativos se 
        cancelen entre sí.
    - MAPE (Error Porcentual Medio): Promedio de los errores porcentuales absolutos
        Mide la precisión del modelo en términos porcentuales.
        Un MAPE más bajo indica un mejor ajuste del modelo a los datos. Un MAPE de 0% indica 
        una predicción perfecta.
        Se utiliza el valor absoluto para evitar que los errores porcentuales positivos y 
        negativos se cancelen entre sí.
    """
    n = len(mileages)   # n guarda el número de muestras de datos (kms.) 
    
    # Predicciones
    predictions = [estimate_price(m, theta0, theta1) for m in mileages]
    """
    Genera una lista de predicciones utilizando la función estimate_price para cada
    kilometraje en mileages, con los parámetros theta0 y theta1.
    predictions contiene los precios estimados por el modelo.
    m representa cada kilometraje en la lista mileages.
    """
    
    # Media de los precios reales
    mean_price = sum(actual_prices) / n
    """
    Calcula la media de los precios reales sumando todos los precios en actual_prices
    y dividiéndolo por el número de muestras n. Se utiliza para calcular la varianza total,
    que representa la dispersión de los precios reales con respecto a su media.
    """
    
    # Suma de cuadrados total (SST)
    ss_total = sum((price - mean_price) ** 2 for price in actual_prices)
    """
    Calcula la suma de cuadrados total (SST) sumando las diferencias al cuadrado entre
    cada precio real y la media de los precios. Se utiliza para medir la varianza total
    en los datos reales. Se eleva al cuadrado para penalizar más las desviaciones grandes 
    y evitar que las diferencias positivas y negativas se cancelen entre sí.
    """
    
    # Suma de cuadrados residual (SSR)
    ss_residual = sum((actual_prices[i] - predictions[i]) ** 2 for i in range(n))
    """
    Calcula la suma de cuadrados residual (SSR) sumando las diferencias al cuadrado entre
    cada precio real y su correspondiente predicción. Se utiliza para medir la varianza
    que no es explicada por el modelo. Se eleva al cuadrado para penalizar más las desviaciones
    grandes y evitar que las diferencias positivas y negativas se cancelen entre sí.
    n representa el número de muestras.
    """
    
    # R² (Coeficiente de determinación)
    # R² = 1 significa predicción perfecta, 0 significa que el modelo no es mejor que la media
    r_squared = 1 - (ss_residual / ss_total) if ss_total != 0 else 0
    """
    Calcula el coeficiente de determinación R² como 1 menos la razón entre SSR y SST.
    Mide qué tan bien el modelo explica la varianza en los datos reales. Un R² de 1 indica
    una predicción perfecta, mientras que un R² de 0 indica que el modelo no es mejor que
    simplemente usar la media. Si SST es distinto de cero, se calcula R²; de lo contrario, 
    se asigna 0 para evitar división por cero.
    """
    
    # MSE (Mean Squared Error)
    mse = ss_residual / n
    """
    Calcula el Error Cuadrático Medio (MSE) dividiendo la suma de cuadrados residual (SSR)
    por el número de muestras n. Mide la precisión del modelo, donde un MSE más bajo indica un
    mejor ajuste a los datos. Un MSE de 0 indica una predicción perfecta.
    Se eleva al cuadrado para penalizar más los errores grandes y evitar que los errores
    positivos y negativos se cancelen entre sí.
    """
    
    # RMSE (Root Mean Squared Error)
    rmse = mse ** 0.5
    """
    Calcula la Raíz del Error Cuadrático Medio (RMSE) como la raíz cuadrada del MSE.
    Mide la precisión del modelo en las mismas unidades que los datos originales.
    Un RMSE más bajo indica un mejor ajuste a los datos. Un RMSE de 0 indica una 
    predicción perfecta.
    """
    
    # MAE (Mean Absolute Error)
    mae = sum(abs(actual_prices[i] - predictions[i]) for i in range(n)) / n
    """
    Calcula el Error Absoluto Medio (MAE) sumando las diferencias absolutas entre
    cada precio real y su correspondiente predicción, y dividiéndolo por el número de
    muestras n. Mide la magnitud promedio de los errores en las predicciones, sin
    considerar su dirección. Un MAE más bajo indica un mejor ajuste a los datos. Un MAE de 0
    indica una predicción perfecta.
    Se utiliza el valor absoluto para evitar que los errores positivos y negativos se 
    cancelen entre sí.
    """
    
    # Error porcentual medio
    mape = sum(abs((actual_prices[i] - predictions[i]) / actual_prices[i]) 
               for i in range(n) if actual_prices[i] != 0) / n * 100
    """
    Calcula el Error Porcentual Medio (MAPE) sumando las diferencias porcentuales absolutas
    entre cada precio real y su correspondiente predicción, dividiéndolo por el número de
    muestras n, y multiplicándolo por 100 para expresarlo como porcentaje. Mide la precisión del
    modelo en términos porcentuales. Un MAPE más bajo indica un mejor ajuste a los datos. 
    Un MAPE de 0% indica una predicción perfecta.
    """
    
    return {
        'r_squared': r_squared,
        'mse': mse,
        'rmse': rmse,
        'mae': mae,
        'mape': mape,
        'n_samples': n
    }
    """
    Retorna un diccionario con las métricas calculadas:
    - 'r_squared': Coeficiente de determinación R²
    - 'mse': Error Cuadrático Medio (MSE)
    - 'rmse': Raíz del Error Cuadrático Medio (RMSE)
    - 'mae': Error Absoluto Medio (MAE)
    - 'mape': Error Porcentual Medio (MAPE)
    - 'n_samples': Número de muestras utilizadas en el cálculo
    """


def print_metrics(metrics, theta0, theta1):
    """
    Imprime las métricas de forma legible.
    """
    print("\n" + "="*60)
    print("         EVALUACIÓN DE PRECISIÓN DEL MODELO")
    print("="*60)
    
    print(f"\nParámetros del modelo:")
    print(f"  θ₀ (intersección): {theta0:,.2f}")
    print(f"  θ₁ (pendiente):    {theta1:.8f}")
    
    print(f"\nNúmero de muestras: {metrics['n_samples']}")
    
    print(f"\nMétricas de precisión:")
    print(f"  R² (Coef. determinación): {metrics['r_squared']:.4f}")
    
    # Interpretación de R²
    if metrics['r_squared'] >= 0.9:
        interpretation = "Excelente ajuste"
    elif metrics['r_squared'] >= 0.7:
        interpretation = "Buen ajuste"
    elif metrics['r_squared'] >= 0.5:
        interpretation = "Ajuste moderado"
    else:
        interpretation = "Ajuste pobre"
    print(f"    → {interpretation}")
    
    print(f"\n  MSE (Error cuadrático medio):  {metrics['mse']:,.2f}")
    print(f"  RMSE (Raíz del MSE):           {metrics['rmse']:,.2f}€")
    print(f"  MAE (Error absoluto medio):    {metrics['mae']:,.2f}€")
    print(f"  MAPE (Error porcentual medio): {metrics['mape']:.2f}%")
    
    print("\n" + "="*60)
    
    # Explicación adicional
    print("\nInterpretación:")
    print(f"  • El modelo explica el {metrics['r_squared']*100:.2f}% de la varianza en los precios")
    print(f"  • Error promedio de ±{metrics['mae']:.0f}€ en las predicciones")
    print(f"  • Error típico (RMSE) de ±{metrics['rmse']:.0f}€")
    print("="*60 + "\n")


def show_predictions_sample(mileages, prices, theta0, theta1, n_samples=5):
    """
    Muestra algunas predicciones de ejemplo.
    """
    print("\nEjemplos de predicciones:")
    print("-" * 60)
    print(f"{'Kilometraje':>12} | {'Precio Real':>12} | {'Predicción':>12} | {'Error':>12}")
    print("-" * 60)
    
    # Seleccionar índices distribuidos uniformemente
    indices = [int(i * len(mileages) / n_samples) for i in range(n_samples)]
    
    for idx in indices:
        pred = estimate_price(mileages[idx], theta0, theta1)
        error = prices[idx] - pred
        print(f"{mileages[idx]:>12,.0f} | {prices[idx]:>12,.0f}€ | "
              f"{pred:>12,.0f}€ | {error:>+12,.0f}€")
    
    print("-" * 60)


def main():
    """
    Función principal.
    """
    # Cargar datos
    print("Cargando datos...")
    mileages, prices = load_data('data.csv')
    print(f"✓ {len(mileages)} muestras cargadas")
    
    # Cargar thetas
    print("Cargando parámetros del modelo...")
    theta0, theta1 = load_thetas()
    print("✓ Parámetros cargados")
    
    # Calcular métricas
    print("Calculando métricas de precisión...")
    metrics = calculate_metrics(mileages, prices, theta0, theta1)
    
    # Mostrar resultados
    print_metrics(metrics, theta0, theta1)
    
    # Mostrar ejemplos
    show_predictions_sample(mileages, prices, theta0, theta1)


if __name__ == "__main__":
    main()
