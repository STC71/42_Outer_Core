; ==============================================================================
; ft_strcmp - Compara dos cadenas lexicográficamente
; ==============================================================================
; Prototipo: int ft_strcmp(const char *s1, const char *s2)
;
; Descripción:
;   Compara las cadenas s1 y s2 byte por byte. La comparación se realiza
;   usando valores de caracteres sin signo.
;
; Parámetros:
;   rdi - Puntero a la primera cadena
;   rsi - Puntero a la segunda cadena
;
; Retorno:
;   rax - Un entero < 0 si s1 < s2
;         Un entero = 0 si s1 == s2
;         Un entero > 0 si s1 > s2
;
; Registros utilizados:
;   rax - Byte de s1 (extendido) / valor de retorno
;   rcx - Índice para recorrer las cadenas
;   al  - Byte temporal de s1
;   dl  - Byte temporal de s2
; ==============================================================================

section .text
	global ft_strcmp

ft_strcmp:
	xor		rax, rax				; Limpiar rax
	xor		rcx, rcx				; Inicializar índice a 0

.loop:
	mov		al, byte [rdi + rcx]	; Leer byte de s1
	mov		dl, byte [rsi + rcx]	; Leer byte de s2
	cmp		al, dl					; Comparar bytes
	jne		.diff					; Si son diferentes, retornar diferencia
	cmp		al, 0					; Verificar si llegamos al final
	je		.equal					; Si es '\0', las cadenas son iguales
	inc		rcx						; Incrementar índice
	jmp		.loop					; Repetir bucle

.diff:
	movzx	rax, al					; Extender al a rax sin signo
	movzx	rdx, dl					; Extender dl a rdx sin signo
	sub		rax, rdx				; Calcular diferencia
	ret

.equal:
	xor		rax, rax				; Retornar 0 (cadenas iguales)
	ret
