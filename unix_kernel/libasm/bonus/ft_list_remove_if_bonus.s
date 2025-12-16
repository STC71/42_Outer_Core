; ==============================================================================
; ft_list_remove_if - Elimina elementos de lista según condición
; ==============================================================================
; Prototipo: void ft_list_remove_if(t_list **begin_list, void *data_ref,
;                                   int (*cmp)(), void (*free_fct)(void *))
;
; Descripción:
;   Elimina todos los nodos cuyo data, al compararse con data_ref usando
;   la función cmp, retorne 0. Libera el data usando free_fct y el nodo
;   usando free.
;
; Estructura t_list:
;   typedef struct s_list {
;       void          *data;    // 8 bytes (offset 0)
;       struct s_list *next;    // 8 bytes (offset 8)
;   } t_list;
;
; Parámetros:
;   rdi (r12) - Puntero a puntero al primer elemento
;   rsi (r13) - Puntero a dato de referencia
;   rdx (r14) - Función de comparación: int (*cmp)(void*, void*)
;   rcx (r15) - Función de liberación: void (*free_fct)(void*)
;
; Funciones de callback:
;   (*cmp)(list_ptr->data, data_ref) retorna 0 si deben ser iguales
;   (*free_fct)(list_ptr->data) libera el data del nodo
;
; Algoritmo:
;   1. Iterar desde el inicio de la lista
;   2. Para cada nodo:
;      a. Comparar nodo->data con data_ref usando cmp
;      b. Si cmp retorna 0:
;         - Guardar next
;         - Liberar data con free_fct
;         - Liberar nodo con free
;         - Actualizar puntero al nodo anterior
;         - Reiniciar desde el inicio
;      c. Si no, avanzar al siguiente
;
; Registros utilizados:
;   r12 - Puntero a puntero de lista (begin_list / current_ptr)
;   r13 - data_ref
;   r14 - Función de comparación
;   r15 - Función de liberación
;   rbx - Nodo actual
; ==============================================================================

section .text
	global ft_list_remove_if
	extern free

ft_list_remove_if:
	cmp		rdi, 0
	je		.end					; Si begin_list es NULL, salir
	cmp		qword [rdi], 0
	je		.end					; Si *begin_list es NULL, salir
	
	push	rbx
	push	r12
	push	r13
	push	r14
	push	r15
	
	mov		r12, rdi				; r12 = puntero a begin_list
	mov		r13, rsi				; r13 = data_ref
	mov		r14, rdx				; r14 = función cmp
	mov		r15, rcx				; r15 = función free_fct

.loop:
	mov		rbx, [r12]				; rbx = *begin_list (nodo actual)
	cmp		rbx, 0
	je		.done					; Si lista vacía, terminar
	
	; Comparar current->data con data_ref
	push	rbx
	mov		rdi, [rbx]				; rdi = current->data
	mov		rsi, r13				; rsi = data_ref
	call	r14						; Llamar función de comparación
	pop		rbx
	
	cmp		rax, 0
	jne		.next					; Si no coincide, siguiente nodo
	
	; Elemento coincide, eliminarlo
	mov		rcx, [rbx + 8]			; rcx = current->next
	mov		[r12], rcx				; *begin_list = current->next
	
	; Liberar data del nodo
	push	rbx
	mov		rdi, [rbx]				; rdi = current->data
	call	r15						; Llamar free_fct
	pop		rbx
	
	; Liberar el nodo
	mov		rdi, rbx
	call	free wrt ..plt
	
	jmp		.loop					; Verificar nuevamente desde inicio

.next:
	lea		r12, [rbx + 8]			; r12 = &(current->next)
	jmp		.loop

.done:
	pop		r15
	pop		r14
	pop		r13
	pop		r12
	pop		rbx

.end:
	ret
