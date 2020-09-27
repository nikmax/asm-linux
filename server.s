# simply TCP echo server
#
#      as --64 server.s -o server.o -a > server.l
#      ld -melf_x86_64 -e main -s server.o -o server
#
#
.include "syscalls.inc" 

.set 	buffer_size, 1024


.data
	sock: 			.quad   0
	read_count:		.quad 	0
	err_num:		.quad 	0
	client:			.quad   0
	num: 			.quad 	0
	buffer: 		.space 	buffer_size


	hello_msg: 		.asciz "Willkommen!\n"
	ok_msg: 		.asciz " ->OK\n"
	socket_msg: 	.asciz "Initialise socket: "
	bind_msg: 		.asciz "Try to bind socket: "
	listen_msg: 	.asciz "Listening on the port: "
	close_msg: 		.asciz "Try to close socket: "

    sock_err_msg:	.asciz " Failed to initialise socket\n"
    bind_err_msg: 	.asciz " Failed to bind socket to listening address\n"
    lstn_err_msg: 	.asciz " Failed to listen on socket\n"
    accept_err_msg: .asciz " Could not accept connection attempt\n"
    fork_err_msg: 	.asciz " Error fork status\n"
    accept_msg:     .asciz "Client connected! -> "
    client_closed: 	.asciz "Client closed.\n"
    crlf: 			.asciz "\n"

    # sockaddr_in structure for the address
    # the listening socket binds to
    server:
        sockaddr_in.sin_family: .word AF_INET    			# 2
        sockaddr_in.sin_port: 	.word 0x901f   # port 8080	# 2
        sockaddr_in.sin_addr: 	.byte 0,0,0,0   # localhost # 4 
        sockaddr_in.sin_zero: 	.quad 0 					# 8
    	.set sockaddr_in_len, . - server

.text
.globl main
main:
	# Initialise listening and client socket values to 0, used for cleanup handling
    xor %rax,%rax
    mov %rax,(client)
    mov %rax,(sock)

	call _fork
	test %rax, %rax
	jnz  _daemon1
	call _exit
_daemon1:
	mov $sys_setsid, %rax
	syscall
	#movl		$1,%EBX			# SIGHUP
	#movl		$1,%ECX			# SIG_IGN

	call _fork
	test %rax, %rax
	jnz  _daemon2
	call _exit
_daemon2:
    # Initialize socket Bind and Listen
    call _socket
	call _bind
	call _listen
	# Main loop handles clients connecting "accept()"
	# then echos any input
	# back to the client
	main_loop:
		call _accept
		mov %rax, %rdi
		call _fork
		test %rax, %rax
		jnz  is_fork
		#call _close_sock
		jmp main_loop
	# Read and Re-send all bytes sent by the client
	# until the client hangs up the connection on their end
	is_fork:#%rdi - socket fork
		mov %rdi,(client)
		mov $hello_msg, %rsi
		call _print_msg_fd
			read_loop:
			call _read
			call _echo
			# read_count is set to zero when client hangs up
			mov (read_count), %rax
			cmp $0, %rax
			jle 	read_complete
			jmp read_loop
		read_complete:
			# Close client socket
			mov (client), %rdi
			call _close_sock
			movq $0, (client)
			mov $client_closed, %rsi
			call _print_msg
			xor %rdi, %rdi      # return 0
			mov %rdi, (err_num)
			mov (client), %rdi
			call _close_sock
			jmp _exit
####################################################################
# Performs a sys_socket call to initialise a TCP/IP listening      #
# socket and reurn socket file descriptor in %rax                  #
####################################################################
_socket:
	mov $sys_socket, %rax 	# SYS_SOCKET
	mov $2, %rdi 			# AF_NET
	mov $1, %rsi 			# SOCK_STREAM
	mov $0, %rdx 			# protocol
	syscall
	# Chek socket was created correcktly
	mov $sock_err_msg, %rsi
	cmp $0, %rax
	jl _fail
    mov %rax, (sock)
	ret
####################################################################
# Calls sys_bind and sys_listen to start listening for connections #
####################################################################
_bind:
	mov $sys_bind, %rax 	# SYS_BIND
	mov (sock), %rdi 			# listening socket fd
	mov $server, %rsi 		# sockaddr in struct
	mov $sockaddr_in_len, %rdx
	syscall
	# Check for succeeded
	mov $bind_err_msg, %rsi
	cmp $0, %rax
	jl _fail
	ret
_listen:
	# Bind succeeded, call sys_listen
	mov $sys_listen, %rax	# SYS_LISTEN
	mov (sock), %rdi 			# listening socket fd
	mov $1, %rsi 			# backlog (dummy value really)
	syscall
	# Check for success
	mov $lstn_err_msg, %rsi
	cmp $0, %rax
	jl _fail
	ret
####################################################################
# Accepts a connection from a client, storing the client socket    #
# file descriptor in the client variable and loggin the connection #
# to stdout                                                        #
####################################################################
_accept:
	mov $sys_accept, %rax 	# SYS_ACCEPT
	mov (sock), %rdi 			# listenig socket fd
	mov $0, %rsi 			# NULL sockaddr_in value as we don't need that data
	mov $0, %rdx 			# Nulls have length 0
	syscall
	# Check call succeeded
	mov $accept_err_msg, %rsi
	cmp $0, %rax
	jl 	_fail
	# Store returned fd in variable
	#mov %rax, (client)
	push %rax
	# Log connection to stdout
	mov $accept_msg, %rsi
	call _print_msg
	pop %rax
	push %rax
	call _print_dec
	mov $crlf, %rsi
	call _print_msg	
	pop %rax
	ret
####################################################################
_fork:
	mov $sys_fork, %rax	# SYS_LISTEN
	syscall
	# Check for success
	mov $fork_err_msg, %rsi
	cmp $0, %rax
	jl _fail
	ret
####################################################################
# Reads up to 256 bytes from the client into buffer and sets the  #
# read_count variable to be the number of bytes read by sys_read
####################################################################
_read:
	mov $sys_read, %rax
	mov (client), %rdi
	mov $buffer, %rsi
	mov $buffer_size, %rdx
	syscall
	# Copy number of bytes read to variable
	mov %rax, (read_count)
	ret
####################################################################
# Sends up to the value of read_count bytes from buffer to the    #
# client socket using sys_write 
####################################################################
_echo:
	mov $sys_write, %rax
	mov (client), %rdi
	mov $buffer, %rsi
	mov (read_count), %rdx
	syscall
	mov $sys_write, %rax
	mov $stdout, %rdi
	mov $buffer, %rsi
	mov (read_count), %rdx
	syscall
	ret
####################################################################
# Performs sys_close on the socket in %rdi                         #
####################################################################
_close_sock:
	mov $sys_close, %rax
	syscall
	ret
####################################################################
# %rsi contains address to a message                                        #
####################################################################
_print_msg:
	push %rdi
	mov $stdout, %rdi		# %rdi stdout
	call _print_msg_fd
	pop %rdi
	ret
_print_msg_fd:# %rdi -fd , %rsi - msg
	push %rdx
	push %rax
	push %rcx
	xor %rdx,%rdx
 1:	cmpb $0,(%rdx,%rsi)
	je  2f
	inc %rdx
	jmp 1b
 2:	mov $sys_write, %rax 	# %rdx contains number of chars
	syscall
	pop %rcx
	pop %rax
	pop %rdx
	ret
####################################################################
# Calls the sys_write syscall, writing an error message to stderr, #
# the exits the application. %rsi must be populated with the error #
# message before calling _fail                                     #
####################################################################
_fail:
	mov %rax, (err_num)
	call _print_dec
	mov $stderr, %rdi
	call _print_msg_fd
	#mov $1, %rdi
####################################################################
# Exits cleanly, checking if the listening or client sockets need  #
# to be closed before calling sys_exit                             #
####################################################################
_exit:
	mov (sock), %rax
	cmp $0, %rax
	je 	3f
	mov (sock), %rdi
	#call _close_sock
 3:	mov (client), %rax
 	cmp $0, %rax
 	je 4f
 	mov (client), %rdi
 	#call _close_sock
 4:	mov $sys_exit, %rax
    mov (err_num), %rdi
    syscall
_print_dec: # zahl in %rax
		push 	%r8
		push 	%r9
		push 	%rsi
		push 	%rdx
		push 	%rax
        mov     $10,  %r8      # Divisor
        xor     %r9, %r9      # Zähler für Anzahl der Ziffern
        mov     $10, %rsi    # zum testen 
        #push    %rsi
        #inc     %r9
  	1: 	#
        xor     %rdx, %rdx      # die Zahl in rdx:rax
        div     %r8
        add     $48,  %dl        # in ein Symbol konvertieren
        push    %rdx
        inc     %r9
        or      %rax, %rax      # sind wir fertig?
        jnz     1b
        mov     $sys_write, %rax
        mov     $1,  %rdi        # STDOUT
        mov     $1,  %rdx        # nur einen Byte
  	2:
        pop     %rsi
        mov     %rsi, (num)
        mov     $num, %rsi       # buffer
        syscall
        dec     %r9
        jnz     2b
        pop 	%rax
        pop 	%rdx
        pop 	%rsi
        pop 	%r9
        pop 	%r8
        ret
