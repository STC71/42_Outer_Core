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
	cmp		rdi, 0					; ¿begin_list es NULL?
	je		.end					; Si begin_list es NULL, no hacer nada
	
	push	rbp						; Guardar viejo frame pointer
	mov		rbp, rsp				; Crear nuevo stack frame
	sub		rsp, 16					; Alinear stack a 16 bytes y reservar espacio
	
	mov		[rbp - 8], rdi			; Guardar begin_list en stack (offset -8)
	mov		[rbp - 16], rsi			; Guardar data en stack (offset -16)
	
	mov		rdi, 16					; sizeof(t_list) = 16 bytes
	call	malloc wrt ..plt		; Reservar memoria para nuevo nodo
	
	test	rax, rax				; ¿malloc devolvió NULL?
	jz		.error					; Si malloc falló, salir
	
	mov		rsi, [rbp - 16]			; Restaurar data
	mov		rdi, [rbp - 8]			; Restaurar begin_list
	
	mov		qword [rax], rsi		; nuevo_nodo->data = data  (offset 0)
	mov		rcx, [rdi]				; rcx = *begin_list → antiguo primer elemento
	mov		qword [rax + 8], rcx	; nuevo_nodo->next = antiguo primer elementoo
	mov		qword [rdi], rax		; *begin_list = nuevo_nodo
	
	leave							: Limpia el stack frame de forma elegante: restaura rsp y rbp.
	ret

.error:
	leave
.end:
	ret

; ==============================================================================
;
; Las líneas 31 a 33, son directivas de ensamblador que definen la estructura 
; y visibilidad de la función ft_list_push_front:
;
;	section .text: Declara la sección de código ejecutable del programa. 
;	En ensamblador, el código se organiza en secciones (.text para código, 
;	.data para datos inicializados, .bss para datos no inicializados).
;
;	global ft_list_push_front: Hace que el símbolo ft_list_push_front sea visible
;	externamente, permitiendo que otros archivos objeto (como un código en C) 
;	puedan llamar a esta función durante el enlazado. Sin esta directiva, 
;	la función sería local y no accesible desde fuera del archivo.
;
;	extern malloc: Declara que malloc es una función externa definida en otra
;	biblioteca (libc). Esta función se utiliza para reservar memoria dinámica
;	en el heap. La declaración permite al enlazador resolver la dirección de
;	malloc en tiempo de enlazado.
;
; En resumen: preparas la sección de código, exportas la función y declaras
; la dependencia externa de malloc para asignación dinámica de memoria.
; ______________________________________________________________________________
;
; Las líneas 35 a 37, son la validación inicial del parámetro begin_list:
;
;	ft_list_push_front: Es la etiqueta que marca el inicio de la función. 
;	Esta es la dirección a la que se salta cuando se llama a ft_list_push_front.
;
;	cmp rdi, 0: Compara el contenido del registro rdi (puntero a puntero begin_list)
;	con 0 (NULL). Si begin_list es NULL, no podemos desreferenciar el puntero
;	para modificar la lista, por lo que debemos salir sin hacer nada.
;
;	je .end: "Jump if Equal" - Salta a la etiqueta .end si la comparación anterior
;	fue igual (rdi == NULL). Esto implementa la protección contra null pointers.
;	Si begin_list es NULL, la función retorna inmediatamente sin efectos.
;
; Esta validación es crítica para evitar segmentation faults al intentar
; desreferenciar un puntero NULL en las líneas posteriores.
; ______________________________________________________________________________
;
; Las líneas 39 a 41, son la configuración del stack frame:
;
;	push rbp: Guarda el valor actual del registro rbp (base pointer) en la pila.
;	Esto preserva el frame pointer del llamador según la convención de llamada
;	x86-64. El rbp sirve como punto de referencia estable para acceder a
;	variables locales y parámetros.
;
;	mov rbp, rsp: Establece rbp al valor actual de rsp (stack pointer).
;	Esto crea el nuevo stack frame para nuestra función. A partir de ahora,
;	rbp marca la base de nuestro frame y rsp puede moverse para reservar espacio.
;
;	sub rsp, 16: Reserva 16 bytes en la pila para variables locales.
;	La sustracción de rsp "crece" la pila hacia direcciones bajas.
;	Los 16 bytes cumplen dos propósitos:
;	  1. Almacenar los parámetros originales (rdi y rsi) que se perderán al
;	     llamar a malloc, ya que malloc puede modificar registros volátiles.
;	  2. Mantener la alineación del stack a 16 bytes, requerida por la
;	     System V ABI antes de llamadas a funciones. Esto es necesario para
;	     instrucciones SSE y compatibilidad con librerías del sistema.
; ______________________________________________________________________________
;
; Las líneas 43 y 44, guardan los parámetros en el stack:
;
;	mov [rbp - 8], rdi: Guarda el puntero begin_list en el stack en la posición
;	rbp - 8 (8 bytes por debajo del base pointer). Usamos rbp como referencia
;	porque es estable y no cambia durante la ejecución de la función.
;
;	mov [rbp - 16], rsi: Guarda el puntero data en el stack en la posición
;	rbp - 16 (16 bytes por debajo del base pointer).
;
; ¿Por qué guardamos los parámetros?
;	La convención de llamada x86-64 System V ABI especifica que ciertos registros
;	son "caller-saved" (volátiles), lo que significa que las funciones llamadas
;	pueden modificarlos libremente. Los registros rdi, rsi, rdx, rcx, r8, r9 son
;	volátiles y se usan para pasar parámetros.
;
;	Al llamar a malloc:
;	  - rdi se sobrescribirá con el argumento de malloc (tamaño)
;	  - rsi y otros registros pueden ser modificados internamente por malloc
;	  - Perdemos los valores originales de begin_list y data
;
;	Por eso los guardamos en el stack antes de la llamada y los restauramos después.
; ______________________________________________________________________________
;
; Las líneas 46 y 47, llaman a malloc para reservar memoria:
;
;	mov rdi, 16: Establece el primer argumento de malloc en rdi.
;	El valor 16 es el tamaño en bytes de la estructura t_list:
;	  - 8 bytes para el puntero data (offset 0)
;	  - 8 bytes para el puntero next (offset 8)
;	  - Total: 16 bytes
;
;	call malloc wrt ..plt: Llama a la función malloc de la biblioteca estándar.
;	- wrt ..plt: "With Respect To PLT" - Usa la tabla PLT (Procedure Linkage Table)
;	  para resolver la dirección de malloc. El PLT permite la vinculación dinámica
;	  de funciones de bibliotecas compartidas (.so) en tiempo de ejecución.
;	- malloc reserva memoria en el heap y retorna en rax un puntero a la memoria
;	  reservada, o NULL (0) si la asignación falló (sin memoria disponible).
;	- El heap es una región de memoria gestionada dinámicamente, diferente del
;	  stack que tiene tamaño limitado y se gestiona automáticamente.
;
; Nota: malloc no inicializa la memoria, contiene "basura" (valores aleatorios).
; Nosotros debemos inicializar los campos data y next explícitamente.
; ______________________________________________________________________________
;
; Las líneas 49 y 50, verifican si malloc tuvo éxito:
;
;	test rax, rax: Realiza una operación AND lógica entre rax y rax, pero solo
;	actualiza las banderas del procesador sin modificar rax. Es equivalente a
;	cmp rax, 0 pero más eficiente en términos de código máquina.
;	- Si rax == 0 (NULL), la bandera ZF (Zero Flag) se establece a 1
;	- Si rax != 0, ZF se establece a 0
;
;	jz .error: "Jump if Zero" - Salta a .error si ZF == 1 (rax era NULL).
;	Esto maneja el caso donde malloc falló por falta de memoria.
;	Si malloc retornó NULL, no podemos continuar creando el nodo, por lo que
;	debemos limpiar el stack y retornar sin modificar la lista.
;
; ¿Por qué usar test en lugar de cmp?
;	test rax, rax es más compacto en código máquina que cmp rax, 0.
;	Es un patrón idiomático común en ensamblador x86-64 para verificar si un
;	registro es cero o NULL.
; ______________________________________________________________________________
;
; Las líneas 52 y 53, restauran los parámetros originales:
;
;	mov rsi, [rbp - 16]: Restaura el puntero data desde el stack a rsi.
;	Recuperamos el valor que habíamos guardado antes de llamar a malloc.
;
;	mov rdi, [rbp - 8]: Restaura el puntero begin_list desde el stack a rdi.
;
; En este punto tenemos:
;	- rax: puntero al nuevo nodo recién asignado (no NULL, porque pasamos el test)
;	- rsi: puntero data original
;	- rdi: puntero begin_list original
;
; Ahora podemos proceder a inicializar el nuevo nodo y modificar la lista.
; ______________________________________________________________________________
;
; Las líneas 55 a 58, construyen el nuevo nodo y actualizan la lista:
;
;	mov qword [rax], rsi: Inicializa el campo data del nuevo nodo.
;	- [rax] es la dirección del nuevo nodo (offset 0)
;	- qword indica que movemos 8 bytes (64 bits) = tamaño de un puntero
;	- Equivale a: nuevo_nodo->data = data
;	- El campo data ahora apunta a los datos proporcionados por el usuario
;
;	mov rcx, [rdi]: Lee el valor apuntado por begin_list (el antiguo primer
;	elemento de la lista) y lo almacena en rcx.
;	- [rdi] desreferencia el puntero: *begin_list
;	- Si la lista estaba vacía, rcx será NULL (0)
;	- Si la lista tenía elementos, rcx apunta al primer nodo antiguo
;
;	mov qword [rax + 8], rcx: Inicializa el campo next del nuevo nodo.
;	- [rax + 8] es la dirección del campo next (offset 8 bytes)
;	- Equivale a: nuevo_nodo->next = antiguo_primer_elemento
;	- Esto enlaza el nuevo nodo con el resto de la lista existente
;	- Si la lista estaba vacía, next será NULL, creando una lista de 1 elemento
;
;	mov qword [rdi], rax: Actualiza begin_list para que apunte al nuevo nodo.
;	- [rdi] desreferencia begin_list para modificar el puntero original
;	- Equivale a: *begin_list = nuevo_nodo
;	- Ahora el nuevo nodo es el primer elemento de la lista
;
; Resultado final: El nuevo nodo está al inicio, apuntando al antiguo primer
; elemento (si existía), y begin_list ha sido actualizado correctamente.
; Esta operación tiene complejidad temporal O(1) - tiempo constante.
; ______________________________________________________________________________
;
; Las líneas 60 y 61, son el retorno exitoso:
;
;	leave: Es una instrucción compuesta que realiza dos operaciones:
;	  1. mov rsp, rbp: Restaura el stack pointer al valor de rbp, eliminando
;	     todas las variables locales del stack frame actual.
;	  2. pop rbp: Restaura el valor anterior de rbp desde la pila, regresando
;	     al frame pointer del llamador.
;	Esta instrucción deshace exactamente lo que hicieron push rbp / mov rbp, rsp.
;	Es equivalente a escribir ambas instrucciones manualmente pero más compacta.
;
;	ret: Retorna al código que llamó a la función.
;	  - Extrae la dirección de retorno del stack (push automático en call)
;	  - Salta a esa dirección
;	  - El stack vuelve al estado anterior a la llamada
;	Como la función es void, no hay valor de retorno en rax, pero la lista
;	ha sido modificada exitosamente a través del puntero begin_list.
; ______________________________________________________________________________
;
; Las líneas 63 a 65, manejan el caso de error cuando malloc falla:
;
;	.error: Etiqueta local para el manejo de errores. Se llega aquí cuando
;	malloc retorna NULL (sin memoria disponible). En este caso, no podemos
;	crear el nuevo nodo, por lo que debemos limpiar y retornar sin hacer cambios.
;
;	leave: Limpia el stack frame igual que en el retorno exitoso.
;	Restaura rsp y rbp a sus valores originales, eliminando las variables locales
;	que habíamos reservado (los 16 bytes).
;
;	.end: Etiqueta local para salida sin operaciones. Se llega aquí desde dos rutas:
;	  1. Desde la línea 37 cuando begin_list es NULL (validación inicial)
;	  2. Desde el .error después de leave cuando malloc falla
;
;	ret: Retorna al llamador sin haber modificado la lista.
;	La función mantiene la garantía de que o bien la inserción es exitosa,
;	o bien la lista permanece sin cambios (seguridad transaccional).
; ______________________________________________________________________________
;
; Análisis de casos según estado de entrada:
;
; Caso 1: begin_list es NULL
;	→ Retorna inmediatamente en línea 37 sin hacer nada (protección)
;
; Caso 2: Lista vacía (*begin_list == NULL)
;	→ malloc reserva memoria
;	→ nuevo->data = data
;	→ nuevo->next = NULL (porque *begin_list era NULL)
;	→ *begin_list = nuevo (ahora apunta al primer nodo)
;	→ Resultado: Lista con un elemento
;
; Caso 3: Lista existente con elementos
;	→ malloc reserva memoria
;	→ nuevo->data = data
;	→ nuevo->next = antiguo_primer_nodo
;	→ *begin_list = nuevo
;	→ Resultado: Nuevo nodo insertado al inicio, lista creció en 1
;
; Caso 4: malloc falla (sin memoria)
;	→ malloc retorna NULL
;	→ Salta a .error
;	→ Limpia stack y retorna sin modificar lista
;	→ Resultado: Lista sin cambios (seguridad)
; ______________________________________________________________________________
;
; Diferencias con inserción al final (complejidad):
;
; Inserción al inicio (esta función):
;	- Complejidad temporal: O(1) - tiempo constante
;	- No necesita recorrer la lista
;	- Solo modifica el puntero begin_list
;	- Operación muy eficiente
;
; Inserción al final:
;	- Complejidad temporal: O(n) - tiempo lineal
;	- Debe recorrer toda la lista para encontrar el último nodo
;	- Modifica el campo next del último nodo existente
;	- Menos eficiente para listas grandes
;
; Por eso, cuando el orden no importa o se procesa en orden inverso, es
; preferible usar ft_list_push_front por su eficiencia.
; ______________________________________________________________________________
;
; Seguridad y robustez:
;
; La función implementa varias medidas de seguridad:
;
; 1. Validación de NULL pointer:
;	Verifica que begin_list no sea NULL antes de desreferenciar
;	→ Evita segmentation faults
;
; 2. Verificación de malloc:
;	Comprueba si malloc retornó NULL antes de usar la memoria
;	→ Manejo graceful de falta de memoria
;
; 3. Preservación de parámetros:
;	Guarda rdi y rsi en el stack antes de llamar a malloc
;	→ Garantiza que no se pierdan los valores originales
;
; 4. Alineación del stack:
;	Mantiene rsp alineado a 16 bytes según System V ABI
;	→ Compatibilidad con instrucciones SSE y convenciones del sistema
;
; 5. Limpieza del stack:
;	Siempre ejecuta leave antes de ret, incluso en errores
;	→ Evita corrupción del stack
;
; 6. Atomicidad conceptual:
;	O la operación completa es exitosa, o no se modifica nada
;	→ La lista nunca queda en estado inconsistente
; ==============================================================================
