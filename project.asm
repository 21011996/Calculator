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
	
	mov rdi, 1	;allocate 1 Lexer
	mov rsi, Lexer_size	;Lexer size
	call calloc
	mov rdx, rax	;address of Lexer
	
	pop rdi
	
	mov [rdx + Lexer.s], rdi	;fill string address
	mov qword[rdx + Lexer.cur], 0	;fill cur with 0
	mov qword[rdx + Lexer.current], 0	;fill current with 0
	mov qword[rdx + Lexer.balance], 0	;fill balance with 0
	
	push rdx
	
	xor rax, rax
	call strlength
	
	pop rdx
	mov qword[rdx + Lexer.length], rax
	
	mov rax, rdx
	
	ret


; Returns 1 if char at RBX in RDI is digit, zero otherwise
;
;Takes:
;	RBX - number
;	RDI - string
;Returns:
;	RAX - answer
isDigit:
	xor rax, rax
	
	mov r15, rdi
	add r15, rbx
	
	cmp byte[r15], '0'
	jge .return_1
	
	cmp byte[r15], '9'
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
	push rsi
	
	mov r10, [rdx + Lexer.cur]
	cmp r10, [rdx + Lexer.length]	;if (end of string)
	
	je .return_empty
	
	mov rbx, qword[rdx + Lexer.cur]	; if (charAtcur is digit)
	call isDigit
	
	cmp rax, 1
	je .return_next_token	; then
	jmp .return_symbol	; else
	
	.return_next_token:
		mov r8, qword[rdx + Lexer.cur]	; create variable j
		
		.loop1:
			mov r14, qword[r8]
			inc r14	; create j+1
			
			mov r13, qword[rdx + Lexer.length] ; r13 = s.length()
			
			cmp r14, r13	; !if (j+1<s.length)
			jge .return_substring	; then
			
			mov rbx, r14	; if !(char at j + 1 is digit)
			call isDigit
			cmp rax, 0
			je .return_substring	; then
			
			inc r8
			jmp .loop1
		
		.return_substring:
			mov r12, qword[rdx + Lexer.cur]	; r12 = cur
			inc r8
			move qword[rdx + Lexer.cur], r8	; set Lexer.cur = j + 1
			dec r8
			;copy sub string (r12, j) from rdi to rsi
			.loop2:
				mov al, byte[rdi + r12]
				inc r12
				mov byte[rsi], al
				inc rsi
				cmp r12, r8
				jle .loop2
			
			mov byte [rsi], 0
			ret
			
			
		
		
	.return_symbol:
		mov r14, qword [rdx + Lexer.cur]	; move cur to r14
		add r14, rdi	; r14 = position in s of cur-th char
		mov al, byte [r14]	; al = s(cur)
		mov byte [rsi], al	; put answer
		inc rsi
		mov byte [rsi], 0
		
		add qword [rdx + Lexer.cur], 1
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
	call next
	
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
	call constructor	; create Lexer from string
	mov rdx, rax	 ; move Lexer to safe register, from now, Lexer is always in RDX
	call parseExpr
	
	ret

