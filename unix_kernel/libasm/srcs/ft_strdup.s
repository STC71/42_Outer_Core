; ==============================================================================
; ft_strdup - Duplica una cadena en memoria dinámica
; ==============================================================================
; Prototipo: char *ft_strdup(const char *s)
;
; Descripción:
;   Crea una copia de la cadena 's' en memoria dinámica. La memoria
;   se reserva con malloc y debe ser liberada por el usuario.
;
; Parámetros:
;   rdi - Puntero a la cadena a duplicar
;
; Retorno:
;   rax - Puntero a la nueva cadena duplicada
;         NULL si malloc falla (errno = ENOMEM)
;
; Registros utilizados:
;   rax - Longitud de cadena / puntero a memoria / retorno
;   rdi - Puntero a cadena original / tamaño para malloc / dst
;   rsi - Puntero a cadena original (para strcpy)
;
; Funciones llamadas:
;   ft_strlen - Para calcular longitud de la cadena
;   malloc    - Para reservar memoria
;   ft_strcpy - Para copiar la cadena
; ==============================================================================

section .text
	global ft_strdup
	extern malloc
	extern ft_strlen
	extern ft_strcpy
	extern __errno_location

ft_strdup:
	push	rdi						; Guardar puntero a cadena original
	call	ft_strlen				; Calcular longitud en rax
	inc		rax						; Añadir 1 para '\0'
	mov		rdi, rax				; Pasar tamaño a malloc
	call	malloc wrt ..plt		; Reservar memoria
	cmp		rax, 0					; Verificar si malloc falló
	je		.error					; Si es NULL, manejar error
	mov		rdi, rax				; dst = memoria reservada
	pop		rsi						; src = cadena original
	push	rax						; Guardar dst para retorno
	call	ft_strcpy				; Copiar cadena
	pop		rax						; Restaurar dst
	ret								; Retornar puntero a nueva cadena

.error:
	pop		rdi							; Limpiar stack
	call	__errno_location wrt ..plt	; Obtener dirección de errno
	mov		qword [rax], 12				; Establecer errno = ENOMEM (12)
	xor		rax, rax					; Retornar NULL
	ret

; ==============================================================================
;
; Las líneas 28-33, son directivas de ensamblador que definen la estructura,
; visibilidad y dependencias externas de la función ft_strdup:
;
;	section .text: Declara la sección de código ejecutable del programa. 
;	En ensamblador, el código se organiza en secciones (.text para código, 
;	.data para datos inicializados, .bss para datos no inicializados).
;
;	global ft_strdup: Hace que el símbolo ft_strdup sea visible externamente, 
;	permitiendo que otros archivos objeto (como un código en C) puedan llamar 
;	a esta función durante el enlazado. Sin esta directiva, la función sería local
;	y no accesible desde fuera del archivo.
;
;	extern malloc: Declara que malloc es una función externa definida en la
;	librería estándar de C (libc). Utilizada para reservar memoria dinámica.
;
;	extern ft_strlen: Declara que ft_strlen es una función externa que hemos
;	implementado en otro archivo. Calcula la longitud de la cadena.
;
;	extern ft_strcpy: Declara que ft_strcpy es una función externa que hemos
;	implementado en otro archivo. Copia el contenido de una cadena a otra.
;
;	extern __errno_location: Declara que __errno_location es una función externa
;	de glibc que retorna la dirección de errno thread-local, necesaria para
;	establecer códigos de error.
;
; En resumen: preparas la sección de código, exportas la función para que pueda 
; ser llamada desde C, e importas todas las funciones necesarias para implementar
; la funcionalidad de duplicación de cadenas con gestión de memoria dinámica.
;
; ==============================================================================
;
; EXPLICACIÓN DETALLADA DE LA IMPLEMENTACIÓN:
;
; Línea 35: push rdi
;   Guarda el puntero a la cadena original en el stack. Necesitamos preservarlo
;   porque vamos a modificar rdi al llamar a otras funciones, pero lo necesitaremos
;   más adelante para copiar la cadena.
;   El stack crece hacia abajo: rsp -= 8, [rsp] = rdi
;
; Línea 36: call ft_strlen
;   Llama a nuestra función ft_strlen para calcular la longitud de la cadena.
;   Parámetro: rdi (puntero a la cadena)
;   Retorno: rax (longitud de la cadena sin contar '\0')
;
; Línea 37: inc rax
;   Incrementa la longitud en 1 para incluir espacio para el terminador nulo '\0'.
;   Si strlen retorna 5, necesitamos reservar 6 bytes (5 caracteres + '\0').
;   Equivalente a: rax = rax + 1
;
; Línea 38: mov rdi, rax
;   Pasa el tamaño a reservar como parámetro para malloc.
;   Según la convención de llamada, el primer parámetro va en rdi.
;   rdi ahora contiene el número de bytes a reservar.
;
; Línea 39: call malloc wrt ..plt
;   Llama a malloc de la librería estándar para reservar memoria dinámica.
;   - wrt ..plt: "With Respect To PLT" (Procedure Linkage Table)
;     Necesario para llamadas a funciones externas en código PIC.
;   Parámetro: rdi (tamaño en bytes)
;   Retorno: rax (puntero a memoria reservada, o NULL si falla)
;
; Línea 40: cmp rax, 0
;   Compara el puntero retornado con 0 (NULL).
;   Si malloc no pudo reservar memoria (por ejemplo, memoria insuficiente),
;   retorna NULL. Establece ZF=1 si rax == 0, ZF=0 si rax != 0.
;
; Línea 41: je .error
;   "Jump if Equal" - Salta a .error si rax == 0 (ZF=1).
;   Esto ocurre cuando malloc falló y no hay memoria disponible.
;
; Línea 42: mov rdi, rax
;   Prepara el primer parámetro para ft_strcpy.
;   rdi = dst (destino) = puntero a la memoria recién reservada.
;   Esta será la ubicación donde copiaremos la cadena.
;
; Línea 43: pop rsi
;   Recupera del stack el puntero a la cadena original.
;   rsi = src (fuente) = cadena original a copiar.
;   Según la convención de llamada, el segundo parámetro va en rsi.
;   El stack se ajusta: rsi = [rsp], rsp += 8
;
; Línea 44: push rax
;   Guarda el puntero a la memoria reservada (dst) en el stack.
;   Lo necesitamos preservar porque ft_strcpy podría modificar rax,
;   pero necesitamos retornar este puntero al finalizar.
;
; Línea 45: call ft_strcpy
;   Llama a nuestra función ft_strcpy para copiar la cadena.
;   Parámetros: rdi (dst), rsi (src)
;   Retorno: rax (puntero a dst, pero no lo usamos aquí)
;   Después de esta llamada, la memoria reservada contiene una copia de la cadena.
;
; Línea 46: pop rax
;   Recupera del stack el puntero a la memoria reservada que guardamos antes.
;   Este es el valor que retornaremos (puntero a la nueva cadena duplicada).
;
; Línea 47: ret
;   Retorna al llamador. rax contiene el puntero a la nueva cadena duplicada.
;   El llamador es responsable de liberar esta memoria con free() cuando ya no
;   la necesite, para evitar memory leaks.
;
; ==============================================================================
;
; MANEJO DE ERRORES (.error):
;
; Línea 50: pop rdi
;   Limpia el stack recuperando el puntero a la cadena original que guardamos
;   al inicio. Aunque no lo necesitamos, debemos mantener el stack balanceado.
;   Si no hacemos este pop, el stack quedará desalineado y causará problemas.
;
; Línea 51: call __errno_location wrt ..plt
;   Llama a __errno_location de glibc para obtener la dirección de errno.
;   Retorno: rax = dirección de memoria donde está almacenado errno.
;   Esta función es thread-safe y retorna la ubicación específica del thread actual.
;
; Línea 52: mov qword [rax], 12
;   Establece errno = ENOMEM (12 = "Cannot allocate memory").
;   - qword: Especifica que escribimos 8 bytes (64 bits)
;   - [rax]: Dirección de memoria donde está errno
;   - 12: Código de error ENOMEM (definido en errno.h)
;   Esto informa al programa llamador de que la asignación de memoria falló.
;
; Línea 53: xor rax, rax
;   Pone rax a 0 (NULL). Forma eficiente de establecer un registro a cero.
;   xor rax, rax es más corto (2 bytes) que mov rax, 0 (7 bytes).
;   En C, strdup() retorna NULL cuando falla, indicando error al llamador.
;
; Línea 54: ret
;   Retorna al llamador con NULL en rax, indicando que la duplicación falló.
;   El llamador debe verificar el retorno y consultar errno para detalles.
;
; ==============================================================================
;
; FLUJO COMPLETO DE EJECUCIÓN:
;
; 1. CASO EXITOSO:
;    Cadena original: "Hello" (5 caracteres)
;    a) push rdi              → Guarda puntero a "Hello" en stack
;    b) ft_strlen             → Retorna 5 en rax
;    c) inc rax               → rax = 6 (necesitamos 6 bytes)
;    d) malloc(6)             → Reserva 6 bytes, retorna dirección en rax
;    e) ft_strcpy             → Copia "Hello\0" a la memoria nueva
;    f) ret                   → Retorna puntero a la nueva cadena
;
; 2. CASO DE ERROR (malloc falla):
;    a) push rdi              → Guarda puntero en stack
;    b) ft_strlen             → Calcula longitud
;    c) malloc                → Retorna NULL (sin memoria)
;    d) je .error             → Salta a manejo de error
;    e) errno = ENOMEM        → Establece código de error
;    f) ret NULL              → Retorna NULL indicando fallo
;
; ==============================================================================
;
; GESTIÓN DE MEMORIA Y RESPONSABILIDADES:
;
; IMPORTANTE: Esta función reserva memoria dinámica que DEBE ser liberada.
;
; Ejemplo de uso correcto en C:
;
;   char *original = "Hello, World!";
;   char *copia = ft_strdup(original);
;   
;   if (copia == NULL) {
;       perror("ft_strdup failed");  // Muestra error basado en errno
;       return -1;
;   }
;   
;   // Usar la copia...
;   printf("%s\n", copia);
;   
;   free(copia);  // ¡OBLIGATORIO! Liberar memoria para evitar memory leak
;
; Ejemplo de uso INCORRECTO (memory leak):
;
;   char *copia = ft_strdup("Test");
;   // ... usar copia ...
;   // ¡ERROR! No se llamó a free(copia) → MEMORY LEAK
;
; ==============================================================================
;
; CÓDIGOS DE ERROR:
;
; - ENOMEM (12): No hay suficiente memoria disponible para la operación
;   Causas comunes:
;   * Sistema sin memoria RAM disponible
;   * Límite de memoria del proceso alcanzado
;   * Fragmentación de memoria
;   * Solicitud de tamaño excesivo
;
; ==============================================================================
;
; CONVENCIÓN DE LLAMADA Y STACK:
;
; El uso del stack en esta función es crítico:
;
; Estado inicial:
;   rsp → [dirección de retorno]
;
; Después de push rdi:
;   rsp → [puntero a cadena original]
;         [dirección de retorno]
;
; Después de pop rsi (si malloc exitoso):
;   rsp → [dirección de retorno]
;
; Después de push rax:
;   rsp → [puntero a memoria nueva]
;         [dirección de retorno]
;
; Después de pop rax:
;   rsp → [dirección de retorno]  ← Estado restaurado correctamente
;
; En caso de error, el pop rdi en .error restaura el balance del stack antes
; de retornar, asegurando que el stack quede en el mismo estado que al inicio.
;
; ==============================================================================
