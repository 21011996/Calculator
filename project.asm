default rel

extern calloc
extern free

global calculate

section .text

; Structure Lexer to work with recursive calls from outside
;
; .s - address of substring
; .cur - number, witch reflects where parser is currently working in the .s
; .current - working string, usually = (Expression)
; .length - .s.length()
; .balance - counter for brackets balance, helps to check validity of .s  
	struc Lexer
.s:	resq	1
.cur:	resq	1
.current:	resq	1
.length:	resq	1
.balance:	resq	1
	endstruc

; To avoid tons of copy paste I use this macro for checking exception.
%macro check_error 0
	xor rax, rax
	cmp r9, rax
	jg .return_e
	jmp .proceed

	.return_e:
		ret
	
	.proceed:
%endmacro

;I'm too lazy to save NCSR 
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
	push r10	; because of working with recursive methods it's safer to save all used registers
	push r8 ; the only register, witch I don't need to save is RAX, 
			; because in recursion ones it contains answer, we got answer for everything.
	
	xor r10,r10	; r10 = length
	mov r8, rdi	; r8 = address of string
	
	.loop:
		cmp byte[r8], 0 ; if (end of string)
		je .return	; then
		inc r10	; else
		inc r8
		jmp .loop
		
	.return:
		mov rax, r10	; return answer
		
		pop r8
		pop r10
		ret
	
	ret


; Creates structure Lexer and puts initial values
;
;Takes:
;	RDI - string
;Returns:
;	RAX - pointer at structure Lexer
constructor:
	push rdx
	push rdi
	push rsi
	push r9
	
	mov rdi, 1	;allocate 1 Lexer
	mov rsi, Lexer_size	;Lexer size
	call calloc
	mov rdx, rax	;address of Lexer
	
	pop r9	; this is very important register 
	pop rsi
	pop rdi
	
	mov qword[rdx + Lexer.cur], 0	;fill cur with 0
	mov qword[rdx + Lexer.current], 0	;fill current with 0
	mov qword[rdx + Lexer.balance], 0	;fill balance with 0
	
	xor rax, rax
	call strlength
	
	mov qword[rdx + Lexer.length], rax
	
	push rdx
	push rdi
	push rsi
	push r9
	
	mov rdi, qword[rdx + Lexer.length]	;allocate length bytes for RCX
	mov rsi, 1
	call calloc
	
	pop r9	; this is very important register 
	pop rsi
	pop rdi
	pop rdx
	
	mov [rdx + Lexer.s], rax
	mov rcx, rax
	
	mov rax, rdx
	
	pop rdx
	
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

	push r14

	xor r14, r14
	mov r14b, byte[r15]
	sub r14b, '0'
	
	pop r14
	
	cmp byte[r15], '0'
	jl .return_0
	
	cmp byte[r15], '9'
	
	jg .return_0
	
	jmp .return_1
	
	.return_1:
		inc rax
		pop r15
		ret
	
	.return_0:
		pop r15
		ret


; Returns sub string - next token to parse
;
;Takes:
;	RDI - string
;	RDX - Lexer
;Returns:
;	RCX - sub string
next:
	push r11
	push r10
	push r15
	push rax
	
	mov r10, qword[rdx + Lexer.cur]
	mov r11, qword[rdx + Lexer.length]
	cmp r10, r11	;if (end of string)
	
	je .return_empty
	
	push rcx

	mov rcx, qword[rdx + Lexer.cur]	; if (charAtcur is digit)
	call isDigit

	pop rcx

	cmp rax, 1
	je .return_next_token	; then
	jmp .return_symbol	; else
	
	.return_next_token:
		push r14
		push r13
		push r12
		push r8
		
		mov r8, qword[rdx + Lexer.cur]	; create variable j = cur
		
		.loop1:
			mov r14, r8
			inc r14	; create j+1
			
			mov r13, qword[rdx + Lexer.length] ; r13 = s.length()
			
			cmp r14, r13	; !if (j+1<s.length)
			jge .return_substring	; then
			
			push rcx

			mov rcx, r14	; if !(char at j + 1 is digit)
			call isDigit

			pop rcx

			cmp rax, 0
			je .return_substring	; then
			
			inc r8
			jmp .loop1
		
		.return_substring:
			mov r12, qword[rdx + Lexer.cur]	; r12 = cur
			inc r8
			mov qword[rdx + Lexer.cur], r8	; set Lexer.cur = j + 1
			dec r8
			;copy sub string (r12, j) from rdi to rcx
			xor r11, r11
			.loop2:
				mov al, byte[rdi + r12]
				inc r12
				mov byte[rcx + r11], al
				inc r11
				cmp r12, r8
				jle .loop2
			
			mov byte [rcx+r11], 0
			
			pop r8
			pop r12
			pop r13
			pop r14
			
			jmp .cleanup_return
			
	.return_symbol:
		push r14
		
		mov r14, qword [rdx + Lexer.cur]	; move cur to r14
		add r14, rdi	; r14 = position in s of cur-th char
		mov al, byte [r14]	; al = s(cur)
		mov byte [rcx], al	; put answer
		mov byte [rcx + 1], 0
		
		add qword [rdx + Lexer.cur], 1
		
		pop r14
		jmp .cleanup_return
	
	.return_empty:
		mov byte [rcx], 0
		jmp .cleanup_return
		
	.cleanup_return:
		pop rax
		pop r15
		pop r10
		pop r11
		
		ret


; String to int
;
;Takes:
;	RDI - string
;Returns:
;	RAX - integer value of string
parseInt:
	push r11
	push r10
	push r8
	
	mov r8, rdi	; r8 = string
	xor r11, r11	; result is stored there
	
	.loop:
	xor r10, r10
	mov r10b, byte[r8]	; r10 = string[r8]
	cmp r10b, 0
	je .cleanup_return	;end of string
	
	inc r8
	sub r10b, '0'	; convert to number
	imul r11, 10	; r11*10 + r10
	add r11, r10
	
	jmp .loop
	
	.cleanup_return:
		mov rax, r11
		pop r8
		pop r10
		pop r11
		ret
	

; Parses value of Lexer.current
;
;Takes:
;	RDX + Lexer.current
;Returns
;	RAX - value
parseValue:
	check_error
	
	push r10
	
	mov r10, [rdx + Lexer.current]

	push rdi

	mov rdi, r10

	push rcx

	xor rcx, rcx
	call isDigit
	cmp rax, rcx	; if (current.charAt(0) is Digit)
	
	pop rcx

	pop rdi

	jg .return_value	; then
	
	cmp byte[r10], '('	; else
	je .return_Expression
	
	jmp .return_error
	
	.return_value:
		push rdi
		
		mov rdi, r10
		call parseInt

		pop rdi

		jmp .cleanup_return
		
	.return_Expression:

		push rcx

		mov rcx, qword[rdx + Lexer.balance]	; we entered new (), increase balance 
		inc rcx
		mov qword[rdx + Lexer.balance], rcx

		pop rcx

		call parseExpr
		jmp .cleanup_return
		
	.return_error:
		inc r9
		jmp .cleanup_return
		
	.cleanup_return:
		pop r10
		ret
		

; Parses expression in Lexer, return value of expression if it features mul
;
;Takes:
;	RDX - Lexer
;Returns:
;	RAX - value of Lexer
parseMultiplier:
	check_error
	
	push r11
	push r10
	push r8
	
	call next
	mov [rdx + Lexer.current], rcx	; current = next()
	mov r8, rcx	; r8 = next, to work with
	
	cmp byte[r8], 0
	je .return_error	; something is wrong with variable in String
	
	cmp byte[r8], '-'
	je .return_minus	; return left - right,
	
	cmp byte[r8], '+'
	je .return_abs
	
	call parseValue
	jmp .cleanup_return
	
	
	.return_error:
		inc r9	; basically r9 = 0, if r9>0 then error occured 
		jmp .cleanup_return
	
	.return_minus:
		call parseMultiplier
		mov r10, rax
		neg r10
		mov rax, r10
		jmp .cleanup_return
	
	.return_abs:
		call parseMultiplier
		mov r10, rax
		xor r11, r11
		cmp r10, r11
		jl .neg
		jmp .normal
		
		.neg:
			neg r10
			mov rax, r10
			jmp .cleanup_return
			
		.normal:
			mov rax, r10
			jmp .cleanup_return
		
	.cleanup_return:
		pop r8
		pop r10
		pop r11
		ret
	

; Parses expression in Lexer, return value of expression if it features sum
;
;Takes:
;	RDX - Lexer
;Returns:
;	RAX - value of Lexer
parseSum:
	check_error
	
	push r11
	push r10
	push r12
	push r8
	
	call parseMultiplier
	mov r12, rax	; lets call r12 "left"
	
	.loop:
		call next
		mov [rdx + Lexer.current], rcx	; current = next()
		mov r8, rcx	; r8 = next, to work with
		
		cmp byte[r8], '*'
		je .multiply
		
		cmp byte[r8], '/'
		je .divide
		
		cmp byte[r8], '%'
		je .mod
		
		jmp .return_left
		
		
	.multiply:
		call parseMultiplier
		imul r12, rax	; left = left * parseMultiplier()
		jmp .loop
		
	.divide:
		call parseMultiplier	; "right" = parseMultiplier
		mov r11, rax	; r11 = "right"
		
		xor r10, r10
		
		cmp r11, r10	; if (right = 0)
		je .return_error	; then
		; else
		push rdx	; preparations for IDIV
		xor rdx, rdx
		mov rax, r12
		
		idiv r11	; r12/r11
		mov r12, rax ; left = left / right
		
		pop rdx
		
		jmp .loop

	.mod:
		call parseMultiplier	; "right" = parseMultiplier
		mov r11, rax	; r11 = "right"
		
		xor r10, r10
		
		cmp r11, r10	; if (right = 0)
		je .return_error	; then
		; else
		push rdx	; preparations for IDIV
		xor rdx, rdx
		mov rax, r12
		
		idiv r11	; r12%r11
		mov r12, rdx ; left = left % right
		
		pop rdx
		
		jmp .loop
	
	.return_error:
		pop r8
		pop r12
		pop r10
		pop r11
		
		inc r9	; set error flag
		ret
		
	.return_left:
		mov rax, r12
		jmp .cleanup_return
		
	.cleanup_return:
		pop r8
		pop r12
		pop r10
		pop r11
		
		ret


; Parses expression in Lexer, return value of expression
;
;Takes:
;	RDX - Lexer
;Returns:
;	RAX - value of 
parseExpr:
	check_error
	
	push r12
	push r10
	push r11
	push r8

call parseSum
	mov r11, rax	; "left" = parseSum()
	
	.loop:
		mov r8, [rdx + Lexer.current]
		
		cmp byte[r8], ')'
		je .return_minus_balance
		
		cmp byte[r8], 0
		je .just_return
		
		cmp byte[r8], '+'
		je .sum
		
		cmp byte[r8], '-'
		je .diff
		
		jmp .return_error
		
	.return_minus_balance:
		mov r10, qword[rdx + Lexer.balance]	; balance--
		dec r10
		mov qword[rdx + Lexer.balance], r10
		
		mov rax, r11	; return left
		jmp .cleanup_return
		
	.just_return:
		mov rax, r11	; return left
		jmp .cleanup_return
		
	.sum:
		call parseSum
		add r11, rax	; left = left + parseSum()
		jmp .loop
		
	.diff:
		call parseSum
		sub r11, rax	; left = left - parseSum()
		jmp .loop
		
	.return_error:
		inc r9
		xor rax, rax
		jmp .cleanup_return
		
	.cleanup_return:
		pop r8
		pop r11
		pop r10
		pop r12
		
		ret
		
; Destroys Lexer for better future calls
;
; Takes:
;	RDX - Lexer to destroy	
deleteLexer:
	push rdi
	push rdx
	push r9
	push rax

	mov rdi, [rdx + Lexer.s]
	call free

	pop rax
	pop r9
	pop rdx
	pop rdi
	
	push rdi
	push rdx
	push r9
	push rax

	mov rdi, rdx
	call free

	pop rax
	pop r9
	pop rdx
	pop rdi
	
	ret

; int calculate(char const *s, int* code);
; Takes String, returns value.
;
;Takes:
;	RDI - string
;	RSI - error_code ( after executing calculate user can check int error_code)
;Returns:
;	RAX - calculated value of given string
calculate:
	push rsi	; just in case

	xor r9, r9	; r9 = 1 if an error occurred
	call constructor	; create Lexer from string
	mov rdx, rax	; move Lexer to safe register, from now, Lexer is always in RDX
	call parseExpr	; rax = parseExpr
	call deleteLexer	; subj	
	
	pop rsi

	push r8
	mov r8, [rdx + Lexer.balance]
	cmp r8, 0
	pop r8
	
	jne .return_error
	jmp .check_errors
	
	.return_error
		inc r9
		
	.check_errors
		mov qword[rsi], r9	; int error_code > 0, if there were errors
		cmp r9, 0
		jg .return_bad_number
		jmp .return_normal_number
	
	.return_bad_number:
		mov rax, 0
		
	.return_normal_number:
		ret
