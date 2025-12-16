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
