; ==============================================================================
; ft_strlen - Calcula la longitud de una cadena
; ==============================================================================
; Prototipo: size_t ft_strlen(const char *s)
;
; Descripción:
;   Calcula el número de caracteres en la cadena 's', excluyendo el
;   terminador nulo '\0'.
;
; Parámetros:
;   rdi - Puntero a la cadena de caracteres
;
; Retorno:
;   rax - Longitud de la cadena
;
; Registros utilizados:
;   rax - Contador de caracteres / valor de retorno
;   rdi - Puntero a la cadena (parámetro)
; ==============================================================================

section .text
	global ft_strlen

ft_strlen:
	xor		rax, rax				; Inicializar contador a 0
	
.loop:
	cmp		byte [rdi + rax], 0		; Comparar byte actual con '\0'
	je		.end					; Si es '\0', terminar
	inc		rax						; Incrementar contador
	jmp		.loop					; Repetir bucle

.end:
	ret								; Retornar longitud en rax

; ==============================================================================
; Las líneas 21 y 22, son directivas de ensamblador que definen la estructura 
; y visibilidad de la función ft_strlen:
;
;	section .text: Declara la sección de código ejecutable del programa. 
;	En ensamblador, el código se organiza en secciones (.text para código, 
;	.data para datos inicializados, .bss para datos no inicializados).
;
; global ft_strlen: Hace que el símbolo ft_strlen sea visible externamente, 
;	permitiendo que otros archivos objeto (como un código en C) puedan llamar 
;	a esta función durante el enlazado. Sin esta directiva, la función sería local
;	y no accesible desde fuera del archivo.
;
; En resumen: preparas la sección de código y exportas la función para que pueda 
; ser llamada desde C.
; ______________________________________________________________________________
;
; Las líneas 24 y 25, son la etiqueta de la función y la inicialización del 
; contador:
;
;	ft_strlen: Es la etiqueta que marca el inicio de la función. 
;	Esta es la dirección a la que se salta cuando se llama a ft_strlen.
;
;	xor rax, rax: Inicializa el registro rax a 0 mediante una operación XOR 
;	consigo mismo. Este registro se usará como contador para almacenar la longitud
;	de la cadena.
;
;	La operación XOR es más eficiente que mov rax, 0 porque genera código máquina 
;	más corto. La función XOR (OR exclusivo) realiza una operación lógica bit a bit, 
;	devolviendo 1 si los bits son diferentes y 0 si son iguales, siendo útil para 
;	invertir bits o inicializar registros a cero (XOR REG, REG). 
; ______________________________________________________________________________
;
; Las líneas 27 a 31, son el bucle principal que recorre la cadena:
;
;	.loop: Etiqueta local del bucle. El punto (.) indica que es una etiqueta local
;	a la función ft_strlen.
;
;	cmp byte [rdi + rax], 0: Compara el byte en la dirección (rdi + rax) con 0 ('\0').
;	rdi contiene la dirección base de la cadena y rax el desplazamiento actual.
;	La palabra clave 'byte' especifica que solo se compare 1 byte.
;
;	je .end: "Jump if Equal" - Salta a la etiqueta .end si la comparación anterior
;	fue igual (encontró el carácter nulo '\0') o sea, si cmp devolvió 0.
;
;	inc rax: Incrementa el contador en 1 para pasar al siguiente carácter.
;
;	jmp .loop: Salta incondicionalmente de vuelta a .loop para continuar verificando
;	el siguiente carácter.
; ______________________________________________________________________________
;
; Las líneas 33 y 34, son la finalización de la función:
;
;	.end: Etiqueta local que marca el final del bucle.
;
;	ret: Retorna al código que llamó a la función. El valor de retorno (la longitud
;	de la cadena) ya está en el registro rax según la convención de llamada x86-64.
; ==============================================================================