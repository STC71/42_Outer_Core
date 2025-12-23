; ==============================================================================
; ft_list_sort - Ordena lista enlazada usando función de comparación
; ==============================================================================
; Prototipo: void ft_list_sort(t_list **begin_list, int (*cmp)())
;
; Descripción:
;   Ordena la lista enlazada intercambiando los datos (no los nodos).
;   Utiliza el algoritmo Bubble Sort con una función de comparación externa.
;
; Estructura t_list:
;   typedef struct s_list {
;       void          *data;    // 8 bytes (offset 0)
;       struct s_list *next;    // 8 bytes (offset 8)
;   } t_list;
;
; Parámetros:
;   rdi - Puntero a puntero al primer elemento (begin_list)
;   rsi - Función de comparación que retorna:
;         > 0 si primer arg > segundo arg (swap necesario)
;         = 0 si son iguales
;         < 0 si primer arg < segundo arg
;
; Retorno:
;   void (modifica la lista ordenando los datos)
;
; Algoritmo (Bubble Sort):
;   1. Validar parámetros
;   2. Bucle externo: repetir mientras haya cambios
;      - Inicializar flag de cambios a 0
;      - Recorrer toda la lista comparando nodos adyacentes
;      - Si par está en orden incorrecto, intercambiar y marcar cambio
;   3. Si no hubo cambios en pasada completa, lista está ordenada
; ==============================================================================

section .text
global ft_list_sort

ft_list_sort:
	test rdi, rdi
	jz .end
	cmp qword [rdi], 0
	je .end
	push rbp
	mov rbp, rsp
	and rsp, -16
	sub rsp, 48
	mov [rsp + 32], r12
	mov [rsp + 24], r13
	mov [rsp + 16], r14
	mov [rsp + 8], r15
	mov [rsp], rdi
	mov r13, rsi

.outer:
	xor r15, r15
	mov rdi, [rsp]
	mov r12, [rdi]
	
.inner:
	test r12, r12
	jz .check_changed
	mov r14, [r12 + 8]
	test r14, r14
	jz .check_changed
	mov rdi, [r12]
	mov rsi, [r14]
	call r13
	cmp rax, 0
	jle .no_swap
	mov rdi, [r12]
	mov rsi, [r14]
	mov [r12], rsi
	mov [r14], rdi
	mov r15, 1

.no_swap:
	mov r12, [r12 + 8]
	jmp .inner

.check_changed:
	test r15, r15
	jnz .outer
	mov r12, [rsp + 32]
	mov r13, [rsp + 24]
	mov r14, [rsp + 16]
	mov r15, [rsp + 8]
	leave

.end:
	ret

; ==============================================================================
;
; Las líneas 35 y 36, son directivas de ensamblador que definen la estructura 
; y visibilidad de la función ft_list_sort:
;
;	section .text: Declara la sección de código ejecutable del programa. 
;	En ensamblador, el código se organiza en secciones (.text para código, 
;	.data para datos inicializados, .bss para datos no inicializados).
;
;	global ft_list_sort: Hace que el símbolo ft_list_sort sea visible externamente,
;	permitiendo que otros archivos objeto (como un código en C) puedan llamar 
;	a esta función durante el enlazado. Sin esta directiva, la función sería local
;	y no accesible desde fuera del archivo.
;
; En resumen: preparas la sección de código y exportas la función para que pueda 
; ser llamada desde C.
; ______________________________________________________________________________
;
; Las líneas 38 a 42, son la validación inicial de parámetros:
;
;	ft_list_sort: Es la etiqueta que marca el inicio de la función. 
;	Esta es la dirección a la que se salta cuando se llama a ft_list_sort.
;
;	test rdi, rdi: Realiza una operación AND lógica entre rdi y sí mismo,
;	estableciendo los flags del procesador sin modificar rdi. Si rdi es 0 (NULL),
;	el flag ZF (Zero Flag) se establece. Esta es la forma idiomática de verificar
;	si un puntero es NULL.
;
;	jz .end: "Jump if Zero" - Salta a .end si rdi es NULL (begin_list == NULL).
;	Protección contra null pointer para el parámetro begin_list.
;
;	cmp qword [rdi], 0: Desreferencia el puntero begin_list y compara el primer
;	nodo de la lista (*begin_list) con 0 (NULL). Si la lista está vacía o tiene
;	solo un elemento, no hay nada que ordenar.
;
;	je .end: "Jump if Equal" - Salta a .end si la lista está vacía (NULL).
;	Esto maneja el caso de una lista vacía de forma eficiente.
;
; Estas validaciones evitan segmentation faults y optimizan casos triviales.
; ______________________________________________________________________________
;
; Las líneas 43 a 46, son la configuración del stack frame y preservación de registros:
;
;	push rbp: Guarda el valor actual del base pointer en la pila, preservando
;	el frame del llamador según la convención x86-64.
;
;	mov rbp, rsp: Establece rbp como nuevo base pointer, creando el stack frame.
;
;	and rsp, -16: Alinea el stack pointer a 16 bytes realizando una operación AND
;	bit a bit con -16 (0xFFFFFFFFFFFFFFF0 en complemento a dos). Esto fuerza que
;	rsp sea un múltiplo de 16, requisito de System V ABI antes de llamar funciones.
;	Por ejemplo: 0x7fffffffe458 AND 0xFFFFFFFFFFFFFFF0 = 0x7fffffffe450
;
;	sub rsp, 48: Reserva 48 bytes en el stack para variables locales:
;	  - 32 bytes para guardar 4 registros callee-saved (r12-r15)
;	  - 8 bytes para guardar begin_list
;	  - 8 bytes adicionales para mantener alineación
;
; ¿Por qué guardar estos registros?
;	Los registros r12, r13, r14, r15 son "callee-saved" según System V ABI,
;	lo que significa que si los modificamos, debemos restaurar sus valores
;	originales antes de retornar. Estos registros son útiles para almacenar
;	valores que deben persistir a través de múltiples llamadas a funciones.
; ______________________________________________________________________________
;
; Las líneas 47 a 50, guardan registros y parámetros en el stack:
;
;	mov [rsp + 32], r12: Guarda r12 en offset 32 del stack
;	mov [rsp + 24], r13: Guarda r13 en offset 24 del stack
;	mov [rsp + 16], r14: Guarda r14 en offset 16 del stack
;	mov [rsp + 8], r15: Guarda r15 en offset 8 del stack
;
; Distribución del stack (48 bytes):
;	[rsp + 40] - No usado (padding para alineación)
;	[rsp + 32] - r12 guardado (current node en bucle interno)
;	[rsp + 24] - r13 guardado (función de comparación)
;	[rsp + 16] - r14 guardado (next node en bucle interno)
;	[rsp + 8]  - r15 guardado (flag de cambios)
;	[rsp]      - begin_list guardado
;
; Estos registros se usan para:
;	r12 - Mantener el puntero al nodo actual durante el bucle interno
;	r13 - Almacenar la función de comparación (segundo parámetro rsi)
;	r14 - Mantener el puntero al siguiente nodo
;	r15 - Flag booleano que indica si hubo intercambios en la pasada
; ______________________________________________________________________________
;
; Las líneas 51 y 52, guardan los parámetros de entrada:
;
;	mov [rsp], rdi: Guarda begin_list en el stack en offset 0. Necesitamos
;	preservar este valor porque rdi se usará repetidamente para pasar argumentos
;	a la función de comparación.
;
;	mov r13, rsi: Copia el puntero a la función de comparación desde rsi a r13.
;	Usamos r13 (un registro callee-saved) porque necesitamos mantener este valor
;	constante a través de todas las iteraciones y llamadas a funciones. rsi es
;	volátil y se sobrescribirá al llamar a la función de comparación.
;
; De esta forma tenemos acceso constante a ambos parámetros originales durante
; toda la ejecución del algoritmo de ordenamiento.
; ______________________________________________________________________________
;
; Las líneas 54 a 57, son el inicio del bucle externo (outer loop):
;
;	.outer: Etiqueta del bucle externo de Bubble Sort. Este bucle se repite
;	mientras haya intercambios en la pasada anterior, garantizando que la lista
;	quede completamente ordenada. En el peor caso, se ejecuta N veces donde N
;	es el número de elementos.
;
;	xor r15, r15: Inicializa el flag de cambios a 0 (false). Este flag indicará
;	si ocurrió algún intercambio durante la pasada completa por la lista.
;	Si no hay intercambios, la lista ya está ordenada y podemos terminar.
;
;	mov rdi, [rsp]: Restaura el puntero begin_list desde el stack.
;	Necesitamos este valor al inicio de cada pasada para obtener el primer nodo.
;
;	mov r12, [rdi]: Desreferencia begin_list para obtener el primer nodo
;	(*begin_list) y lo almacena en r12. r12 será nuestro iterador para el
;	bucle interno, apuntando al nodo actual que estamos procesando.
; ______________________________________________________________________________
;
; Las líneas 59 a 64, son el inicio del bucle interno y validaciones:
;
;	.inner: Etiqueta del bucle interno. Este bucle recorre la lista comparando
;	cada par de nodos adyacentes. Para cada par, compara sus datos y los
;	intercambia si están en el orden incorrecto.
;
;	test r12, r12: Verifica si el nodo actual es NULL mediante operación AND
;	consigo mismo. Si r12 es NULL, hemos llegado al final de la lista.
;
;	jz .check_changed: Salta a verificar si hubo cambios si r12 es NULL.
;
;	mov r14, [r12 + 8]: Obtiene el siguiente nodo (current->next) accediendo
;	al campo 'next' en offset 8 de la estructura. r14 apuntará al nodo que
;	viene después del actual.
;
;	test r14, r14: Verifica si el siguiente nodo es NULL.
;
;	jz .check_changed: Si no hay siguiente nodo, hemos llegado al final de
;	la comparación posible (no podemos comparar el último nodo con nada).
;
; Estas validaciones aseguran que siempre tenemos un par válido para comparar.
; ______________________________________________________________________________
;
; Las líneas 65 a 69, son la llamada a la función de comparación:
;
;	mov rdi, [r12]: Carga el data del nodo actual (current->data) en rdi.
;	Este será el primer argumento para la función de comparación.
;
;	mov rsi, [r14]: Carga el data del siguiente nodo (next->data) en rsi.
;	Este será el segundo argumento para la función de comparación.
;
;	call r13: Llama a la función de comparación almacenada en r13. Esta es una
;	llamada indirecta porque el destino está en un registro, no es una dirección
;	inmediata. La función compara los dos datos y retorna:
;	  - Valor > 0 si rdi > rsi (necesita swap)
;	  - Valor = 0 si son iguales
;	  - Valor < 0 si rdi < rsi (orden correcto)
;
;	cmp rax, 0: Compara el valor de retorno con 0. La función retorna el resultado
;	en rax según la convención de llamada x86-64.
;
;	jle .no_swap: "Jump if Less or Equal" - Si rax <= 0, el par ya está en orden
;	correcto (o son iguales), por lo que saltamos el intercambio y continuamos.
; ______________________________________________________________________________
;
; Las líneas 70 a 74, son el intercambio de datos (swap):
;
;	mov rdi, [r12]: Recarga current->data en rdi. Es necesario recargar porque
;	la función de comparación puede haber modificado los registros.
;
;	mov rsi, [r14]: Recarga next->data en rsi.
;
;	mov [r12], rsi: Escribe next->data en la posición de current->data.
;	Primera parte del intercambio: current->data = next->data
;
;	mov [r14], rdi: Escribe el original current->data (guardado en rdi) en la
;	posición de next->data. Segunda parte del intercambio: next->data = temp
;
;	mov r15, 1: Establece el flag de cambios a 1 (true). Esto indica que
;	ocurrió al menos un intercambio en esta pasada, por lo que necesitaremos
;	otra pasada completa para verificar si la lista está ordenada.
;
; Nota importante: Intercambiamos los datos (punteros void*), no los nodos.
; Esto es más simple porque no requiere manipular múltiples punteros next.
; ______________________________________________________________________________
;
; Las líneas 76 a 78, son el avance al siguiente par y continuación del bucle:
;
;	.no_swap: Etiqueta a la que saltamos cuando no es necesario intercambiar.
;	El flujo llega aquí tanto después de un swap como cuando se salta el swap.
;
;	mov r12, [r12 + 8]: Avanza al siguiente nodo moviendo r12 a current->next.
;	Esto hace: current = current->next, preparándonos para comparar el siguiente
;	par de nodos adyacentes.
;
;	jmp .inner: Salta incondicionalmente de vuelta al inicio del bucle interno
;	para procesar el siguiente par. El bucle continuará hasta que r12 o r14
;	sean NULL (final de la lista).
; ______________________________________________________________________________
;
; Las líneas 80 a 82, son la verificación de cambios y decisión de continuar:
;
;	.check_changed: Etiqueta a la que llegamos cuando terminamos una pasada
;	completa por la lista (bucle interno completado).
;
;	test r15, r15: Verifica el flag de cambios mediante AND consigo mismo.
;	Si r15 es 0, no hubo intercambios en esta pasada, lo que significa que
;	la lista ya está ordenada.
;
;	jnz .outer: "Jump if Not Zero" - Si r15 != 0, hubo intercambios, por lo
;	que necesitamos otra pasada completa para asegurar que la lista esté
;	totalmente ordenada. Salta de vuelta al inicio del bucle externo.
;
; Este es el corazón de Bubble Sort: repetir pasadas hasta que una pasada
; completa no produzca ningún intercambio, garantizando el ordenamiento.
; ______________________________________________________________________________
;
; Las líneas 83 a 87, son la restauración de registros y finalización:
;
;	mov r12, [rsp + 32]: Restaura el valor original de r12 desde el stack
;	mov r13, [rsp + 24]: Restaura el valor original de r13 desde el stack
;	mov r14, [rsp + 16]: Restaura el valor original de r14 desde el stack
;	mov r15, [rsp + 8]: Restaura el valor original de r15 desde el stack
;
; Es obligatorio restaurar los registros callee-saved (r12-r15) según System V ABI.
; Si no lo hacemos, el código llamador podría fallar si dependía de esos valores.
;
;	leave: Instrucción equivalente a:
;	  mov rsp, rbp  ; Restaura rsp al valor original
;	  pop rbp       ; Restaura rbp del stack
;	Esto deshace el stack frame, liberando el espacio reservado y restaurando
;	el base pointer del llamador.
; ______________________________________________________________________________
;
; Las líneas 89 y 90, son la salida de la función:
;
;	.end: Etiqueta de salida a la que saltamos si los parámetros son inválidos
;	(begin_list es NULL o la lista está vacía). También es el punto de retorno
;	normal después de ordenar la lista.
;
;	ret: Retorna al código llamador. El valor de retorno es void, por lo que
;	no necesitamos establecer rax. La instrucción ret hace pop de la dirección
;	de retorno del stack y salta a esa dirección.
; ______________________________________________________________________________
;
; Complejidad del algoritmo:
;   Tiempo: O(n²) en el peor y promedio caso, O(n) en el mejor caso (ya ordenada)
;   Espacio: O(1) - ordenamiento in-place, solo usa stack para registros
;
; El algoritmo Bubble Sort no es eficiente para listas grandes, pero es simple
; y adecuado para propósitos educativos. Para listas grandes, algoritmos como
; Merge Sort (O(n log n)) serían más apropiados.
;
; ==============================================================================
