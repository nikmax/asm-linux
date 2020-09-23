# Stack
# (%rsp) -> number of arguments
# 8(%rsp) -> address of the name of the executable
# 16(%rsp) -> address of the first command line argument (if exists)
# ... so on ...

# ld -melf_x86_64 -e main 
.set    sys_write, 1
.set    sys_exit,  60
.set    stdout,    1



.data
msg:
        .asciz  "Hello, world!\n"
.text

.globl main
main:
        mov     $msg, %rsi
        mov     $stdout, %rdi
        call    print
exit:
        mov    $sys_exit, %rax        # exit() system call
        xor    %rdi, %rdi      # return 0
        syscall
##################################
#      print                     #
# zero terminated string ausgabe #
# %rsi zeiger auf String,        #
# %rdi Ausgabekanal              #
##################################
print:
        xor %rdx,%rdx
   1:   cmpb $0, (%rdx,%rsi)
        je 2f
        inc %rdx
        jmp 1b
   2:   mov     $sys_write, %rax
        syscall                   # %rax, %rsi, %rdi, %rdx
        ret
