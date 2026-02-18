#!/usr/bin/env python3
"""
DSLR - data_preprocessing.py
Utilidades de limpieza y preprocesamiento de datos para el proyecto DSLR.

Características:
- Manejar valores faltantes (NaN)
- Normalización de características (Min-Max y Z-score)
- Selección de características
- División de datos
"""

import csv  # Para leer y escribir archivos CSV
import sys  # Para manejo de errores y argumentos


def parse_float(value):
    """
    Convertir cadena a float de forma segura.
    Retorna None si no es posible la conversión.
    """
    try:  # Intentar conversión
        return float(value)
    except (ValueError, TypeError):  # Si hay error
        return None  # Retornar None


def read_csv(filename):
    """
    Leer archivo CSV y extraer encabezados y datos.
    filename: ruta al archivo CSV
    Retorna tupla (headers, data) donde:
    - headers: lista de nombres de columnas
    - data: diccionario {columna: [valores]}
    """
    try:  # Intentar abrir archivo
        with open(filename, 'r') as f:  # Abrir en modo lectura
            reader = csv.reader(f)  # Crear lector CSV
            headers = next(reader)  # Leer primera fila (encabezados)
            # next() obtiene la siguiente línea del iterador
            
            # Inicializar diccionario con listas vacías para cada columna
            data = {header: [] for header in headers}  # Dict comprehension
            
            # Leer todas las filas restantes
            for row in reader:  # Para cada fila
                for i, value in enumerate(row):  # enumerate da (indice, valor)
                    if i < len(headers):  # Verificar índice válido
                        data[headers[i]].append(value)  # Añadir valor a columna
        
        return headers, data  # Retornar encabezados y datos
    
    except FileNotFoundError:  # Si archivo no existe
        print(f"Error: Archivo '{filename}' no encontrado", file=sys.stderr)
        sys.exit(1)  # Salir con error
    except Exception as e:  # Cualquier otro error
        print(f"Error leyendo archivo: {e}", file=sys.stderr)
        sys.exit(1)  # Salir con error


def is_numerical_column(column_data):
    """
    Verificar si una columna contiene datos numéricos.
    Intenta convertir el primer valor no vacío a float.
    """
    for value in column_data:  # Para cada valor
        if value and value.strip():  # Si no está vacío
            try:  # Intentar conversión
                float(value)  # Convertir a float
                return True  # Es numérica
            except ValueError:  # Si falla
                return False  # No es numérica
    return False  # Si no hay valores, no es numérica


def calculate_mean(values):
    """
    Calcular la media de valores numéricos, ignorando None.
    values: lista de valores que puede contener None
    Retorna la media o None si no hay valores válidos.
    """
    clean_values = [v for v in values if v is not None]  # Filtrar None
    if len(clean_values) == 0:  # Si no hay valores válidos
        return None  # Retornar None
    return sum(clean_values) / len(clean_values)  # Retornar promedio


def calculate_median(values):
    """
    Calcular la mediana de valores numéricos, ignorando None.
    La mediana es el valor central cuando los datos están ordenados.
    values: lista de valores que puede contener None
    Retorna la mediana o None si no hay valores válidos.
    """
    clean_values = [v for v in values if v is not None]  # Filtrar None
    if len(clean_values) == 0:  # Si no hay valores válidos
        return None  # Retornar None
    sorted_values = sorted(clean_values)  # Ordenar valores
    n = len(sorted_values)  # Número de valores
    if n % 2 == 0:  # Si es par
        # Mediana = promedio de los dos valores centrales
        return (sorted_values[n//2 - 1] + sorted_values[n//2]) / 2
    else:  # Si es impar
        return sorted_values[n//2]  # Mediana = valor central


def impute_missing_values(data, numerical_features, method='mean'):
    """
    Llenar valores faltantes con la media o mediana.
    La imputación reemplaza valores None/NaN con un valor estadístico representativo.
    Esto es necesario porque los algoritmos de ML no pueden trabajar con valores faltantes.
    
    Args:
        data: Diccionario columna -> lista de valores
        numerical_features: Lista de nombres de características numéricas
        method: 'mean' (media) o 'median' (mediana)
    
    Returns:
        Diccionario con valores imputados (sin None)
    """
    imputed_data = {}  # Diccionario para datos imputados
    
    for feature in numerical_features:  # Para cada característica numérica
        # Convertir valores a float
        values = [parse_float(v) for v in data[feature]]
        
        # Calcular valor de relleno según el método elegido
        if method == 'mean':  # Si se elige media
            fill_value = calculate_mean(values)  # Calcular promedio
            # La media es sensible a outliers pero usa toda la información
        elif method == 'median':  # Si se elige mediana
            fill_value = calculate_median(values)  # Calcular mediana
            # La mediana es robusta a outliers (valores extremos)
        else:  # Si el método no es reconocido
            fill_value = 0.0  # Usar 0 como valor por defecto
        
        # Imputar valores faltantes reemplazándolos con fill_value
        imputed_values = []  # Lista para valores imputados
        for v in values:  # Para cada valor
            if v is None:  # Si el valor está faltante
                imputed_values.append(fill_value)  # Reemplazar con fill_value
            else:  # Si el valor existe
                imputed_values.append(v)  # Mantener valor original
        
        imputed_data[feature] = imputed_values  # Guardar valores imputados
    
    return imputed_data  # Retornar diccionario con datos completos


def normalize_minmax(values):
    """
    Normalización Min-Max: escalar valores al rango [0, 1].
    Fórmula: valor_normalizado = (valor - mínimo) / (máximo - mínimo)
    Esta normalización preserva la distribución original de los datos.
    Útil cuando necesitas que todos los valores estén en el mismo rango.
    
    Args:
        values: Lista de valores numéricos (puede contener None)
    
    Returns:
        Tupla (valores_normalizados, mínimo, máximo)
    """
    # Filtrar valores None para cálculos
    clean_values = [v for v in values if v is not None]
    if len(clean_values) == 0:  # Si no hay valores válidos
        return values  # Retornar sin cambios
    
    # Encontrar valores mínimo y máximo
    min_val = min(clean_values)  # Valor mínimo de la característica
    max_val = max(clean_values)  # Valor máximo de la característica
    
    # Evitar división por cero si todos los valores son iguales
    if max_val == min_val:  # Si no hay variación
        return [0.5 for _ in values]  # Retornar todos 0.5 (punto medio)
    
    # Aplicar normalización Min-Max a cada valor
    normalized = []  # Lista para valores normalizados
    for v in values:  # Para cada valor
        if v is None:  # Si está faltante
            normalized.append(None)  # Mantener como None
        else:  # Si tiene valor
            # Fórmula: (v - min) / (max - min) mapea [min, max] a [0, 1]
            normalized.append((v - min_val) / (max_val - min_val))
    
    return normalized, min_val, max_val  # Retornar valores normalizados y parámetros


def normalize_zscore(values):
    """
    Normalización Z-score: escalar valores para tener media=0 y desviación estándar=1.
    Fórmula: valor_normalizado = (valor - media) / desviación_estándar
    Esta normalización estandariza los datos en términos de desviaciones de la media.
    Útil para comparar características en diferentes escalas.
    Mejora la convergencia de algoritmos de gradiente descendente.
    
    Args:
        values: Lista de valores numéricos (puede contener None)
    
    Returns:
        Tupla (valores_normalizados, media, desviación_estándar)
    """
    # Filtrar valores None para cálculos
    clean_values = [v for v in values if v is not None]
    if len(clean_values) == 0:  # Si no hay valores válidos
        return values  # Retornar sin cambios
    
    # Calcular media (promedio)
    mean = sum(clean_values) / len(clean_values)  # Media = suma / cantidad
    
    # Calcular desviación estándar
    # Varianza = promedio de las desviaciones al cuadrado
    variance = sum((v - mean) ** 2 for v in clean_values) / len(clean_values)
    std = variance ** 0.5  # Desviación estándar = raíz de varianza
    # std mide qué tan dispersos están los valores respecto a la media
    
    # Evitar división por cero si todos los valores son iguales
    if std == 0:  # Si no hay variación
        return [0.0 for _ in values]  # Retornar todos 0
    
    # Aplicar normalización Z-score a cada valor
    normalized = []  # Lista para valores normalizados
    for v in values:  # Para cada valor
        if v is None:  # Si está faltante
            normalized.append(None)  # Mantener como None
        else:  # Si tiene valor
            # Fórmula: (v - media) / std convierte a "número de desviaciones estándar desde la media"
            normalized.append((v - mean) / std)
    
    return normalized, mean, std  # Retornar valores normalizados y parámetros


def preprocess_data(filename, selected_features=None, normalization='minmax', 
                   imputation='mean'):
    """
    Pipeline completo de preprocesamiento de datos.
    Combina todos los pasos necesarios para preparar datos para machine learning:
    1. Leer datos del CSV
    2. Identificar características numéricas
    3. Convertir a float
    4. Imputar valores faltantes
    5. Normalizar características
    
    Args:
        filename: Ruta al archivo CSV
        selected_features: Lista de nombres de características a usar (None = usar todas las numéricas)
        normalization: 'minmax' (escalar a [0,1]) o 'zscore' (estandarizar)
        imputation: 'mean' (media) o 'median' (mediana) para valores faltantes
    
    Returns:
        Diccionario con datos preprocesados y metadatos:
        - features: características normalizadas
        - labels: etiquetas de casas
        - feature_names: nombres de características usadas
        - normalization_method: método de normalización usado
        - normalization_params: parámetros de normalización
        - n_samples: número de muestras
    """
    headers, data = read_csv(filename)  # Leer archivo CSV
    
    # Identificar características numéricas (excluir columnas no relevantes)
    excluded_columns = ['Index', 'Hogwarts House', 'First Name', 'Last Name', 
                       'Birthday', 'Best Hand']  # Columnas a excluir
    
    # Filtrar solo columnas numéricas
    all_numerical_features = []  # Lista para características numéricas
    for header in headers:  # Para cada encabezado
        # Si no está excluida y es numérica
        if header not in excluded_columns and is_numerical_column(data[header]):
            all_numerical_features.append(header)  # Añadir a lista
    
    # Usar características seleccionadas o todas las numéricas
    if selected_features is None:  # Si no se especificaron características
        selected_features = all_numerical_features  # Usar todas
    
    # Convertir valores a float
    float_data = {}  # Diccionario para datos convertidos a float
    for feature in selected_features:  # Para cada característica seleccionada
        # Convertir cada valor a float (retorna None si no es convertible)
        float_data[feature] = [parse_float(v) for v in data[feature]]
    
    # Imputar valores faltantes (reemplazar None con estadística)
    imputed_data = impute_missing_values(float_data, selected_features, 
                                        method=imputation)
    # Después de esto, no debería haber valores None
    
    # Normalizar características
    normalized_data = {}  # Diccionario para datos normalizados
    normalization_params = {}  # Diccionario para parámetros de normalización
    
    for feature in selected_features:  # Para cada característica
        if normalization == 'minmax':  # Si se elige normalización Min-Max
            # Normalizar a rango [0, 1]
            norm_values, min_val, max_val = normalize_minmax(imputed_data[feature])
            normalized_data[feature] = norm_values  # Guardar valores normalizados
            # Guardar parámetros para normalizar datos de prueba de la misma manera
            normalization_params[feature] = {'min': min_val, 'max': max_val}
        elif normalization == 'zscore':  # Si se elige normalización Z-score
            # Estandarizar: media=0, std=1
            norm_values, mean, std = normalize_zscore(imputed_data[feature])
            normalized_data[feature] = norm_values  # Guardar valores normalizados
            # Guardar parámetros para normalizar datos de prueba
            normalization_params[feature] = {'mean': mean, 'std': std}
        else:  # Si no se reconoce el método de normalización
            # No normalizar, usar datos imputados directamente
            normalized_data[feature] = imputed_data[feature]
            normalization_params[feature] = {}  # Sin parámetros
    
    # Obtener etiquetas (casas de Hogwarts)
    labels = data.get('Hogwarts House', [])  # Lista de casas
    
    # Retornar diccionario con todos los datos y metadatos
    return {
        'features': normalized_data,              # Datos normalizados
        'labels': labels,                         # Etiquetas de casas
        'feature_names': selected_features,       # Nombres de características
        'normalization_method': normalization,    # Método usado
        'normalization_params': normalization_params,  # Parámetros para datos futuros
        'n_samples': len(labels)                  # Número de muestras
    }


def save_preprocessed_data(preprocessed_data, output_filename):
    """
    Guardar datos preprocesados en archivo CSV.
    Escribe un CSV con las etiquetas y características normalizadas.
    
    Args:
        preprocessed_data: Diccionario retornado por preprocess_data
        output_filename: Nombre del archivo de salida
    """
    # Extraer componentes del diccionario de datos preprocesados
    feature_names = preprocessed_data['feature_names']  # Nombres de características
    labels = preprocessed_data['labels']  # Etiquetas de casas
    features = preprocessed_data['features']  # Características normalizadas
    
    with open(output_filename, 'w', newline='') as f:  # Abrir archivo en modo escritura
        writer = csv.writer(f)  # Crear escritor CSV
        
        # Escribir encabezados (casa + nombres de características)
        writer.writerow(['Hogwarts House'] + feature_names)
        # ['Hogwarts House'] + feature_names concatena listas
        
        # Escribir filas (una por estudiante)
        n_samples = preprocessed_data['n_samples']  # Número de muestras
        for i in range(n_samples):  # Para cada muestra
            row = [labels[i]]  # Comenzar con la etiqueta (casa)
            for feature in feature_names:  # Para cada característica
                value = features[feature][i]  # Obtener valor normalizado
                # Formatear con 6 decimales o vacío si es None
                row.append(f"{value:.6f}" if value is not None else "")
                # .6f formatea float con 6 decimales
            writer.writerow(row)  # Escribir fila completa
    
    print(f"Datos preprocesados guardados en: {output_filename}")  # Confirmar guardado


def main():
    """
    Función principal para probar el preprocesamiento de datos.
    Lee un CSV, aplica preprocesamiento y guarda el resultado.
    """
    if len(sys.argv) < 2:  # Si no se proporciona archivo de entrada
        print("Uso: python data_preprocessing.py <dataset.csv> [salida.csv]")
        print("Ejemplo: python data_preprocessing.py dataset_train.csv preprocessed_train.csv")
        sys.exit(1)  # Salir con error
    
    # Extraer argumentos de línea de comandos
    filename = sys.argv[1]  # Archivo de entrada
    # Usar segundo argumento o nombre por defecto
    output_filename = sys.argv[2] if len(sys.argv) > 2 else 'preprocessed_data.csv'
    
    # Mostrar información de configuración
    print("Preprocesando datos...")
    print(f"Entrada: {filename}")
    print(f"Normalización: minmax")  # Método de normalización
    print(f"Imputación: media")  # Método de imputación
    
    # Ejecutar pipeline de preprocesamiento
    preprocessed = preprocess_data(filename, normalization='minmax', imputation='mean')
    
    # Mostrar información sobre las características procesadas
    print(f"\nCaracterísticas usadas ({len(preprocessed['feature_names'])}):")
    for feat in preprocessed['feature_names']:  # Para cada característica
        print(f"  - {feat}")  # Imprimir nombre
    
    print(f"\nNúmero de muestras: {preprocessed['n_samples']}")
    
    # Guardar datos preprocesados en archivo
    save_preprocessed_data(preprocessed, output_filename)


if __name__ == "__main__":
    main()  # Ejecutar función principal si se ejecuta como script
    # __name__ == "__main__" es True solo cuando el archivo se ejecuta directamente
