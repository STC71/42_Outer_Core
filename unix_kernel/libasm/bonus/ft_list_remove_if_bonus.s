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
	
	push	rbx						; Para rbx → nodo actual (current)
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
	push	rbx						; Guardar current (lo vamos a usar después, y call podría modificar registros)
	mov		rdi, [rbx]				; rdi = current->data (primer arg para cmp)
	mov		rsi, r13				; rsi = data_ref (segundo arg)
	call	r14						; Llamar función de comparación → cmp(current->data, data_ref)
	pop		rbx						; Recuperar current
	
	cmp		rax, 0					; Podría sustituirse por → test rax, rax
	jne		.next					; Si no coincide, siguiente nodo
	
	; Elemento coincide, eliminarlo
	mov		rcx, [rbx + 8]			; Copiar la dirección del siguiente nodo en rcx → rcx = current->next
	mov		[r12], rcx				; Guardar esa dirección de "el que sigue" en el puntero del nodo anterior (apuntado por r12) → *begin_list = current->next
	
	; Liberar data del nodo
	push	rbx						; Asegura que la llamada a r15 no lo sobrescriba y pueda recuperarse después
	mov		rdi, [rbx]				; Mover la dirección de los datos a rdi → rdi = current->data
	call	r15						; Llamar free_fct pasando los datos en rdi
	pop		rbx						; Recuperar el valor original de rbx de la pila
	
	; Liberar el nodo
	mov		rdi, rbx				; rbx contiene la dirección de memoria "puenteada" anteriormente
	call	free wrt ..plt			; Invoca la función estándar free
	
	jmp		.loop					; Verificar nuevamente desde inicio

.next:
	lea		r12, [rbx + 8]			; r12 = &(current->next) lea → no lee contenido → calcula una dirección y la guarda
	jmp		.loop

.done:
	pop		r15
	pop		r14
	pop		r13
	pop		r12
	pop		rbx

.end:
	ret

; ==============================================================================
;
; Las líneas 48 a 50, son directivas de ensamblador que definen la estructura 
; y visibilidad de la función ft_list_remove_if:
;
;	section .text: Declara la sección de código ejecutable del programa. 
;	En ensamblador, el código se organiza en secciones (.text para código, 
;	.data para datos inicializados, .bss para datos no inicializados).
;
;	global ft_list_remove_if: Hace que el símbolo ft_list_remove_if sea visible
;	externamente, permitiendo que otros archivos objeto (como un código en C) 
;	puedan llamar a esta función durante el enlazado. Sin esta directiva, 
;	la función sería local y no accesible desde fuera del archivo.
;
;	extern free: Declara que free es una función externa definida en otra
;	biblioteca (libc). Esta función se utiliza para liberar memoria dinámica
;	del heap. La declaración permite al enlazador resolver la dirección de
;	free en tiempo de enlazado.
;
; En resumen: preparas la sección de código, exportas la función y declaras
; la dependencia externa de free para liberación de memoria dinámica.
; ______________________________________________________________________________
;
; Las líneas 52 a 56, son la validación inicial de parámetros:
;
;	ft_list_remove_if: Es la etiqueta que marca el inicio de la función. 
;	Esta es la dirección a la que se salta cuando se llama a ft_list_remove_if.
;
;	cmp rdi, 0: Compara el contenido del registro rdi (puntero a puntero begin_list)
;	con 0 (NULL). Si begin_list es NULL, no podemos desreferenciar el puntero
;	para acceder a la lista, por lo que debemos salir sin hacer nada.
;
;	je .end: "Jump if Equal" - Salta a la etiqueta .end si la comparación anterior
;	fue igual (rdi == NULL). Esto implementa la protección contra null pointers
;	en el parámetro begin_list.
;
;	cmp qword [rdi], 0: Compara el valor apuntado por rdi (*begin_list) con 0 (NULL).
;	Si la lista está vacía (primer nodo es NULL), no hay nada que eliminar.
;
;	je .end: Salta a .end si *begin_list es NULL, manejando el caso de lista vacía.
; ______________________________________________________________________________
;
; Las líneas 58 a 67, son el prólogo de la función y preparación de registros:
;
;	push rbx/r12/r13/r14/r15: Guarda los registros no volátiles en la pila
;	según la convención de llamada x86-64. Estos registros deben ser restaurados
;	antes de retornar. Los preservamos porque los vamos a usar durante la función.
;
;	mov r12, rdi: Guarda el puntero a begin_list en r12. Este registro contendrá
;	la dirección del puntero que apunta al nodo actual a examinar. Inicialmente
;	es &(*begin_list), pero cambiará a &(current->next) durante la iteración.
;
;	mov r13, rsi: Guarda data_ref en r13. Este es el dato de referencia con el
;	que compararemos cada nodo->data.
;
;	mov r14, rdx: Guarda el puntero a la función de comparación en r14. Esta
;	función tiene la firma: int (*cmp)(void *data1, void *data2) y retorna 0
;	cuando los datos coinciden.
;
;	mov r15, rcx: Guarda el puntero a la función de liberación en r15. Esta
;	función tiene la firma: void (*free_fct)(void *data) y se usa para liberar
;	el data de cada nodo antes de liberar el nodo mismo.
; ______________________________________________________________________________
;
; Las líneas 69 a 72, son el inicio del bucle principal:
;
;	.loop: Etiqueta local del bucle principal. El punto (.) indica que es una
;	etiqueta local a la función ft_list_remove_if.
;
;	mov rbx, [r12]: Desreferencia el puntero almacenado en r12 para obtener
;	el nodo actual. Inicialmente rbx = *begin_list. Después de eliminar un nodo,
;	rbx contendrá el nodo que tomó su lugar. Si no se elimina, r12 apuntará
;	a &(current->next).
;
;	cmp rbx, 0: Compara el nodo actual con NULL para verificar si hemos llegado
;	al final de la lista.
;
;	je .done: "Jump if Equal" - Salta a .done si no hay más nodos que procesar
;	(rbx == NULL), finalizando el bucle de eliminación.
; ______________________________________________________________________________
;
; Las líneas 74 a 82, son la comparación del nodo actual con data_ref:
;
;	push rbx: Guarda rbx en la pila antes de llamar a la función de comparación,
;	ya que las llamadas a funciones pueden modificar registros volátiles y
;	necesitamos preservar el puntero al nodo actual.
;
;	mov rdi, [rbx]: Carga el data del nodo actual (current->data, offset 0) en rdi,
;	que es el primer parámetro de la función de comparación según la convención
;	de llamada x86-64.
;
;	mov rsi, r13: Carga data_ref (guardado en r13) en rsi, que es el segundo
;	parámetro de la función de comparación.
;
;	call r14: Llama a la función de comparación almacenada en r14. La función
;	retorna 0 en rax si los datos coinciden, o un valor diferente de 0 si no.
;
;	pop rbx: Restaura rbx de la pila después de la llamada a la función,
;	recuperando el puntero al nodo actual.
;
;	cmp rax, 0: Compara el valor de retorno de la función de comparación con 0.
;
;	jne .next: "Jump if Not Equal" - Salta a .next si la comparación retornó
;	un valor diferente de 0 (los datos no coinciden), avanzando al siguiente nodo
;	sin eliminar el actual.
; ______________________________________________________________________________
;
; Las líneas 84 a 98, son la eliminación del nodo cuando coincide:
;
;	mov rcx, [rbx + 8]: Guarda el puntero al siguiente nodo (current->next, offset 8)
;	en rcx antes de liberar el nodo actual.
;
;	mov [r12], rcx: Actualiza el puntero que apuntaba al nodo actual para que
;	apunte al siguiente nodo. Si estamos en el inicio, esto actualiza *begin_list.
;	Si estamos en medio de la lista, actualiza previous->next. Esto "salta" el
;	nodo actual, eliminándolo de la lista enlazada.
;
;	push rbx: Guarda rbx antes de llamar a free_fct, porque necesitamos el nodo
;	después para liberar su memoria.
;
;	mov rdi, [rbx]: Carga current->data en rdi para pasarlo como parámetro
;	a la función de liberación.
;
;	call r15: Llama a la función de liberación (free_fct) almacenada en r15
;	para liberar la memoria del data del nodo.
;
;	pop rbx: Restaura rbx después de la llamada, recuperando el puntero al nodo.
;
;	mov rdi, rbx: Carga el puntero al nodo en rdi para pasarlo como parámetro a free.
;
;	call free wrt ..plt: Libera la memoria del nodo mismo. 'wrt ..plt' (With Respect
;	To Procedure Linkage Table) es una directiva de NASM para código independiente
;	de posición (PIC), necesaria para bibliotecas compartidas.
;
;	jmp .loop: Salta de vuelta al inicio del bucle. Nota que NO avanzamos r12
;	porque el siguiente nodo ahora está en la misma posición (fue movido allí
;	por la línea mov [r12], rcx). Esto permite encontrar múltiples nodos
;	consecutivos que coincidan.
; ______________________________________________________________________________
;
; Las líneas 100 a 102, son el avance al siguiente nodo sin eliminación:
;
;	.next: Etiqueta local para cuando el nodo actual no coincide y debemos avanzar.
;
;	lea r12, [rbx + 8]: Carga la dirección efectiva de &(current->next) en r12.
;	Esto hace que r12 apunte al campo 'next' del nodo actual, preparándolo para
;	la siguiente iteración. En la próxima iteración, mov rbx, [r12] cargará
;	current->next, avanzando en la lista.
;
;	jmp .loop: Salta de vuelta al bucle principal para procesar el siguiente nodo.
; ______________________________________________________________________________
;
; Las líneas 104 a 112, son el epílogo de la función:
;
;	.done: Etiqueta local que marca el final del bucle cuando hemos procesado
;	todos los nodos de la lista.
;
;	pop r15/r14/r13/r12/rbx: Restaura los registros no volátiles de la pila
;	en orden inverso (LIFO - Last In, First Out). Esto es esencial según la
;	convención de llamada x86-64 para mantener la consistencia del estado
;	de registros para el código que llamó a esta función.
;
;	.end: Etiqueta local de finalización de la función, usada tanto cuando
;	los parámetros iniciales son inválidos como cuando terminamos normalmente.
;
;	ret: Retorna al código que llamó a la función. No hay valor de retorno
;	(void), pero la lista ha sido modificada, con los nodos coincidentes eliminados.
; ==============================================================================
