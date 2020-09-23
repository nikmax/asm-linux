# simply TCP echo server
#
#      as --64 server.s -o server.o -a > server.l
#      ld -melf_x86_64 -e main -s server.o -o server
#
#
.include "syscalls.inc" 

.set 	buffer_size, 1024
.set 	FD_SETSIZE,  3


.data
	sock1: 			.quad   0
	sock2: 			.quad   0
	sock3: 			.quad   0
	ready: 			.quad 	0
	sock_max: 		.quad	0
	max: 			.quad 	-1
	client_sock:	.rept 	FD_SETSIZE
					.quad   0
					.endr
	gesamt_sock: 	.quad 	0
	lese_sock: 		.quad 	0
	buffer: 		.space 	buffer_size

	hello_msg: 		.asciz "Gruss got:"
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
    crlf: 			.asciz "\n"

    # sockaddr_in structure for the address
    # the listening socket binds to
    server:
        sockaddr_in.sin_family: .word 2       # AF_INET
        sockaddr_in.sin_port: 	.word 0xfeff    # port 65534
        sockaddr_in.sin_addr: 	.long 0         # localhost
        sockaddr_in.sin_zero: 	.long 0,0
    	.set sockaddr_in_len, . - server

.text
.globl main
main:
    # Initialize socket
    call _socket
    mov %rax, (sock_max)
    mov %rax, (sock1)
	# Bind and Listen
	call _listen
	# Initialise values to -1, used for cleanup handling
	mov $FD_SETSIZE, %rcx
	mov $client_sock, %rdi
	xor %rax,%rax
	dec %rax
  1:mov %rax, (%rdi,%rcx,8)
  	dec %rcx
  	jnz 1b



	# Main loop handles clients connecting "accept()"
	# then echos any input
	# back to the client
	main_loop:
		call _accept
		mov $sys_fork, %rax
		syscall
		cmp $0, %rax
		mov $fork_err_msg, %rsi
		jl  _fail
		jnz read_loop  # fork
		mov (client), %rdi
	 	call _close_sock
		jmp main_loop
		#
	# Read and Re-send all bytes sent by the client
	# until the client hangs up the connection on their end
	read_loop:
#		mov $sys_write, %rax
#		mov (client), %rdi
#		mov $hello_msg, %rsi
#		mov $hello_msg_len, %rdx
#		syscall
#
#		mov $sys_select, %rax 	# SYS_SELECT
#		mov $2, %rdi 			# AF_NET
#		mov $1, %rsi 			# SOCK_STREAM
#		mov $0, %rdx
#		syscall
#

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
		xor %rdi, %rdi      # return 0
		jmp _exit_fork
####################################################################
# Performs a sys_socket call to initialise a TCP/IP listening      #
# socket and reurn socket file descriptor in %rax                  #
####################################################################
_socket:
	mov $socket_msg, %rsi
	call _print_msg

	mov $sys_socket, %rax 	# SYS_SOCKET
	mov $2, %rdi 			# AF_NET
	mov $1, %rsi 			# SOCK_STREAM
	mov $0, %rdx 			# protocol
	syscall
	# Chek socket was created correcktly
	mov $sock_err_msg, %rsi
	cmp $0, %rax
	jle _fail
	ret
####################################################################
# Calls sys_bind and sys_listen to start listening for connections #
####################################################################
_listen:
	mov $bind_msg, %rsi
	call _print_msg
	mov $sys_bind, %rax 	# SYS_BIND
	mov (sock1), %rdi 			# listening socket fd
	mov $server, %rsi 		# sockaddr in struct
	mov $sockaddr_in_len, %rdx
	syscall
	# Check for succeeded
	mov $bind_err_msg, %rsi
	cmp $0, %rax
	jl _fail
	# Bind succeeded, call sys_listen
	#call _print_dec
	#mov $ok_msg, %rsi
	#call _print_msg
	#mov $listen_msg, %rsi
	#call _print_msg
	mov $sys_listen, %rax	# SYS_LISTEN
	mov $1, %rsi 			# backlog (dummy value really)
	syscall
	# Check for success
	mov $lstn_err_msg, %rsi
	cmp $0, %rax
	jl _fail
	mov $ok_msg, %rsi
	call _print_msg
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
	mov %rax, (client)
	push %rax
	# Log connection to stdout
	mov $accept_msg, %rsi
	call _print_msg
	pop %rax
	call _print_dec
	mov $crlf, %rsi
	call _print_msg	
	ret
####################################################################
# Reads up to 256 bytes from the client into echobuf and sets the  #
# read_count variable to be the number of bytes read by sys_read
####################################################################
_read:
	mov $sys_read, %rax
	mov (client), %rdi
	mov $echobuf, %rsi
	mov $buffer_size, %rdx
	syscall
	# Copy number of bytes read to variable
	mov %rax, (read_count)
	ret
####################################################################
# Sends up to the value of read_count bytes from echobuf to the    #
# client socket using sys_write 
####################################################################
_echo:
	mov $sys_write, %rax
	mov (client), %rdi
	mov $echobuf, %rsi
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
	mov $stdout, %rdi		# %rdi stdout
	_print_msg_fail:
	xor %rdx,%rdx
 1:	cmpb $0,(%rdx,%rsi)
	je  2f
	inc %rdx
	jmp 1b
 2:	mov $sys_write, %rax 	# %rdx contains number of chars
	syscall
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
	call _print_msg_fail
	mov $1, %rdi
####################################################################
# Exits cleanly, checking if the listening or client sockets need  #
# to be closed before calling sys_exit                             #
####################################################################
_exit:
	mov (sock), %rax
	cmp $0, %rax
	je 	3f
	mov (sock), %rdi
	call _close_sock
 3:	#mov (client), %rax
 	#cmp $0, %rax
 	#je 4f
 	#mov (client), %rdi
 	#call _close_sock
_exit_fork:
 4:	mov $sys_exit, %rax
    #xor %rdi, %rdi      # return 0
    mov (err_num), %rdi
    syscall

_print_dec: # zahl in %rax
        mov     $10,  %r8      # Divisor
        xor     %r9, %r9      # Zähler für Anzahl der Ziffern
        mov     $10, %rsi    # zum testen 
        #push    %rsi
        #inc     %r9
  lo: 	#
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
        ret
