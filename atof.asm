;@Author: Michelangelo Sarafis
;@Description: A file that includes my implementation of the atof function
;@License: Under the MIT public license
;@Version: 1.0

global string_to_float

section .data
    ten dd 10
    zero dd 0

section .text

;Arguments: 1
;Type of argument: string
;Argument location: Top of the stack
;Return type: Float
;Returned at: Top of the stack
;Summary: This method is an assembly implementation of the atoif function. The caller has to clean up the stack
;after calling this function.
string_to_float:
    ;we add zero to the FPU register, as a dummy number
    fild dword[zero]
    mov ecx, dword[esp+4]
    ;we get first digit of the string
    mov al, [ecx]
    ;if the digit is equals to minus, then we jump to the appropriate label
    cmp al, '-'
    je .SIGNISNEGATIVE
    jmp .SIGNISPOSITIVE
    
    .SIGNISNEGATIVE:
    ;we move minus one to eax
    mov eax, -1
    ;we push it to the stack to save it
    push eax
    ;and we "remove" the character from our string
    inc ecx
    ;we begin the conversion on the numbers
    jmp .STARTOFINTEGERPART
    
    .SIGNISPOSITIVE:
    ;we move (positive) one into eax
    mov eax, 1
    ;we push it to the stack to save it
    push eax
    
    .STARTOFINTEGERPART:
    mov al, [ecx] ;we save a character to al (al is only 8 bits, so it takes only one char)
    
    ;if we reach the end of string, we stop the conversion
    cmp al, 0
    je .ENDOFCONVERSION
    ;if we reach the new line character, we stop the conversion
    cmp al, `\n`
    je .ENDOFCONVERSION
    ;if we find the point char, that means that the number has decimal
    ;part. So we continue by converting that
    cmp al, '.'
    je .STARTOFDECIMALPART
    
    ;we move the current character to eax
    movzx eax, al
    ;we remove '48' in order to transform the letter value, to number
    sub eax, 48
    
    ;we add the number 10 to the stack
    fild dword[ten]  
    ;we multiply the number that we got so far, by 10, in order to add numbers to its tail
    fmul

    ;we push the current number to the stack
    push eax
    ;we load it to the st0 FPU register
    fild dword[esp]
    ;we retreive the number back to eax
    pop eax
    
    ;we add the number to the total sum of the numbers
    fadd
    
    ;we increase ecx in order to go to the next character 
    ;and convert it in the next loop
    inc ecx
    
    ;we jump to the beginning of the loop
    jmp .STARTOFINTEGERPART
    
    .STARTOFDECIMALPART:
    ;we increase ecx in order to remove the point(.) from the string
    inc ecx
    ;edx will hold the number with which we wil divide the numbers
    ;to make them decimal
    mov edx, 10
    .STARTOFDECIMALLOOP:
    mov al, [ecx] ;we save a character to al (al is only 8 bits, so it takes only one char)
    
    ;if we reach the end of string, we stop the conversion
    cmp al, 0
    je .ENDOFCONVERSION
    ;if we reach the new line character, we stop the conversion
    cmp al, `\n`
    je .ENDOFCONVERSION
    
    ;we move the current character to eax
    movzx eax, al
    ;we remove '48' in order to transform the letter value, to number
    sub eax, 48
    
    ;we push the current number to the stack
    push eax
    ;we load it from the stack to the st0 FPU register
    fild dword[esp]
    ;we retreive the current number back to eax
    pop eax
    
    ;we push the divisor of the current number to the stack
    push edx
    ;we load it from the stack to the st0 FPU register
    fild dword[esp]
    ;we retreive the divisor to edx
    pop edx
    
    ;divide the current number with our divisor, in order to bring it
    ;to its decimal representation
    fdiv
    
    ;we increase ecx to remove the current character from the string
    inc ecx
    
    ;we multiply edx, which is our divisor, by 10, in order
    ;to do the next conversion in the next loop, if any.
    mov eax, 10
    mul edx
    mov edx, eax
    
    ;we add the newly added number to the total sum
    fadd
    jmp .STARTOFDECIMALLOOP
    
    .ENDOFCONVERSION:
    ;we load the sign of the number to the FPU st0 register
    fild dword[esp]
    ;we multiply our result by the sign (1 or -1) in order to change the sign of the result
    fmul
    ;remove sign from the stack
    add esp, 4
    ;we save the return address from the stack to eax
    mov eax, dword[esp]
    ;we remove the return address from the stack
    add esp, 8
    ;we reserve space for our result
    sub esp, 8
    ;we add the result to the top of the stack
    fstp qword[esp]

    ;we push the return address back to the stack
    push eax
    
    ret