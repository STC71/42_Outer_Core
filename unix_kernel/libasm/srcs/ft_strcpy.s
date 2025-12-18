; ==============================================================================
; ft_strcpy - Copia una cadena de caracteres
; ==============================================================================
; Prototipo: char *ft_strcpy(char *dst, const char *src)
;
; Descripción:
;   Copia la cadena apuntada por 'src' (incluyendo el '\0' final) al
;   buffer apuntado por 'dst'. El programador debe asegurar que hay
;   espacio suficiente en dst.
;
; Parámetros:
;   rdi - Puntero al buffer de destino
;   rsi - Puntero a la cadena fuente
;
; Retorno:
;   rax - Puntero al buffer de destino (dst)
;
; Registros utilizados:
;   rax - Puntero de retorno (dst guardado)
;   rcx - Índice para recorrer las cadenas
;   dl  - Byte temporal para la copia
; ==============================================================================

section .text
	global ft_strcpy

ft_strcpy:
	mov		rax, rdi				; Guardar dst para retorno
	xor		rcx, rcx				; Inicializar índice a 0

.loop:
	mov		dl, byte [rsi + rcx]	; Leer byte de src
	mov		byte [rdi + rcx], dl	; Escribir byte en dst
	cmp		dl, 0					; Verificar si es '\0'
	je		.end					; Si es '\0', terminar
	inc		rcx						; Incrementar índice
	jmp		.loop					; Repetir bucle

.end:
	ret								; Retornar puntero dst en rax

; ==============================================================================
;
; Las líneas 24 y 25, son directivas de ensamblador que definen la estructura 
; y visibilidad de la función ft_strcpy:
;
;	section .text: Declara la sección de código ejecutable del programa. 
;	En ensamblador, el código se organiza en secciones (.text para código, 
;	.data para datos inicializados, .bss para datos no inicializados).
;
;	global ft_strcpy: Hace que el símbolo ft_strcpy sea visible externamente, 
;	permitiendo que otros archivos objeto (como un código en C) puedan llamar 
;	a esta función durante el enlazado. Sin esta directiva, la función sería local
;	y no accesible desde fuera del archivo.
;
; En resumen: preparas la sección de código y exportas la función para que pueda 
; ser llamada desde C.
; ______________________________________________________________________________
;
; Las líneas 27 a 29, son la etiqueta de la función e inicialización de registros:
;
;	ft_strcpy: Es la etiqueta que marca el inicio de la función. 
;	Esta es la dirección a la que se salta cuando se llama a ft_strcpy.
;
;	mov rax, rdi: Guarda el puntero de destino (dst) en rax. Esto es necesario
;	porque la función debe retornar el puntero original de dst, pero rdi será
;	usado durante la copia.
;
;	xor rcx, rcx: Inicializa el registro rcx a 0 mediante una operación XOR 
;	consigo mismo. Este registro se usará como índice para recorrer ambas cadenas
;	(src y dst) simultáneamente. La operación XOR es más eficiente que mov rcx, 0.
; ______________________________________________________________________________
;
; Las líneas 31 a 37, son el bucle principal que copia la cadena carácter por carácter:
;
;	.loop: Etiqueta local del bucle. El punto (.) indica que es una etiqueta local
;	a la función ft_strcpy.
;
;	mov dl, byte [rsi + rcx]: Lee un byte de la cadena fuente en la dirección
;	(rsi + rcx) y lo almacena en el registro dl (parte baja de rdx). rsi contiene
;	la dirección base de src y rcx el desplazamiento actual.
;
;	mov byte [rdi + rcx], dl: Escribe el byte almacenado en dl a la dirección
;	(rdi + rcx) del buffer de destino.
;
;	cmp dl, 0: Compara el byte copiado con 0 ('\0') para detectar el final
;	de la cadena.
;
;	je .end: "Jump if Equal" - Salta a la etiqueta .end si el byte copiado
;	era el carácter nulo '\0', finalizando la copia.
;
;	inc rcx: Incrementa el índice en 1 para pasar al siguiente carácter.
;
;	jmp .loop: Salta incondicionalmente de vuelta a .loop para continuar copiando
;	el siguiente carácter.
; ______________________________________________________________________________
;
; Las líneas 39 y 40, son la finalización de la función:
;
;	.end: Etiqueta local que marca el final del bucle de copia.
;
;	ret: Retorna al código que llamó a la función. El valor de retorno (el puntero
;	original a dst) ya está en el registro rax, guardado al inicio de la función,
;	según la convención de llamada x86-64.
;
; ==============================================================================
