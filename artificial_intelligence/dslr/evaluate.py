"""
Evaluador de predicciones DSLR.
Coloca estos archivos en la misma carpeta que `houses.csv` y `dataset_truth.csv`.

Uso:
    $ python evaluate.py
"""
from __future__ import print_function  # Compatibilidad Python 2/3
import csv  # Para leer archivos CSV
import sys  # Para salir del programa si hay errores
import os.path  # Para verificar existencia de archivos


def load_csv(filename):
    """
    Cargar archivo CSV y retornar lista con datos (etiquetas o predicciones).
    filename: ruta al archivo CSV
    Retorna lista de etiquetas de casas.
    """
    datas = list()  # Inicializar lista vacía
    with open(filename, 'r') as opened_csv:  # Abrir archivo
        read_csv = csv.reader(opened_csv, delimiter=',')  # Lector CSV
        for line in read_csv:  # Para cada fila
            datas.append(line[1])  # Añadir segunda columna (casa)
    # Limpiar celda de encabezado
    datas.remove("Hogwarts House")  # Eliminar encabezado
    return datas  # Retornar lista de casas

if __name__ == '__main__':  # Si se ejecuta como script
    # Cargar verdades del dataset
    if os.path.isfile("dataset_truth.csv"):  # Si existe archivo de verdades
        truths = load_csv("dataset_truth.csv")  # Cargar etiquetas verdaderas
    else:  # Si no existe
        sys.exit("Error: falta dataset_truth.csv en el directorio actual.")
    
    # Cargar predicciones
    if os.path.isfile("houses.csv"):  # Si existe archivo de predicciones
        predictions = load_csv("houses.csv")  # Cargar predicciones
    else:  # Si no existe
        sys.exit("Error: falta houses.csv en el directorio actual.")
    
    # Comparar cada valor y contar coincidencias
    count = 0  # Contador de aciertos
    if len(truths) == len(predictions):  # Si tienen mismo tamaño
        for i in range(len(truths)):  # Para cada ejemplo
            if truths[i] == predictions[i]:  # Si predicción correcta
                count += 1  # Incrementar contador de aciertos
    
    # Calcular puntuación (accuracy)
    score = float(count) / len(truths)  # Aciertos / total
    print("Your score on test set: %.3f" % score)  # Mostrar puntuación
    
    # Mensaje según puntuación
    if score >= .98:  # Si accuracy >= 98%
        print("Good job! Mc Gonagall congratulates you.")  # Felicitación
    else:  # Si accuracy < 98%
        print("Too bad, Mc Gonagall flunked you.")  # Suspenso

