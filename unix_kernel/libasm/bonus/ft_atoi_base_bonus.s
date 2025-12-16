; ==============================================================================
; ft_atoi_base - Convierte string a entero en base específica
; ==============================================================================
; Prototipo: int ft_atoi_base(char *str, char *base)
;
; Descripción:
;   Convierte la parte inicial de la cadena str a una representación
;   entera según la base proporcionada. Maneja espacios en blanco iniciales
;   y signos +/-. La base debe ser válida (sin duplicados, sin +/-, al menos 2 chars).
;
; Parámetros:
;   rdi (r12) - Puntero a la cadena a convertir
;   rsi (r13) - Puntero a la cadena de base
;
; Retorno:
;   rax - El número convertido, o 0 si la base es inválida
;
; Validación de base:
;   - Longitud mínima: 2 caracteres
;   - No puede contener: '+', '-', o espacios en blanco
;   - No puede tener caracteres duplicados
;
; Registros utilizados:
;   r12 - Puntero a str (modificado al saltar espacios y signos)
;   r13 - Puntero a base
;   r14 - Resultado acumulado
;   r15 - Indicador de signo (0=positivo, 1=negativo)
;   rbx - Longitud de la base
; ==============================================================================

section .text
	global ft_atoi_base

ft_atoi_base:
	push	rbx
	push	r12
	push	r13
	push	r14
	push	r15
	
	mov		r12, rdi				; r12 = str
	mov		r13, rsi				; r13 = base
	xor		r14, r14				; r14 = resultado (inicializado a 0)
	xor		r15, r15				; r15 = signo (0 = positivo)
	
	call	.check_base				; Validar base y obtener longitud
	cmp		rax, 0
	jle		.return_zero			; Base inválida, retornar 0
	mov		rbx, rax				; rbx = longitud de base
	
	call	.skip_whitespace		; Saltar espacios en blanco
	call	.handle_sign			; Procesar signos +/-
	call	.convert				; Convertir número
	
	cmp		r15, 1					; Verificar si es negativo
	jne		.return
	neg		r14						; Aplicar signo negativo

.return:
	mov		rax, r14				; Retornar resultado
	pop		r15
	pop		r14
	pop		r13
	pop		r12
	pop		rbx
	ret

.return_zero:
	xor		rax, rax				; Retornar 0
	pop		r15
	pop		r14
	pop		r13
	pop		r12
	pop		rbx
	ret

; ------------------------------------------------------------------------------
; Subrutina: check_base
; Valida la base y retorna su longitud
; Retorno: rax = longitud de base (0 si es inválida)
; ------------------------------------------------------------------------------
.check_base:
	xor		rax, rax				; Contador de longitud
	xor		rcx, rcx				; Índice
.check_loop:
	movzx	edx, byte [r13 + rcx]	; Leer carácter de base
	cmp		dl, 0
	je		.check_done				; Fin de cadena
	cmp		dl, '+'
	je		.check_invalid			; '+' no permitido
	cmp		dl, '-'
	je		.check_invalid			; '-' no permitido
	cmp		dl, ' '
	jle		.check_invalid			; Espacios/control no permitidos
	
	; Verificar duplicados
	push	rcx
	inc		rcx
.dup_loop:
	movzx	edi, byte [r13 + rcx]	; Leer siguiente carácter
	cmp		dil, 0
	je		.dup_ok					; No hay más caracteres
	cmp		dl, dil
	je		.check_invalid_pop		; Duplicado encontrado
	inc		rcx
	jmp		.dup_loop
.dup_ok:
	pop		rcx
	inc		rcx
	jmp		.check_loop
.check_invalid_pop:
	pop		rcx
.check_invalid:
	xor		rax, rax
	ret
.check_done:
	cmp		rcx, 2					; Longitud mínima = 2
	jl		.check_invalid
	mov		rax, rcx
	ret

; ------------------------------------------------------------------------------
; Subrutina: skip_whitespace
; Salta espacios en blanco al inicio de str
; ------------------------------------------------------------------------------
.skip_whitespace:
	xor		rcx, rcx
.ws_loop:
	mov		dl, byte [r12 + rcx]
	cmp		dl, ' '
	je		.ws_next
	cmp		dl, 9					; Tab
	jl		.ws_done
	cmp		dl, 13					; CR
	jg		.ws_done
.ws_next:
	inc		rcx
	jmp		.ws_loop
.ws_done:
	add		r12, rcx				; Avanzar puntero
	ret

; ------------------------------------------------------------------------------
; Subrutina: handle_sign
; Procesa signos +/- y actualiza r15 (indicador de signo)
; ------------------------------------------------------------------------------
.handle_sign:
.sign_loop:
	mov		dl, byte [r12]
	cmp		dl, '+'
	je		.sign_plus
	cmp		dl, '-'
	je		.sign_minus
	ret
.sign_plus:
	inc		r12
	jmp		.sign_loop
.sign_minus:
	xor		r15, 1					; Alternar signo
	inc		r12
	jmp		.sign_loop

; ------------------------------------------------------------------------------
; Subrutina: convert
; Convierte la cadena numérica a entero según la base
; ------------------------------------------------------------------------------
.convert:
	xor		rcx, rcx
.conv_loop:
	mov		dl, byte [r12 + rcx]
	cmp		dl, 0
	je		.conv_done				; Fin de cadena
	
	push	rcx
	call	.find_in_base			; Buscar carácter en base
	pop		rcx
	cmp		rax, -1
	je		.conv_done				; Carácter no válido
	
	imul	r14, rbx				; resultado *= base
	add		r14, rax				; resultado += índice
	inc		rcx
	jmp		.conv_loop
.conv_done:
	ret

; ------------------------------------------------------------------------------
; Subrutina: find_in_base
; Busca un carácter (dl) en la base y retorna su índice
; Retorno: rax = índice (o -1 si no se encuentra)
; ------------------------------------------------------------------------------
.find_in_base:
	xor		rax, rax
.find_loop:
	cmp		rax, rbx
	jge		.find_not_found
	movzx	edi, byte [r13 + rax]
	cmp		dl, dil
	je		.find_found
	inc		rax
	jmp		.find_loop
.find_not_found:
	mov		rax, -1
.find_found:
	ret
