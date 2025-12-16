; ==============================================================================
; ft_list_size - Cuenta elementos en lista enlazada
; ==============================================================================
; Prototipo: int ft_list_size(t_list *begin_list)
;
; Descripción:
;   Recorre la lista enlazada y cuenta el número de elementos.
;
; Estructura t_list:
;   typedef struct s_list {
;       void          *data;    // 8 bytes (offset 0)
;       struct s_list *next;    // 8 bytes (offset 8)
;   } t_list;
;
; Parámetros:
;   rdi - Puntero al primer elemento de la lista
;
; Retorno:
;   rax - Número de elementos en la lista (0 si lista vacía)
;
; Algoritmo:
;   1. Inicializar contador a 0
;   2. Mientras el nodo actual no sea NULL:
;      - Incrementar contador
;      - Avanzar al siguiente nodo (current = current->next)
;   3. Retornar contador
; ==============================================================================

section .text
	global ft_list_size

ft_list_size:
	xor		rax, rax				; Inicializar contador a 0
	cmp		rdi, 0
	je		.end					; Si lista vacía, retornar 0

.loop:
	inc		rax						; Incrementar contador
	mov		rdi, [rdi + 8]			; rdi = current->next (offset 8)
	cmp		rdi, 0
	jne		.loop					; Si no es NULL, continuar

.end:
	ret								; Retornar tamaño en rax
