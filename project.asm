default rel

extern calloc
extern printf
extern free

global calculate
global constructor
global strlength
global parseExpr
global parseSum
global parseMultiplier
global next
global isDigit

section .text

	struc Lexer
.s:	resq	1
.cur:	resq	1
.current:	resq	1
.length:	resq	1
.balance:	resq	1
	endstruc
;I'm too lazy to save CSR 
%macro push_regs 0
	push rbx
	push rbp
	push rsi
	push rsp
	push r12
	push r13
	push r14
	push r15
%endmacro


%macro pop_regs 0
	pop r15
	pop r14
	pop r13
	pop r12
	pop rsp
	pop rsi
	pop rbp
	pop rbx
%endmacro

; Counts given string length
;
;Takes:
;	RDI - string
;Returns:
;	RAX - length(string)
strlength:
	xor rcx, rcx ; make 0
	xor al, al	; make 0
	not rcx	; make highest value 
	
	cld
	repne scasb	; finding NULL in string
	
	not rcx
	dec rcx	; converting RCX to the answer value
	mov rax, rcx
	
	ret


; Creates structure Lexer and puts initial values
;
;Takes:
;	RDI - string
;Returns:
;	RAX - pointer at structure Lexer
constructor:
	push rdi
	push rsi
	
	mov rdi, 1	;allocate 1 Lexer
	mov rsi, Lexer_size	;Lexer size
	call calloc
	mov rdx, rax	;address of Lexer
	
	pop rsi
	pop rdi
	
	mov [rdx + Lexer.s], rdi	;fill string address
	mov qword[rdx + Lexer.cur], 0	;fill cur with 0
	mov qword[rdx + Lexer.current], 0	;fill current with 0
	mov qword[rdx + Lexer.balance], 0	;fill balance with 0
	
	xor rax, rax
	call strlength
	
	mov qword[rdx + Lexer.length], rax
	
	mov rax, rdx
	
	ret


; Returns 1 if char at RCX in RDI is digit, zero otherwise
;
;Takes:
;	RCX - number
;	RDI - string
;Returns:
;	RAX - answer
isDigit:
	xor rax, rax
	
	push r15
	
	mov r15, rdi
	add r15, rcx
	
	cmp byte[r15], '0'
	jge .return_1
	
	cmp byte[r15], '9'
	
	pop r15
	
	jle .return_1
	
	jmp .return_0
	
	return_1:
		inc rax
		ret
	
	.return_0
		ret


; Returns sub string - next token to parse
;Takes:
;	RDI - string
;	RDX - Lexer
;Returns:
;	RSI - sub string
next:
	mov r10, qword[rdx + Lexer.cur]
	mov r11, qword[rdx + Lexer.length]
	cmp r10, r11	;if (end of string)
	
	je .return_empty
	
	mov rcx, qword[rdx + Lexer.cur]	; if (charAtcur is digit)
	call isDigit

	cmp rax, 1
	je .return_next_token	; then
	jmp .return_symbol	; else
	
	.return_next_token:
		mov r8, qword[rdx + Lexer.cur]	; create variable j = cur
		
		push r12
		push r13
		push r14
		
		.loop1:
			mov r14, qword[r8]
			inc r14	; create j+1
			
			mov r13, qword[rdx + Lexer.length] ; r13 = s.length()
			
			cmp r14, r13	; !if (j+1<s.length)
			jge .return_substring	; then
			
			mov rcx, r14	; if !(char at j + 1 is digit)
			call isDigit
			cmp rax, 0
			je .return_substring	; then
			
			inc r8
			jmp .loop1
		
		.return_substring:
			mov r12, qword[rdx + Lexer.cur]	; r12 = cur
			inc r8
			mov qword[rdx + Lexer.cur], r8	; set Lexer.cur = j + 1
			dec r8
			;copy sub string (r12, j) from rdi to rsi
			xor r11, r11
			.loop2:
				mov al, byte[rdi + r12]
				inc r12
				mov byte[rsi + r11], al
				inc r11
				cmp r12, r8
				jle .loop2
			
			mov byte [rsi+r11], 0
			
			pop r14
			pop r13
			pop r12
			
			ret
			
			
		
		
	.return_symbol:
		push r14
		
		mov r14, qword [rdx + Lexer.cur]	; move cur to r14
		add r14, rdi	; r14 = position in s of cur-th char
		mov al, byte [r14]	; al = s(cur)
		mov byte [rsi], al	; put answer
		mov byte [rsi + 1], 0
		
		add qword [rdx + Lexer.cur], 1
		
		pop r14
		ret
	
	.return_empty:
		mov byte [rsi], 0
		ret


	
; Parses expression in Lexer, return value of expression if it features mul
;
;Takes:
;	RDX - Lexer
;Returns:
;	RAX - value of Lexer
parseMultiplier:
	push rsi
	
	call next
	mov [rdx + Lexer.current], rsi	; current = next()
	mov r8, [rsi]	; r8 = next, to work with
	
	pop rsi
	
	cmp byte[r8], 0
	je .return_error
	
	cmp byte[r8], '-'
	je .return_minus
	
	cmp byte[r8], '+'
	je .return_abs
	
	
	.return_error:
		inc r9	; basically r9 = 0, if r9>0 then error occured 
		ret
	
	.return_minus
		call parseMultiplier
		mov r10, rax
		neg r10
		mov rax, r10
		ret
	
	.return_abs
		call parseMultiplier
		
	
	ret


; Parses expression in Lexer, return value of expression if it features sum
;
;Takes:
;	RDX - Lexer
;Returns:
;	RAX - value of Lexer
parseSum:
	call parseMultiplier
	
	ret


; Parses expression in Lexer, return value of expression
;
;Takes:
;	RDX - Lexer
;Returns:
;	RAX - value of 
parseExpr:
	call parseSum
	
	ret
	
; "main" of program
; Takes String, returns parsed value.
;
;Takes:
;	RDI - string
;Returns:
;	RAX - calculated value of given string
calculate:
	xor r9, r9	; r9 = 1 if an error occurred
	call constructor	; create Lexer from string
	mov rdx, rax	 ; move Lexer to safe register, from now, Lexer is always in RDX
	call parseExpr
	
	ret

