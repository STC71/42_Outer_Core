#!/usr/bin/env python3
"""
Programa bonus para visualizar los datos y la regresión lineal.
Muestra un gráfico con los puntos del dataset y la línea de regresión.
Utiliza los datos de 'data.csv' y los parámetros guardados en 'thetas.txt'.
"""

import csv
import sys
import os

try:
    import matplotlib.pyplot as plt
except ImportError:
    print("Error: Se requiere matplotlib para la visualización.")
    print("Instala con: pip install matplotlib")
    sys.exit(1)


def load_data(filename):
    """
    Carga los datos del archivo CSV.
    """
    mileages = []
    prices = []
    
    try:
        with open(filename, 'r') as f:
            reader = csv.DictReader(f)
            for row in reader:
                mileages.append(float(row['km']))
                prices.append(float(row['price']))
        return mileages, prices
    except FileNotFoundError:
        print(f"Error: No se encuentra el archivo '{filename}'")
        sys.exit(1)
    except (ValueError, KeyError) as e:
        print(f"Error al leer datos: {e}")
        sys.exit(1)


def load_thetas(filename='thetas.txt'):
    """
    Carga los parámetros theta0 y theta1.
    """
    if not os.path.exists(filename):
        print(f"Advertencia: No se encuentra '{filename}'. Usando valores por defecto (0, 0).")
        print("Ejecuta 'python3 train.py' primero para entrenar el modelo.")
        return 0.0, 0.0
    
    try:
        with open(filename, 'r') as f:
            lines = f.readlines()
            theta0 = float(lines[0].strip())
            theta1 = float(lines[1].strip())
            return theta0, theta1
    except (IOError, ValueError, IndexError) as e:
        print(f"Error al leer thetas: {e}")
        return 0.0, 0.0


def estimate_price(mileage, theta0, theta1):
    """
    Calcula el precio estimado.
    """
    return theta0 + (theta1 * mileage)


def plot_data_and_regression(mileages, prices, theta0, theta1):
    """
    Crea un gráfico con los datos y la línea de regresión.
    """
    # Configurar el gráfico
    plt.figure(figsize=(12, 7))
    
    # Plotear los puntos de datos originales
    plt.scatter(mileages, prices, color='blue', alpha=0.6, s=50, 
                label='Datos originales', edgecolors='black', linewidth=0.5)
    
    # Crear la línea de regresión
    min_mileage = min(mileages)
    max_mileage = max(mileages)
    
    # Puntos para la línea
    line_mileages = [min_mileage, max_mileage]
    line_prices = [estimate_price(m, theta0, theta1) for m in line_mileages]
    
    # Plotear la línea de regresión
    plt.plot(line_mileages, line_prices, color='red', linewidth=2, 
             label=f'Regresión lineal\n(θ₀={theta0:.2f}, θ₁={theta1:.6f})')
    
    # Añadir líneas de cuadrícula
    plt.grid(True, alpha=0.3, linestyle='--')
    
    # Etiquetas y título
    plt.xlabel('Kilometraje (km)', fontsize=12, fontweight='bold')
    plt.ylabel('Precio (€)', fontsize=12, fontweight='bold')
    plt.title('Regresión Lineal: Precio vs Kilometraje', 
              fontsize=14, fontweight='bold', pad=20)
    
    # Leyenda
    plt.legend(loc='upper right', fontsize=10, framealpha=0.9)
    
    # Ajustar el layout
    plt.tight_layout()
    
    # Mostrar el gráfico
    print("\nMostrando visualización...")
    plt.show()


def main():
    """
    Función principal.
    """
    print("=== Visualización de Regresión Lineal ===\n")
    
    # Cargar datos
    print("Cargando datos...")
    mileages, prices = load_data('data.csv')
    print(f"✓ {len(mileages)} muestras cargadas")
    
    # Cargar thetas
    theta0, theta1 = load_thetas()
    print(f"✓ Parámetros cargados: θ₀={theta0:.2f}, θ₁={theta1:.6f}")
    
    # Crear visualización
    plot_data_and_regression(mileages, prices, theta0, theta1)


if __name__ == "__main__":
    main()
