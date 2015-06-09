section .text

global str2double

; Converts string to double
; originally was made at 5th practice
;
; Takes:
;	RDI - string
; Returns:
;	XMM0 - double
str2double:
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
        ret
