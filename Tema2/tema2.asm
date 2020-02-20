%include "include/io.inc"

extern atoi
extern printf
extern exit

; Functions to read/free/print the image.
; The image is passed in argv[1].
extern read_image
extern free_image
; void print_image(int* image, int width, int height);
extern print_image

; Get image's width and height.
; Store them in img_[width, height] variables.
extern get_image_width
extern get_image_height

section .data
	use_str db "Use with ./tema2 <task_num> [opt_arg1] [opt_arg2]", 10, 0

section .bss
    task:       resd 1
    img:        resd 1
    img_width:  resd 1
    img_height: resd 1

section .text
global main

; ***** FUNCTION FOR TASK 1 *****

bruteforce_singlebyte_xor:
    push ebp
    mov ebp, esp

    mov esi, [ebp + 8] ; image's address
    mov ebx, 0 ; store actual key's value   

search_the_correct_key:
    mov edx, 0 ; store line's index -> 0...[img_height-1]

line_by_line:
    mov ecx, 6 ; store column's index -> 0...[img_width-1]

column_by_column:
    mov edi, dword[img_width] 
    imul edi, edx
    add edi, ecx ; edi stores the position of the element within 
		 ; the image's matrix  
    mov eax, dword[esi + edi * 4] ; store in eax the element 
			          ; at the position edi
    xor eax, ebx ; xor between the current pixel and the key
    cmp eax, 0 
    je step_to_the_next_line
    
   ; check if the "revient" word is found in the matrix letter by letter:
   ; if I find the last letter of the word, I check the previous letter
   ; if the previous letter, I check the previous letter of the previous letter 
   ; and so on

current_char:    
    cmp eax, 't'
    je next_char1
    jmp step_to_the_next_column
    
next_char1: 
    mov eax, dword[esi + (edi - 1) * 4]
    xor eax, ebx
    cmp eax, 'n'
    je next_char2
    jmp step_to_the_next_column
    
next_char2:
    mov eax, dword[esi + (edi - 2) * 4]
    xor eax, ebx
    cmp eax, 'e'
    je next_char3
    jmp step_to_the_next_column
    
next_char3:    
    mov eax, dword[esi + (edi - 3) * 4]
    xor eax, ebx
    cmp eax, 'i'
    je next_char4
    jmp step_to_the_next_column
    
next_char4:
    mov eax, dword[esi + (edi - 4) * 4]
    xor eax, ebx
    cmp eax, 'v'
    je next_char5
    jmp step_to_the_next_column
    
next_char5:
    mov eax, dword[esi + (edi - 5) * 4]
    xor eax, ebx
    cmp eax, 'e'
    je next_char6
    jmp step_to_the_next_column
    
next_char6:
    mov eax, dword[esi + (edi - 6) * 4]
    xor eax, ebx
    cmp eax, 'r'
    je revient_found
    jmp step_to_the_next_column
    
revient_found:
    push edx ; place the value of the line on the stack
    push ebx ; place the value of the key on the stack
    
step_to_the_next_column:
    inc ecx
    cmp ecx, [img_width]
    jb column_by_column
   
step_to_the_next_line: 
    inc edx
    cmp edx, [img_height]
    jb line_by_line
    
next_key:
    inc ebx
    cmp ebx, 256 ; check if the actual key's dimension is one byte
    jb search_the_correct_key
    
    pop ebx
    pop edx
    
return_key_and_line_number:
    mov eax, ebx 
    shl eax, 16 ; the most 16-significant bits contains the key, the 
                ; least 16-significant bits are 0
    or ax, dx ; the least 16-significant bits contains the line's number
    leave 
    ret    
  
    
; ***** FUNCTION FOR TASK 2 *****  

encode_message:
    push ebp
    mov ebp, esp
    
    mov ecx, [ebp + 8] ; old key
    mov ebx, [ebp + 12] ; line
    mov esi, [ebp + 16] ; image
   
    ; calculate the new key
    movsx eax, cx
    imul eax, 2
    add eax, 3
    cdq
    mov edi, 5
    idiv edi

    ; the key must be always positive;
    ; => I apply the absolute value (module) in case it's negative
    cmp eax, 0
    jl make_positive
    jmp substract
    
make_positive:
    imul eax, -1

substract:
    sub eax, 4 ; eax - the new key 
    push eax ; the new key
    push ebx ; the line
    push ecx ; the old key
    
    pop ebx
    mov edx, 0 ; line's index

    ; decrypt the matrix with the old key
decrypt_line_by_line:
    mov ecx, 0 ; store column's index

decrypt_column_by_column:
    mov edi, dword[img_width]
    imul edi, edx
    add edi, ecx
    mov eax, dword[esi + edi * 4] ; edi retains the order of a element 
    xor eax, ebx ; xor between the current pixel and the key
    mov dword[esi + edi * 4], eax
    
decrypt_next_column:
    inc ecx
    cmp ecx, [img_width]
    jb decrypt_column_by_column

decrypt_next_line: 
    inc edx
    cmp edx, [img_height]
    jb decrypt_line_by_line
    mov edi, dword[img_width]
    pop edx
    inc edx
    imul edi, edx
    
    ; place the message in the image's matrix character by character
    xor ecx, ecx
    mov dword[esi + edi * 4], 'C'
   
    inc edi
    mov dword[esi + edi * 4], "'"
    
    inc edi
    mov dword[esi + edi * 4], 'e'
    
    inc edi
    mov dword[esi + edi * 4], 's'

    inc edi
    mov dword[esi + edi * 4], 't'
    
    inc edi
    mov dword[esi + edi * 4], ' '
    
    inc edi
    mov dword[esi + edi * 4], 'u'    

    inc edi
    mov dword[esi + edi * 4], 'n'
    
    inc edi
    mov dword[esi + edi * 4], ' '

    inc edi
    mov dword[esi + edi * 4], 'p'            
    
    inc edi
    mov dword[esi + edi * 4], 'r'
    
    inc edi
    mov dword[esi + edi * 4], 'o'
    
    inc edi
    mov dword[esi + edi * 4], 'v'
    
    inc edi
    mov dword[esi + edi * 4], 'e'

    inc edi
    mov dword[esi + edi * 4], 'r'
    
    inc edi
    mov dword[esi + edi * 4], 'b'
    
    inc edi
    mov dword[esi + edi * 4], 'e'
    
    inc edi
    mov dword[esi + edi * 4], ' '
    
    inc edi
    mov dword[esi + edi * 4], 'f'

    inc edi
    mov dword[esi + edi * 4], 'r'
    
    inc edi
    mov dword[esi + edi * 4], 'a'
    
    inc edi
    mov dword[esi + edi * 4], 'n'
    
    inc edi
    mov dword[esi + edi * 4], 'c'
    
    inc edi
    mov dword[esi + edi * 4], 'a'
    
    inc edi
    mov dword[esi + edi * 4], 'i'
    
    inc edi
    mov dword[esi + edi * 4], 's'
    
    inc edi
    mov dword[esi + edi * 4], '.' 
    
    inc edi
    mov dword[esi + edi * 4], 0
    mov edx, 0 ; line's index

    pop ebx
    
encrypt_line_by_line:
    mov ecx, 0 ; store column's index

    ; encrypt the matrix with the new key

encrypt_column_by_column:
    mov edi, dword[img_width]
    imul edi, edx
    add edi, ecx
    mov eax, dword[esi + edi * 4]
    xor eax, ebx ; xor between the current pixel and the key
    mov dword[esi + edi * 4], eax
    
encrypt_next_column:
    inc ecx
    cmp ecx, [img_width]
    jb encrypt_column_by_column

encrypt_next_line: 
    inc edx
    cmp edx, [img_height]
    jb encrypt_line_by_line
    
    mov eax, [img]    
    leave
    ret

; ***** FUNCTION FOR TASK 3 ***** 

morse_encrypt:
    push ebp
    mov ebp, esp
    
    mov edx, [ebp + 8] ; img
    mov ebx, [ebp + 12] ; msg
    mov ecx, [ebp + 16] ; byte_id
    
    push edx
    
    mov eax, ecx
    mov edi, 4
    mul edi 
    mov ecx, eax

    pop edx
    xor eax, eax
    
convert_msg_to_moise:
    cmp eax, 0 ; if it's the first letter of the message
    je without_space

    cmp byte[ebx + eax], 0 ; if it's the end of the message
    je without_space
   
    mov dword[edx + ecx], ' ' ; add a space after each character, except 
			      ; the first and the last
    add ecx, 4
    
without_space:
    cmp byte [ebx + eax], 'A'
    je case_A
    
    cmp byte[ebx + eax], 'B'
    je case_B
   
    cmp byte[ebx + eax], 'C'
    je case_C
        
    cmp byte[ebx + eax], 'D'
    je case_D
     
    cmp byte[ebx + eax], 'E'
    je case_E
    
    cmp byte[ebx + eax], 'F'
    je case_F

    cmp byte[ebx + eax], 'G'
    je case_G
    
    cmp byte[ebx + eax], 'H'
    je case_H
    
    cmp byte[ebx + eax], 'I'
    je case_I
    
    cmp byte[ebx + eax], 'J'
    je case_J
    
    cmp byte[ebx + eax], 'K'
    je case_K
    
    cmp byte[ebx + eax], 'L'
    je case_L
    
    cmp byte[ebx + eax], 'M'
    je case_M
    
    cmp byte[ebx + eax], 'N'
    je case_N

    cmp byte[ebx + eax], 'O'
    je case_O

    cmp byte[ebx + eax], 'P'
    je case_P
    
    cmp byte[ebx+ + eax], 'Q'
    je case_Q
    
    cmp byte[ebx + eax], 'R'
    je case_R
    
    cmp byte[ebx + eax], 'S'
    je case_S
    
    cmp byte[ebx + eax], 'T'
    je case_T
    
    cmp byte[ebx + eax], 'U'
    je case_U
    
    cmp byte[ebx + eax], 'V'
    je case_V
    
    cmp byte[ebx + eax], 'W'
    je case_W
    
    cmp byte[ebx + eax], 'X'
    je case_X
    
    cmp byte[ebx + eax], 'Y'
    je case_Y
    
    cmp byte[ebx + eax], 'Z'
    je case_Z
    
    cmp byte[ebx + eax], ','
    je case_coma
    
    cmp byte[ebx + eax], '1'
    je case_1
    
    cmp byte[ebx + eax], '2'
    je case_2
    
    cmp byte[ebx + eax], '3'
    je case_3
    
    cmp byte[ebx + eax], '4'
    je case_4
    
    cmp byte[ebx + eax], '5'
    je case_5
    
    cmp byte[ebx + eax], '6'
    je case_6
    
    cmp byte[ebx + eax], '7'
    je case_7
    
    cmp byte[ebx + eax], '8'
    je case_8
    
    cmp byte[ebx + eax], '9'
    je case_9
    
    
    cmp byte[ebx + eax], 0
    je print_img

case_A:
    mov dword[edx + ecx], '.'
    add ecx, 4 
    mov dword[edx + ecx], '-'
    add ecx, 4
    inc eax
    jmp convert_msg_to_moise
        
case_B:
    mov dword[edx + ecx], '-'
    add ecx, 4
    mov dword[edx + ecx], '.'
    add ecx, 4
    mov dword[edx + ecx], '.'
    add ecx, 4
    mov dword[edx + ecx], '.'
    add ecx, 4
    inc eax
    jmp convert_msg_to_moise

case_C:
    mov dword[edx + ecx], '-'
    add ecx, 4
    mov dword[edx + ecx], '.'
    add ecx, 4
    mov dword[edx + ecx], '-'
    add ecx, 4
    mov dword[edx + ecx], '.'
    add ecx, 4
    inc eax
    jmp convert_msg_to_moise

case_D:
    mov dword[edx + ecx], '-'
    add ecx, 4
    mov dword[edx + ecx], '.'
    add ecx, 4
    mov dword[edx + ecx], '.'
    add ecx, 4
    inc eax
    jmp convert_msg_to_moise
    
case_E:
    mov dword[edx + ecx], '.'
    add ecx, 4
    
    inc eax
    jmp convert_msg_to_moise
    
case_F:
    mov dword[edx + ecx], '.'
    add ecx, 4
    mov dword[edx + ecx], '.'
    add ecx, 4
    mov dword[edx + ecx], '-'
    add ecx, 4
    mov dword[edx + ecx], '.'
    add ecx, 4
    inc eax
    jmp convert_msg_to_moise
    
case_G:
    mov dword[edx + ecx], '-'
    add ecx, 4
    mov dword[edx + ecx], '-'
    add ecx, 4
    mov dword[edx + ecx], '.'
    add ecx, 4
    inc eax
    jmp convert_msg_to_moise

case_H:
    mov dword[edx + ecx], '.'
    add ecx, 4
    mov dword[edx + ecx], '.'
    add ecx, 4
    mov dword[edx + ecx], '.'
    add ecx, 4
    mov dword[edx + ecx], '.'
    add ecx, 4
    inc eax
    jmp convert_msg_to_moise

case_I:
    mov dword[edx + ecx], '.'
    add ecx, 4
    mov dword[edx + ecx], '.'
    add ecx, 4
    inc eax
    jmp convert_msg_to_moise
    
case_J:
    mov dword[edx + ecx], '.'
    add ecx, 4
    mov dword[edx + ecx], '-'
    add ecx, 4
    mov dword[edx + ecx], '-'
    add ecx, 4
    mov dword[edx + ecx], '-'
    add ecx, 4
    inc eax
    jmp convert_msg_to_moise
    
case_K:
    mov dword[edx + ecx], '-'
    add ecx, 4
    mov dword[edx + ecx], '.'
    add ecx, 4
    mov dword[edx + ecx], '-'
    add ecx, 4
    inc eax
    jmp convert_msg_to_moise
    
case_L:
    mov dword[edx + ecx], '.'
    add ecx, 4
    mov dword[edx + ecx], '-'
    add ecx, 4
    mov dword[edx + ecx], '.'
    add ecx, 4
    mov dword[edx + ecx], '.'
    add ecx, 4
    inc eax
    jmp convert_msg_to_moise
    
case_M:
    mov dword[edx + ecx], '-'
    add ecx, 4
    mov dword[edx + ecx], '-'
    add ecx, 4
    inc eax
    jmp convert_msg_to_moise
    
case_N:
    mov dword[edx + ecx], '-'
    add ecx, 4
    mov dword[edx + ecx], '.'
    add ecx, 4
    inc eax
    jmp convert_msg_to_moise
    
case_O:
    mov dword[edx + ecx], '-'
    add ecx, 4
    mov dword[edx + ecx], '-'
    add ecx, 4
    mov dword[edx + ecx], '-'
    add ecx, 4
    inc eax
    jmp convert_msg_to_moise
    
case_P:
    mov dword[edx + ecx], '.'
    add ecx, 4
    mov dword[edx + ecx], '-'
    add ecx, 4
    mov dword[edx + ecx], '-'
    add ecx, 4
    mov dword[edx + ecx], '.'
    add ecx, 4
    inc eax
    jmp convert_msg_to_moise
    
case_Q:
    mov dword[edx + ecx], '-'
    add ecx, 4
    mov dword[edx + ecx], '-'
    add ecx, 4
    mov dword[edx + ecx], '.'
    add ecx, 4
    mov dword[edx + ecx], '-'
    add ecx, 4
    inc eax
    jmp convert_msg_to_moise
    
case_R:
    mov dword[edx + ecx], '.'
    add ecx, 4
    mov dword[edx + ecx], '-'
    add ecx, 4
    mov dword[edx + ecx], '.'
    add ecx, 4
    inc eax
    jmp convert_msg_to_moise
    
case_S:
    mov dword[edx + ecx], '.'
    add ecx, 4
    mov dword[edx + ecx], '.'
    add ecx, 4
    mov dword[edx + ecx], '.'
    add ecx, 4
    inc eax
    jmp convert_msg_to_moise
    
case_T:
    mov dword[edx + ecx], '-'
    add ecx, 4
    inc eax
    jmp convert_msg_to_moise
    
case_U:
    mov dword[edx + ecx], '.'
    add ecx, 4
    mov dword[edx + ecx], '.'
    add ecx, 4
    mov dword[edx + ecx], '-'
    add ecx, 4
    inc eax
    jmp convert_msg_to_moise
    
case_V:
    mov dword[edx + ecx], '.'
    add ecx, 4
    mov dword[edx + ecx], '.'
    add ecx, 4
    mov dword[edx + ecx], '.'
    add ecx, 4
    mov dword[edx + ecx], '-'
    add ecx, 4
    inc eax
    jmp convert_msg_to_moise
    
case_W:
    mov dword[edx + ecx], '.'
    add ecx, 4
    mov dword[edx + ecx], '-'
    add ecx, 4
    mov dword[edx + ecx], '-'
    add ecx, 4
    inc eax
    jmp convert_msg_to_moise
    
case_X:
    mov dword[edx + ecx], '-'
    add ecx, 4
    mov dword[edx + ecx], '.'
    add ecx, 4
    mov dword[edx + ecx], '.'
    add ecx, 4
    mov dword[edx + ecx], '-'
    add ecx, 4
    inc eax
    jmp convert_msg_to_moise
    
case_Y:
    mov dword[edx + ecx], '-'
    add ecx, 4
    mov dword[edx + ecx], '.'
    add ecx, 4
    mov dword[edx + ecx], '-'
    add ecx, 4
    mov dword[edx + ecx], '-'
    add ecx, 4
    inc eax
    jmp convert_msg_to_moise
    
case_Z:
    mov dword[edx + ecx], '-'
    add ecx, 4
    mov dword[edx + ecx], '-'
    add ecx, 4
    mov dword[edx + ecx], '.'
    add ecx, 4
    mov dword[edx + ecx], '.'
    add ecx, 4
    inc eax
    jmp convert_msg_to_moise

case_coma:
    mov dword[edx + ecx], '-'
    add ecx, 4
    mov dword[edx + ecx], '-'
    add ecx, 4
    mov dword[edx + ecx], '.'
    add ecx, 4
    mov dword[edx + ecx], '.'
    add ecx, 4
    mov dword[edx + ecx], '-'
    add ecx, 4
    mov dword[edx + ecx], '-'
    add ecx, 4
    inc eax
    jmp convert_msg_to_moise

case_1:
    mov dword[edx + ecx], '.'
    add ecx, 4
    mov dword[edx + ecx], '-'
    add ecx, 4
    mov dword[edx + ecx], '-'
    add ecx, 4
    mov dword[edx + ecx], '-'
    add ecx, 4
    mov dword[edx + ecx], '-'
    add ecx, 4
    inc eax
    jmp convert_msg_to_moise
    
case_2:
    mov dword[edx + ecx], '.'
    add ecx, 4
    mov dword[edx + ecx], '.'
    add ecx, 4
    mov dword[edx + ecx], '-'
    add ecx, 4
    mov dword[edx + ecx], '-'
    add ecx, 4
    mov dword[edx + ecx], '-'
    add ecx, 4
    inc eax
    jmp convert_msg_to_moise
    
case_3:
    mov dword[edx + ecx], '.'
    add ecx, 4
    mov dword[edx + ecx], '.'
    add ecx, 4
    mov dword[edx + ecx], '.'
    add ecx, 4
    mov dword[edx + ecx], '-'
    add ecx, 4
    mov dword[edx + ecx], '-'
    add ecx, 4
    inc eax
    jmp convert_msg_to_moise
    
case_4:
    mov dword[edx + ecx], '.'
    add ecx, 4
    mov dword[edx + ecx], '.'
    add ecx, 4
    mov dword[edx + ecx], '.'
    add ecx, 4
    mov dword[edx + ecx], '.'
    add ecx, 4
    mov dword[edx + ecx], '-'
    add ecx, 4
    inc eax
    jmp convert_msg_to_moise
    
case_5:
    mov dword[edx + ecx], '.'
    add ecx, 4
    mov dword[edx + ecx], '.'
    add ecx, 4
    mov dword[edx + ecx], '.'
    add ecx, 4
    mov dword[edx + ecx], '.'
    add ecx, 4
    mov dword[edx + ecx ], '.'
    add ecx, 4
    inc eax
    jmp convert_msg_to_moise
    
case_6:
    mov dword[edx + ecx], '-'
    add ecx, 4
    mov dword[edx + ecx], '.'
    add ecx, 4
    mov dword[edx + ecx], '.'
    add ecx, 4
    mov dword[edx + ecx], '.'
    add ecx, 4
    mov dword[edx + ecx], '.'
    add ecx, 4
    inc eax
    jmp convert_msg_to_moise
    
case_7:
    mov dword[edx + ecx], '-'
    add ecx, 4
    mov dword[edx + ecx], '-'
    add ecx, 4
    mov dword[edx + ecx], '.'
    add ecx, 4
    mov dword[edx + ecx], '.'
    add ecx, 4
    mov dword[edx + ecx], '.'
    add ecx, 4
    inc eax
    jmp convert_msg_to_moise
    
case_8:
    mov dword[edx + ecx], '-'
    add ecx, 4
    mov dword[edx + ecx], '-'
    add ecx, 4
    mov dword[edx + ecx], '-'
    add ecx, 4
    mov dword[edx + ecx], '.'
    add ecx, 4
    mov dword[edx + ecx], '.'
    add ecx, 4
    inc eax
    jmp convert_msg_to_moise
    
case_9:
    mov dword[edx + ecx], '-'
    add ecx, 4
    mov dword[edx + ecx], '-'
    add ecx, 4
    mov dword[edx + ecx], '-'
    add ecx, 4
    mov dword[edx + ecx], '-'
    add ecx, 4
    mov dword[edx + ecx], '.'
    add ecx, 4
    inc eax
    jmp convert_msg_to_moise
    
case_0:
    mov dword[edx + ecx], '-'
    add ecx, 4
    mov dword[edx + ecx], '-'
    add ecx, 4
    mov dword[edx + ecx], '-'
    add ecx, 4
    mov dword[edx + ecx], '-'
    add ecx, 4
    mov dword[edx + ecx], '-'
    add ecx, 4
    inc eax
    jmp convert_msg_to_moise
    
print_img:
    mov dword[edx + ecx], 0
    mov ebx, [img_width]
    mov ecx, [img_height]
    push ecx
    push ebx
    push edx
    call print_image
    add esp, 12   
    
    leave
    ret
 
       
; ***** FUNCTION FOR TASK 4 *****

lsb_encode:
    push ebp
    mov ebp, esp

    mov esi, [ebp + 8] ; img
    mov edi, [ebp + 12] ; msg
    mov eax, [ebp + 16] ; byte_id
    dec eax
    
    mov ebx, 4
    mul ebx 
    
    xor edx, edx ; index used to iterate through the string

traverse_string:
    mov bl, byte[edi + edx] ; store the letters of the string one by one
    
    mov cl, 7 ; iterate through the bits of the letter 

bit_by_bit:
    push eax
    mov al, 1
    shl al, cl ; make the bit on the position cl in al equal to 1
    test bl, al ; check if the bit is 0 or 1
    jnz bit_set
    jmp bit_not_set


    ; if the bit is set and the LSB of the number at the position 
    ;eax is 1, do not change anyhting
    ; if the bit is set and the LSB of number at the position eax is 0, 
    ; make the LSB equal to 1 by adding to the number 2^0 

bit_set:
    pop eax
    bt dword[esi + eax], 0
    jc next_bit
    inc dword[esi + eax]
    jmp next_bit
    

    ; if the bit is set and the LSB of the number at the position 
    ;eax is 0, do not change anyhting
    ; if the bit is set and the LSB of number at the position eax is 1, 
    ; make the LSB equal to 0 by substractiong from the number 2^0 

bit_not_set:
     pop eax
     bt dword[esi + eax], 0
     jnc next_bit
     dec dword[esi + eax]
     
next_bit:
     add eax, 4
     dec cl
     cmp cl, -1
     jg bit_by_bit
     
next_letter:    
    inc edx
    cmp byte[edi + edx - 1], 0
    je end_of_string
    jmp traverse_string
    
end_of_string:
    mov eax, esi
    leave
    ret

; ***** FUNCTION FOR TASK 5 *****

lsb_decode:
    push ebp
    mov ebp, esp
    
    mov esi, [ebp + 8] ; img
    mov ebx, [ebp + 12] ; byte_id
    
    dec ebx
    imul ebx, 4 

find_a_new_letter:
    xor eax, eax ; the letter in decimal format
    xor edi, edi ; index used to iterate bit by bit through a letter
    xor edx, edx ; number of 0 bits in a letter

   ; take the LSB of each number starting from the byte_id and add
   ; it to the letter

find_a_new_bit_of_the_letter:
    bt dword[esi + ebx], 0
    jnc add_0_to_the_letter ; carry = 0 (the last bit is 0)
    
    bt dword[esi + ebx], 0
    jc add_1_to_the_letter ; carry = 1 (the last bit is 1)
    
add_0_to_the_letter:
    add ebx, 4 ; step to the next byte of the image
    inc edi ; found a new bit of the letter
    inc edx ; found a new 0-bit
    jmp check_new_letter
    
add_1_to_the_letter:
    add ebx, 4 ; step to the next byte of the image
    inc edi ; found a new bit of the letter
 
    mov ecx, 8
    sub ecx, edi
    
    push edi
    mov edi, 1
    shl edi, cl
    add eax, edi
    pop edi
    jmp check_new_letter

check_new_letter:
    cmp edx, 8  ; when 8 bits of 0 are found => the terminator of string 
    je leave_function
    
    cmp edi, 8  ; a letter contains 8 bits
    je print_the_letter
    jmp find_a_new_bit_of_the_letter
    
print_the_letter:   
    PRINT_CHAR eax
    jmp find_a_new_letter
    
leave_function:
    NEWLINE ; add the string terminator
    leave
    ret

; ***** FUNCTION FOR TASK 6 *****   

blur:
    push ebp
    mov ebp, esp
       
    mov esi, [ebp + 8] ; image
    
    mov ebx, 1 ; store line's index -> 1...[img_height] - 2
        
push_line_by_line:
    mov ecx, 1 ; store column's index -> 1...[img_width] - 2
    
push_column_by_column:         
    xor eax, eax    

    mov edi, dword[img_width]
    imul edi, ebx
    dec ecx
    add edi, ecx
    add eax, dword[esi + edi * 4] ; add left element to the current element
    inc ecx ; ecx back to its current value
    
    mov edi, dword[img_width]
    imul edi, ebx
    inc ecx
    add edi, ecx
    add eax, dword[esi + edi * 4] ; add right element to the current element
    dec ecx ; ecx back to its current value
    
    mov edi, dword[img_width]
    dec ebx
    imul edi, ebx
    add edi, ecx
    add eax, dword[esi + edi * 4] ; add upper element to the current element
    inc ebx ; ebx back to its current value
    
    mov edi, dword[img_width]
    inc ebx
    imul edi, ebx
    add edi, ecx
    add eax, dword[esi + edi * 4] ; add lower element to the current element
    dec ebx; ebx back to its current value
    
    mov edi, dword[img_width]
    imul edi, ebx
    add edi, ecx
    add eax, dword[esi + edi * 4] ; eax - current position value
    
    xor edx, edx
    cdq
    mov edi, 5
    idiv edi
    
    ; store on the stack the blurred pixel
    push eax
        
push_the_next_column:
    inc ecx
    mov edi, [img_width]
    dec edi
    cmp ecx, edi
    jb push_column_by_column
   
push_the_next_line: 
    inc ebx
    mov edi, [img_height]
    dec edi
    cmp ebx, edi
    jb push_line_by_line
   
   
;replace the values in image's matrix by traversing the matrix in reverse order
    mov ebx, [img_height] ; store line's index -> [img_height] - 2 ... 1
    dec ebx
    dec ebx
    
blur_line_by_line:
    mov ecx, [img_width] ; store column's index -> [img_width] - 2 ... 1
    dec ecx
    dec ecx
    
blur_column_by_column:         
    xor eax, eax    
    
    pop eax
    mov edi, dword[img_width]
    imul edi, ebx
    add edi, ecx
    mov dword[esi + edi * 4], eax ; eax - current position value
    
blur_the_next_column:
    dec ecx
    cmp ecx, 0
    jg blur_column_by_column
   
blur_the_next_line: 
    dec ebx
    cmp ebx, 0
    jg blur_line_by_line
     
    mov ebx, [img_width]
    mov ecx, [img_height]
    push ecx
    push ebx
    push esi
    call print_image
    add esp, 12
    leave 
    ret

    
main:
    ; Prologue
    ; Do not modify!
    push ebp
    mov ebp, esp
    mov eax, [ebp + 8]
    cmp eax, 1
    jne not_zero_param
    
    push use_str
    call printf
    add esp, 4

    push -1
    call exit

not_zero_param:
    
    ; We read the image. You can thank us later! :)
    ; You have it stored at img variable's address.
    mov eax, [ebp + 12]
    push DWORD[eax + 4]
    call read_image
    add esp, 4
    mov [img], eax

    ; We saved the image's dimensions in the variables below.
    call get_image_width
    mov [img_width], eax

    call get_image_height
    mov [img_height], eax
    
    ; Let's get the task number. It will be stored at task variable's address.
    mov eax, [ebp + 12]
    push DWORD[eax + 8]
    call atoi
    add esp, 4
    mov [task], eax

    ; There you go! Have fun! :D
    mov eax, [task]
    cmp eax, 1
    je solve_task1
    cmp eax, 2
    je solve_task2
    cmp eax, 3
    je solve_task3
    cmp eax, 4
    je solve_task4
    cmp eax, 5
    je solve_task5
    cmp eax, 6
    je solve_task6
    jmp done

solve_task1:
    mov ebx, [img]
    push ebx
    call bruteforce_singlebyte_xor   
    add esp, 4
    
    xor edx, edx
    movsx edx, ax ; edx - the line

    mov ebx, eax
    shr ebx, 16  ; ecx - the key

    mov ecx, -1 ; column's index

print_the_message:
    inc ecx
    mov edi, dword[img_width]
    imul edi, edx
    add edi, ecx
    mov eax, dword[esi + edi * 4]
    xor eax, ebx ; xor between the current pixel and the key
    cmp eax, 0
    je print_key_and_line_number
    PRINT_CHAR eax
    jmp print_the_message
       
print_key_and_line_number:
    NEWLINE
    PRINT_DEC 4, ebx
    NEWLINE
    PRINT_DEC 4, edx
    NEWLINE
    jmp done
    
solve_task2:    
    mov ebx, [img]
    push ebx
    call bruteforce_singlebyte_xor 
    add esp, 4
    
    xor edx, edx
    movsx edx, ax ; edx - the line
  
    mov ecx, eax
    shr ecx, 16  ; ecx - the key
    
    mov ebx, [img]
    push ebx  ; image
    push edx ; line
    push ecx ; key
    call encode_message
    add esp, 12
    
    mov edx, eax
    mov ebx, [img_width]
    mov ecx, [img_height]
    push ecx
    push ebx
    push edx
    call print_image
    add esp, 12   
    jmp done
    
solve_task3:
    mov ebx, [img]  
    
    ; convert byte_id from string to int
    mov eax, [ebp + 12]    
    push DWORD[eax + 16] ; byte_id as a string
    call atoi
    add esp, 4
    mov ecx, eax ; byte_id as int in ecx

    ; call the function morse_encrypt
    mov eax, [ebp + 12]
    push ecx ; byte_id
    push DWORD[eax + 12] ; msg
    push ebx ; img
    call morse_encrypt
    add esp, 12
    jmp done
    
solve_task4:
    mov ebx, [img] ; img
   
   ; convert the byte_id from string to int
    mov eax, [ebp + 12] ; the second argument of the main function 
    push DWORD[eax + 16] ; byte_id as a string
    call atoi
    add esp, 4
    mov ecx, eax ; ecx retains the byte_id
       
   ; call the function lsb_encode
    mov eax, [ebp + 12]
    push ecx ; byte_id
    push DWORD[eax + 12] ; msg
    push ebx ; img
    call lsb_encode
    add esp, 12
    
    mov edx, eax
    mov ebx, [img_width]
    mov ecx, [img_height]
    push ecx
    push ebx
    push edx
    call print_image
    add esp, 12   
    jmp done
    
solve_task5:
    mov ebx, [img]
    
    ; convert the byte_id from string to int
    mov eax, [ebp + 12] ; the second argument of the main function 
    push DWORD[eax + 12] ; byte_id as a string
    call atoi
    add esp, 4
    mov ecx, eax ; ecx retains the byte_id
    
    ; call the function lsb_decode
    push ecx
    push ebx
    call lsb_decode
    add esp, 8
    
    jmp done
    
solve_task6:
    mov ebx, [img]
    
    push ebx
    call blur
    add esp, 4
    
    jmp done

    ; Free the memory allocated for the image.
done:
    push DWORD[img]
    call free_image
    add esp, 4

    ; Epilogue
    ; Do not modify!
    xor eax, eax
    leave
    ret
