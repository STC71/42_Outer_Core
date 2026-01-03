#!/usr/bin/env python3
"""
Programa de predicción de precio de coches basado en kilometraje.
Utiliza los parámetros theta0 y theta1 obtenidos del entrenamiento.
Lee el kilometraje desde la entrada estándar y muestra el precio estimado.
"""

import os
import sys


def load_thetas():
    """
    Carga los parámetros theta0 y theta1 desde el archivo.
    Si no existe, retorna valores iniciales (0, 0).
    """
    theta_file = 'thetas.txt'
    
    if not os.path.exists(theta_file):
        return 0.0, 0.0
    
    try:
        with open(theta_file, 'r') as f:
            lines = f.readlines()
            theta0 = float(lines[0].strip())
            theta1 = float(lines[1].strip())
            return theta0, theta1
    except (IOError, ValueError, IndexError) as e:
        print(f"Error al leer thetas: {e}")
        return 0.0, 0.0


def estimate_price(mileage, theta0, theta1):
    """
    Calcula el precio estimado usando la función lineal:
    estimatePrice(mileage) = theta0 + (theta1 * mileage)
    """
    return theta0 + (theta1 * mileage)


def main():
    """
    Función principal que solicita el kilometraje y predice el precio.
    """
    # Cargar parámetros
    theta0, theta1 = load_thetas()
    
    # Solicitar kilometraje al usuario
    try:
        mileage_input = input("Introduce el kilometraje del coche: ")
        mileage = float(mileage_input)
        
        if mileage < 0:
            print("Error: El kilometraje no puede ser negativo.")
            sys.exit(1)
        
        # Calcular precio estimado
        price = estimate_price(mileage, theta0, theta1)
        
        print(f"Precio estimado para {mileage:.0f} km: {price:.2f}€")
        
    except ValueError:
        print("Error: Por favor introduce un número válido.")
        sys.exit(1)
    except KeyboardInterrupt:
        print("\nOperación cancelada.")
        sys.exit(0)


if __name__ == "__main__":
    main()
