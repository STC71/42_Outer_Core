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
	xor		rax, rax				; Contador = 0  →  rax será el tamaño final
	cmp		rdi, 0					; ¿begin_list es NULL?
	je		.end					; Si sí → lista vacía → retornar 0 inmediatamente

.loop:
	inc		rax						; Incrementar contador (++rax)
	mov		rdi, [rdi + 8]			; rdi = current->next (offset 8)
	cmp		rdi, 0					; ¿El siguiente es NULL?
	jne		.loop					; Si no es NULL → hay más nodos → volver al bucle

.end:
	ret								; Retornar tamaño final en rax 

; ==============================================================================
; Las líneas 29 y 30, son directivas de ensamblador que definen la estructura 
; y visibilidad de la función ft_list_size:
;
;	section .text: Declara la sección de código ejecutable del programa. 
;	En ensamblador, el código se organiza en secciones (.text para código, 
;	.data para datos inicializados, .bss para datos no inicializados).
;
;	global ft_list_size: Hace que el símbolo ft_list_size sea visible externamente,
;	permitiendo que otros archivos objeto (como un código en C) puedan llamar 
;	a esta función durante el enlazado. Sin esta directiva, la función sería local
;	y no accesible desde fuera del archivo.
;
; En resumen: preparas la sección de código y exportas la función para que pueda 
; ser llamada desde C.
; ______________________________________________________________________________
;
; Las líneas 32 a 35, son la inicialización de la función y la validación de 
; entrada:
;
;	ft_list_size: Es la etiqueta que marca el inicio de la función. 
;	Esta es la dirección a la que se salta cuando se llama a ft_list_size.
;
;	xor rax, rax: Inicializa el registro rax a 0 mediante una operación XOR 
;	consigo mismo. Este registro se usará como contador para almacenar el tamaño
;	de la lista. La operación XOR es más eficiente que mov rax, 0 porque genera
;	código máquina más corto.
;
;	cmp rdi, 0: Compara el contenido del registro rdi (puntero al primer elemento)
;	con 0 (NULL). Si la lista está vacía (NULL), debemos retornar 0.
;
;	je .end: "Jump if Equal" - Salta a la etiqueta .end si la comparación anterior
;	fue igual (rdi == NULL). Esto implementa la protección contra null pointers
;	y el manejo de listas vacías.
; ______________________________________________________________________________
;
; Las líneas 37 a 41, son el bucle principal que recorre la lista:
;
;	.loop: Etiqueta local del bucle. El punto (.) indica que es una etiqueta local
;	a la función ft_list_size.
;
;	inc rax: Incrementa el contador en 1, contabilizando el nodo actual.
;
;	mov rdi, [rdi + 8]: Avanza al siguiente nodo de la lista. Lee el valor 
;	almacenado en la dirección (rdi + 8 bytes), que corresponde al campo 'next'
;	de la estructura t_list (data está en offset 0, next en offset 8), y lo 
;	almacena en rdi. Efectivamente hace: rdi = current->next.
;
;	cmp rdi, 0: Compara el nuevo valor de rdi con 0 (NULL) para verificar si
;	hemos llegado al final de la lista.
;
;	jne .loop: "Jump if Not Equal" - Salta de vuelta a .loop si rdi no es NULL,
;	continuando el recorrido de la lista.
; ______________________________________________________________________________
;
; Las líneas 43 y 44, son la finalización de la función:
;
;	.end: Etiqueta local que marca el final de la función.
;
;	ret: Retorna al código que llamó a la función. El valor de retorno (el tamaño
;	de la lista) ya está en el registro rax según la convención de llamada x86-64.
;	Si la lista estaba vacía, rax contiene 0 (valor inicial); si no, contiene
;	el número de nodos contados en el bucle.
; ==============================================================================
