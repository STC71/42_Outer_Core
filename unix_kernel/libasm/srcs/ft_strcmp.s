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
	xor		rax, rax				; Limpiar rax, almacena bytes de S1
	xor		rcx, rcx				; Inicializar índice a 0, recorra S1 y S2

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

; ==============================================================================
;
; Las líneas 26 y 27, son directivas de ensamblador que definen la estructura 
; y visibilidad de la función ft_strcmp:
;
;	section .text: Declara la sección de código ejecutable del programa. 
;	En ensamblador, el código se organiza en secciones (.text para código, 
;	.data para datos inicializados, .bss para datos no inicializados).
;
;	global ft_strcmp: Hace que el símbolo ft_strcmp sea visible externamente, 
;	permitiendo que otros archivos objeto (como un código en C) puedan llamar 
;	a esta función durante el enlazado. Sin esta directiva, la función sería local
;	y no accesible desde fuera del archivo.
;
; En resumen: preparas la sección de código y exportas la función para que pueda 
; ser llamada desde C.
; ______________________________________________________________________________
;
; Las líneas 29 a 31, son la etiqueta de la función e inicialización de registros:
;
;	ft_strcmp: Es la etiqueta que marca el inicio de la función. 
;	Esta es la dirección a la que se salta cuando se llama a ft_strcmp.
;
;	xor rax, rax: Inicializa el registro rax a 0 mediante una operación XOR 
;	consigo mismo. Este registro se usará para almacenar los bytes de s1 y
;	eventualmente el valor de retorno.
;
;	xor rcx, rcx: Inicializa el registro rcx a 0 mediante una operación XOR 
;	consigo mismo. Este registro se usará como índice para recorrer ambas cadenas
;	(s1 y s2) simultáneamente. La operación XOR es más eficiente que mov rcx, 0.
; ______________________________________________________________________________
;
; Las líneas 33 a 41, son el bucle principal que compara las cadenas carácter por carácter:
;
;	.loop: Etiqueta local del bucle. El punto (.) indica que es una etiqueta local
;	a la función ft_strcmp.
;
;	mov al, byte [rdi + rcx]: Lee un byte de la primera cadena (s1) en la dirección
;	(rdi + rcx) y lo almacena en el registro al (parte baja de rax). rdi contiene
;	la dirección base de s1 y rcx el desplazamiento actual.
;
;	mov dl, byte [rsi + rcx]: Lee un byte de la segunda cadena (s2) en la dirección
;	(rsi + rcx) y lo almacena en el registro dl (parte baja de rdx).
;	____________________________________________________________________________
;
;	cmp al, dl: Compara los dos bytes leídos de s1 y s2.
;
;	jne .diff: "Jump if Not Equal" - Salta a la etiqueta .diff si los bytes son
;	diferentes, procediendo a calcular la diferencia.
;
;	cmp al, 0: Si los bytes son iguales, verifica si hemos llegado al final de
;	la cadena comprobando si el byte es '\0'.
;
;	je .equal: "Jump if Equal" - Si el byte es '\0', significa que ambas cadenas
;	son iguales hasta el final, salta a .equal para retornar 0.
;
;	inc rcx: Incrementa el índice en 1 para pasar al siguiente carácter.
;
;	jmp .loop: Salta incondicionalmente de vuelta a .loop para continuar comparando
;	el siguiente par de caracteres.
; ______________________________________________________________________________
;
; Las líneas 43 a 47, manejan el caso cuando se encuentra una diferencia:
;
;	.diff: Etiqueta local para el caso donde los bytes comparados son diferentes.
;
;	movzx rax, al: "Move with Zero Extend" - Copia el byte de al a rax,
;	extendiendo con ceros los bits superiores. Esto convierte el valor a un
;	entero sin signo de 64 bits, esencial para la comparación correcta según
;	el estándar strcmp.
;
;	movzx rdx, dl: Similar al anterior, extiende el byte de dl a rdx con ceros.
;
;	sub rax, rdx: Calcula la diferencia entre los dos valores. El resultado
;	será negativo si s1 < s2, positivo si s1 > s2.
;
;	ret: Retorna con la diferencia en rax.
; ______________________________________________________________________________
;
; Las líneas 49 a 51, manejan el caso cuando las cadenas son idénticas:
;
;	.equal: Etiqueta local para el caso donde las cadenas son completamente iguales.
;
;	xor rax, rax: Pone rax a 0 mediante XOR consigo mismo, indicando que no hay
;	diferencia entre las cadenas.
;
;	ret: Retorna con 0 en rax, indicando que s1 y s2 son iguales.
;
; ==============================================================================
