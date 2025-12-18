; ==============================================================================
; ft_write - Escribe datos en un descriptor de archivo
; ==============================================================================
; Prototipo: ssize_t ft_write(int fd, const void *buf, size_t count)
;
; Descripción:
;   Escribe hasta 'count' bytes desde el buffer 'buf' al descriptor de
;   archivo 'fd'. Maneja errores correctamente estableciendo errno.
;
; Parámetros:
;   rdi - Descriptor de archivo
;   rsi - Puntero al buffer de datos
;   rdx - Número de bytes a escribir
;
; Retorno:
;   rax - Número de bytes escritos en caso de éxito
;         -1 en caso de error (errno se establece)
;
; Registros utilizados:
;   rax - Número de syscall (1 para write) / valor de retorno
;   rdi - Parámetro fd (preservado por syscall)
;
; Syscall: write (1)
; ==============================================================================

section .text
	global ft_write
	extern __errno_location

ft_write:
	mov		rax, 1					; Número de syscall para write
	syscall							; Llamar al kernel
	cmp		rax, 0					; Verificar si hubo error (valor negativo)
	jl		.error					; Si hay error, manejarlo
	ret								; Retornar bytes escritos

.error:
	neg		rax							; Convertir código de error a positivo
	mov		rdi, rax					; Guardar código de error
	call	__errno_location wrt ..plt	; Obtener dirección de errno
	mov		[rax], rdi					; Establecer errno
	mov		rax, -1						; Retornar -1
	ret

; ==============================================================================
;
; Las líneas 27 y 28, son directivas de ensamblador que definen la estructura 
; y visibilidad de la función ft_write:
;
;	section .text: Declara la sección de código ejecutable del programa. 
;	En ensamblador, el código se organiza en secciones (.text para código, 
;	.data para datos inicializados, .bss para datos no inicializados).
;
;	global ft_write: Hace que el símbolo ft_write sea visible externamente, 
;	permitiendo que otros archivos objeto (como un código en C) puedan llamar 
;	a esta función durante el enlazado. Sin esta directiva, la función sería local
;	y no accesible desde fuera del archivo.
;
;	extern __errno_location: Declara que __errno_location es una función externa
;	definida en otra biblioteca (glibc). Esta función devuelve la dirección de la
;	variable errno del hilo actual, necesaria para manejar errores correctamente.
;
; En resumen: preparas la sección de código, exportas ft_write y declaras la
; dependencia externa para manejo de errores.
; ______________________________________________________________________________
;
; Las líneas 31 a 35, implementan la llamada al sistema (syscall) para write:
;
;	ft_write: Es la etiqueta que marca el inicio de la función. 
;	Esta es la dirección a la que se salta cuando se llama a ft_write.
;
;	mov rax, 1: Establece el número de syscall en rax. En Linux x86-64, el
;	syscall número 1 corresponde a write. Otros syscalls comunes:
;	- 0 = read
;	- 1 = write
;	- 2 = open
;	- 3 = close
;	- 60 = exit
;
;	syscall: Instrucción especial que transfiere el control al kernel de Linux.
;	Los parámetros ya están correctamente posicionados según la System V ABI:
;	- rdi = fd (descriptor de archivo)
;	- rsi = buf (puntero al buffer)
;	- rdx = count (número de bytes)
;	El kernel ejecuta la operación write y devuelve el resultado en rax.
;
;	cmp rax, 0: Compara el valor de retorno con 0. Si rax es negativo, indica
;	que hubo un error. Si es >= 0, indica el número de bytes escritos exitosamente.
;
;	jl .error: "Jump if Less" - Salta a .error si rax < 0 (hubo error).
;	La bandera SF (Sign Flag) se establece cuando el resultado es negativo.
;
;	ret: Si no hubo error, retorna inmediatamente con el número de bytes
;	escritos en rax.
; ______________________________________________________________________________
;
; Las líneas 37 a 42, manejan los errores estableciendo errno:
;
;	.error: Etiqueta local para el manejo de errores cuando write falla.
;
;	neg rax: "Negate" - Convierte el código de error a positivo. Linux devuelve
;	errores como valores negativos (ej: -1, -2, -13). neg rax calcula -rax,
;	convirtiendo el valor negativo en positivo para almacenar en errno.
;	Ejemplo: si rax = -13 (EACCES), después de neg será rax = 13.
;
;	mov rdi, rax: Guarda el código de error (ahora positivo) en rdi. Necesitamos
;	preservarlo porque la siguiente llamada a función podría modificar rax.
;
;	call __errno_location wrt ..plt: Llama a la función de glibc que devuelve
;	la dirección de la variable errno del hilo actual. 
;	- wrt ..plt: "With Respect To PLT" - Usa la tabla PLT (Procedure Linkage Table)
;	  para resolver la dirección de la función externa en tiempo de ejecución.
;	- La función retorna en rax un puntero a errno.
;
;	mov [rax], rdi: Escribe el código de error en la ubicación apuntada por errno.
;	[rax] es la dirección de errno, y rdi contiene el código de error.
;	Esto establece errno = código_de_error.
;
;	mov rax, -1: Establece el valor de retorno a -1, indicando error según la
;	especificación POSIX de write().
;
;	ret: Retorna al código llamador con -1 en rax y errno establecido.
; ______________________________________________________________________________
;
; Códigos de error comunes de write():
;	EBADF (9)    - fd no es un descriptor de archivo válido
;	EFAULT (14)  - buf apunta fuera del espacio de direcciones accesible
;	EINVAL (22)  - fd está asociado a un objeto no apropiado para escritura
;	ENOSPC (28)  - No hay espacio en el dispositivo
;	EPIPE (32)   - fd está conectado a un pipe cuyo extremo de lectura está cerrado
;	EAGAIN (11)  - El archivo está marcado como no bloqueante y la escritura bloquearía
;
; Nota sobre seguridad de hilos (thread-safety):
;
;	__errno_location devuelve la dirección de errno específica del hilo actual,
;	haciendo que esta implementación sea thread-safe. Cada hilo tiene su propia
;	copia de errno, evitando condiciones de carrera (race condition).
;
;	Race condition = Múltiples hilos acceden a datos compartidos → resultado impredecible
;	Solución en ft_write: Usar __errno_location que da a cada hilo su propio errno, 
;	evitando que se pisen entre sí.
;
; ==============================================================================
