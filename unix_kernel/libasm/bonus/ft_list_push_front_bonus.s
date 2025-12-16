; ==============================================================================
; ft_list_push_front - Añade elemento al inicio de lista enlazada
; ==============================================================================
; Prototipo: void ft_list_push_front(t_list **begin_list, void *data)
;
; Descripción:
;   Crea un nuevo nodo con los datos proporcionados y lo inserta al
;   principio de la lista. Si malloc falla, la función no hace nada.
;
; Estructura t_list:
;   typedef struct s_list {
;       void          *data;    // 8 bytes (offset 0)
;       struct s_list *next;    // 8 bytes (offset 8)
;   } t_list;                   // Total: 16 bytes
;
; Parámetros:
;   rdi - Puntero a puntero al primer elemento (begin_list)
;   rsi - Puntero a los datos a almacenar
;
; Retorno:
;   void (modifica la lista apuntada por begin_list)
;
; Algoritmo:
;   1. Reservar memoria para nuevo nodo (16 bytes)
;   2. Asignar data al nuevo nodo
;   3. Hacer que nuevo nodo apunte al antiguo primer elemento
;   4. Actualizar begin_list para que apunte al nuevo nodo
; ==============================================================================

section .text
	global ft_list_push_front
	extern malloc

ft_list_push_front:
	cmp		rdi, 0
	je		.end					; Si begin_list es NULL, no hacer nada
	
	push	rbp
	mov		rbp, rsp
	sub		rsp, 16					; Alinear stack a 16 bytes y reservar espacio
	
	mov		[rbp - 8], rdi			; Guardar begin_list en stack
	mov		[rbp - 16], rsi			; Guardar data en stack
	
	mov		rdi, 16					; sizeof(t_list) = 16 bytes
	call	malloc wrt ..plt		; Reservar memoria
	
	test	rax, rax
	jz		.error					; Si malloc falló, salir
	
	mov		rsi, [rbp - 16]			; Restaurar data
	mov		rdi, [rbp - 8]			; Restaurar begin_list
	
	mov		qword [rax], rsi		; nuevo->data = data
	mov		rcx, [rdi]				; rcx = *begin_list (antiguo primer elemento)
	mov		qword [rax + 8], rcx	; nuevo->next = antiguo primer elemento
	mov		qword [rdi], rax		; *begin_list = nuevo
	
	leave
	ret

.error:
	leave
.end:
	ret
