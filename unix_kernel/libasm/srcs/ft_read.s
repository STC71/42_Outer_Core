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
