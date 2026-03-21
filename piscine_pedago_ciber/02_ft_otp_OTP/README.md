# 🔐 ft_otp - Contraseña de Un Solo Uso Basada en Tiempo

**Versión**: 1.00  
**Tipo de Proyecto**: Implementación TOTP  
**Cita**: "Nada dura para siempre..."

## 📋 Tabla de Contenidos
- [Descripción General](#descripción-general)
- [El Problema con las Contraseñas](#el-problema-con-las-contraseñas)
- [¿Qué es TOTP?](#qué-es-totp)
- [Requisitos del Programa](#requisitos-del-programa)
- [Uso](#uso)
- [Especificaciones Técnicas](#especificaciones-técnicas)
- [Guía de Implementación](#guía-de-implementación)
- [Validación](#validación)
- [Funcionalidades Bonus](#funcionalidades-bonus)

---

## 🎯 Descripción General

Implementar un sistema **TOTP (Contraseña de Un Solo Uso Basada en Tiempo)** capaz de generar contraseñas efímeras a partir de una clave maestra. El sistema debe ser funcional para uso diario y estar basado en el estándar RFC 6238.

**Funcionalidad Principal:**
- Almacenar clave maestra cifrada
- Generar contraseñas de un solo uso basadas en tiempo
- Producir códigos de 6 dígitos que expiran automáticamente

---

## 🔑 El Problema con las Contraseñas

Las contraseñas tradicionales son uno de los mayores dolores de cabeza en seguridad informática:

| Problema | Descripción |
|---------|-------------|
| 🤦 **Olvidadas** | Los usuarios olvidan constantemente sus contraseñas |
| 🔓 **Compartidas** | Las contraseñas se comparten con otras personas |
| ♻️ **Reutilizadas** | Misma contraseña en múltiples servicios |
| 😱 **Débiles** | Los usuarios eligen contraseñas terriblemente inseguras |
| 💥 **Filtradas** | Eventualmente expuestas en brechas de seguridad |

### La Solución: Contraseñas de Un Solo Uso

**OTPs basadas en tiempo** que:
- ⏰ **Expiran** después de unos minutos
- 🚫 Se vuelven **inválidas** automáticamente
- 🛡️ **Reducen** el riesgo de compromiso de credenciales
- 🔄 **Cambian** constantemente basándose en el tiempo

---

## 📖 ¿Qué es TOTP?

**TOTP (Contraseña de Un Solo Uso Basada en Tiempo)** es un algoritmo que genera una contraseña única usando:
1. Una **clave secreta compartida** (almacenada de forma segura)
2. La **hora actual** (sincronizada)
3. Hash criptográfico **HMAC-SHA1**

**Cómo funciona:**
```
Clave Secreta + Marca de Tiempo Actual → HMAC → código de 6 dígitos
```

La misma clave + mismo tiempo = mismo código (sincronizado entre cliente y servidor).

**Estándares:**
- **RFC 6238**: Especificación TOTP
- **RFC 4226**: Algoritmo base HOTP (OTP basado en HMAC)

---

## 💻 Requisitos del Programa

### Nombre del Ejecutable
```
ft_otp
```

### Lenguaje
Cualquier lenguaje de programación de tu elección.

### Restricciones de Librerías
- ✅ **Permitido**: Librerías que faciliten la implementación del algoritmo (crypto, HMAC)
- ✅ **Permitido**: Librerías/funciones para acceder a la hora del sistema
- ❌ **PROHIBIDO**: Librerías TOTP completas que hagan todo el trabajo

**Debes implementar la lógica principal tú mismo.**

---

## 🚀 Uso

### Modo 1: Generación de Clave (`-g`)

Almacenar una clave maestra de forma segura en formato cifrado.

**Comando:**
```bash
./ft_otp -g <archivo_clave>
```

**Funcionalidad:**
- Recibe una **clave hexadecimal** de al menos **64 caracteres** como argumento
- Almacena la clave **de forma segura y cifrada** en un archivo llamado `ft_otp.key`

**Validación:**
- Si la clave tiene menos de 64 caracteres hexadecimales → **Error**

**Ejemplo:**
```bash
# Clave inválida (demasiado corta)
$ echo -n "NEVER GONNA GIVE YOU UP" > key.txt
$ ./ft_otp -g key.txt
./ft_otp: error: key must be 64 hexadecimal characters.

# Clave válida (64 caracteres hex)
$ cat key.hex | wc -c
64
$ ./ft_otp -g key.hex
Key was successfully saved in ft_otp.key.
```

### Modo 2: Generación de Contraseña (`-k`)

Generar una nueva contraseña temporal.

**Comando:**
```bash
./ft_otp -k <archivo_clave>
```

**Funcionalidad:**
- Genera una **nueva contraseña temporal** basada en la clave almacenada
- Imprime la contraseña en **salida estándar**

**Formato de Contraseña:**
- Exactamente **6 dígitos**
- Basada en tiempo (cambia cada 30 segundos típicamente)
- Apariencia aleatoria pero determinista

**Ejemplo:**
```bash
$ ./ft_otp -k ft_otp.key
836492

$ sleep 60
$ ./ft_otp -k ft_otp.key
123518
```

---

## 🔐 Especificaciones Técnicas

### Detalles del Algoritmo

#### HOTP (Contraseña de Un Solo Uso Basada en HMAC)
Según RFC 4226:
```
HOTP(K, C) = Truncate(HMAC-SHA-1(K, C))
```
- **K**: Clave secreta compartida
- **C**: Contador (para TOTP, derivado del tiempo)

#### TOTP (OTP Basada en Tiempo)
Según RFC 6238:
```
TOTP = HOTP(K, T)
donde T = floor((Tiempo Unix Actual - T0) / X)
```
- **T0**: Tiempo Unix para empezar a contar (típicamente 0)
- **X**: Paso de tiempo (típicamente 30 segundos)

### Formatos de Archivo

#### Archivo de Clave de Entrada (`key.hex`)
```
# Formato: Caracteres hexadecimales
# Longitud: Mínimo 64 caracteres
# Caracteres válidos: 0-9, A-F (sin distinción entre mayúsculas y minúsculas)
# Ejemplo:
48656c6c6f576f726c6448656c6c6f576f726c6448656c6c6f576f726c6448656c6c6f576f726c64
```

#### Archivo de Clave Cifrada (`ft_otp.key`)
- **Formato binario** (cifrado)
- Generado por la opción `-g`
- Contiene la clave maestra cifrada
- Leído por la opción `-k`

#### Formato de Salida
```
# Siempre 6 dígitos
# Formato: NNNNNN
# Rango: 000000 - 999999
# Ejemplos:
123456
000123
999999
```

---

## 🛠️ Guía de Implementación

### Implementación Paso a Paso

#### 1. Analizar Argumentos de Línea de Comandos
```python
# Pseudocódigo
if arg == "-g":
    modo_generar_clave(archivo_clave)
elif arg == "-k":
    modo_generar_contraseña(archivo_clave)
else:
    imprimir_error_uso()
```

#### 2. Validar Clave Hexadecimal
```python
def validar_clave_hex(clave):
    # Eliminar espacios en blanco
    clave = clave.strip()
    
    # Comprobar longitud
    if len(clave) < 64:
        error("key must be 64 hexadecimal characters")
    
    # Comprobar formato hex
    if not all(c in '0123456789ABCDEFabcdef' for c in clave):
        error("key must contain only hex characters")
    
    return clave
```

#### 3. Cifrar y Almacenar Clave
```python
def almacenar_clave_cifrada(clave_hex, archivo_salida):
    # Convertir hex a bytes
    bytes_clave = bytes.fromhex(clave_hex)
    
    # Cifrar (tu método de elección)
    cifrada = cifrar(bytes_clave, contraseña/sal)
    
    # Escribir a archivo
    with open(archivo_salida, 'wb') as f:
        f.write(cifrada)
    
    print("Key was successfully saved in ft_otp.key.")
```

#### 4. Implementar Algoritmo HOTP
```python
import hmac
import hashlib

def hotp(clave, contador):
    # HMAC-SHA1
    h = hmac.new(clave, contador.to_bytes(8, 'big'), hashlib.sha1)
    resultado_hmac = h.digest()
    
    # Truncamiento dinámico
    offset = resultado_hmac[-1] & 0x0F
    codigo = (
        (resultado_hmac[offset] & 0x7F) << 24 |
        resultado_hmac[offset + 1] << 16 |
        resultado_hmac[offset + 2] << 8 |
        resultado_hmac[offset + 3]
    )
    
    # Devolver 6 dígitos
    return codigo % 1000000
```

#### 5. Implementar TOTP
```python
import time

def totp(clave, paso_tiempo=30, t0=0):
    # Calcular contador de tiempo
    tiempo_actual = int(time.time())
    contador = (tiempo_actual - t0) // paso_tiempo
    
    # Generar HOTP con contador de tiempo
    return hotp(clave, contador)
```

#### 6. Generar y Mostrar Contraseña
```python
def generar_contraseña(archivo_clave):
    # Leer y descifrar clave
    clave = leer_clave_cifrada(archivo_clave)
    
    # Generar TOTP
    contraseña = totp(clave)
    
    # Formatear como 6 dígitos
    print(f"{contraseña:06d}")
```

---

## ✅ Validación

### Usando Oathtool

Verifica tu implementación contra el estándar `oathtool`:

```bash
# Generar contraseña con tu programa
$ ./ft_otp -k ft_otp.key
123456

# Verificar con oathtool
$ oathtool --totp $(cat key.hex)
123456
```

**¡Deberían coincidir!**

### Otras Herramientas de Validación
- **Google Authenticator** (aplicación móvil)
- **Authy** (móvil/escritorio)
- **1Password** (soporte TOTP)
- Cualquier implementación conforme a RFC 6238

### Procedimiento de Prueba
```bash
# 1. Crear una clave de prueba
$ echo "3132333435363738393031323334353637383930313233343536373839303132" > test.hex

# 2. Almacenarla
$ ./ft_otp -g test.hex
Key was successfully saved in ft_otp.key.

# 3. Generar códigos y comparar
$ ./ft_otp -k ft_otp.key
456789
$ oathtool --totp 3132333435363738393031323334353637383930313233343536373839303132
456789

# 4. Esperar y verificar cambios basados en tiempo
$ sleep 35  # Esperar a la siguiente ventana de tiempo
$ ./ft_otp -k ft_otp.key
234567  # Debería ser diferente
```

---

## 🏆 Funcionalidades Bonus

Los bonus **SOLO** se evaluarán si la parte obligatoria está **PERFECTA**.

### 1. Generación de Código QR
Generar códigos QR para importar fácilmente en aplicaciones móviles de autenticación:

```bash
# Generar código QR con semilla
$ ./ft_otp -g key.hex --qr
Key saved. QR Code:
█████████████████████████████
██ ▄▄▄▄▄ █▀█ █▄▄▀▄█ ▄▄▄▄▄ ██
██ █   █ █▀▀▀█ ▀▀▄█ █   █ ██
...
```

**Formato QR**: `otpauth://totp/Label?secret=BASE32SECRET&issuer=ft_otp`

### 2. Interfaz Gráfica
Crear una GUI para:
- Gestión de claves
- Generación de contraseñas
- Indicador de tiempo restante
- Soporte de múltiples cuentas

**Características de Ejemplo:**
- Temporizador visual de cuenta atrás (30 segundos)
- Botón de copiar al portapapeles
- Lista/gestión de cuentas
- Funcionalidad de importar/exportar

---

## 📦 Estructura del Proyecto

```
03_ft_otp_OTP/
├── README.md
├── .gitignore
├── en.subject.pdf
├── ft_otp*                  # Tu ejecutable
├── ft_otp.key              # Almacenamiento de clave cifrada (generado)
├── test.hex                # Clave de prueba de ejemplo
└── [archivos fuente]       # Tu implementación
```

---

## 🧪 Lista de Verificación de Pruebas

### Pruebas Obligatorias
- [ ] Rechaza claves con < 64 caracteres hex
- [ ] Acepta claves hex válidas de 64+ caracteres
- [ ] Almacena la clave cifrada en `ft_otp.key`
- [ ] Genera contraseñas de exactamente 6 dígitos
- [ ] Las contraseñas cambian con el tiempo
- [ ] Coincide con implementación de referencia (oathtool)
- [ ] Maneja archivos de clave inválidos correctamente
- [ ] Mensajes de error correctos

### Casos Extremos
- [ ] Archivo de clave con espacios/saltos de línea
- [ ] Archivo de clave inexistente
- [ ] Clave cifrada corrupta
- [ ] Hexadecimal mayúsculas/minúsculas
- [ ] Exactamente 64 vs. más caracteres

---

## 📚 Recursos

### Estándares RFC
- [RFC 6238 - TOTP](https://datatracker.ietf.org/doc/html/rfc6238)
- [RFC 4226 - HOTP](https://datatracker.ietf.org/doc/html/rfc4226)

### Herramientas
- **oathtool**: Herramienta TOTP de línea de comandos para validación
- **Google Authenticator**: Aplicación móvil de referencia
- **qrencode**: Generar códigos QR (para bonus)

### Librerías (Ejemplos)
- **Python**: `pyotp`, `hmac`, `hashlib`
- **JavaScript**: `speakeasy`, `otplib`
- **Go**: `github.com/pquerna/otp`
- **Rust**: `totp-rs`

---

## 🎓 Resultados de Aprendizaje

Después de completar este proyecto, comprenderás:
- Internos de autenticación de dos factores (2FA)
- Criptografía basada en HMAC
- Sincronización de tiempo en sistemas distribuidos
- Almacenamiento seguro de claves y cifrado
- Manipulación de marcas de tiempo Unix
- Proceso de implementación de RFC

---

## ⚠️ Notas de Seguridad

1. **Nunca compartas tu clave maestra** - Trátala como una contraseña
2. **Cifra el archivo de clave** - No almacenes claves en texto plano
3. **La sincronización de tiempo importa** - Asegúrate de que el reloj del sistema es preciso
4. **Usa claves fuertes** - Genera claves hex aleatorias, no uses valores predecibles
5. **No registres contraseñas** - Los OTPs generados solo deben mostrarse, nunca almacenarse

---

**Nota**: Este proyecto forma parte de la Piscina de Ciberseguridad de 42. El enunciado completo está disponible en `en.subject.pdf`.
