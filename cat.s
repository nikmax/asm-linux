# Stack
# (%rsp) -> number of arguments
# 8(%rsp) -> address of the name of the executable
# 16(%rsp) -> address of the first command line argument (if exists)
# ... so on ...


.set    sys_read,  0
.set    sys_write, 1
.set    sys_open,  2
.set    sys_close, 3
.set    sys_exit,  60

.data
msg:
        .ascii "Bitte Datei zum Anzeigen angeben!\n"
        .ascii "z.B. ./cat test.txt\n"
        .set len, . - msg
buf:
        .quad size
.text

.globl  _start
_start:
        mov     $len,   %rdx
        mov     $msg,   %rsi

        mov     (%rsp), %rax
        cmp     $1,     %rax
        ja      open
        mov    $sys_write, %rax        # write() system call
        mov    $1, %rdi        # fd STDOUT
        syscall
        jmp     close
open:
        mov    $sys_open, %rax  # open() system call
        mov    16(%rsp), %rdi   # first argument
        mov    $0, %rsi         # intended for reading
        mov    $0666, %rdx      # permission
        syscall

read:
        mov    %rax, %rdi      # store fd for read()
        mov    $sys_read, %rax        # read() system call
        mov    $buf, %rsi   # store buffer address
        mov    $size, %rdx     # buffer size
        syscall
    
        cmp    $0, %rax        # EOF
        jle     close           # close

display:# rdx 1
        mov     %rdi, %rbp      # store fd into %ebp
        mov    $sys_write, %rax        # write() system call
        mov    $1, %rdi        # fd STDOUT
        syscall
    
        mov     %rbp, %rax      # move fd into %eax
        jmp     read            # continue reading

close:
        mov    $sys_close, %rax        # close() system call
        mov    %rbp, %rdi      # move fd back into %ebx
        syscall

exit:
        mov    $sys_exit, %rax        # exit() system call
        xor    %rdi, %rdi      # return 0
        syscall
