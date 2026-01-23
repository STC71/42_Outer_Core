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
    """
    Si no existe el archivo 'thetas.txt', retorna los valores iniciales (0.0, 0.0) 
    para theta0 y theta1. 
    Esto asegura que el programa pueda continuar ejecutándose incluso si los parámetros 
    no han sido entrenados previamente.
    """
    
    try:
        with open(theta_file, 'r') as f:
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
        return 0.0, 0.0
        """
        Si ocurre un error al leer el archivo (como problemas de E/S, conversión de tipos 
        o índice fuera de rango), imprime un mensaje de error y retorna los valores iniciales
        (0.0, 0.0).
        e contiene la descripción del error ocurrido.
        """


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
    """
    load_thetas(): carga los parámetros theta0 y theta1 desde el archivo 'thetas.txt'.
    Si el archivo no existe o hay un error, retorna (0.0, 0.0).
    theta0 y theta1 son los parámetros del modelo de regresión lineal.
    """
    
    # Solicitar kilometraje al usuario
    try:
        mileage_input = input("🚗 Introduce el kilometraje del coche: ")
        """
        input(): solicita al usuario que introduzca el kilometraje del coche.
        El valor introducido se almacena en la variable mileage_input como una cadena de texto.
        """
        mileage = float(mileage_input)
        """
        Convierte la entrada del usuario (cadena de texto) a un número de punto flotante.
        mileage representa el kilometraje del coche en kilómetros.
        """
        
        if mileage < 0:
            print("Error: El kilometraje no puede ser negativo.")
            sys.exit(1)
        """
        Verifica si el kilometraje es negativo. Si es así, imprime un mensaje de error y termina el programa
        con un código de salida 1, indicando que hubo un error.
        """
        
        # Calcular precio estimado
        # estimate_price(): calcula el precio estimado usando la función lineal:
        # estimatePrice(mileage) = theta0 + (theta1 * mileage)
        price = estimate_price(mileage, theta0, theta1)
        
        # Muestra el precio estimado en euros para el kilometraje proporcionado.
        # El kilometraje se muestra sin decimales y el precio con dos decimales.
        print(f"💰 Precio estimado para {mileage:.0f} km: {price:.2f}€")
        
    # Si la conversión a float falla (por ejemplo, si el usuario introduce texto no numérico),
    # captura la excepción ValueError, imprime un mensaje de error y termina el programa.
    except ValueError:
        print("Error: Por favor introduce un número válido.")
        sys.exit(1)
    
    # Captura la excepción KeyboardInterrupt (por ejemplo, si el usuario presiona Ctrl+C),
    # imprime un mensaje de cancelación y termina el programa con un código de salida 0.
    except KeyboardInterrupt:
        print("\n👋 Operación cancelada.")
        sys.exit(0)


if __name__ == "__main__":
    main()
"""
Si el script es ejecutado directamente (no importado como módulo), llama a la función main().
Sirve para iniciar la ejecución del programa cuando se corre el archivo. En caso de que el 
archivo sea importado como módulo en otro script, la función main() no se ejecutará automáticamente.
"""
