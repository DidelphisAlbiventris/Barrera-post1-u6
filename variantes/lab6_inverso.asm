; Johan Barrera - 1152538 - Arquitectura de computadores
; NASM, formato COM, codigo de 16 bits compatible con 8086.
bits 16
cpu 8086
org 100h
jmp inicio
array dw 10,20,30,40,50
nota1 dw 85
nota2 dw 73
promedio dw 0
var_x dw 0FFFFh
matriz dw 1,2,3,4,5,6,7,8,9
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

; MODO 1: inmediatos; CX y DX se inicializaron para reproducibilidad.
inmediato:
    mov ax, 100
    mov bx, 0A5h
    add cx, 55
    and dx, 00FFh
cp_inmediato:
    call mostrar
; MODO 2: direccion directa relativa a DS.
directo:
    mov ax, [var_x]
    mov bx, [array]
    mov cx, [nota1]
    mov word [var_x], 0
cp_directo:
    call mostrar
; MODO 3: puntero en SI, segmento DS por defecto.
indirecto:
    mov si, nota1
    mov ax, [si]
    mov si, nota2
    mov bx, [si]
    add ax, bx
    shr ax, 1
    mov si, promedio
    mov [si], ax
cp_indirecto:
    call mostrar
; MODO 4: base + indice; elementos word de dos bytes.
indexado:
    mov bx, array
    mov si, 4
    mov ax, [bx+si]
cp_elemento:
    call mostrar
    xor ax, ax
    mov bx, array
    mov cx, 5
    mov si, 8
bucle_array:
    add ax, [bx+si]
    sub si, 2
    loop bucle_array
cp_array:
    call mostrar
    mov bx, nota1
    mov ax, [bx]
    mov cx, [bx+2]
    mov dx, [bx+4]
cp_struct:
    call mostrar
; MARCO BP: SS es el segmento predeterminado.
marco:
    push bp
    mov bp, sp
cp_reserva_antes:
    sub sp, 4
cp_reserva_despues:
    mov word [bp-2], 99
    mov word [bp-4], 250
cp_locales:
    mov ax, [bp-2]
    add ax, [bp-4]
cp_pila:
    call mostrar
    mov sp, bp
    pop bp
cp_restaurado:
    nop
; MATRIZ: EA = base + (fila*3+columna)*2.
matriz_inicio:
    mov ax, 1
    mov bx, 3
    mul bx
    shl ax, 1
    mov si, ax
    mov cx, 2
    shl cx, 1
    add si, cx
    mov bx, matriz
    mov dx, [bx+si]
cp_matriz:
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
