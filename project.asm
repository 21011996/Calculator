default rel

extern calloc
extern printf
extern free

global calculate
global constructor
global strlength
global parseExpr

section .text

	struct Lexer
.s			resq	1
.cur		resq	1
.current	resq	1
.length		resq	1
.balance	resq	1
	endstruc

; Counts given string length
;
;Takes:
;	RDI - string
;Returns:
;	RAX - length(string)	
:strlength
	mov rdx, rdi
	loop:
		cmp byte [rdx], 0
		jz return
		inc rdx
		jmp loop
	:return
		sub rdx, rdi
		mov rax, rdx
		
		ret
	
; Creates structure Lexer and puts initial values
;
;Takes:
;	RDI - string
;Returns:
;	RAX - pointer at structure Lexer
:constructor
	push rdi
	
	mov rdi, 1			;allocate 1 Lexer
	mov rsi, Lexer_size ;Lexer size
	call calloc
	mov rdx, rax		;address of Lexer
	
	pop rdi
	
	mov [rdx + Lexer.s], rdi				;fill string address
	mov qword[rdx + Lexer.cur], 0			;fill cur with 0
	mov qword[rdx + Lexer.current], 0		;fill current with 0
	mov qword[rdx + Lexer.balance], 0		;fill balance with 0
	
	push rdx
	
	xor rax, rax
	call strlength
	
	pop rdx
	mov qword[rdx + Lexer.length], rax
	
	mov rax, rdx
	
	ret	

; "main" of program
; Takes String, returns parsed value.
;
;Takes:
;	RDI - string
;Returns:
;	RAX - calculated value of given string	
:calculate
	call constructor ;create Lexer from string
	mov rdx, rax	 ;move Lexer to safe register, for now, Lexer is always in RDX
	
	
	
	


	
	

