#!/usr/bin/env python3
"""
Programa bonus para visualizar la curva de aprendizaje.
Muestra cómo evoluciona el MSE (Error Cuadrático Medio) durante el entrenamiento,
demostrando la convergencia del algoritmo de gradiente descendente.
"""

import sys
import os

try:
    import matplotlib.pyplot as plt
except ImportError:
    print("Error: Se requiere matplotlib para la visualización.")
    print("Instala con: pip install matplotlib")
    sys.exit(1)


def load_mse_history(filename='mse_history.txt'):
    """
    Carga el historial de MSE del entrenamiento.
    """
    if not os.path.exists(filename):
        print(f"Error: No se encuentra '{filename}'")
        print("Debes ejecutar 'python3 train.py' primero para generar el historial.")
        sys.exit(1)
    
    try:
        with open(filename, 'r') as f:
            mse_values = [float(line.strip()) for line in f if line.strip()]
        
        if len(mse_values) == 0:
            print("Error: El archivo de historial está vacío.")
            sys.exit(1)
        
        return mse_values
    
    except (IOError, ValueError) as e:
        print(f"Error al leer historial: {e}")
        sys.exit(1)


def plot_learning_curve(mse_history):
    """
    Crea un gráfico de la curva de aprendizaje.
    """
    iterations = range(1, len(mse_history) + 1)
    
    # Crear figura con tamaño amplio
    plt.figure(figsize=(14, 8))
    
    # Gráfico principal: Curva completa
    plt.subplot(2, 1, 1)
    plt.plot(iterations, mse_history, color='#2E86AB', linewidth=2, label='MSE')
    plt.xlabel('Iteración', fontsize=12, fontweight='bold')
    plt.ylabel('MSE (Error Cuadrático Medio)', fontsize=12, fontweight='bold')
    plt.title('Curva de Aprendizaje - Convergencia del Gradiente Descendente', 
              fontsize=14, fontweight='bold', pad=15)
    plt.grid(True, alpha=0.3, linestyle='--')
    plt.legend(loc='upper right', fontsize=11)
    
    # Añadir información de convergencia
    initial_mse = mse_history[0]
    final_mse = mse_history[-1]
    improvement = ((initial_mse - final_mse) / initial_mse) * 100
    
    info_text = f'MSE inicial: {initial_mse:.6f}\n'
    info_text += f'MSE final: {final_mse:.6f}\n'
    info_text += f'Mejora: {improvement:.2f}%'
    
    plt.text(0.02, 0.98, info_text, transform=plt.gca().transAxes,
             fontsize=10, verticalalignment='top',
             bbox=dict(boxstyle='round', facecolor='wheat', alpha=0.5))
    
    # Gráfico secundario: Primeras 100 iteraciones (zoom)
    plt.subplot(2, 1, 2)
    zoom_range = min(100, len(mse_history))
    plt.plot(range(1, zoom_range + 1), mse_history[:zoom_range], 
             color='#A23B72', linewidth=2, label='MSE (primeras iteraciones)')
    plt.xlabel('Iteración', fontsize=12, fontweight='bold')
    plt.ylabel('MSE', fontsize=12, fontweight='bold')
    plt.title('Zoom: Convergencia Inicial (Primeras 100 iteraciones)', 
              fontsize=12, fontweight='bold', pad=10)
    plt.grid(True, alpha=0.3, linestyle='--')
    plt.legend(loc='upper right', fontsize=11)
    
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
    
    if converged_at:
        plt.axvline(x=converged_at, color='red', linestyle='--', alpha=0.7,
                    label=f'Convergencia aprox. (iter {converged_at})')
        plt.legend(loc='upper right', fontsize=10)
    
    # Ajustar layout
    plt.tight_layout()
    
    # Mostrar
    print("\n✓ Curva de aprendizaje generada")
    print(f"  • Iteraciones totales: {len(mse_history)}")
    print(f"  • MSE inicial: {initial_mse:.6f}")
    print(f"  • MSE final: {final_mse:.6f}")
    print(f"  • Reducción del error: {improvement:.2f}%")
    
    if converged_at:
        print(f"  • Convergencia alcanzada en ~{converged_at} iteraciones")
    
    print("\nMostrando visualización...")
    plt.show()


def main():
    """
    Función principal.
    """
    print("=== Curva de Aprendizaje - Análisis de Convergencia ===\n")
    
    print("Cargando historial de entrenamiento...")
    mse_history = load_mse_history()
    print(f"✓ {len(mse_history)} valores de MSE cargados")
    
    # Crear visualización
    plot_learning_curve(mse_history)


if __name__ == "__main__":
    main()
