; Johan Barrera - 1152538 - Arquitectura de computadores
; NASM, formato COM, codigo de 16 bits compatible con 8086.
bits 16
cpu 8086
org 100h
jmp inicio
valor_a dw 45
valor_b dw 12
resultado dw 0
contador db 5
mascara db 0Fh
inicio:
    mov dx, identidad
    mov ah, 9
    int 21h
    xor ax, ax
    xor bx, bx
    xor cx, cx
    xor dx, dx
    xor si, si
    xor di, di
    xor bp, bp

; BLOQUE 1: transferencia, direcciones y preservacion en pila.
transferencia:
    mov ax, [valor_a]
    mov bx, [valor_b]
    mov cx, ax
    mov dx, bx
    lea si, [valor_a]
    mov ax, [si]
    xchg cx, dx
    xchg cx, dx
    push ax
    mov ax, 0FFFFh
    pop ax
cp_transferencia:
    call mostrar
; BLOQUE 2: aritmetica. MUL de byte produce AX, no DX:AX.
    mov ax, [valor_a]
    add ax, [valor_b]
cp_add:
    mov [resultado], ax
    call mostrar
    mov ax, [valor_b]
    sub ax, [valor_a]
cp_sub:
    call mostrar
    mov ax, [valor_a]
    inc ax
    dec ax
    mov al, 10
    mov bl, 7
    mul bl
cp_mul:
    call mostrar
    mov ax, 100
    mov bl, 7
    div bl
cp_div:
    call mostrar
; BLOQUE 3: mascaras y desplazamientos.
    mov al, 0B7h
    and al, [mascara]
cp_and:
    call mostrar
    mov al, 0B7h
    or al, 0F0h
    mov al, 0AAh
    xor al, 0FFh
    xor bx, bx
    mov al, 0B7h
    test al, 1
cp_test:
    call mostrar
    mov al, 8
    shl al, 1
    shl al, 1
    shr al, 1
; BLOQUE 4: comparacion con signo y suma contada.
    mov ax, [valor_a]
    cmp ax, [valor_b]
cp_cmp:
    jg mayor
    je igual
    xor cx, cx
    jmp fin_cmp
mayor:
    mov cx, 1
    jmp fin_cmp
igual:
    mov cx, 2
fin_cmp:
    mov ax, 1
    mov cx, 5
    mov bx, 1
bucle_suma:
    mul bx
    inc bx
    loop bucle_suma
cp_bucle:
    call mostrar
; BLOQUE 5: cada operacion parte del mismo byte 81h.
    mov al, 81h
    mov bl, al
    shl bl, 1
cp_shl:
    call mostrar
    mov cl, al
    rol cl, 1
cp_rol:
    call mostrar
    mov dl, al
    shr dl, 1
cp_shr:
    call mostrar
    mov bh, al
    ror bh, 1
cp_ror:
    call mostrar
    mov al, 0A5h
    ; CL se preserva; cuatro rotaciones unitarias son validas en 8086.
    rol al, 1
    rol al, 1
    rol al, 1
    rol al, 1
cp_nibbles:
    call mostrar
fin:
    int 20h

; Imprime una instantanea REAL y restaura todos los registros y FLAGS.
; SP mostrado corresponde al llamador antes de CALL.
mostrar:
    pushf
    push ax
    push bx
    push cx
    push dx
    push si
    push di
    push bp
    mov bp, sp
    mov dx, titulo
    mov ah, 9
    int 21h
    mov si, nombres
    mov di, 12
    mov cx, 4
.reg:
    lodsb
    mov dl, al
    mov ah, 2
    int 21h
    mov dl, '='
    int 21h
    mov bx, [ss:bp+di]
    call hexword
    sub di, 2
    loop .reg
    mov dx, otros
    mov ah, 9
    int 21h
    mov bx, [ss:bp+4]
    call hexword
    mov bx, [ss:bp]
    call hexword
    lea bx, [bp+18]
    call hexword
    mov bx, [ss:bp+14]
    call hexword
    mov dx, salto
    mov ah, 9
    int 21h
    pop bp
    pop di
    pop si
    pop dx
    pop cx
    pop bx
    pop ax
    popf
    ret
hexword:
    push ax
    push cx
    push dx
    mov cx, 4
.hex:
    rol bx, 1
    rol bx, 1
    rol bx, 1
    rol bx, 1
    mov dl, bl
    and dl, 0Fh
    add dl, '0'
    cmp dl, '9'
    jbe .dig
    add dl, 7
.dig:
    mov ah, 2
    int 21h
    loop .hex
    mov dl, ' '
    mov ah, 2
    int 21h
    pop dx
    pop cx
    pop ax
    ret
salto db 13,10,'$'
titulo db 'AX/BX/CX/DX: $'
nombres db 'ABCD'
otros db ' SI BP SP FLAGS: $'
identidad db 'Johan Barrera | Cod: 1152538',13,10
          db 'Arquitectura de computadores - Unidad 6',13,10,'$'
