%include "io.inc"

extern getAST
extern freeAST

struc Node
    data resd 1
    left resd 1
    right resd 1
endstruc
        
section .bss
    ; La aceasta adresa, scheletul stocheaza radacina arborelui
    root: resd 1

section .text
global main
atoi_function:
    push ebp
    mov ebp, esp  
    xor eax, eax ; stocheaza numarul convertit din string
    xor ecx, ecx ; contor pentru cifrele numarului de la stanga la dreapta
    mov edx, [ebp + 8]
atoi:
    mov bl, byte[edx]    ; iau fiecare cifra/operand din numar

    cmp bl, 0  ; verific daca am ajuns la finalul numarului
    jne convert_digit
    
    cmp ecx, 1 ; verific daca e operand(-, +, *, /) sau numar
    jg check_negative_before_exit
  
    cmp eax, 0  ; eax = 0 --> avem doar '-+*/' sau 0 ; eax > 0 --> avem doar o cifra > 0
    je op
    jmp leave_funct
    
convert_digit:
    cmp bl, '-'
    je negative_number
    cmp bl, '+'
    je op
    cmp bl, '*'
    je op
    cmp bl, '/'
    je op
    
    sub bl, 48 ; transform din caracter in cifra
    push ecx
    movsx ecx, bl 
    imul eax, 10 ; inmultesc numarul cu 10 
    add eax, ecx ; adun cifra la numar
    pop ecx
    
    inc edx
    inc ecx
    jmp atoi
    
negative_number:
    mov bh, 1    
    inc edx
    inc ecx
    jmp atoi
    
check_negative_before_exit:
    cmp bh, 1 
    je convert_negative
    jmp leave_funct

convert_negative:
    imul eax, -1
    jmp leave_funct
    
op:  
    mov edx, [ebp + 8]
    movsx eax, byte[edx]
    cmp eax, '0'
    je subs
    jmp leave_funct
subs:
    sub eax, 48
leave_funct:    
    leave
    ret
    
recursiveTraversal:
    push ebp
    mov ebp, esp
    mov ebx, [esp + 8] ; nodul de la care pornesc traversarea
    mov ecx, [ebx + left] ; fiul sau stang
    cmp ecx, 0 ; daca fiul sau stang e null, atunci e frunza
    je leaf
   
not_leaf:
    mov ebx, [ebx + data]
    push ebx
    call atoi_function
    add esp, 4
    push eax
    
    ; eax = recursiveTraversal(Node->left)
    ; ecx = recursiveTraversal(Node->right)
     ;return recursiveTraversal(Node->left) - recursiveTraversal(Node->right)  

LeftSubtree:
    mov ebx, [ebp + 8]
    mov ebx, [ebx + left] 
    push ebx
    call recursiveTraversal ; recursive call for left subtree
    add esp, 4    
    push eax
        
RightSubtree:
    mov ebx, [ebp + 8]
    mov ebx, [ebx + right]
    push ebx
    call recursiveTraversal
    add esp, 4
    push eax
    
    pop ecx ; valoarea din subarborele drept    
    pop eax ; valoarea din subarborele stang
    pop edx ; valoarea din nodul curent
    
    cmp edx, '-'
    je substract
    
    cmp edx, '+'
    je addition
    
    cmp edx, '*'
    je multiplication
    
    cmp edx, '/'
    je division
    
substract:
    xor edx, edx
    sub eax, ecx
    jmp exit_recursiveTraversal

addition:
    xor edx, edx
    add eax, ecx
    jmp exit_recursiveTraversal

multiplication:
    xor edx, edx
    imul eax, ecx
    jmp exit_recursiveTraversal

division:
    xor edx, edx
    cdq
    idiv ecx
    jmp exit_recursiveTraversal
    
leaf:
    mov eax, [ebx + data]
    push eax
    call atoi_function
    add esp, 4
    jmp exit_recursiveTraversal    

exit_recursiveTraversal:
    leave
    ret 
    
main:
    push ebp
    mov ebp, esp
    
    ; Se citeste arborele si se scrie la adresa indicata mai sus
    call getAST
    mov [root], eax

    mov ebx, [root]
    push ebx
    call recursiveTraversal
    add esp, 4
    PRINT_DEC 4, eax ; rezultatul functiei
          
    ; Se elibereaza memoria alocata pentru arbore
    push dword [root]
    call freeAST
    
    xor eax, eax
    leave
    ret