#!/usr/bin/env python3
"""
Programa de entrenamiento para regresión lineal.
Implementa el algoritmo de gradiente descendente para encontrar
los parámetros theta0 y theta1 óptimos.
"""

import csv
import sys


def load_data(filename):
    """
    Carga los datos del archivo CSV.
    Retorna dos listas: kilometrajes y precios.
    """
    mileages = []
    prices = []
    
    try:
        with open(filename, 'r') as f:
            reader = csv.DictReader(f)
            for row in reader:
                mileages.append(float(row['km']))
                prices.append(float(row['price']))
        
        if len(mileages) == 0:
            raise ValueError("El archivo está vacío")
        
        return mileages, prices
    
    except FileNotFoundError:
        print(f"Error: No se encuentra el archivo '{filename}'")
        sys.exit(1)
    except (ValueError, KeyError) as e:
        print(f"Error al leer datos: {e}")
        sys.exit(1)


def estimate_price(mileage, theta0, theta1):
    """
    Calcula el precio estimado usando la función lineal:
    estimatePrice(mileage) = theta0 + (theta1 * mileage)
    """
    return theta0 + (theta1 * mileage)


def normalize_data(data):
    """
    Normaliza los datos para mejorar la convergencia del gradiente descendente.
    Retorna los datos normalizados, la media y la desviación estándar.
    """
    mean = sum(data) / len(data)
    
    # Calcular desviación estándar
    variance = sum((x - mean) ** 2 for x in data) / len(data)
    std = variance ** 0.5
    
    # Evitar división por cero
    if std == 0:
        std = 1
    
    normalized = [(x - mean) / std for x in data]
    
    return normalized, mean, std


def denormalize_theta(theta0_norm, theta1_norm, mean_x, std_x, mean_y, std_y):
    """
    Desnormaliza los parámetros theta para usarlos con datos originales.
    """
    theta1 = theta1_norm * (std_y / std_x)
    theta0 = mean_y - (theta1 * mean_x)
    
    return theta0, theta1


def train_model(mileages, prices, learning_rate=0.1, iterations=1000):
    """
    Entrena el modelo usando gradiente descendente.
    
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
        
        # Mostrar progreso cada 100 iteraciones
        if (iteration + 1) % 100 == 0 or iteration == 0:
            # Calcular error medio (MSE)
            mse = sum((estimate_price(mileages_norm[i], theta0, theta1) - prices_norm[i]) ** 2 
                     for i in range(m)) / m
            print(f"Iteración {iteration + 1}/{iterations} - MSE: {mse:.6f}")
    
    # Desnormalizar thetas
    theta0_final, theta1_final = denormalize_theta(
        theta0, theta1, mean_km, std_km, mean_price, std_price
    )
    
    return theta0_final, theta1_final


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
    theta0, theta1 = train_model(mileages, prices)
    
    # Guardar parámetros
    save_thetas(theta0, theta1)
    
    print("\n¡Entrenamiento completado exitosamente!")


if __name__ == "__main__":
    main()
