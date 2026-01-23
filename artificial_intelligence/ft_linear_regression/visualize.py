#!/usr/bin/env python3
"""
Programa bonus para visualizar los datos y la regresión lineal.
Muestra un gráfico con los puntos del dataset y la línea de regresión.
Utiliza los datos de 'data.csv' y los parámetros guardados en 'thetas.txt'.
"""

import csv      # Para leer archivos CSV
import sys      # Para manejar salidas y errores del sistema
import os       # Para verificar la existencia de archivos

try:
    import matplotlib.pyplot as plt
    # import matplotlib.pyplot as plt: importa la biblioteca matplotlib para crear gráficos
    # plt: alias comúnmente usado para referirse a matplotlib.pyplot
except ImportError:
    print("Error: Se requiere matplotlib para la visualización.")
    print("Instala con: pip install matplotlib")
    sys.exit(1)


def load_data(filename):
    """
    Carga los datos del archivo CSV.
    load_data: función que lee un archivo CSV y extrae los datos de kilometraje y precio
    esta función se encuentra definida también en train.py, pero se repite aquí para mantener 
    la independencia del script de visualización.
    """
    mileages = []   # Lista para almacenar los kilometrajes
    prices = []     # Lista para almacenar los precios
    
    try:
        """
        Intenta abrir el archivo CSV y leer sus contenidos.
        Si el archivo no existe o hay un error en los datos, maneja las excepciones
        adecuadamente mostrando un mensaje de error y saliendo del programa.
        f : variable que representa el archivo abierto
        reader : objeto que permite iterar sobre las filas del archivo CSV como diccionarios
        row : cada fila del archivo CSV representada como un diccionario
        mileages.append(float(row['km'])) : convierte el valor de 'km' a float y lo añade 
        a la lista mileages
        prices.append(float(row['price'])) : convierte el valor de 'price' a float y lo añade 
        a la lista prices
        csv es un módulo estándar de Python para manejar archivos CSV (Comma Separated Values)
        DictReader es una clase del módulo csv que lee un archivo CSV y lo convierte en un
        iterable de diccionarios, donde cada fila del archivo se representa como un diccionario
        con las claves siendo los nombres de las columnas. 
        (f) es el archivo abierto en modo lectura.
        """
        with open(filename, 'r') as f:
            reader = csv.DictReader(f)
            for row in reader:
                mileages.append(float(row['km']))
                # Añade el valor de 'km' convertido a float a la lista mileages
                prices.append(float(row['price']))
                # Añade el valor de 'price' convertido a float a la lista prices
        return mileages, prices
    except FileNotFoundError:
        print(f"Error: No se encuentra el archivo '{filename}'")
        sys.exit(1)
    except (ValueError, KeyError) as e:
        """
        ValueError: ocurre si la conversión a float falla (datos no numéricos)
        KeyError: ocurre si las claves 'km' o 'price' no existen en el archivo CSV
        Ambas son funciones propias de Python para manejar errores específicos 
        y mostrar mensajes adecuados.
        e : variable que captura la excepción ocurrida, permitiendo mostrar detalles del error
        como parte del mensaje de error. 
        ej "Error al leer datos: could not convert string to float: 'abc'
        """
        print(f"Error al leer datos: {e}")
        sys.exit(1)


def load_thetas(filename='thetas.txt'):
    """
    Carga los parámetros theta0 y theta1.
    load_thetas: función que lee los parámetros theta0 y theta1 desde un archivo de texto
    Si el archivo no existe, retorna valores por defecto (0.0, 0.0)
    load_thetas se encuentra definida también en train.py, pero se repite aquí para mantener
    la independencia del script de visualización.
    0.0: valor por defecto para theta0 y theta1 si el archivo no existe o hay un error al leerlo
    """
    if not os.path.exists(filename):
        print(f"Advertencia: No se encuentra '{filename}'. Usando valores por defecto (0, 0).")
        print("Ejecuta 'python3 train.py' primero para entrenar el modelo.")
        return 0.0, 0.0
    
    try:
        """
        Intenta abrir el archivo y leer los valores de theta0 y theta1.
        Si hay un error al leer los valores (por ejemplo, formato incorrecto),
        maneja la excepción mostrando un mensaje de error y retornando valores por defecto.
        """
        with open(filename, 'r') as f:
            lines = f.readlines()
            theta0 = float(lines[0].strip())    # Lee y convierte a float el primer valor (theta0)
            theta1 = float(lines[1].strip())    # Lee y convierte a float el segundo valor (theta1)
            # strip(): elimina espacios en blanco y saltos de línea alrededor del texto
            return theta0, theta1
    except (IOError, ValueError, IndexError) as e:
        print(f"Error al leer thetas: {e}")
        return 0.0, 0.0


def estimate_price(mileage, theta0, theta1):
    """
    Calcula el precio estimado.
    estimate_price: función que calcula el precio estimado dado un kilometraje
    y los parámetros theta0 y theta1 usando la fórmula de regresión lineal.
    El precio estimado se calcula como: precio = θ₀ + θ₁ * kilometraje
    y viene dado por los parámetros theta0 (θ₀) y theta1 (θ₁), almacenados en 
    el archivo 'thetas.txt', creado durante el entrenamiento del modelo.
    """
    return theta0 + (theta1 * mileage)


def plot_data_and_regression(mileages, prices, theta0, theta1):
    """
    Crea un gráfico con los datos y la línea de regresión.
    plot_data_and_regression: función que genera un gráfico de dispersión
    con los puntos de datos originales y la línea de regresión lineal.
    mileages: lista de kilometrajes
    prices: lista de precios
    theta0: parámetro que representa la intersección con el eje Y
    theta1: parámetro que representa la pendiente de la línea
    """
    # Configurar el gráfico
    plt.figure(figsize=(12, 7))
    """
    plt.figure(figsize=(12, 7)): crea una nueva figura (ventana) para el gráfico con un tamaño
    de 12 pulgadas de ancho por 7 pulgadas de alto. La pulgada es la unidad por defecto
    en matplotlib para definir el tamaño de las figuras, es un estándar en diseño 
    gráfico y tipografía heredado por matplotlib.
    """
    
    # Plotear los puntos de datos originales
    plt.scatter(mileages, prices, color='blue', alpha=0.6, s=50, 
                label='Datos originales', edgecolors='black', linewidth=0.5)
    """
    plt.scatter(...): crea un gráfico de dispersión (scatter plot) con los puntos
    de datos originales.
    color='blue': color de los puntos
    alpha=0.6: transparencia de los puntos (0 es totalmente transparente, 1 es opaco)
    s=50: tamaño de los puntos
    label='Datos originales': etiqueta para la leyenda del gráfico
    edgecolors='black': color del borde de los puntos
    linewidth=0.5: grosor del borde de los puntos
    0.5: valor que define el grosor del borde de los puntos en el gráfico
    """
    
    # Crear la línea de regresión
    min_mileage = min(mileages)
    max_mileage = max(mileages)
    """
    min_mileage: variable que almacena el valor mínimo de la lista mileages
    max_mileage: variable que almacena el valor máximo de la lista mileages
    min(): función incorporada en Python que retorna el valor mínimo de una lista
    max(): función incorporada en Python que retorna el valor máximo de una lista
    """
    
    # Puntos para la línea
    line_mileages = [min_mileage, max_mileage]
    """
    line_mileages: lista que contiene los dos extremos del rango de kilometraje
    que se utilizarán para dibujar la línea de regresión. Es el eje X de la línea.
    """
    line_prices = [estimate_price(m, theta0, theta1) for m in line_mileages]
    """
    line_prices: lista que contiene los precios estimados correspondientes
    a los extremos del rango de kilometraje, calculados usando la función
    estimate_price. Es el eje Y de la línea.
    """
    
    # Plotear la línea de regresión
    plt.plot(line_mileages, line_prices, color='red', linewidth=2, 
             label=f'Regresión lineal\n(θ₀={theta0:.2f}, θ₁={theta1:.6f})')
    """
    plt.plot(...): dibuja la línea de regresión lineal en el gráfico.
    color='red': color de la línea
    linewidth=2: grosor de la línea
    label=f'Regresión lineal\n(θ₀={theta0:.2f}, θ₁={theta1:.6f})': 
        etiqueta para la leyenda del gráfico.
    """
    
    # Añadir líneas de cuadrícula
    plt.grid(True, alpha=0.3, linestyle='--')
    """
    plt.grid(...): añade una cuadrícula al gráfico para mejorar la legibilidad.
    True: activa la cuadrícula
    alpha=0.3: define la transparencia de las líneas de la cuadrícula
    linestyle='--': estilo de las líneas de la cuadrícula (líneas discontinuas)
    """
    
    # Etiquetas y título
    plt.xlabel('Kilometraje (km)', fontsize=12, fontweight='bold')
    plt.ylabel('Precio (€)', fontsize=12, fontweight='bold')
    plt.title('Regresión Lineal: Precio vs Kilometraje', 
              fontsize=14, fontweight='bold', pad=20)
    """
    plt.xlabel y plt.ylabel: establecen las etiquetas de los ejes X e Y respectivamente.
    fontsize especifica el tamaño de la fuente de las etiquetas.
    fontweight='bold' hace que las etiquetas sean negritas.
    plt.title: establece el título del gráfico que aparece en la parte superior.
    pad=20: añade un espacio adicional entre el título y el gráfico para mejorar la apariencia
    """
    
    # Leyenda
    plt.legend(loc='upper right', fontsize=10, framealpha=0.9)
    """
    plt.legend(...): añade una leyenda al gráfico para identificar los elementos.
    loc='upper right': posición de la leyenda en la esquina superior derecha del gráfico
    fontsize=10: tamaño de la fuente de la leyenda
    framealpha=0.9: transparencia del fondo de la leyenda (1 es opaco, 0 es transparente)
    La leyenda ayuda a identificar qué representan los diferentes colores y estilos
    en el gráfico, mejorando la comprensión visual de los datos presentados.
    """
    
    # Ajustar el layout
    plt.tight_layout()
    """
    plt.tight_layout(): ajusta automáticamente los elementos del gráfico
    para que no se solapen y se vean correctamente. En concreto, ajusta los márgenes
    y el espacio entre los elementos del gráfico (títulos, etiquetas, leyendas, etc.)
    para mejorar la presentación visual.
    tight_layout es un método de matplotlib que optimiza el diseño del gráfico.
    """
    
    # Mostrar el gráfico
    print("\n📈 Mostrando visualización...")
    plt.show()
    """
    plt.show(): muestra el gráfico generado en una ventana emergente.
    Esta función es esencial para visualizar el gráfico después de haberlo configurado
    con todos los elementos necesarios (puntos, líneas, etiquetas, etc.).
    """


def main():
    """
    Función principal.
    """
    print("=== Visualización de Regresión Lineal ===\n")
    
    # Cargar datos
    print("\n📊 Cargando datos...")
    mileages, prices = load_data('data.csv')
    print(f"✅ {len(mileages)} muestras cargadas")
    
    # Cargar thetas
    theta0, theta1 = load_thetas()
    print(f"✅ Parámetros cargados: θ₀={theta0:.2f}, θ₁={theta1:.6f}")
    
    # Crear visualización
    plot_data_and_regression(mileages, prices, theta0, theta1)
    """
    plot_data_and_regression(...): llama a la función para crear y mostrar
    el gráfico con los datos y la línea de regresión.
    mileages: lista de kilometrajes
    prices: lista de precios
    theta0: parámetro que representa la intersección con el eje Y
    theta1: parámetro que representa la pendiente de la línea
    """


if __name__ == "__main__":
    main()
"""
Si el script es ejecutado directamente (no importado como módulo), llama a la función main().
Sirve para iniciar la ejecución del programa cuando se corre el archivo. En caso de que el archivo
sea importado como módulo en otro script, la función main() no se ejecutará automáticamente.
"""
