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
