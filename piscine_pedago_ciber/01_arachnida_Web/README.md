# 🕷️ Arachnida - Piscina de Ciberseguridad

**Versión**: 1.00  
**Tipo de Proyecto**: Web Scraping y Análisis de Metadatos

## 📋 Tabla de Contenidos
- [Descripción General](#descripción-general)
- [¿Qué son los Metadatos?](#qué-son-los-metadatos)
- [Programas](#programas)
  - [Spider - Scraper de Imágenes Web](#spider---scraper-de-imágenes-web)
  - [Scorpion - Analizador de Metadatos EXIF](#scorpion---analizador-de-metadatos-exif)
- [Requisitos Técnicos](#requisitos-técnicos)
- [Funcionalidades Bonus](#funcionalidades-bonus)
- [Ejemplos de Uso](#ejemplos-de-uso)

---

## 🎯 Descripción General

Este proyecto te enseña a procesar datos de la web mediante:
1. **Web scraping**: Extraer automáticamente información (imágenes) desde sitios web
2. **Análisis de metadatos**: Manipular y analizar metadatos de archivos de imagen

**Objetivos de aprendizaje**:
- Comprender las peticiones HTTP y rastreo web
- Implementar navegación recursiva
- Analizar y mostrar datos EXIF de imágenes
- Gestionar diferentes formatos de imagen

---

## 📊 ¿Qué son los Metadatos?

Los **metadatos** son información cuyo propósito es describir otros datos ("datos sobre datos"). 

Comúnmente se usan para describir información contenida en imágenes y documentos. Los metadatos pueden revelar información sensible sobre quién creó o manipuló los archivos, incluyendo:
- Fecha y hora de creación
- Información del dispositivo/cámara
- Coordenadas GPS (geoetiquetado)
- Información del autor/propietario
- Software de edición utilizado

---

## 🛠️ Programas

### 🕷️ Spider - Scraper de Imágenes Web

Extrae todas las imágenes de un sitio web de forma recursiva.

#### Sintaxis
```bash
./spider [-rlp] URL
```

#### Opciones

| Opción | Descripción | Por Defecto |
|--------|-------------|-------------|
| `-r` | Descarga imágenes de forma recursiva | - |
| `-l [N]` | Profundidad máxima para la descarga recursiva | 5 |
| `-p [PATH]` | Ruta donde se guardarán los archivos descargados | `./data/` |

#### Extensiones Soportadas
- `.jpg` / `.jpeg`
- `.png`
- `.gif`
- `.bmp`

#### Ejemplo de Uso
```bash
# Descargar imágenes de URL, profundidad máx 3, guardar en ./images/
./spider -r -l 3 -p ./images/ https://ejemplo.com

# Descargar con profundidad por defecto (5) a ruta por defecto (./data/)
./spider -r https://ejemplo.com

# Descargar sin recursión
./spider https://ejemplo.com/imagen.jpg
```

---

### 🦂 Scorpion - Analizador de Metadatos EXIF

Analiza y muestra metadatos EXIF de archivos de imagen.

#### Sintaxis
```bash
./scorpion ARCHIVO1 [ARCHIVO2 ...]
```

#### Funcionalidades
- Compatible con las **mismas extensiones** que spider
- Muestra **atributos básicos** (fecha de creación, etc.)
- Extrae y muestra **datos EXIF**
- **Formato de salida flexible** (a tu elección)

#### Ejemplo de Uso
```bash
# Analizar una sola imagen
./scorpion foto.jpg

# Analizar múltiples imágenes
./scorpion img1.png img2.jpg img3.gif

# Analizar todas las imágenes de un directorio
./scorpion ./data/*.jpg
```

#### Datos EXIF Típicos Mostrados
- Marca y modelo de la cámara
- Fecha y hora  de captura
- Dimensiones de la imagen
- Velocidad ISO
- Tiempo de exposición
- Apertura (número f)
- Coordenadas GPS (si están disponibles)
- Software utilizado

---

## ⚙️ Requisitos Técnicos

### Reglas Generales
1. **Formato**: Los programas pueden ser scripts o binarios
2. **Lenguajes compilados**: Si se usan, incluir todo el código fuente y compilar durante la evaluación
3. **Librerías permitidas**:
   - ✅ Funciones/librerías para peticiones HTTP
   - ✅ Funciones/librerías para manejo de archivos
4. **Lógica principal**: Debe ser desarrollada por ti mismo

### ⚠️ PROHIBIDO (Resulta en Calificación 0)
- Usar `wget` (considerado TRAMPA)
- Usar `scrapy` (considerado TRAMPA)
- La **lógica de cada programa debe ser TU PROPIA implementación**

---

## 🎁 Funcionalidades Bonus

Los bonus **SOLO** se evaluarán si la parte obligatoria está **PERFECTA**.

### Ideas de Bonus
1. **Mejora de Scorpion**: Añadir opción para **modificar/eliminar** metadatos de archivos
   ```bash
   ./scorpion --remove-metadata foto.jpg
   ./scorpion --edit-metadata foto.jpg
   ```

2. **Interfaz Gráfica**: Crear una interfaz gráfica para:
   - Ver metadatos de forma amigable
   - Editar/eliminar metadatos visualmente
   - Explorar imágenes descargadas por spider

⚠️ **IMPORTANTE**: Los bonus no se evalúan a menos que TODOS los requisitos obligatorios estén aprobados sin fallos.

---

## 📦 Estructura del Proyecto

```
01_arachnida_Web/
├── README.md
├── .gitignore
├── en.subject.pdf
├── spider*              # Programa scraper web
├── scorpion*            # Programa analizador de metadatos
├── data/                # Directorio de descarga por defecto
└── [archivos fuente]    # Tus archivos de implementación
```

---

## 🧪 Ejemplos de Uso

### Flujo de Trabajo Completo

```bash
# 1. Descargar imágenes de un sitio web
./spider -r -l 2 -p ./imagenes_descargadas/ https://ejemplo.com

# 2. Analizar imágenes descargadas
./scorpion ./imagenes_descargadas/*.jpg

# 3. Verificar metadatos de imagen específica
./scorpion ./imagenes_descargadas/imagen_sospechosa.png
```

---

## 📝 Notas de Implementación

### Para Spider
- Implementar análisis adecuado de URLs
- Gestionar URLs relativas y absolutas
- Respetar límites de profundidad de recursión
- Crear directorios si no existen
- Gestionar errores HTTP con elegancia
- Evitar descargar duplicados

### Para Scorpion
- Soportar múltiples formatos de imagen
- Gestionar imágenes sin datos EXIF
- Presentar datos en formato legible
- Gestionar archivos corruptos con elegancia

---

## 🔍 Consideraciones de Seguridad y Privacidad

Este proyecto demuestra:
- Lo fácil que es hacer scraping de imágenes de sitios web
- Cuánta información pueden filtrar las imágenes a través de metadatos
- La importancia de eliminar metadatos de imágenes sensibles
- Por qué importa la privacidad de los metadatos

**Recuerda**: Respeta siempre el `robots.txt` de los sitios web y sus términos de servicio al hacer scraping.

---

## 📚 Recursos

- **Estándar EXIF**: [Especificación EXIF 2.32](http://www.cipa.jp/std/documents/e/DC-008-Translation-2019-E.pdf)
- **Protocolo HTTP**: RFC 2616
- **Librerías Python** (si usas Python):
  - `requests` - Librería HTTP
  - `BeautifulSoup4` - Análisis HTML
  - `Pillow` (PIL) - Manejo de imágenes y lectura EXIF
- **Otros Lenguajes**: Consulta documentación para librerías cliente HTTP y analizadores EXIF

---

## 🎓 Resultados de Aprendizaje

Después de completar este proyecto, comprenderás:
- Fundamentos de web scraping
- Algoritmos de navegación recursiva
- Gestión de peticiones HTTP
- Extracción y análisis de metadatos
- Especificaciones de formatos de imagen
- Implicaciones de privacidad de los metadatos

---

**Nota**: Este proyecto forma parte de la Piscina de Ciberseguridad de 42. El enunciado completo está disponible en `en.subject.pdf`.
