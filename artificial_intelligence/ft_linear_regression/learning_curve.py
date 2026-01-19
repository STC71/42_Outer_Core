#!/usr/bin/env python3
"""
Programa bonus para visualizar la curva de aprendizaje.
Muestra cómo evoluciona el MSE (Error Cuadrático Medio) durante el entrenamiento,
demostrando la convergencia del algoritmo de gradiente descendente.
"""

import sys      # Para manejo de errores y salidas
import os       # Para verificar la existencia de archivos

try:
    import matplotlib.pyplot as plt
    """
    matplotlib.pyplot: módulo de matplotlib utilizado para crear gráficos y visualizaciones.
    Proporciona una interfaz similar a MATLAB para crear figuras, gráficos de líneas,
    histogramas, diagramas de dispersión, etc. En este script, se usa para graficar la curva
    de aprendizaje del MSE durante el entrenamiento del modelo de regresión lineal.
    """
except ImportError:
    print("Error: Se requiere matplotlib para la visualización.")
    print("Instala con: pip install matplotlib")
    sys.exit(1)


def load_mse_history(filename='mse_history.txt'):
    """
    Carga el historial de MSE del entrenamiento.
    """
    if not os.path.exists(filename):
        """
        Verifica si el archivo de historial existe. Si no, muestra un mensaje de error y 
        termina el programa. 
        os.path.exists: función que comprueba si una ruta de archivo o directorio existe 
        en el sistema de archivos; en concreto, verifica la existencia del archivo 
        'mse_history.txt'.
        """
        print(f"Error: No se encuentra '{filename}'")
        print("Debes ejecutar 'python3 train.py' primero para generar el historial.")
        sys.exit(1)
    
    try:
        with open(filename, 'r') as f:
        """
        Abre el archivo de historial en modo lectura.
        with open(...): contexto que asegura que el archivo se cierre automáticamente
        después de su uso, evitando fugas de recursos.
        f: objeto archivo que permite leer el contenido del archivo línea por línea.
        """
            mse_values = [float(line.strip()) for line in f if line.strip()]
            """
            Lee cada línea del archivo, convierte el valor a float y lo almacena en una lista.
            line.strip(): elimina espacios en blanco y saltos de línea al inicio y final de cada línea.
            La condición 'if line.strip()' asegura que no se incluyan líneas vacías en la lista.
            """
        
        if len(mse_values) == 0:
            print("Error: El archivo de historial está vacío.")
            sys.exit(1)
        
        return mse_values
    
    except (IOError, ValueError) as e:
    """
    Maneja errores de lectura o conversión de datos.
    IOError: error relacionado con la entrada/salida del archivo.
    ValueError: error que ocurre si la conversión a float falla.
    e: variable que contiene el mensaje de error específico.
    """
        print(f"Error al leer historial: {e}")
        sys.exit(1)


def plot_learning_curve(mse_history):
    """
    Crea un gráfico de la curva de aprendizaje.
    """
    iterations = range(1, len(mse_history) + 1)
    """
    Genera una secuencia de números para las iteraciones.
    range(1, len(mse_history) + 1): crea un rango que va desde 1 
    hasta el número total de iteraciones, que corresponde a la 
    longitud del historial de MSE.
    Esta secuencia se utiliza como eje x en el gráfico.
    """
    
    # Crear figura con tamaño amplio
    plt.figure(figsize=(14, 8))
    """
    plt.figure(figsize=(14, 8)): crea una nueva figura para el gráfico
    con un tamaño específico de 14 pulgadas de ancho por 8 pulgadas de alto.
    Esto proporciona un espacio amplio para visualizar los datos de manera clara.
    """
    
    # Gráfico principal: Curva completa
    plt.subplot(2, 1, 1)
    """
    plt.subplot(2, 1, 1): crea un subgráfico en una figura dividida en 2 filas y 1 columna,
    y selecciona el primer subgráfico para dibujar la curva completa del MSE.
    2, 1: indica que la figura tendrá 2 filas y 1 columna de subgráficos.
    1: selecciona el primer subgráfico para la siguiente operación de dibujo.
    La figura se divide en dos partes para mostrar tanto la curva completa como un zoom en 
    las primeras iteraciones del entrenamiento que es donde suele ocurrir la mayor parte de 
    la convergencia.
    """
    plt.plot(iterations, mse_history, color='#2E86AB', linewidth=2, label='MSE')
    """
    plt.plot(...): dibuja una línea en el gráfico con los valores de iteraciones en el eje x
    y los valores de mse_history en el eje y.
    color='#2E86AB': especifica el color de la línea utilizando un código hexadecimal.
    linewidth=2: define el grosor de la línea.
    label='MSE': etiqueta la línea para la leyenda del gráfico.
    """
    plt.xlabel('Iteración', fontsize=12, fontweight='bold')
    """
    plt.xlabel(...): establece la etiqueta del eje x del gráfico.
    'Iteración': texto que se mostrará como etiqueta del eje x.
    fontsize=12: tamaño de la fuente de la etiqueta.
    fontweight='bold': estilo de fuente en negrita para resaltar la etiqueta.
    """
    plt.ylabel('MSE (Error Cuadrático Medio)', fontsize=12, fontweight='bold')
    """
    plt.ylabel(...): establece la etiqueta del eje y del gráfico.
    'MSE (Error Cuadrático Medio)': texto que se mostrará como etiqueta del eje y.
    fontsize=12: tamaño de la fuente de la etiqueta.
    fontweight='bold': estilo de fuente en negrita para resaltar la etiqueta.   
    """
    plt.title('Curva de Aprendizaje - Convergencia del Gradiente Descendente', 
              fontsize=14, fontweight='bold', pad=15)
    """
    plt.title(...): establece el título del gráfico.
    'Curva de Aprendizaje - Convergencia del Gradiente Descendente': texto del título.
    fontsize=14: tamaño de la fuente del título.
    fontweight='bold': estilo de fuente en negrita para resaltar el título.
    pad=15: espacio adicional entre el título y el gráfico para mejorar la presentación visual.
    """
    plt.grid(True, alpha=0.3, linestyle='--')
    """
    plt.grid(...): añade una cuadrícula al gráfico para mejorar la legibilidad.
    True: activa la cuadrícula.
    alpha=0.3: establece la transparencia de las líneas de la cuadrícula (0 es totalmente 
    transparente, 1 es opaco).
    linestyle='--': define el estilo de las líneas de la cuadrícula como líneas discontinuas.
    """
    plt.legend(loc='upper right', fontsize=11)
    """
    plt.legend(...): añade una leyenda al gráfico para identificar las líneas.
    loc='upper right': posiciona la leyenda en la esquina superior derecha del gráfico.
    fontsize=11: tamaño de la fuente de la leyenda.
    La leyenda ayuda a identificar qué representa cada línea en el gráfico.
    """
    
    # Añadir información de convergencia
    initial_mse = mse_history[0]    # Primer valor de MSE
    final_mse = mse_history[-1]     # -1 para acceder al último elemento de la lista
    improvement = ((initial_mse - final_mse) / initial_mse) * 100
    """
    Calcula la mejora porcentual del MSE desde el inicio hasta el final del entrenamiento.
    initial_mse: almacena el primer valor del historial de MSE.
    final_mse: almacena el último valor del historial de MSE.
    improvement: calcula y almacena el porcentaje de mejora del MSE.
    ej.: si el MSE inicial es 100 y el final es 20, la mejora será 
    ((100 - 20) / 100) * 100 = 80%
    """
    
    info_text = f'MSE inicial: {initial_mse:.6f}\n'
    info_text += f'MSE final: {final_mse:.6f}\n'
    info_text += f'Mejora: {improvement:.2f}%'
    """
    Prepara el texto informativo para mostrar en el gráfico.
    info_text: cadena de texto que contiene el MSE inicial, final y la mejora porcentual.
    f = string formatting (formateo de cadenas) utilizado para insertar valores en la cadena.
    f'...{value:.6f}': formato para mostrar el valor con 6 decimales.
    f'...{value:.2f}': formato para mostrar el valor con 2 decimales, más el símbolo de porcentaje.
    El texto se mostrará en una caja dentro del gráfico para proporcionar contexto 
    adicional sobre la convergencia.
    """
    
    plt.text(0.02, 0.98, info_text, transform=plt.gca().transAxes,
             fontsize=10, verticalalignment='top',
             bbox=dict(boxstyle='round', facecolor='wheat', alpha=0.5))
    """
    plt.text(...): añade un cuadro de texto al gráfico con la información de convergencia.
    0.02, 0.98: coordenadas normalizadas (0 a 1) para posicionar el texto en el gráfico.
    transform=plt.gca().transAxes: indica que las coordenadas son relativas al área del gráfico;
    plt.gca(): obtiene el eje actual del gráfico donde se añadirá el texto.
    transAxes: transforma las coordenadas al sistema de coordenadas del eje; es decir,
    las coordenadas se interpretan en relación con el área del gráfico.
    fontsize=10: tamaño de la fuente del texto.
    verticalalignment='top': alinea el texto en la parte superior del cuadro.
    bbox=dict(...): define las propiedades del cuadro que contiene el texto.
        boxstyle='round': estilo del cuadro con bordes redondeados.
        facecolor='wheat': color de fondo del cuadro.
        alpha=0.5: transparencia del cuadro (0 es totalmente transparente, 1 es opaco).
    """
    
    # Gráfico secundario: Primeras 100 iteraciones (zoom)
    plt.subplot(2, 1, 2)
    """
    plt.subplot(2, 1, 2): crea un subgráfico en una figura dividida en 2 filas y 1 columna,
    y selecciona el segundo subgráfico para dibujar un zoom en las primeras 100 iteraciones.
    2, 1: indica que la figura tendrá 2 filas y 1 columna de subgráficos.
    2: selecciona el segundo subgráfico para la siguiente operación de dibujo.
    Este subgráfico permite observar con más detalle la convergencia inicial del MSE.
    """
    zoom_range = min(100, len(mse_history))
    """
    Define el rango para el zoom en las primeras 100 iteraciones.
    zoom_range: almacena el número de iteraciones a mostrar en el zoom,
    """
    plt.plot(range(1, zoom_range + 1), mse_history[:zoom_range], 
             color='#A23B72', linewidth=2, label='MSE (primeras iteraciones)')
    """
    plt.plot(...): dibuja una línea en el subgráfico con los valores de las primeras
    iteraciones del MSE.
    range(1, zoom_range + 1): genera una secuencia de números desde 1 hasta zoom_range para 
        el eje x.
    mse_history[:zoom_range]: obtiene los primeros valores del historial de MSE para 
        el eje y.
    color='#A23B72': especifica el color de la línea utilizando un código hexadecimal.
    linewidth=2: define el grosor de la línea.
    label='MSE (primeras iteraciones)': etiqueta la línea para la leyenda del subgráfico.
    """
    plt.xlabel('Iteración', fontsize=12, fontweight='bold')
    """
    plt.xlabel(...): establece la etiqueta del eje x del subgráfico.
    'Iteración': texto que se mostrará como etiqueta del eje x.
    fontsize=12: tamaño de la fuente de la etiqueta.
    fontweight='bold': estilo de fuente en negrita para resaltar la etiqueta.
    """
    plt.ylabel('MSE', fontsize=12, fontweight='bold')
    """
    plt.ylabel(...): establece la etiqueta del eje y del subgráfico.
    'MSE': texto que se mostrará como etiqueta del eje y.
    fontsize=12: tamaño de la fuente de la etiqueta.
    fontweight='bold': estilo de fuente en negrita para resaltar la etiqueta.
    """
    plt.title('Zoom: Convergencia Inicial (Primeras 100 iteraciones)', 
              fontsize=12, fontweight='bold', pad=10)
    plt.grid(True, alpha=0.3, linestyle='--')
    """
    plt.grid(...): añade una cuadrícula al subgráfico para mejorar la legibilidad.
    True: activa la cuadrícula.
    alpha=0.3: establece la transparencia de las líneas de la cuadrícula (0 es totalmente 
    transparente, 1 es opaco).
    linestyle='--': define el estilo de las líneas de la cuadrícula como líneas discontinuas.
    """
    plt.legend(loc='upper right', fontsize=11)
    """
    plt.legend(...): añade una leyenda al subgráfico para identificar las líneas.
    loc='upper right': posiciona la leyenda en la esquina superior derecha del subgráfico.
    fontsize=11: tamaño de la fuente de la leyenda.
    La leyenda ayuda a identificar qué representa cada línea en el subgráfico.
    """
    
    # Resaltar punto de convergencia aproximado
    # Convergencia: cuando el cambio es < 1% del MSE
    converged_at = None
    for i in range(1, len(mse_history)):
        if i >= zoom_range:
            break
        change = abs(mse_history[i] - mse_history[i-1])
        if change < mse_history[i] * 0.01:  # 1% de cambio
            converged_at = i
            break
    """
    None indica que inicialmente no se ha encontrado un punto de convergencia.
    El bucle itera sobre el historial de MSE para encontrar la primera iteración
    donde el cambio en el MSE es menor al 1% del valor actual del MSE.
    Si i es mayor o igual a zoom_range, se detiene el bucle para no exceder
    el rango de zoom. zoom_range: número máximo de iteraciones a considerar para el zoom.
    change: calcula el cambio absoluto entre el MSE de la iteración actual y la
    iteración anterior.
    Si se encuentra tal iteración, se almacena en converged_at y se sale del bucle.
    0.01: representa el 1% en formato decimal. 
    """
    
    if converged_at:
        plt.axvline(x=converged_at, color='red', linestyle='--', alpha=0.7,
                    label=f'Convergencia aprox. (iter {converged_at})')
        plt.legend(loc='upper right', fontsize=10)
    """
    Si se ha encontrado un punto de convergencia, se dibuja una línea vertical
    en esa iteración para resaltarla en el gráfico.
    plt.axvline(...): dibuja una línea vertical en la posición x especificada.
    x=converged_at: posición en el eje x donde se dibuja la línea.
    color='red': color de la línea.
    linestyle='--': estilo de línea discontinua.
    alpha=0.7: transparencia de la línea (0 es totalmente transparente, 1 es opaco).
    label=f'Convergencia aprox. (iter {converged_at})': etiqueta para la leyenda que 
    indica la iteración de convergencia.
    plt.legend(...): añade una leyenda al subgráfico para identificar la línea de convergencia.
    loc='upper right': posiciona la leyenda en la esquina superior derecha del subgráfico.
    fontsize=10: tamaño de la fuente de la leyenda.
    """
    
    # Ajustar layout
    plt.tight_layout()
    """
    plt.tight_layout(): ajusta automáticamente los elementos del gráfico
    para que no se solapen y se vean correctamente. En concreto, ajusta los márgenes
    y el espacio entre los elementos del gráfico (títulos, etiquetas, leyendas, etc.)
    para mejorar la presentación visual.
    tight_layout es un método de matplotlib que optimiza el diseño del gráfico.
    """
    
    # Mostrar
    print("\n✓ Curva de aprendizaje generada")
    print(f"  • Iteraciones totales: {len(mse_history)}")
    print(f"  • MSE inicial: {initial_mse:.6f}")
    print(f"  • MSE final: {final_mse:.6f}")
    print(f"  • Reducción del error: {improvement:.2f}%")
    # Muestra información relevante sobre la curva de aprendizaje en la consola.
    
    if converged_at:
        print(f"  • Convergencia alcanzada en ~{converged_at} iteraciones")
    
    print("\nMostrando visualización...")
    plt.show()
    # plt.show(): muestra el gráfico generado en una ventana emergente.

def main():
    """
    Función principal.
    """
    print("=== Curva de Aprendizaje - Análisis de Convergencia ===\n")
    
    print("Cargando historial de entrenamiento...")
    mse_history = load_mse_history()
    """
    load_mse_history(): carga el historial de MSE desde el archivo 'mse_history.txt'.
    mse_history: lista que contiene los valores de MSE leídos del archivo.
    """
    print(f"✓ {len(mse_history)} valores de MSE cargados")
    
    # Crear visualización
    plot_learning_curve(mse_history)
    """
    plot_learning_curve(mse_history): crea y muestra la curva de aprendizaje
    utilizando los valores de MSE proporcionados.
    mse_history: lista que contiene los valores de MSE para graficar.
    """

if __name__ == "__main__":
    main()
"""
Si el script es ejecutado directamente (no importado como módulo), llama a la función main().
Sirve para iniciar la ejecución del programa cuando se corre el archivo. En caso de que el 
archivo sea importado como módulo en otro script, la función main() no se ejecutará 
automáticamente
"""
