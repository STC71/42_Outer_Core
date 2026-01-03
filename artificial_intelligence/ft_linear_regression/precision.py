#!/usr/bin/env python3
"""
Programa bonus para calcular la precisión del modelo.
Calcula métricas como R², MSE, RMSE y MAE.
Utiliza los datos de 'data.csv' y los parámetros guardados en 'thetas.txt'.
"""

import csv
import sys
import os


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
        print(f"Error: No se encuentra '{filename}'.")
        print("Ejecuta 'python3 train.py' primero para entrenar el modelo.")
        sys.exit(1)
    
    try:
        with open(filename, 'r') as f:
            lines = f.readlines()
            theta0 = float(lines[0].strip())
            theta1 = float(lines[1].strip())
            return theta0, theta1
    except (IOError, ValueError, IndexError) as e:
        print(f"Error al leer thetas: {e}")
        sys.exit(1)


def estimate_price(mileage, theta0, theta1):
    """
    Calcula el precio estimado.
    """
    return theta0 + (theta1 * mileage)


def calculate_metrics(mileages, actual_prices, theta0, theta1):
    """
    Calcula varias métricas de precisión del modelo.
    
    Métricas:
    - R² (Coeficiente de determinación): Mide qué tan bien el modelo explica la varianza
    - MSE (Error Cuadrático Medio): Promedio de los errores al cuadrado
    - RMSE (Raíz del MSE): MSE en la misma escala que los datos
    - MAE (Error Absoluto Medio): Promedio de los errores absolutos
    """
    n = len(mileages)
    
    # Predicciones
    predictions = [estimate_price(m, theta0, theta1) for m in mileages]
    
    # Media de los precios reales
    mean_price = sum(actual_prices) / n
    
    # Suma de cuadrados total (SST)
    ss_total = sum((price - mean_price) ** 2 for price in actual_prices)
    
    # Suma de cuadrados residual (SSR)
    ss_residual = sum((actual_prices[i] - predictions[i]) ** 2 for i in range(n))
    
    # R² (Coeficiente de determinación)
    # R² = 1 significa predicción perfecta, 0 significa que el modelo no es mejor que la media
    r_squared = 1 - (ss_residual / ss_total) if ss_total != 0 else 0
    
    # MSE (Mean Squared Error)
    mse = ss_residual / n
    
    # RMSE (Root Mean Squared Error)
    rmse = mse ** 0.5
    
    # MAE (Mean Absolute Error)
    mae = sum(abs(actual_prices[i] - predictions[i]) for i in range(n)) / n
    
    # Error porcentual medio
    mape = sum(abs((actual_prices[i] - predictions[i]) / actual_prices[i]) 
               for i in range(n) if actual_prices[i] != 0) / n * 100
    
    return {
        'r_squared': r_squared,
        'mse': mse,
        'rmse': rmse,
        'mae': mae,
        'mape': mape,
        'n_samples': n
    }


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
