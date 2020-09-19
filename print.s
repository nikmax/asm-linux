# Stack
# (%rsp) -> number of arguments
# 8(%rsp) -> address of the name of the executable
# 16(%rsp) -> address of the first command line argument (if exists)
# ... so on ...
.set    size,   1
.set    sys_read,  0
.set    sys_write, 1
.set    sys_open,  2
.set    sys_close, 3
.set    sys_exit,  60

.data

num:    .quad 0
.text

.globl _start
.globl _print_dec
_start:
        mov     (%rsp),  %rax     # Dividend in register schieben
_print_dec:
        mov     $10,  %r8      # Divisor
        xor     %r9, %r9      # Zähler für Anzahl der Ziffern

        mov     $10, %rsi    # zum testen 
        push    %rsi
        inc     %r9

lo:
        xor     %rdx, %rdx      # die Zahl in rdx:rax
        div     %r8
        add     $48,  %dl        # in ein Symbol konvertieren
        push    %rdx
        inc     %r9
        or      %rax, %rax      # sind wir fertig?
        jnz     lo

        mov     $sys_write, %rax
        mov     $1,  %rdi        # STDOUT
        mov     $1,  %rdx        # nur einen Byte
display:
        pop     %rsi
        mov     %rsi, (num)
        mov     $num, %rsi       # buffer
        syscall
        dec     %r9
        jnz     display

exit:
        mov    $sys_exit, %rax        # exit() system call
        xor    %rdi, %rdi      # return 0
        syscall
