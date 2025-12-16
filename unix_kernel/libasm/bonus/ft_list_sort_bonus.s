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
