; ==============================================================================
; ft_atoi_base - Convierte string a entero en base específica
; ==============================================================================
; Prototipo: int ft_atoi_base(char *str, char *base)
;
; Descripción:
;   Convierte la parte inicial de la cadena str a una representación
;   entera según la base proporcionada. Maneja espacios en blanco iniciales
;   y signos +/-. La base debe ser válida (sin duplicados, sin +/-, al menos 2 chars).
;
; Parámetros:
;   rdi (r12) - Puntero a la cadena a convertir
;   rsi (r13) - Puntero a la cadena de base
;
; Retorno:
;   rax - El número convertido, o 0 si la base es inválida
;
; Validación de base:
;   - Longitud mínima: 2 caracteres
;   - No puede contener: '+', '-', o espacios en blanco
;   - No puede tener caracteres duplicados
;
; Registros utilizados:
;   r12 - Puntero a str (modificado al saltar espacios y signos)
;   r13 - Puntero a base
;   r14 - Resultado acumulado
;   r15 - Indicador de signo (0=positivo, 1=negativo)
;   rbx - Longitud de la base
; ==============================================================================

section .text
	global ft_atoi_base

ft_atoi_base:
	push	rbx						; Longitud válida de la base
	push	r12						; Puntero a str (lo vamos a modificar)
	push	r13						; Puntero a base (constante)
	push	r14						; Resultado acumulado (el número que vamos construyendo)
	push	r15						; Bandera de signo (0 = positivo, 1 = negativo)
	
	mov		r12, rdi				; r12 = str
	mov		r13, rsi				; r13 = base
	xor		r14, r14				; r14 = resultado (inicializado a 0)
	xor		r15, r15				; r15 = signo (0 por defecto)
	
	call	.check_base				; Validar base y obtener longitud
	cmp		rax, 0
	jle		.return_zero			; Si longitud <= 0 → base inválida → retornar 0
	mov		rbx, rax				; rbx = longitud válida de la base
	
	call	.skip_whitespace		; Saltar espacios en blanco
	call	.handle_sign			; Procesar signos +/-
	call	.convert				; Convertir número
	
	cmp		r15, 1					; Verificar si es negativo
	jne		.return
	neg		r14						; Si negativo → negamos el resultado

.return:
	mov		rax, r14				; Retornar resultado
	pop		r15
	pop		r14
	pop		r13
	pop		r12
	pop		rbx
	ret

.return_zero:
	xor		rax, rax				; Retornar 0
	pop		r15
	pop		r14
	pop		r13
	pop		r12
	pop		rbx
	ret

; ------------------------------------------------------------------------------
; Subrutina: check_base
; Valida la base y retorna su longitud
; Retorno: rax = longitud de base (0 si es inválida)
; ------------------------------------------------------------------------------
.check_base:
	xor		rax, rax				; Contador de longitud = 0
	xor		rcx, rcx				; Índice = 0
.check_loop:
	movzx	edx, byte [r13 + rcx]	; Leer carácter de base
	cmp		dl, 0					; dl = base[rcx] (con zero-extend)
	je		.check_done				; Fin de cadena → terminar
	cmp		dl, '+'
	je		.check_invalid			; '+' no permitido
	cmp		dl, '-'
	je		.check_invalid			; '-' no permitido
	cmp		dl, ' '
	jle		.check_invalid			; Espacios/control no permitidos
	
	; Verificar duplicados
	push	rcx						; Guardar índice actual
	inc		rcx
.dup_loop:
	movzx	edi, byte [r13 + rcx]	; Leer siguiente carácter
	cmp		dil, 0
	je		.dup_ok					; No hay más caracteres
	cmp		dl, dil
	je		.check_invalid_pop		; Duplicado encontrado
	inc		rcx
	jmp		.dup_loop
.dup_ok:
	pop		rcx						; Restaurar índice original
	inc		rcx						; Avanzar al siguiente carácter a comprobar
	jmp		.check_loop
.check_invalid_pop:
	pop		rcx						; Limpiar pila
.check_invalid:
	xor		rax, rax
	ret
.check_done:
	cmp		rcx, 2					; Longitud mínima = 2
	jl		.check_invalid			; Longitud < 2 → inválida
	mov		rax, rcx				; Devolver longitud
	ret

; ------------------------------------------------------------------------------
; Subrutina: skip_whitespace
; Salta espacios en blanco al inicio de str
; ------------------------------------------------------------------------------
.skip_whitespace:
	xor		rcx, rcx
.ws_loop:
	mov		dl, byte [r12 + rcx]
	cmp		dl, ' '
	je		.ws_next
	cmp		dl, 9					; Tab horizontal
	jl		.ws_done
	cmp		dl, 13					; CR (retorno de carro)
	jg		.ws_done
.ws_next:
	inc		rcx
	jmp		.ws_loop
.ws_done:
	add		r12, rcx				; r12 += rcx → avanzar puntero
	ret

; ------------------------------------------------------------------------------
; Subrutina: handle_sign
; Procesa signos +/- y actualiza r15 (indicador de signo)
; ------------------------------------------------------------------------------
.handle_sign:
.sign_loop:
	mov		dl, byte [r12]
	cmp		dl, '+'
	je		.sign_plus
	cmp		dl, '-'
	je		.sign_minus
	ret								; Ningún signo → terminar
.sign_plus:
	inc		r12
	jmp		.sign_loop
.sign_minus:
	xor		r15, 1					; Invertir bit de signo (toggle)
	inc		r12
	jmp		.sign_loop

; ------------------------------------------------------------------------------
; Subrutina: convert
; Convierte la cadena numérica a entero según la base
; ------------------------------------------------------------------------------
.convert:
	xor		rcx, rcx
.conv_loop:
	mov		dl, byte [r12 + rcx]	; Carácter actual
	cmp		dl, 0
	je		.conv_done				; Fin de cadena
	
	push	rcx
	call	.find_in_base			; Buscar carácter en base
	pop		rcx
	cmp		rax, -1
	je		.conv_done				; Carácter no válido → parar
	
	imul	r14, rbx				; resultado *= base
	add		r14, rax				; resultado += índice
	inc		rcx
	jmp		.conv_loop
.conv_done:
	ret

; ------------------------------------------------------------------------------
; Subrutina: find_in_base
; Busca un carácter (dl) en la base y retorna su índice
; Retorno: rax = índice (o -1 si no se encuentra)
; ------------------------------------------------------------------------------
.find_in_base:
	xor		rax, rax
.find_loop:
	cmp		rax, rbx
	jge		.find_not_found			; Si índice >= longitud → no encontrado
	movzx	edi, byte [r13 + rax]
	cmp		dl, dil
	je		.find_found
	inc		rax
	jmp		.find_loop
.find_not_found:
	mov		rax, -1
.find_found:
	ret

; ==============================================================================
;
; Las líneas 31 y 32, son directivas de ensamblador que definen la estructura 
; y visibilidad de la función ft_atoi_base:
;
;	section .text: Declara la sección de código ejecutable del programa. 
;	En ensamblador, el código se organiza en secciones (.text para código, 
;	.data para datos inicializados, .bss para datos no inicializados).
;
;	global ft_atoi_base: Hace que el símbolo ft_atoi_base sea visible externamente, 
;	permitiendo que otros archivos objeto (como un código en C) puedan llamar 
;	a esta función durante el enlazado. Sin esta directiva, la función sería local
;	y no accesible desde fuera del archivo.
;
; En resumen: preparas la sección de código y exportas la función para que pueda 
; ser llamada desde C.
; ______________________________________________________________________________
;
; Las líneas 34 a 48, son el prólogo de la función e inicialización:
;
;	ft_atoi_base: Es la etiqueta que marca el inicio de la función. 
;	Esta es la dirección a la que se salta cuando se llama a ft_atoi_base.
;
;	push rbx, r12, r13, r14, r15: Guarda los registros callee-saved en la pila
;	según la convención de llamada x86-64. Estos registros deben ser preservados
;	a través de llamadas a funciones y restaurados antes de retornar.
;
;	mov r12, rdi / mov r13, rsi: Copia los parámetros de entrada (str y base)
;	a registros callee-saved para preservarlos durante toda la función.
;
;	xor r14, r14 / xor r15, r15: Inicializa a 0 el acumulador de resultado (r14)
;	y el indicador de signo (r15). La operación XOR es más eficiente que mov.
;
;	call .check_base: Llama a la subrutina que valida la base y retorna su longitud.
;
;	cmp rax, 0 / jle .return_zero: Si la base es inválida (longitud <= 0),
;	salta a retornar 0 como resultado.
;
;	mov rbx, rax: Guarda la longitud de la base en rbx para uso posterior.
; ______________________________________________________________________________
;
; Las líneas 50 a 52, son las llamadas a las subrutinas de procesamiento:
;
;	call .skip_whitespace: Invoca la subrutina que avanza el puntero r12
;	saltando todos los caracteres de espacio en blanco al inicio de la cadena.
;
;	call .handle_sign: Invoca la subrutina que procesa los signos '+' y '-',
;	actualizando r15 para rastrear si el resultado final debe ser negativo.
;
;	call .convert: Invoca la subrutina principal que convierte los dígitos
;	en la base especificada al valor numérico entero acumulado en r14.
; ______________________________________________________________________________
;
; Las líneas 54 a 56, son la aplicación del signo:
;
;	cmp r15, 1: Verifica si el indicador de signo es 1 (negativo).
;	r15 actúa como un flag booleano donde 0=positivo y 1=negativo.
;
;	jne .return: "Jump if Not Equal" - Si r15 no es 1 (es decir, es 0),
;	salta a .return sin aplicar negación. El número es positivo.
;
;	neg r14: Niega el valor en r14, convirtiendo el resultado positivo
;	acumulado en su equivalente negativo mediante complemento a dos.
; ______________________________________________________________________________
;
; Las líneas 58 a 64, son el epílogo y retorno normal:
;
;	.return: Etiqueta local que marca el punto de retorno normal.
;
;	mov rax, r14: Mueve el resultado final desde r14 al registro de retorno rax,
;	según la convención de llamada x86-64.
;
;	pop r15, r14, r13, r12, rbx: Restaura los registros callee-saved desde la pila
;	en orden inverso a como fueron guardados (LIFO - Last In, First Out).
;
;	ret: Retorna al código que llamó a la función con el resultado en rax.
; ______________________________________________________________________________
;
; Las líneas 66 a 73, son el retorno de error:
;
;	.return_zero: Etiqueta local para retornar 0 cuando la base es inválida.
;
;	xor rax, rax: Establece el valor de retorno a 0 mediante XOR.
;	Esto indica que la conversión falló debido a una base inválida.
;
;	pop r15, r14, r13, r12, rbx: Restaura los registros callee-saved desde la pila
;	para mantener el estado correcto de la pila antes de retornar.
;
;	ret: Retorna al llamador con 0 en rax.
; ______________________________________________________________________________
;
; Las líneas 75 a 117, implementan la subrutina .check_base:
;
;	.check_base: Subrutina que valida la base y calcula su longitud.
;	Una base válida debe tener al menos 2 caracteres, no contener '+', '-',
;	espacios o caracteres de control, y no tener caracteres duplicados.
;
;	xor rax, rax / xor rcx, rcx: Inicializa el contador de longitud (rax)
;	y el índice (rcx) a 0.
;
;	.check_loop: Bucle principal que itera sobre cada carácter de la base.
;
;	movzx edx, byte [r13 + rcx]: Lee un byte de la base y lo extiende con ceros
;	a un registro de 32 bits. 'movzx' (move with zero extension) evita basura
;	en los bits superiores de edx.
;
;	cmp dl, 0 / je .check_done: Si encuentra el terminador nulo '\0',
;	salta a verificar si la longitud es válida.
;
;	cmp dl, '+' / je .check_invalid: Valida que no haya '+' en la base.
;	cmp dl, '-' / je .check_invalid: Valida que no haya '-' en la base.
;	cmp dl, ' ' / jle .check_invalid: Valida que no haya espacios o caracteres
;	de control (ASCII <= 32).
;	____________________________________________________________________________
;
;	push rcx: Guarda el índice actual antes del bucle interno de duplicados.
;
;	inc rcx: Avanza al siguiente carácter para comenzar la búsqueda de duplicados.
;
;	.dup_loop: Bucle interno que verifica si el carácter actual (dl) aparece
;	más adelante en la base, lo cual invalidaría la base.
;
;	movzx edi, byte [r13 + rcx]: Lee el siguiente carácter para comparar.
;
;	cmp dil, 0 / je .dup_ok: Si llegamos al final sin encontrar duplicados,
;	el carácter actual es único.
;
;	cmp dl, dil / je .check_invalid_pop: Si encontramos el mismo carácter,
;	la base es inválida (tiene duplicados).
;
;	.dup_ok: pop rcx / inc rcx / jmp .check_loop: Restaura el índice,
;	lo incrementa para el siguiente carácter y continúa el bucle principal.
;
;	.check_invalid_pop: pop rcx: Restaura la pila antes de retornar error.
;	.check_invalid: xor rax, rax / ret: Retorna 0 indicando base inválida.
;
;	.check_done: cmp rcx, 2 / jl .check_invalid: Verifica que la base tenga
;	al menos 2 caracteres. Si es menor, retorna 0.
;	mov rax, rcx / ret: Retorna la longitud válida de la base.
; ______________________________________________________________________________
;
; Las líneas 119 a 136, implementan la subrutina .skip_whitespace:
;
;	.skip_whitespace: Subrutina que salta los espacios en blanco iniciales
;	en la cadena str, avanzando el puntero r12.
;
;	xor rcx, rcx: Inicializa el contador de caracteres a saltar.
;
;	.ws_loop: Bucle que examina cada carácter para determinar si es whitespace.
;
;	mov dl, byte [r12 + rcx]: Lee el carácter actual de la cadena.
;
;	cmp dl, ' ' / je .ws_next: Si es un espacio (ASCII 32), lo salta.
;
;	cmp dl, 9 / jl .ws_done: Si es menor que TAB (ASCII 9), no es whitespace.
;	Caracteres con código ASCII < 9 no son whitespace estándar.
;
;	cmp dl, 13 / jg .ws_done: Si es mayor que CR (ASCII 13), no es whitespace.
;	Los whitespace estándar están entre ASCII 9-13: TAB, LF, VT, FF, CR.
;
;	.ws_next: inc rcx / jmp .ws_loop: Incrementa el contador y continúa.
;
;	.ws_done: add r12, rcx / ret: Avanza el puntero r12 por el número de
;	caracteres whitespace encontrados y retorna.
; ______________________________________________________________________________
;
; Las líneas 138 a 152, implementan la subrutina .handle_sign:
;
;	.handle_sign: Subrutina que procesa signos '+' y '-' consecutivos
;	al inicio de la cadena numérica.
;
;	.sign_loop: Bucle que examina caracteres mientras sean signos.
;
;	mov dl, byte [r12]: Lee el carácter actual sin offset (directo desde r12).
;
;	cmp dl, '+' / je .sign_plus: Si es '+', salta a .sign_plus.
;	El signo '+' no afecta el resultado, solo avanza el puntero.
;
;	cmp dl, '-' / je .sign_minus: Si es '-', salta a .sign_minus.
;
;	ret: Si no es ni '+' ni '-', termina el procesamiento de signos.
;
;	.sign_plus: inc r12 / jmp .sign_loop: Avanza el puntero y continúa
;	buscando más signos (permite múltiples signos como "+++-5").
;
;	.sign_minus: xor r15, 1: Alterna el bit menos significativo de r15.
;	Esto invierte el signo: 0→1 (positivo→negativo) o 1→0 (negativo→positivo).
;	Cada '-' invierte el signo, así "--5" sería positivo y "---5" negativo.
;	inc r12 / jmp .sign_loop: Avanza y continúa el bucle.
; ______________________________________________________________________________
;
; Las líneas 154 a 175, implementan la subrutina .convert:
;
;	.convert: Subrutina principal que convierte los dígitos de la cadena
;	al valor numérico entero según la base especificada.
;
;	xor rcx, rcx: Inicializa el índice para recorrer la cadena str.
;
;	.conv_loop: Bucle que procesa cada carácter hasta encontrar uno inválido
;	o el final de la cadena.
;
;	mov dl, byte [r12 + rcx]: Lee el carácter actual de str.
;
;	cmp dl, 0 / je .conv_done: Si es '\0', termina la conversión.
;
;	push rcx: Guarda el índice antes de llamar a .find_in_base, ya que
;	esa subrutina usa rax como retorno y podría modificar otros registros.
;
;	call .find_in_base: Invoca la subrutina que busca el carácter (dl)
;	en la base y retorna su posición/índice en rax.
;
;	pop rcx: Restaura el índice después de la llamada.
;
;	cmp rax, -1 / je .conv_done: Si .find_in_base retornó -1, el carácter
;	no está en la base, por lo que termina la conversión aquí.
;
;	imul r14, rbx: Multiplica el resultado acumulado por la base.
;	Esto es equivalente a: resultado = resultado * base_length.
;	Por ejemplo, en base 10: 5 * 10 = 50 antes de agregar el siguiente dígito.
;
;	add r14, rax: Suma el valor del dígito actual (índice en base) al resultado.
;	Por ejemplo: 50 + 3 = 53.
;
;	inc rcx / jmp .conv_loop: Incrementa el índice y continúa con el siguiente carácter.
;
;	.conv_done: ret: Retorna con el resultado acumulado en r14.
; ______________________________________________________________________________
;
; Las líneas 177 a 191, implementan la subrutina .find_in_base:
;
;	.find_in_base: Subrutina que busca un carácter (dl) en la cadena base
;	y retorna su índice, o -1 si no se encuentra.
;
;	xor rax, rax: Inicializa el índice de búsqueda a 0.
;
;	.find_loop: Bucle que itera sobre cada carácter de la base.
;
;	cmp rax, rbx / jge .find_not_found: Si el índice alcanza o supera
;	la longitud de la base (rbx), el carácter no está en la base.
;	'jge' significa "jump if greater or equal" (signed comparison).
;
;	movzx edi, byte [r13 + rax]: Lee el carácter de la base en la posición
;	actual (rax) y lo extiende con ceros a un registro de 32 bits.
;	r13 contiene el puntero a la base.
;
;	cmp dl, dil: Compara el carácter buscado (dl) con el carácter actual
;	de la base (dil - parte baja de edi).
;
;	je .find_found: Si son iguales, se encontró el carácter.
;	rax ya contiene su índice, que es el valor de retorno deseado.
;
;	inc rax / jmp .find_loop: Incrementa el índice y continúa la búsqueda.
;
;	.find_not_found: mov rax, -1: Establece el valor de retorno a -1
;	para indicar que el carácter no se encontró en la base.
;
;	.find_found: ret: Retorna con el índice del carácter en rax
;	(o -1 si no se encontró).
; ==============================================================================
