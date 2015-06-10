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

; Macro to push XMM registers
%macro push_xmm 1
	sub rsp, 16
	movsd [rsp], %1
%endmacro

%macro pop_xmm 1
	movsd %1, [rsp]
	add rsp, 16
%endmacro

;I'm too lazy to save NCSR 
%macro push_all_regs 0
    push    rdi
    push    rsi
    push    rdx
    push    rcx
    push    rbx
    push    r8
    push    r9
    push    r10
    push    r11
    push    r12
    push    r13
    push    r14
    push    r15
%endmacro


%macro pop_all_regs 0
    pop     r15
    pop     r14
    pop     r13
    pop     r12
    pop     r11
    pop     r10
    pop     r9
    pop     r8
    pop     rbx
    pop     rcx
    pop     rdx
    pop     rsi
    pop     rdi
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

	cmp byte[r15], '.'
	je .return_2
	
	cmp byte[r15], '0'
	jl .return_0
	
	cmp byte[r15], '9'
	
	jg .return_0
	
	jmp .return_1
	

	.return_2:
		inc rax
		inc rax
		pop r15
		ret

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
	push rbp
	
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

		xor rbp, rbp
		
		mov r8, qword[rdx + Lexer.cur]	; create variable j = cur
		
		.loop1:
			mov r14, r8
			inc r14	; create j+1
			
			mov r13, qword[rdx + Lexer.length] ; r13 = s.length()
			
			cmp r14, r13	; !if (j+1<s.length)
			jge .return_substring	; then
			
			push rcx

			mov rcx, r14	; if !(char at j + 1 is digit) or !(char at j + 1 is '.')
			call isDigit

			pop rcx

			cmp rax, 0
			je .return_substring	; then
			
			cmp rax, 2
			je .set_flag
				
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
	
	.set_flag
		cmp rbp, 0	; if flag > 0 then there are 2 '.' in one digit
		jg .return_empty
		inc rbp
		inc r8
		jmp .loop1
		
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
		pop rbp
		pop rax
		pop r15
		pop r10
		pop r11
		
		ret


; Converts string to double
; originally was made at 5th practice
;
; Takes:
;	RDI - string
; Returns:
;	XMM0 - double
str2double:
	push_xmm xmm1
        push rbp	; save CSR            
        push rbx
        push r12
        push r13
        push r14
        push r15
        mov r13, rdi	; move string to the safe place
        xorps xmm0, xmm0	; prepare for answer
        xor rdx, rdx	; make it zero to use as byte constant
        mov dl, byte [rdi]	; check for "-", but in calculate we dont have "-"
        cmp rdx, '-'
        jne .prep_fraction	; start
        inc rdi	; skip "-"

    .prep_fraction:
        xor rbx, rbx
        mov r10, 4503599627370495	; max Int, for cheking errors   
        mov r12, 10	; dec multiplier
        xor r11, r11                
        xor rax, rax
        xor rcx, rcx
    .loop:                         
        mov cl, byte [rdi]	; cl is a part of rcx, made it zero
        inc rdi	; next
        cmp rcx, 0	; if (end of string)
        je .done_fraction	; then
        cmp rcx, '.'	; else              
        je .begin_fraction	; if (we reached '.') then
        test r11, r11	; else
        jz .next_digit	; if (r11=0)
        inc r11	; r11 counts numbers after '.'
    .next_digit:
        sub rcx, '0'	; convert to decimal number
        mul r12	; mul by 10
        add rax, rcx	; and put it to sub-answer
        cmp rax, r10	; if (not overflow)
        jl .loop	; proceed
    .begin_fraction:                
        mov r11, 1 ; flag is 1, because we are doing .part   
        jmp .loop
    .done_fraction:                
        cvtsi2sd xmm0, rax	; xmm0 is string value, but ignores '.'
        dec r11	; so we need to shift it by 10 r11-1 times
        mov r9, 10
        cvtsi2sd xmm1, r9 ; xmm1 is a shifter
	cmp r11, 0
	jl .done ; if r11 = 0 then its int to double
    .loop1:
        divsd xmm0, xmm1	
        dec r11
        jnz .loop1

        xor rdx, rdx	; check if '-' was first byte
        mov dl, byte [r13]	; unused in my case
        cmp rdx, '-'
        jne .done
        movsd xmm1, xmm0            
        subsd xmm0, xmm1
        subsd xmm0, xmm1
    .done:
        pop r15                     
        pop r14
        pop r13
        pop r12
        pop rbx
        pop rbp
	pop_xmm xmm1
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
		
		push_all_regs

		mov rdi, r10
		call str2double
		
		pop_all_regs

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
		push_xmm xmm1
		
		movsd xmm1, xmm0            
		subsd xmm0, xmm1
		subsd xmm0, xmm1
		
		pop_xmm xmm1
		jmp .cleanup_return
	
	.return_abs:
		call parseMultiplier
		push_xmm xmm1
		push_xmm xmm2

		movsd xmm1, xmm0
		xorps xmm2, xmm2
		cmpsd xmm2, xmm1, 5 ; 0 not less then xmm1
		xor r11, r11
		cvtsd2si r10, xmm2
		jne .neg
		jmp .normal
		
		.neg:
			movsd xmm2, xmm1            
			subsd xmm1, xmm2
			subsd xmm1, xmm2
			movsd xmm0, xmm1
			
			pop_xmm xmm2
			pop_xmm xmm1
			jmp .cleanup_return
			
		.normal:
			movsd xmm0, xmm1
			
			pop_xmm xmm2
			pop_xmm xmm1
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
	push_xmm xmm1
	push_xmm xmm2
	movsd xmm1, xmm0	; lets call xmm1 "left"
	
	.loop:
		call next
		mov [rdx + Lexer.current], rcx	; current = next()
		mov r8, rcx	; r8 = next, to work with
		
		cmp byte[r8], '*'
		je .multiply
		
		cmp byte[r8], '/'
		je .divide
		
		jmp .return_left
		
		
	.multiply:
		call parseMultiplier
		
		mulsd xmm1, xmm0	; left = left * parseMultiplier()
		jmp .loop
		
	.divide:
		call parseMultiplier	; "right" = parseMultiplier
		push_xmm xmm3
		movsd xmm2, xmm0	; xmm2 = "right"
		
		xorpd xmm3, xmm3
		
		cmpsd xmm3, xmm2, 0	; if (right = 0)
		
		cvtsd2si r10, xmm3
		pop_xmm xmm3
		cmp r10, 0
		jg .return_error	; then
		; else
		divsd xmm1, xmm2	; left/right
		
		jmp .loop
	
	.return_error:		
		inc r9	; set error flag

		jmp .cleanup_return
		ret
		
	.return_left:
		movsd xmm0, xmm1
		jmp .cleanup_return
		
	.cleanup_return:
		pop_xmm xmm2
		pop_xmm xmm1

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
	push_xmm xmm1
	movsd xmm1, xmm0	; "left" = parseSum()
	
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
		
		movsd xmm0, xmm1	; return left
		jmp .cleanup_return
		
	.just_return:
		movsd xmm0, xmm1	; return left
		jmp .cleanup_return
		
	.sum:
		call parseSum
		addsd xmm1, xmm0	; left = left + parseSum()
		jmp .loop
		
	.diff:
		call parseSum
		subsd xmm1, xmm0	; left = left - parseSum()
		jmp .loop
		
	.return_error:
		inc r9
		xorpd xmm0, xmm0
		jmp .cleanup_return
		
	.cleanup_return:
		pop_xmm xmm1
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

; double calculate(char const *s, int* code);
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
		cvtsi2sd xmm1, rax
		movsd xmm0, xmm1 
		
	.return_normal_number:
		ret
