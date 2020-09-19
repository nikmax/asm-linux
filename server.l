GAS LISTING server.s 			page 1


   1              	# simply TCP echo server
   2              	#
   3              	#      as --64 server.s -o server.o -a > server.l
   4              	#      ld -melf_x86_64 -e main -s server.o -o server
   5              	#
   6              	#
   7              	.set 	stdout, 	1
   8              	.set 	stderr, 	2
   9              	
  10              	.set    sys_read, 	0
  11              	.set    sys_write, 	1
  12              	.set    sys_open, 	2
  13              	.set    sys_close, 	3
  14              	.set    sys_exit, 	60
  15              	
  16              	.set 	sys_socket, 41
  17              	.set 	sys_bind, 	49
  18              	.set 	sys_listen,	50
  19              	.set 	sys_accept, 43
  20              	.set 	sys_select, 23
  21              	.set 	sys_fork, 	57
  22              	
  23              	.set 	buffer_size, 256
  24              	
  25              	
  26              	
  27              	
  28              	.data
  29 0000 00000000 		sock: 			.quad   0
  29      00000000 
  30 0008 00000000 		client: 		.quad   0     
  30      00000000 
  31 0010 00000000 		echobuf: 		.space 	buffer_size
  31      00000000 
  31      00000000 
  31      00000000 
  31      00000000 
  32 0110 00000000 		read_count:		.quad 	0
  32      00000000 
  33 0118 00000000 		err_num: 		.quad 	0
  33      00000000 
  34 0120 00000000 		num: 			.quad   0
  34      00000000 
  35              		#sockaddr: struckt
  36              		#    sin_family:	.long   0
  37              		#    sin_port: 		.long 	0
  38              		#    sin_addr: 		.quad 	0
  39              		#    sin_zero: 		.quad 	0
  40 0128 47727573 		hello_msg: 		.ascii "Gruss got:"
  40      7320676F 
  40      743A
  41              			.set hello_msg_len, . - hello_msg
  42 0132 202D3E4F 		ok_msg: 		.asciz " ->OK\n"
  42      4B0A00
  43 0139 496E6974 		socket_msg: 	.asciz "Initialise socket: "
  43      69616C69 
  43      73652073 
GAS LISTING server.s 			page 2


  43      6F636B65 
  43      743A2000 
  44 014d 54727920 		bind_msg: 		.asciz "Try to bind socket: "
  44      746F2062 
  44      696E6420 
  44      736F636B 
  44      65743A20 
  45 0162 4C697374 		listen_msg: 	.asciz "Listening on the port: "
  45      656E696E 
  45      67206F6E 
  45      20746865 
  45      20706F72 
  46 017a 54727920 		close_msg: 		.asciz "Try to close socket: "
  46      746F2063 
  46      6C6F7365 
  46      20736F63 
  46      6B65743A 
  47              	
  48 0190 20466169 	    sock_err_msg:	.asciz " Failed to initialise socket\n"
  48      6C656420 
  48      746F2069 
  48      6E697469 
  48      616C6973 
  49 01ae 20466169 	    bind_err_msg: 	.asciz " Failed to bind socket to listening address\n"
  49      6C656420 
  49      746F2062 
  49      696E6420 
  49      736F636B 
  50 01db 20466169 	    lstn_err_msg: 	.asciz " Failed to listen on socket\n"
  50      6C656420 
  50      746F206C 
  50      69737465 
  50      6E206F6E 
  51 01f8 20436F75 	    accept_err_msg: .asciz " Could not accept connection attempt\n"
  51      6C64206E 
  51      6F742061 
  51      63636570 
  51      7420636F 
  52 021e 20457272 	    fork_err_msg: 	.asciz " Error fork status\n"
  52      6F722066 
  52      6F726B20 
  52      73746174 
  52      75730A00 
  53 0232 436C6965 	    accept_msg:     .asciz "Client connected! -> "
  53      6E742063 
  53      6F6E6E65 
  53      63746564 
  53      21202D3E 
  54 0248 0A00     	    crlf: 			.asciz "\n"
  55              	
  56              	    # sockaddr_in structure for the address
  57              	    # the listening socket binds to
  58              	    pop_sa:
  59 024a 0200     	        sockaddr_in.sin_family: .word 2       # AF_INET
  60 024c FFFE     	        sockaddr_in.sin_port: 	.word 0xfeff    # port 60833
  61 024e 00000000 	        sockaddr_in.sin_addr: 	.long 0         # localhost
  62 0252 00000000 	        sockaddr_in.sin_zero: 	.long 0,0
GAS LISTING server.s 			page 3


  62      00000000 
  63              	    	.set sockaddr_in_len, . - pop_sa
  64              	
  65              	.text
  66              	.globl main
  67              	main:
  68              		# Initialise listening and client socket values to 0, 
  69              		# used for cleanup handling
  70 0000 4831C0   		xor %rax, %rax
  71 0003 48890425 		mov %rax, (sock)
  71      00000000 
  72 000b 48890425 		mov %rax, (client)
  72      00000000 
  73 0013 48890425 		mov %rax, (err_num)
  73      00000000 
  74              	
  75              	    # Initialize socket
  76 001b E8700000 	    call _socket
  76      00
  77              	    
  78              		# Bind and Listen
  79 0020 E8C00000 		call _listen
  79      00
  80              		# Main loop handles clients connecting "accept()"
  81              		# then echos any input
  82              		# back to the client
  83              		main_loop:
  84 0025 E8250100 			call _accept
  84      00
  85 002a 48C7C039 			mov $sys_fork, %rax
  85      000000
  86 0031 0F05     			syscall
  87 0033 4883F800 			cmp $0, %rax
  88 0037 48C7C600 			mov $fork_err_msg, %rsi
  88      000000
  89 003e 0F8CD501 			jl  _fail
  89      0000
  90 0044 750F     			jnz read_loop  # fork
  91 0046 488B3C25 			mov (client), %rdi
  91      00000000 
  92 004e E89D0100 		 	call _close_sock
  92      00
  93 0053 EBD0     			jmp main_loop
  94              			#
  95              		# Read and Re-send all bytes sent by the client
  96              		# until the client hangs up the connection on their end
  97              		read_loop:
  98              	#		mov $sys_write, %rax
  99              	#		mov (client), %rdi
 100              	#		mov $hello_msg, %rsi
 101              	#		mov $hello_msg_len, %rdx
 102              	#		syscall
 103              	#
 104              	#		mov $sys_select, %rax 	# SYS_SELECT
 105              	#		mov $2, %rdi 			# AF_NET
 106              	#		mov $1, %rsi 			# SOCK_STREAM
 107              	#		mov $0, %rdx
GAS LISTING server.s 			page 4


 108              	#		syscall
 109              	#
 110              	
 111 0055 E84D0100 			call _read
 111      00
 112 005a E8700100 			call _echo
 112      00
 113              	
 114              			# read_count is set to zero when client hangs up
 115 005f 488B0425 			mov (read_count), %rax
 115      00000000 
 116 0067 4883F800 			cmp $0, %rax
 117 006b 7E02     			jle 	read_complete
 118 006d EBE6     			jmp read_loop
 119              		read_complete:
 120              			# Close client socket
 121 006f 488B3C25 			mov (client), %rdi
 121      00000000 
 122 0077 E8740100 			call _close_sock
 122      00
 123 007c 48C70425 			movq $0, (client)
 123      00000000 
 123      00000000 
 124 0088 4831FF   			xor %rdi, %rdi      # return 0
 125 008b E9DF0100 			jmp _exit_fork
 125      00
 126              	####################################################################
 127              	# Performs a sys_socket call to initialise a TCP/IP listening      #
 128              	# socket and storing socket file descriptor in the sock variable   #
 129              	####################################################################
 130              	_socket:
 131 0090 48C7C600 		mov $socket_msg, %rsi
 131      000000
 132 0097 E85E0100 		call _print_msg
 132      00
 133              	
 134 009c 48C7C029 		mov $sys_socket, %rax 	# SYS_SOCKET
 134      000000
 135 00a3 48C7C702 		mov $2, %rdi 			# AF_NET
 135      000000
 136 00aa 48C7C601 		mov $1, %rsi 			# SOCK_STREAM
 136      000000
 137 00b1 48C7C200 		mov $0, %rdx
 137      000000
 138 00b8 0F05     		syscall
 139              		# Chek socket was created correcktly
 140 00ba 48C7C600 		mov $sock_err_msg, %rsi
 140      000000
 141 00c1 4883F800 		cmp $0, %rax
 142 00c5 0F8E4E01 		jle _fail
 142      0000
 143              		# Store socket file descriptor in variable
 144 00cb 48890425 		mov %rax, (sock)
 144      00000000 
 145 00d3 E8A80100 		call _print_dec
 145      00
 146 00d8 48C7C600 		mov $ok_msg, %rsi
GAS LISTING server.s 			page 5


 146      000000
 147 00df E8160100 		call _print_msg
 147      00
 148 00e4 C3       		ret
 149              	####################################################################
 150              	# Calls sys_bind and sys_listen to start listening for connections #
 151              	####################################################################
 152              	_listen:
 153 00e5 48C7C600 		mov $bind_msg, %rsi
 153      000000
 154 00ec E8090100 		call _print_msg
 154      00
 155 00f1 48C7C031 		mov $sys_bind, %rax 	# SYS_BIND
 155      000000
 156 00f8 488B3C25 		mov (sock), %rdi 			# listening socket fd
 156      00000000 
 157 0100 48C7C600 		mov $pop_sa, %rsi 		# sockaddr in struct
 157      000000
 158 0107 48C7C210 		mov $sockaddr_in_len, %rdx
 158      000000
 159 010e 0F05     		syscall
 160              		# Check for succeeded
 161 0110 48C7C600 		mov $bind_err_msg, %rsi
 161      000000
 162 0117 4883F800 		cmp $0, %rax
 163 011b 0F8CF800 		jl _fail
 163      0000
 164              		# Bind succeeded, call sys_listen
 165              		#call _print_dec
 166              		#mov $ok_msg, %rsi
 167              		#call _print_msg
 168              		#mov $listen_msg, %rsi
 169              		#call _print_msg
 170 0121 48C7C032 		mov $sys_listen, %rax	# SYS_LISTEN
 170      000000
 171 0128 48C7C601 		mov $1, %rsi 			# backlog (dummy value really)
 171      000000
 172 012f 0F05     		syscall
 173              		# Check for success
 174 0131 48C7C600 		mov $lstn_err_msg, %rsi
 174      000000
 175 0138 4883F800 		cmp $0, %rax
 176 013c 0F8CD700 		jl _fail
 176      0000
 177 0142 48C7C600 		mov $ok_msg, %rsi
 177      000000
 178 0149 E8AC0000 		call _print_msg
 178      00
 179 014e C3       		ret
 180              	####################################################################
 181              	# Accepts a connection from a client, storing the client socket    #
 182              	# file descriptor in the client variable and loggin the connection #
 183              	# to stdout                                                        #
 184              	####################################################################
 185              	_accept:
 186 014f 48C7C02B 		mov $sys_accept, %rax 	# SYS_ACCEPT
 186      000000
GAS LISTING server.s 			page 6


 187 0156 488B3C25 		mov (sock), %rdi 			# listenig socket fd
 187      00000000 
 188 015e 48C7C600 		mov $0, %rsi 			# NULL sockaddr_in value as we don't need that data
 188      000000
 189 0165 48C7C200 		mov $0, %rdx 			# Nulls have length 0
 189      000000
 190 016c 0F05     		syscall
 191              		# Check call succeeded
 192 016e 48C7C600 		mov $accept_err_msg, %rsi
 192      000000
 193 0175 4883F800 		cmp $0, %rax
 194 0179 0F8C9A00 		jl 	_fail
 194      0000
 195              		# Store returned fd in variable
 196 017f 48890425 		mov %rax, (client)
 196      00000000 
 197 0187 50       		push %rax
 198              		# Log connection to stdout
 199 0188 48C7C600 		mov $accept_msg, %rsi
 199      000000
 200 018f E8660000 		call _print_msg
 200      00
 201 0194 58       		pop %rax
 202 0195 E8E60000 		call _print_dec
 202      00
 203 019a 48C7C600 		mov $crlf, %rsi
 203      000000
 204 01a1 E8540000 		call _print_msg	
 204      00
 205 01a6 C3       		ret
 206              	####################################################################
 207              	# Reads up to 256 bytes from the client into echobuf and sets the  #
 208              	# read_count variable to be the number of bytes read by sys_read
 209              	####################################################################
 210              	_read:
 211 01a7 48C7C000 		mov $sys_read, %rax
 211      000000
 212 01ae 488B3C25 		mov (client), %rdi
 212      00000000 
 213 01b6 48C7C600 		mov $echobuf, %rsi
 213      000000
 214 01bd 48C7C200 		mov $buffer_size, %rdx
 214      010000
 215 01c4 0F05     		syscall
 216              		# Copy number of bytes read to variable
 217 01c6 48890425 		mov %rax, (read_count)
 217      00000000 
 218 01ce C3       		ret
 219              	####################################################################
 220              	# Sends up to the value of read_count bytes from echobuf to the    #
 221              	# client socket using sys_write 
 222              	####################################################################
 223              	_echo:
 224 01cf 48C7C001 		mov $sys_write, %rax
 224      000000
 225 01d6 488B3C25 		mov (client), %rdi
 225      00000000 
GAS LISTING server.s 			page 7


 226 01de 48C7C600 		mov $echobuf, %rsi
 226      000000
 227 01e5 488B1425 		mov (read_count), %rdx
 227      00000000 
 228 01ed 0F05     		syscall
 229 01ef C3       		ret
 230              	####################################################################
 231              	# Performs sys_close on the socket in %rdi                         #
 232              	####################################################################
 233              	_close_sock:
 234 01f0 48C7C003 		mov $sys_close, %rax
 234      000000
 235 01f7 0F05     		syscall
 236 01f9 C3       		ret
 237              	####################################################################
 238              	# %rsi contains address to a message                                        #
 239              	####################################################################
 240              	_print_msg:
 241 01fa 48C7C701 		mov $stdout, %rdi		# %rdi stdout
 241      000000
 242              		_print_msg_fail:
 243 0201 4831D2   		xor %rdx,%rdx
 244 0204 803C3200 	 1:	cmpb $0,(%rdx,%rsi)
 245 0208 7405     		je  2f
 246 020a 48FFC2   		inc %rdx
 247 020d EBF5     		jmp 1b
 248 020f 48C7C001 	 2:	mov $sys_write, %rax 	# %rdx contains number of chars
 248      000000
 249 0216 0F05     		syscall
 250 0218 C3       		ret
 251              	####################################################################
 252              	# Calls the sys_write syscall, writing an error message to stderr, #
 253              	# the exits the application. %rsi must be populated with the error #
 254              	# message before calling _fail                                     #
 255              	####################################################################
 256              	_fail:
 257 0219 48890425 		mov %rax, (err_num)
 257      00000000 
 258 0221 E85A0000 		call _print_dec
 258      00
 259 0226 48C7C702 		mov $stderr, %rdi
 259      000000
 260 022d E8CFFFFF 		call _print_msg_fail
 260      FF
 261 0232 48C7C701 		mov $1, %rdi
 261      000000
 262              	####################################################################
 263              	# Exits cleanly, checking if the listening or client sockets need  #
 264              	# to be closed before calling sys_exit                             #
 265              	####################################################################
 266              	_exit:
 267 0239 488B0425 		mov (sock), %rax
 267      00000000 
 268 0241 4883F800 		cmp $0, %rax
 269 0245 740D     		je 	3f
 270 0247 488B3C25 		mov (sock), %rdi
 270      00000000 
GAS LISTING server.s 			page 8


 271 024f E89CFFFF 		call _close_sock
 271      FF
 272 0254 488B0425 	 3:	mov (client), %rax
 272      00000000 
 273 025c 4883F800 	 	cmp $0, %rax
 274 0260 740D     	 	je 4f
 275 0262 488B3C25 	 	mov (client), %rdi
 275      00000000 
 276 026a E881FFFF 	 	call _close_sock
 276      FF
 277              	_exit_fork:
 278 026f 48C7C03C 	 4:	mov $sys_exit, %rax
 278      000000
 279              	    #xor %rdi, %rdi      # return 0
 280 0276 488B3C25 	    mov (err_num), %rdi
 280      00000000 
 281 027e 0F05     	    syscall
 282              	
 283              	_print_dec: # zahl in %rax
 284 0280 49C7C00A 	        mov     $10,  %r8      # Divisor
 284      000000
 285 0287 4D31C9   	        xor     %r9, %r9      # Zähler für Anzahl der Ziffern
 286 028a 48C7C60A 	        mov     $10, %rsi    # zum testen 
 286      000000
 287              	        #push    %rsi
 288              	        #inc     %r9
 289              	  lo: 	#
 290 0291 4831D2   	        xor     %rdx, %rdx      # die Zahl in rdx:rax
 291 0294 49F7F0   	        div     %r8
 292 0297 80C230   	        add     $48,  %dl        # in ein Symbol konvertieren
 293 029a 52       	        push    %rdx
 294 029b 49FFC1   	        inc     %r9
 295 029e 4809C0   	        or      %rax, %rax      # sind wir fertig?
 296 02a1 75EE     	        jnz     lo
 297 02a3 48C7C001 	        mov     $sys_write, %rax
 297      000000
 298 02aa 48C7C701 	        mov     $1,  %rdi        # STDOUT
 298      000000
 299 02b1 48C7C201 	        mov     $1,  %rdx        # nur einen Byte
 299      000000
 300              	  display:
 301 02b8 5E       	        pop     %rsi
 302 02b9 48893425 	        mov     %rsi, (num)
 302      00000000 
 303 02c1 48C7C600 	        mov     $num, %rsi       # buffer
 303      000000
 304 02c8 0F05     	        syscall
 305 02ca 49FFC9   	        dec     %r9
 306 02cd 75E9     	        jnz     display
 307 02cf C3       	        ret
GAS LISTING server.s 			page 9


DEFINED SYMBOLS
            server.s:7      *ABS*:0000000000000001 stdout
            server.s:8      *ABS*:0000000000000002 stderr
            server.s:10     *ABS*:0000000000000000 sys_read
            server.s:11     *ABS*:0000000000000001 sys_write
            server.s:12     *ABS*:0000000000000002 sys_open
            server.s:13     *ABS*:0000000000000003 sys_close
            server.s:14     *ABS*:000000000000003c sys_exit
            server.s:16     *ABS*:0000000000000029 sys_socket
            server.s:17     *ABS*:0000000000000031 sys_bind
            server.s:18     *ABS*:0000000000000032 sys_listen
            server.s:19     *ABS*:000000000000002b sys_accept
            server.s:20     *ABS*:0000000000000017 sys_select
            server.s:21     *ABS*:0000000000000039 sys_fork
            server.s:23     *ABS*:0000000000000100 buffer_size
            server.s:29     .data:0000000000000000 sock
            server.s:30     .data:0000000000000008 client
            server.s:31     .data:0000000000000010 echobuf
            server.s:32     .data:0000000000000110 read_count
            server.s:33     .data:0000000000000118 err_num
            server.s:34     .data:0000000000000120 num
            server.s:40     .data:0000000000000128 hello_msg
            server.s:41     *ABS*:000000000000000a hello_msg_len
            server.s:42     .data:0000000000000132 ok_msg
            server.s:43     .data:0000000000000139 socket_msg
            server.s:44     .data:000000000000014d bind_msg
            server.s:45     .data:0000000000000162 listen_msg
            server.s:46     .data:000000000000017a close_msg
            server.s:48     .data:0000000000000190 sock_err_msg
            server.s:49     .data:00000000000001ae bind_err_msg
            server.s:50     .data:00000000000001db lstn_err_msg
            server.s:51     .data:00000000000001f8 accept_err_msg
            server.s:52     .data:000000000000021e fork_err_msg
            server.s:53     .data:0000000000000232 accept_msg
            server.s:54     .data:0000000000000248 crlf
            server.s:58     .data:000000000000024a pop_sa
            server.s:59     .data:000000000000024a sockaddr_in.sin_family
            server.s:60     .data:000000000000024c sockaddr_in.sin_port
            server.s:61     .data:000000000000024e sockaddr_in.sin_addr
            server.s:62     .data:0000000000000252 sockaddr_in.sin_zero
            server.s:63     *ABS*:0000000000000010 sockaddr_in_len
            server.s:67     .text:0000000000000000 main
            server.s:130    .text:0000000000000090 _socket
            server.s:152    .text:00000000000000e5 _listen
            server.s:83     .text:0000000000000025 main_loop
            server.s:185    .text:000000000000014f _accept
            server.s:256    .text:0000000000000219 _fail
            server.s:97     .text:0000000000000055 read_loop
            server.s:233    .text:00000000000001f0 _close_sock
            server.s:210    .text:00000000000001a7 _read
            server.s:223    .text:00000000000001cf _echo
            server.s:119    .text:000000000000006f read_complete
            server.s:277    .text:000000000000026f _exit_fork
            server.s:240    .text:00000000000001fa _print_msg
            server.s:283    .text:0000000000000280 _print_dec
            server.s:242    .text:0000000000000201 _print_msg_fail
            server.s:266    .text:0000000000000239 _exit
GAS LISTING server.s 			page 10


            server.s:289    .text:0000000000000291 lo
            server.s:300    .text:00000000000002b8 display

NO UNDEFINED SYMBOLS
