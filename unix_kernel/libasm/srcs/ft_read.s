; ==============================================================================
; ft_read - Lee datos desde un descriptor de archivo
; ==============================================================================
; Prototipo: ssize_t ft_read(int fd, void *buf, size_t count)
;
; Descripción:
;   Lee hasta 'count' bytes desde el descriptor de archivo 'fd' al buffer
;   'buf'. Maneja errores correctamente estableciendo errno.
;
; Parámetros:
;   rdi - Descriptor de archivo
;   rsi - Puntero al buffer donde almacenar los datos
;   rdx - Número máximo de bytes a leer
;
; Retorno:
;   rax - Número de bytes leídos en caso de éxito (0 indica EOF)
;         -1 en caso de error (errno se establece)
;
; Registros utilizados:
;   rax - Número de syscall (0 para read) / valor de retorno
;   rdi - Parámetro fd (preservado por syscall)
;
; Syscall: read (0)
; ==============================================================================

section .text
	global ft_read
	extern __errno_location

ft_read:
	mov		rax, 0					; Número de syscall para read
	syscall							; Llamar al kernel
	cmp		rax, 0					; Verificar si hubo error (valor negativo)
	jl		.error					; Si hay error, manejarlo
	ret								; Retornar bytes leídos

.error:
	neg		rax							; Convertir código de error a positivo
	mov		rdi, rax					; Guardar código de error
	call	__errno_location wrt ..plt	; Obtener dirección de errno
	mov		[rax], rdi					; Establecer errno
	mov		rax, -1						; Retornar -1
	ret

; ==============================================================================
;
; Las líneas 26, 27 y 28, son directivas de ensamblador que definen la estructura,
; visibilidad y dependencias externas de la función ft_read:
;
;	section .text: Declara la sección de código ejecutable del programa. 
;	En ensamblador, el código se organiza en secciones (.text para código, 
;	.data para datos inicializados, .bss para datos no inicializados).
;
;	global ft_read: Hace que el símbolo ft_read sea visible externamente, 
;	permitiendo que otros archivos objeto (como un código en C) puedan llamar 
;	a esta función durante el enlazado. Sin esta directiva, la función sería local
;	y no accesible desde fuera del archivo.
;
;	extern __errno_location: Declara que __errno_location es una función externa
;	definida en otra librería (glibc). Esta función devuelve la dirección de la
;	variable errno thread-local, necesaria para establecer códigos de error.
;
; En resumen: preparas la sección de código, exportas la función para que pueda 
; ser llamada desde C, e importas la función necesaria para manejar errores.
;
; ==============================================================================
;
; EXPLICACIÓN DETALLADA DE LA IMPLEMENTACIÓN:
;
; Línea 30: mov rax, 0
;   Establece el número de syscall. En Linux x86-64, el syscall 0 corresponde
;   a la llamada al sistema 'read'. Este valor le indica al kernel qué operación
;   debe realizar.
;
; Línea 31: syscall
;   Ejecuta la llamada al sistema. En este momento:
;   - rdi contiene el descriptor de archivo (fd)
;   - rsi contiene el puntero al buffer donde se almacenarán los datos
;   - rdx contiene el número máximo de bytes a leer
;   El kernel ejecuta la operación y retorna en rax:
;   - Un valor >= 0: número de bytes leídos (0 indica fin de archivo - EOF)
;   - Un valor < 0: código de error (valor negativo)
;
; Línea 32: cmp rax, 0
;   Compara el valor de retorno con 0. Esto establece los flags del procesador:
;   - Si rax >= 0: la operación fue exitosa (SF flag = 0)
;   - Si rax < 0: hubo un error (SF flag = 1)
;
; Línea 33: jl .error
;   "Jump if Less" - Salta a .error si rax < 0 (si SF flag = 1).
;   Esto sucede cuando la syscall falló y retornó un código de error negativo.
;
; Línea 34: ret
;   Si no hubo error, retorna directamente. rax contiene el número de bytes leídos.
;   Nota: Un retorno de 0 bytes indica que se alcanzó el final del archivo (EOF),
;   lo cual NO es un error.
;
; ==============================================================================
;
; MANEJO DE ERRORES (.error):
;
; Línea 37: neg rax
;   NEGate - Convierte el código de error de negativo a positivo.
;   Ejemplo: si rax = -13 (EACCES), después de neg rax = 13.
;   Los códigos de error de Linux se definen como números positivos, pero las
;   syscalls los retornan como negativos para distinguirlos de valores válidos.
;
; Línea 38: mov rdi, rax
;   Guarda el código de error positivo en rdi. Necesitamos preservar este valor
;   porque vamos a llamar a __errno_location, que modificará rax.
;
; Línea 39: call __errno_location wrt ..plt
;   Llama a la función __errno_location de glibc, que retorna en rax la dirección
;   de memoria donde se debe almacenar errno para el thread actual.
;   - wrt ..plt: "With Respect To PLT" (Procedure Linkage Table)
;     Es necesario para llamadas a funciones externas en código PIC
;     (Position Independent Code), permitiendo la resolución dinámica de símbolos.
;
; Línea 40: mov [rax], rdi
;   Almacena el código de error (guardado en rdi) en la dirección apuntada por rax
;   (la ubicación de errno). Esto establece la variable errno con el código de error.
;   Los corchetes [rax] indican "escribir en la dirección contenida en rax".
;
; Línea 41: mov rax, -1
;   Establece el valor de retorno a -1, que es el valor estándar que retorna
;   read() en C cuando ocurre un error. El código de error específico puede
;   consultarse examinando errno.
;
; Línea 42: ret
;   Retorna al llamador con -1 en rax.
;
; ==============================================================================
;
; CASOS DE USO Y RETORNOS:
;
; 1. Lectura exitosa:
;    - Retorna: número de bytes leídos (> 0)
;    - errno: no se modifica
;
; 2. Fin de archivo (EOF):
;    - Retorna: 0
;    - errno: no se modifica
;    - Nota: Esto NO es un error, simplemente indica que no hay más datos
;
; 3. Error (archivo no existe, permisos insuficientes, etc.):
;    - Retorna: -1
;    - errno: se establece al código de error específico (EBADF, EACCES, etc.)
;
; 4. Lectura parcial (buffer lleno antes de leer todos los datos):
;    - Retorna: número de bytes realmente leídos
;    - errno: no se modifica
;
; ==============================================================================
;
; CÓDIGOS DE ERROR COMUNES:
;
; - EBADF (9): fd no es un descriptor de archivo válido
; - EFAULT (14): buf apunta fuera del espacio de direcciones accesible
; - EINTR (4): La llamada fue interrumpida por una señal
; - EINVAL (22): fd no es apto para lectura
; - EIO (5): Error de E/S de bajo nivel
; - EISDIR (21): fd se refiere a un directorio
;
; ==============================================================================
