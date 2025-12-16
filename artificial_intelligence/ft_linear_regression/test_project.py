#!/usr/bin/env python3
"""
Script de prueba para validar que el proyecto cumple con todos los requisitos.
"""

import os
import sys


def print_header(text):
    """Imprime un encabezado formateado."""
    print("\n" + "="*70)
    print(f"  {text}")
    print("="*70 + "\n")


def check_file_exists(filename):
    """Verifica si un archivo existe."""
    exists = os.path.exists(filename)
    status = "✓" if exists else "✗"
    print(f"{status} {filename}")
    return exists


def test_basic_requirements():
    """Verifica los requisitos básicos del proyecto."""
    print_header("VERIFICANDO REQUISITOS BÁSICOS")
    
    files_to_check = [
        ('data.csv', True),
        ('predict.py', True),
        ('train.py', True),
        ('visualize.py', False),
        ('precision.py', False),
    ]
    
    all_ok = True
    for filename, mandatory in files_to_check:
        exists = check_file_exists(filename)
        if mandatory and not exists:
            all_ok = False
    
    return all_ok


def test_prediction_without_training():
    """Prueba predicción sin entrenamiento previo."""
    print_header("TEST 1: Predicción sin entrenamiento")
    print("Cuando no hay entrenamiento, θ0 = 0 y θ1 = 0")
    print("Por lo tanto, cualquier predicción debe ser 0")
    
    # Eliminar thetas.txt si existe
    if os.path.exists('thetas.txt'):
        os.remove('thetas.txt')
        print("✓ Archivo thetas.txt eliminado para la prueba")
    
    # Crear script de prueba
    test_cmd = "echo '100000' | python3 predict.py"
    print(f"\nEjecutando: {test_cmd}")
    os.system(test_cmd)


def test_training():
    """Prueba el entrenamiento del modelo."""
    print_header("TEST 2: Entrenamiento del modelo")
    
    print("Ejecutando train.py...\n")
    result = os.system("python3 train.py")
    
    if result == 0:
        print("\n✓ Entrenamiento completado exitosamente")
        
        # Verificar que se creó thetas.txt
        if os.path.exists('thetas.txt'):
            print("✓ Archivo thetas.txt creado")
            with open('thetas.txt', 'r') as f:
                lines = f.readlines()
                theta0 = float(lines[0].strip())
                theta1 = float(lines[1].strip())
                print(f"  θ0 = {theta0}")
                print(f"  θ1 = {theta1}")
                
                # Verificar que los valores no son 0
                if theta0 != 0 or theta1 != 0:
                    print("✓ Los parámetros han sido entrenados (no son 0)")
                else:
                    print("✗ ADVERTENCIA: Los parámetros siguen siendo 0")
        else:
            print("✗ ERROR: No se creó thetas.txt")
    else:
        print("✗ ERROR: El entrenamiento falló")


def test_predictions():
    """Prueba predicciones con diferentes valores."""
    print_header("TEST 3: Predicciones con modelo entrenado")
    
    test_values = [50000, 100000, 150000, 200000]
    
    for km in test_values:
        cmd = f"echo '{km}' | python3 predict.py"
        print(f"\nPrueba con {km} km:")
        os.system(cmd)


def test_precision():
    """Prueba el cálculo de precisión."""
    print_header("TEST 4: Cálculo de precisión (BONUS)")
    
    if os.path.exists('precision.py'):
        print("Ejecutando precision.py...\n")
        os.system("python3 precision.py")
    else:
        print("✗ precision.py no encontrado")


def test_formulas():
    """Verifica que se usan las fórmulas correctas."""
    print_header("VERIFICACIÓN DE FÓRMULAS")
    
    print("Verificando que train.py usa las fórmulas especificadas...")
    
    required_patterns = [
        'estimatePrice',
        'theta0',
        'theta1',
        'learning_rate',
        'mileage'
    ]
    
    try:
        with open('train.py', 'r') as f:
            content = f.read()
            
        for pattern in required_patterns:
            if pattern in content:
                print(f"✓ Contiene '{pattern}'")
            else:
                print(f"✗ No contiene '{pattern}'")
    except FileNotFoundError:
        print("✗ train.py no encontrado")


def main():
    """Función principal."""
    print("\n" + "="*70)
    print("  FT_LINEAR_REGRESSION - SUITE DE PRUEBAS")
    print("="*70)
    
    # Cambiar al directorio correcto si es necesario
    script_dir = os.path.dirname(os.path.abspath(__file__))
    os.chdir(script_dir)
    
    # Ejecutar pruebas
    test_basic_requirements()
    test_prediction_without_training()
    test_training()
    test_predictions()
    test_precision()
    test_formulas()
    
    print_header("PRUEBAS COMPLETADAS")
    print("Revisa los resultados anteriores para verificar que todo funciona correctamente.")
    print("\nPara usar el proyecto:")
    print("  1. Entrenar: python3 train.py")
    print("  2. Predecir: python3 predict.py")
    print("  3. Visualizar (bonus): python3 visualize.py")
    print("  4. Precisión (bonus): python3 precision.py")
    print()


if __name__ == "__main__":
    main()
