;@Author: Michelangelo Sarafis
;@Description: A simple calculator written assembly(NASM). The C standard library
;has been used for the user input output.
;@License: Under the MIT public license
;@Version: 1.0

%include "atof.asm"

global _main

extern _printf
extern _scanf
extern _ExitProcess@4

section .data
    ;general variables
    intro_message db `Hello! Welcome to the "ASM Calculator".\n`, 10, 0
    menu db `\n1) Addition\n2) Subtraction\n3) Multiplication\n4) Division\n5) Exit\n`, 10, 0
    enter_your_choice db `\nPlease enter your choice:`, 10, 0
    bad_selection db `\nThe menu option does not exist!`, 10, 0
    enter_first_num_msg db `\nPlease enter the first number: `, 10, 0
    enter_second_num_msg db `\nPlease enter the second number: `, 10, 0
    exiting_message db `\n\nExiting ...`, 10, 0
    ;addition variables
    addition_greeting db `\n\nYou chose addition!`, 10, 0
    addition_result db `\n\nThe result of the addition is: `, 10 , 0
    ;subtraction variables
    subtraction_greeting db `\nYou chose Subtraction!`, 10, 0
    subtraction_result db `\nThe result of the subtraction is: `, 10 , 0
    ;multiplication variables
    multiplication_greeting db `\nYou chose Multiplication!`, 10, 0
    multiplication_result db `\nThe result of the multiplication is: `, 10 , 0
    ;division variables
    division_greeting db `\nYou chose Division!`, 10, 0
    division_result db `\nThe result of the division is: `, 10 , 0
    division_by_zero_msg db `\nSorry but division by zero is not possible!\n`, 10, 0
    ;printf/scanf variables
    scanf_filter db '%s', 0
    float_sign db '%0.2f', 10, 0
    buff dd 1.0
    
section .bss
    buffer: resb 8
section .text

;====================================== FUNCTIONS BELLOW ======================================
    
read_string:
    ;we push the buffer to save the data
    push buffer
    ;we push the "filter" that scanf needs
    push scanf_filter
    ;we call scanf
    call _scanf ;not the best approach; potential buffer overflow here
    ;we adjust the stack pointer
    add esp, 8
    ret
    
read_number:
    ;read a string from user first
    call read_string
    ;convert the user input to int
    push buffer
    ;we call the "function" that converts eax from string to integer
    call string_to_float
    ;we load the number to the fpu stack
    fld qword[esp]
    ;we save the number now to our buffer
    fstp qword[buff]
    ;clean the stack
    add esp, 8
    ret
    
compare_decimal_with_integer:
    ;save the return address
    mov ebx, esp
    ;remove the return address from the stack
    add esp, 4
    
    ;move the address of the buffer into eax
    mov eax, dword[esp]
    ;load the float from eax's address
    fld qword[eax]
    ;remove the address of the buffer from the stack
    add esp, 4
    
    ;we load the integer to the fpu stack
    fild dword[esp]
    ;we compare the data
    fcomi

    ;we clean the st0 and st1 FPU registers that hold our numbers
    ffreep st0
    ffreep st0
    
    ;we move the return address back to esp
    mov esp, ebx

    ret
    
;====================================== MAIN FUNCTION BELLOW ======================================
    
_main:
    mov ebp, esp; for correct debugging
    ;Greet the user
    push intro_message
    call _printf
    add esp,4
.START_OF_MENU:   
    ;Print the menu
    push menu
    call _printf
    add esp,4
    ;print the 'waiting user input' message
    push enter_your_choice
    call _printf
    add esp,4
    
    ;read an integer from the user and store it to eax
    call read_number
    
    push 1
    push buff
    call compare_decimal_with_integer
    je .ADDITION
    
    push 2
    push buff
    call compare_decimal_with_integer
    je .SUBTRACTION
    
    push 3
    push buff
    call compare_decimal_with_integer
    je .MULTIPLICATION
    
    push 4
    push buff
    call compare_decimal_with_integer
    je .DIVISION
    
    push 5
    push buff
    call compare_decimal_with_integer
    je .EXITPROGRAM
    
    ;if we reached that far, that means that the user
    ;has entered something invalid, so we inform him
    ;by taking the appropriate jump
    jmp .BADSELECTION
    
.ADDITION:
    ;inform the user that chose the addition as an option
    push addition_greeting
    call _printf
    add esp, 4
    ;ask for a user input
    push enter_first_num_msg
    call _printf
    add esp, 4

    ;we get number from the user
    call read_number
    ;we load the number from the buffer to the FPU
    fld qword[buff]
    
    ;ask for a user input again
    push enter_second_num_msg
    call _printf
    add esp, 4
    
    ;we get number from the user
    call read_number
    ;we load the number from the buffer to the FPU
    fld qword[buff]
    
    ;we add the numbers in st0 and st1
    fadd
    
    ;we print the message to the user, that will announce the result of the operation
    push addition_result
    call _printf
    add esp, 4
    
    ;we reserve space to save our result into the stack
    sub esp, 8
    ;we get the result of the operation and we pop it into our stack
    fstp qword[esp]
    
    ;we push the sign that is used for printf to print doubles
    push float_sign
    ;we call printf
    call _printf
    ;we clean the stack
    add esp, 12
        
    ;we jump to exit the program
    jmp .START_OF_MENU
    
.SUBTRACTION:
    ;greet again and inform the user that he selected subtraction
    push subtraction_greeting
    call _printf
    add esp, 4
    
    ;ask for a user input
    push enter_first_num_msg
    call _printf
    add esp, 4

    ;we get number from the user
    call read_number
    ;we load the number from the buffer to the FPU
    fld qword[buff]

    ;ask for a user input again
    push enter_second_num_msg
    call _printf
    add esp, 4
    
    ;we subtract the numbers in st0 and st1
    fsub
    
    ;we print the message to the user, that will announce the result of the operation
    push subtraction_result
    call _printf
    add esp, 4
    
    ;we reserve space to save our result into the stack
    sub esp, 8
    ;we get the result of the operation and we pop it into our stack
    fstp qword[esp]
    
    ;we push the sign that is used for printf to print doubles
    push float_sign
    ;we call printf
    call _printf
    ;we clean the stack
    add esp, 12
    
    jmp .START_OF_MENU

.MULTIPLICATION:
    ;greet again and inform the user that he selected multiplication
    push multiplication_greeting
    call _printf
    add esp, 4
    
    ;ask for a user input
    push enter_first_num_msg
    call _printf
    add esp, 4

    ;we get number from the user
    call read_number
    ;we load the number from the buffer to the FPU
    fld qword[buff]
    
    ;ask for a user input again
    push enter_second_num_msg
    call _printf
    add esp, 4
    
    ;we get number from the user
    call read_number
    ;we load the number from the buffer to the FPU
    fld qword[buff]
    
    ;we multiply the numbers in st0 and st1
    fmul
    
    ;we print the message to the user, that will announce the result of the operation
    push multiplication_result
    call _printf
    add esp, 4
    
    ;we reserve space to save our result into the stack
    sub esp, 8
    ;we get the result of the operation and we pop it into our stack
    fstp qword[esp]
    
    ;we push the sign that is used for printf to print doubles
    push float_sign
    ;we call printf
    call _printf
    ;we clean the stack
    add esp, 12
    
    jmp .START_OF_MENU
    
.DIVISION:
    ;greet again and inform the user that he selected division
    push division_greeting
    call _printf
    add esp, 4
    
    ;ask for a user input
    push enter_first_num_msg
    call _printf
    add esp, 4
    
    ;we get number from the user
    call read_number
    ;we load the number from the buffer to the FPU
    fld qword[buff]
    
    push enter_second_num_msg
    call _printf
    add esp, 4
    
    ;we get number from the user
    call read_number
    ;we load the number from the buffer to the FPU
    fld qword[buff]
    
    push 0
    push buff
    call compare_decimal_with_integer
    je .DIVISIONBYZERO
    
    ;we divide the numbers in st0 and st1
    fdiv
    
    ;we print the message to the user, that will announce the result of the operation
    push division_result
    call _printf
    add esp, 4
    
    ;we reserve space to save our result into the stack
    sub esp, 8
    ;we get the result of the operation and we pop it into our stack
    fstp qword[esp]
    
    ;we push the sign that is used for printf to print doubles
    push float_sign
    ;we call printf
    call _printf
    ;we clean the stack
    add esp, 12

    jmp .ENDOFDIVISION
    
    .DIVISIONBYZERO:
    ;we inform the user that he wanted to divide a number by zero
    finit
    push division_by_zero_msg
    call _printf
    add esp, 4
    jmp .ENDOFDIVISION
    
    .ENDOFDIVISION:
    jmp .START_OF_MENU
    
.BADSELECTION:
    ;we print the bad selection message
    push bad_selection
    call _printf
    add esp, 4
    jmp .START_OF_MENU
    
.EXITPROGRAM:  
    ;we print to the console that the program will exit, and we safely do so. 
    push exiting_message
    call _printf
    add esp, 4             
    call _ExitProcess@4