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
    
    # Abre el archivo de historial en modo lectura.
    # with open(...): contexto que asegura que el archivo se cierre automáticamente
    # después de su uso, evitando fugas de recursos.
    # f: objeto archivo que permite leer el contenido del archivo línea por línea.
    try:
        with open(filename, 'r') as f:
            # Lee cada línea del archivo, convierte el valor a float y lo almacena en una lista.
            # line.strip(): elimina espacios en blanco y saltos de línea al inicio y final de cada línea.
            # La condición 'if line.strip()' asegura que no se incluyan líneas vacías en la lista.
            mse_values = [float(line.strip()) for line in f if line.strip()]
        
        if len(mse_values) == 0:
            print("Error: El archivo de historial está vacío.")
            sys.exit(1)
        
        return mse_values
    
    # Maneja errores de lectura o conversión de datos.
    # IOError: error relacionado con la entrada/salida del archivo.
    # ValueError: error que ocurre si la conversión a float falla.
    # e: variable que contiene el mensaje de error específico.
    except (IOError, ValueError) as e:
        print(f"Error al leer historial: {e}")
        sys.exit(1)


def plot_learning_curve(mse_history):
    """
    Crea un gráfico de la curva de aprendizaje.
    range(1, len(mse_history) + 1): crea un rango que va desde 1 
    hasta el número total de iteraciones, que corresponde a la 
    longitud del historial de MSE. Esta secuencia se utiliza como eje x en el gráfico.
    """
    # Genera una secuencia de números para las iteraciones.
    iterations = range(1, len(mse_history) + 1)
    
    # Crear figura con tamaño amplio
    # plt.figure(figsize=(14, 8)): crea una nueva figura para el gráfico
    # con un tamaño específico de 14 pulgadas de ancho por 8 pulgadas de alto.
    plt.figure(figsize=(14, 8))
    
    # Gráfico principal: Curva completa
    # plt.subplot(2, 1, 1): crea un subgráfico en una figura dividida en 2 filas y 1 columna,
    # y selecciona el primer subgráfico para dibujar la curva completa del MSE.
    plt.subplot(2, 1, 1)
    
    # plt.plot(...): dibuja una línea en el gráfico
    # color, linewidth, label: personalizan el aspecto y etiqueta de la línea
    plt.plot(iterations, mse_history, color='#2E86AB', linewidth=2, label='MSE')
    
    # Configurar etiquetas y título
    plt.xlabel('Iteración', fontsize=12, fontweight='bold')
    plt.ylabel('MSE (Error Cuadrático Medio)', fontsize=12, fontweight='bold')
    plt.title('Curva de Aprendizaje - Convergencia del Gradiente Descendente', 
              fontsize=14, fontweight='bold', pad=15)
    plt.grid(True, alpha=0.3, linestyle='--')
    plt.legend(loc='upper right', fontsize=11)
    
    # Añadir información de convergencia
    # Calcula la mejora porcentual del MSE desde el inicio hasta el final del entrenamiento.
    initial_mse = mse_history[0]    # Primer valor de MSE
    final_mse = mse_history[-1]     # -1 para acceder al último elemento de la lista
    improvement = ((initial_mse - final_mse) / initial_mse) * 100
    
    # Prepara el texto informativo para mostrar en el gráfico
    info_text = f'MSE inicial: {initial_mse:.6f}\n'
    info_text += f'MSE final: {final_mse:.6f}\n'
    info_text += f'Mejora: {improvement:.2f}%'
    
    # Añade un cuadro de texto al gráfico con la información de convergencia
    plt.text(0.02, 0.98, info_text, transform=plt.gca().transAxes,
             fontsize=10, verticalalignment='top',
             bbox=dict(boxstyle='round', facecolor='wheat', alpha=0.5))
    
    # Gráfico secundario: Primeras 100 iteraciones (zoom)
    plt.subplot(2, 1, 2)
    
    # Define el rango para el zoom en las primeras 100 iteraciones
    zoom_range = min(100, len(mse_history))
    
    # Dibuja la línea del zoom con los primeros valores del MSE
    plt.plot(range(1, zoom_range + 1), mse_history[:zoom_range], 
             color='#A23B72', linewidth=2, label='MSE (primeras iteraciones)')
    
    # Configurar etiquetas y título del zoom
    plt.xlabel('Iteración', fontsize=12, fontweight='bold')
    plt.ylabel('MSE', fontsize=12, fontweight='bold')
    plt.title('Zoom: Convergencia Inicial (Primeras 100 iteraciones)', 
              fontsize=12, fontweight='bold', pad=10)
    plt.grid(True, alpha=0.3, linestyle='--')
    plt.legend(loc='upper right', fontsize=11)
    
    # Resaltar punto de convergencia aproximado
    # Convergencia: cuando el cambio es < 1% del MSE
    # El bucle busca la primera iteración donde el cambio en el MSE
    # es menor al 1% del valor actual del MSE
    converged_at = None
    for i in range(1, len(mse_history)):
        if i >= zoom_range:
            break
        change = abs(mse_history[i] - mse_history[i-1])
        if change < mse_history[i] * 0.01:  # 1% de cambio
            converged_at = i
            break
    
    # Si se encuentra convergencia, dibuja una línea vertical en esa iteración
    if converged_at:
        plt.axvline(x=converged_at, color='red', linestyle='--', alpha=0.7,
                    label=f'Convergencia aprox. (iter {converged_at})')
        plt.legend(loc='upper right', fontsize=10)
    
    # Ajustar layout automáticamente
    plt.tight_layout()
    
    # Mostrar información en consola
    print("\n✅ Curva de aprendizaje generada")
    print(f"  • Iteraciones totales: {len(mse_history)}")
    print(f"  • MSE inicial: {initial_mse:.6f}")
    print(f"  • MSE final: {final_mse:.6f}")
    print(f"  • Reducción del error: {improvement:.2f}%")
    
    if converged_at:
        print(f"  • Convergencia alcanzada en ~{converged_at} iteraciones")
    
    print("\n📊 Mostrando visualización...")
    plt.show()

def main():
    """
    Función principal.
    """
    print("=== Curva de Aprendizaje - Análisis de Convergencia ===\n")
    
    print("📊 Cargando historial de entrenamiento...")
    # load_mse_history(): carga el historial de MSE desde el archivo
    mse_history = load_mse_history()
    print(f"✅ {len(mse_history)} valores de MSE cargados")
    
    # Crear y mostrar visualización
    plot_learning_curve(mse_history)


# Si el script es ejecutado directamente (no importado como módulo), llama a main()
if __name__ == "__main__":
    main()
