	.file	"server.c"
	.section	.rodata
.LC0:
	.string	"%s: %s\n"
	.text
	.globl	error_exit
	.type	error_exit, @function
error_exit:
 .LFB2:
	.cfi_startproc
	pushq	%rbp
	.cfi_def_cfa_offset 16
	.cfi_offset 6, -16
	movq	%rsp, %rbp
	.cfi_def_cfa_register 6
	subq	$16, %rsp
	movq	%rdi, -8(%rbp)
	call	__errno_location@PLT
	movl	(%rax), %eax
	movl	%eax, %edi
	call	strerror@PLT
	movq	%rax, %rcx
	movq	stderr(%rip), %rax
	movq	-8(%rbp), %rdx
	leaq	.LC0(%rip), %rsi
	movq	%rax, %rdi
	movl	$0, %eax
	call	fprintf@PLT
	movl	$1, %edi
	call	exit@PLT
	.cfi_endproc
 .LFE2:
	.size	error_exit, .-error_exit
	.section	.rodata
	.align 8
 .LC1:
	.string	"Fehler beim Anlegen eines Sockets"
	.text
	.globl	create_socket
	.type	create_socket, @function
create_socket:
 .LFB3:
	.cfi_startproc
	pushq	%rbp
	.cfi_def_cfa_offset 16
	.cfi_offset 6, -16
	movq	%rsp, %rbp
	.cfi_def_cfa_register 6
	subq	$32, %rsp
	movl	%edi, -20(%rbp)
	movl	%esi, -24(%rbp)
	movl	%edx, -28(%rbp)
	movl	$1, -8(%rbp)
	movl	-28(%rbp), %edx
	movl	-24(%rbp), %ecx
	movl	-20(%rbp), %eax
	movl	%ecx, %esi
	movl	%eax, %edi
	call	socket@PLT
	movl	%eax, -4(%rbp)
	cmpl	$0, -4(%rbp)
	jns	.L3
	leaq	.LC1(%rip), %rdi
	call	error_exit
 .L3:
	leaq	-8(%rbp), %rdx
	movl	-4(%rbp), %eax
	movl	$4, %r8d
	movq	%rdx, %rcx
	movl	$2, %edx
	movl	$1, %esi
	movl	%eax, %edi
	call	setsockopt@PLT
	movl	-4(%rbp), %eax
	leave
	.cfi_def_cfa 7, 8
	ret
	.cfi_endproc
 .LFE3:
	.size	create_socket, .-create_socket
	.section	.rodata
	.align 8
 .LC2:
	.string	"Kann das Socket nicht \"binden\""
	.text
	.globl	bind_socket
	.type	bind_socket, @function
bind_socket:
 .LFB4:
	.cfi_startproc
	pushq	%rbp
	.cfi_def_cfa_offset 16
	.cfi_offset 6, -16
	movq	%rsp, %rbp
	.cfi_def_cfa_register 6
	subq	$48, %rsp
	movq	%rdi, -24(%rbp)
	movq	%rsi, -32(%rbp)
	movl	%edx, %eax
	movw	%ax, $sock1(%rbp)
	leaq	-16(%rbp), %rax
	movl	$16, %edx
	movl	$0, %esi
	movq	%rax, %rdi
	call	memset@PLT
	movw	$2, -16(%rbp)
	movq	-32(%rbp), %rax
	movl	%eax, %edi
	call	htonl@PLT
	movl	%eax, -12(%rbp)
	movzwl	$sock1(%rbp), %eax
	movl	%eax, %edi
	call	htons@PLT
	movw	%ax, -14(%rbp)
	movq	-24(%rbp), %rax
	movl	(%rax), %eax
	leaq	-16(%rbp), %rcx
	movl	$16, %edx
	movq	%rcx, %rsi
	movl	%eax, %edi
	call	bind@PLT
	testl	%eax, %eax
	jns	.L7
	leaq	.LC2(%rip), %rdi
	call	error_exit
 .L7:
	nop
	leave
	.cfi_def_cfa 7, 8
	ret
	.cfi_endproc
 .LFE4:
	.size	bind_socket, .-bind_socket
	.section	.rodata
 .LC3:
	.string	"Fehler bei listen"
	.text
	.globl	listen_socket
	.type	listen_socket, @function
listen_socket:
 .LFB5:
	.cfi_startproc
	pushq	%rbp
	.cfi_def_cfa_offset 16
	.cfi_offset 6, -16
	movq	%rsp, %rbp
	.cfi_def_cfa_register 6
	subq	$16, %rsp
	movq	%rdi, -8(%rbp)
	movq	-8(%rbp), %rax
	movl	(%rax), %eax
	movl	$5, %esi
	movl	%eax, %edi
	call	listen@PLT
	cmpl	$-1, %eax
	jne	.L10
	leaq	.LC3(%rip), %rdi
	call	error_exit
 .L10:
	nop
	leave
	.cfi_def_cfa 7, 8
	ret
	.cfi_endproc
 .LFE5:
	.size	listen_socket, .-listen_socket
	.section	.rodata
 .LC4:
	.string	"Fehler bei accept"
	.text
	.globl	accept_socket
	.type	accept_socket, @function
accept_socket:
 .LFB6:
	.cfi_startproc
	pushq	%rbp
	.cfi_def_cfa_offset 16
	.cfi_offset 6, -16
	movq	%rsp, %rbp
	.cfi_def_cfa_register 6
	subq	$48, %rsp
	movq	%rdi, -40(%rbp)
	movq	%rsi, -48(%rbp)
	movl	$16, -20(%rbp)
	movq	-40(%rbp), %rax
	movl	(%rax), %eax
	leaq	-20(%rbp), %rdx
	leaq	-16(%rbp), %rcx
	movq	%rcx, %rsi
	movl	%eax, %edi
	call	accept@PLT
	movl	%eax, %edx
	movq	-48(%rbp), %rax
	movl	%edx, (%rax)
	movq	-48(%rbp), %rax
	movl	(%rax), %eax
	cmpl	$-1, %eax
	jne	.L13
	leaq	.LC4(%rip), %rdi
	call	error_exit
 .L13:
	nop
	leave
	.cfi_def_cfa 7, 8
	ret
	.cfi_endproc
 .LFE6:
	.size	accept_socket, .-accept_socket
	.section	.rodata
 .LC5:
	.string	"Fehler bei recv()"
	.text
	.globl	TCP_recv
	.type	TCP_recv, @function
TCP_recv:
 .LFB7:
	.cfi_startproc
	pushq	%rbp
	.cfi_def_cfa_offset 16
	.cfi_offset 6, -16
	movq	%rsp, %rbp
	.cfi_def_cfa_register 6
	subq	$48, %rsp
	movq	%rdi, -24(%rbp)
	movq	%rsi, -32(%rbp)
	movq	%rdx, -40(%rbp)
	movq	-24(%rbp), %rax
	movl	(%rax), %eax
	movq	-40(%rbp), %rdx
	movq	-32(%rbp), %rsi
	movl	$0, %ecx
	movl	%eax, %edi
	call	recv@PLT
	movl	%eax, -4(%rbp)
	cmpl	$0, -4(%rbp)
	jg	.L15
	cmpl	$-1, -4(%rbp)
	je	.L16
 .L15:
	movl	-4(%rbp), %eax
	movslq	%eax, %rdx
	movq	-32(%rbp), %rax
	addq	%rdx, %rax
	movb	$0, (%rax)
	jmp	.L17
 .L16:
	leaq	.LC5(%rip), %rdi
	call	error_exit
 .L17:
	nop
	leave
	.cfi_def_cfa 7, 8
	ret
	.cfi_endproc
 .LFE7:
	.size	TCP_recv, .-TCP_recv
	.globl	close_socket
	.type	close_socket, @function
close_socket:
 .LFB8:
	.cfi_startproc
	pushq	%rbp
	.cfi_def_cfa_offset 16
	.cfi_offset 6, -16
	movq	%rsp, %rbp
	.cfi_def_cfa_register 6
	subq	$16, %rsp
	movq	%rdi, -8(%rbp)
	movq	-8(%rbp), %rax
	movl	(%rax), %eax
	movl	%eax, %edi
	call	close@PLT
	nop
	leave
	.cfi_def_cfa 7, 8
	ret
	.cfi_endproc
 .LFE8:
	.size	close_socket, .-close_socket
	.section	.rodata
	.align 8
 .LC6:
	.string	"Server \303\274berlastet \342\200\223 zu viele Clients"
 .LC7:
	.string	"Nachricht empfangen: %s\n"
 .LC8:
	.string	"quit\n"
 .LC9:
	.string	"Ein Client hat sich beendet"
	.text
	.globl	main
	.type	main, @function
main:
 .LFB9:
 	# -8        ready
 	# -36(%rbp) sock1
 	# -40       sock2
 	# -16(%rbp) max
 	# -24(%rbp) buffer
 	# -12(%rbp) sock_max
 	# -4144 client_sock
 	# -4272 	gesamt_sock
 	# -4400 	lese_sock
	.cfi_startproc
	pushq	%rbp
	.cfi_def_cfa_offset 16
	.cfi_offset 6, -16
	movq	%rsp, %rbp
	.cfi_def_cfa_register 6
	subq	$4400, %rsp
	movl	$-1, $max(%rbp)
	movl	$1024, %edi
	call	malloc@PLT
	movq	%rax, $buffer(%rbp)
	#sock_max = sock1 = create_socket(AF_INET, SOCK_STREAM, 0);
	movl	$0, %edx
	movl	$1, %esi
	movl	$2, %edi
	call	create_socket
	movl	%eax, $sock1(%rbp)
	movl	$sock1(%rbp), %eax
	movl	%eax, $sock_max(%rbp)
	# bind_socket( &sock1, INADDR_ANY, 15000 );
	leaq	$sock1(%rbp), %rax
	movl	$15000, %edx
	movl	$0, %esi
	movq	%rax, %rdi
	call	bind_socket

	leaq	$sock1(%rbp), %rax
	movq	%rax, %rdi
	call	listen_socket
	# for( i=0; i<FD_SETSIZE; i++) client_sock[i] = -1;
	movl	$0, -4(%rbp)
	jmp	.L20
 .L21:
	movl	-4(%rbp), %eax
	cltq
	movl	$-1, -$client_sock(%rbp,%rax,4)
	addl	$1, -4(%rbp)
 .L20:
	cmpl	$1023, -4(%rbp)
	jle	.L21
	# FD_ZERO(&gesamt_sock);
		movl	$0, %eax
		movl	$16, %ecx
		leaq	-$gesamt_sock(%rbp), %rdx
		movq	%rdx, %rdi
	    #APP
	    # 88 "server.c" 1
		cld; rep; stosq
	    # 0 "" 2
	    #NO_APP
		movl	%edi, %eax
		movl	%ecx, %edx
		movl	%edx, -28(%rbp)
		movl	%eax, -32(%rbp)
	# FD_SET(sock1, &gesamt_sock);
		movl	$sock1(%rbp), %eax
		leal	63(%rax), %edx
		testl	%eax, %eax
		cmovs	%edx, %eax
		sarl	$6, %eax
		movl	%eax, %esi
		movslq	%esi, %rax
		movq	$gesamt_sock(%rbp,%rax,8), %rdi
		movl	$sock1(%rbp), %eax
		cltd
		shrl	$26, %edx
		addl	%edx, %eax
		andl	$63, %eax
		subl	%edx, %eax
		movl	$1, %edx
		movl	%eax, %ecx
		salq	%cl, %rdx
		movq	%rdx, %rax
		orq	%rax, %rdi
		movq	%rdi, %rdx
		movslq	%esi, %rax
		movq	%rdx, $gesamt_sock(%rbp,%rax,8)
 .L36:
 	## for (;;) {
 	## lese_sock = gesamt_sock;
		movq	$gesamt_sock(%rbp), %rax
		movq	%rax, $lese_sock(%rbp)

	#########
		movq	-4264(%rbp), %rax
		movq	%rax, -4392(%rbp)
		movq	-4256(%rbp), %rax
		movq	%rax, -4384(%rbp)
		movq	-4248(%rbp), %rax
		movq	%rax, -4376(%rbp)
		movq	-4240(%rbp), %rax
		movq	%rax, -4368(%rbp)
		movq	-4232(%rbp), %rax
		movq	%rax, -4360(%rbp)
		movq	-4224(%rbp), %rax
		movq	%rax, -4352(%rbp)
		movq	-4216(%rbp), %rax
		movq	%rax, -4344(%rbp)
		movq	-4208(%rbp), %rax
		movq	%rax, -4336(%rbp)
		movq	-4200(%rbp), %rax
		movq	%rax, -4328(%rbp)
		movq	-4192(%rbp), %rax
		movq	%rax, -4320(%rbp)
		movq	-4184(%rbp), %rax
		movq	%rax, -4312(%rbp)
		movq	-4176(%rbp), %rax
		movq	%rax, -4304(%rbp)
		movq	-4168(%rbp), %rax
		movq	%rax, -4296(%rbp)
		movq	-4160(%rbp), %rax
		movq	%rax, -4288(%rbp)
		movq	-4152(%rbp), %rax
		movq	%rax, -4280(%rbp)
	# ready=select(sock_max+1, &lese_sock, NULL, NULL, NULL);
		movl	$sock_max(%rbp), %eax
		leal	1(%rax), %edi
		leaq	$lese_sock(%rbp), %rax
		movl	$0, %r8d
		movl	$0, %ecx
		movl	$0, %edx
		movq	%rax, %rsi
		call	select@PLT
		movl	%eax, $ready(%rbp)

	movl	$sock1(%rbp), %eax
	leal	63(%rax), %edx
	testl	%eax, %eax
	cmovs	%edx, %eax
	sarl	$6, %eax
	cltq
	movq	$lese_sock(%rbp,%rax,8), %rsi
	movl	$sock1(%rbp), %eax
	cltd
	shrl	$26, %edx
	addl	%edx, %eax
	andl	$63, %eax
	subl	%edx, %eax
	movl	$1, %edx
	movl	%eax, %ecx
	salq	%cl, %rdx
	movq	%rdx, %rax
	andq	%rsi, %rax
	testq	%rax, %rax
	je	.L22
	#accept_socket( &sock1, &sock2 );
		leaq	$sock2(%rbp), %rdx
		leaq	$sock1(%rbp), %rax
		movq	%rdx, %rsi
		movq	%rax, %rdi
		call	accept_socket
	# for( i=0; i< FD_SETSIZE; i++)
		movl	$0, -4(%rbp)
		jmp	.L23
	 .L26:
		movl	-4(%rbp), %eax
		cltq
		movl	$client_sock(%rbp,%rax,4), %eax
		testl	%eax, %eax
		jns	.L24
		movl	$sock2(%rbp), %edx
		movl	-4(%rbp), %eax
		cltq
		movl	%edx, $client_sock(%rbp,%rax,4)
		jmp	.L25 # break;
	 .L24:
		addl	$1, -4(%rbp)
	 .L23:
		cmpl	$1023, -4(%rbp)
		jle	.L26
		#} // for( i=0; i< FD_SETSIZE; i++)
 .L25:
	cmpl	$1024, -4(%rbp)
	jne	.L27
	leaq	.LC6(%rip), %rdi
	call	error_exit
 .L27:
 	# FD_SET(sock2, &gesamt_sock);
		movl	$sock2(%rbp), %eax
		leal	63(%rax), %edx
		testl	%eax, %eax
		cmovs	%edx, %eax
		sarl	$6, %eax
		movl	%eax, %esi
		movslq	%esi, %rax
		movq	$gesamt_sock(%rbp,%rax,8), %rdi
		movl	$sock2(%rbp), %eax
		cltd
		shrl	$26, %edx
		addl	%edx, %eax
		andl	$63, %eax
		subl	%edx, %eax
		movl	$1, %edx
		movl	%eax, %ecx
		salq	%cl, %rdx
		movq	%rdx, %rax
		orq	%rax, %rdi
		movq	%rdi, %rdx
		movslq	%esi, %rax
		movq	%rdx, $gesamt_sock(%rbp,%rax,8)

	## if( sock2 > sock_max ) sock_max = sock2;
		movl	$sock2(%rbp), %eax
		cmpl	$sock_max(%rbp), %eax
		jle	.L28
		movl	$sock2(%rbp), %eax
		movl	%eax, $sock_max(%rbp)
 		.L28:
 	## if( i > max ) max = i;
		movl	-4(%rbp), %eax
		cmpl	$max(%rbp), %eax
		jle	.L29
		movl	-4(%rbp), %eax
		movl	%eax, $max(%rbp)
	    .L29:
 	## if( --ready <= 0 ) continue;
		subl	$1, $ready(%rbp)
		cmpl	$0, $ready(%rbp)
		jle	.L37
    .L22:
	movl	$0, -4(%rbp)
	jmp	.L36 ## } //if(FD_ISSET ...
	## for(i=0; i<=max; i++) {
	    .L35: 
		movl	-4(%rbp), %eax
		# #if((sock3 = client_sock[i]) < 0) continue;
			cltq
			movl	$client_sock(%rbp,%rax,4), %eax
			movl	%eax, -44(%rbp)
			movl	-44(%rbp), %eax
			testl	%eax, %eax
			js	.L38
			movl	-44(%rbp), %eax
			leal	63(%rax), %edx
			testl	%eax, %eax
			cmovs	%edx, %eax
			sarl	$6, %eax
			cltq
			movq	$lese_sock(%rbp,%rax,8), %rsi
			movl	-44(%rbp), %eax
			cltd
			shrl	$26, %edx
			addl	%edx, %eax
			andl	$63, %eax
			subl	%edx, %eax
			movl	$1, %edx
			movl	%eax, %ecx
			salq	%cl, %rdx
			movq	%rdx, %rax
			andq	%rsi, %rax
			testq	%rax, %rax
			je	.L33

		movq	$buffer(%rbp), %rcx
		leaq	-44(%rbp), %rax
		movl	$1023, %edx
		movq	%rcx, %rsi
		movq	%rax, %rdi
		call	TCP_recv
		movq	$buffer(%rbp), %rax
		movq	%rax, %rsi
		leaq	.LC7(%rip), %rdi
		movl	$0, %eax
		call	printf@PLT
		movq	$buffer(%rbp), %rax
		leaq	.LC8(%rip), %rsi
		movq	%rax, %rdi
		call	strcmp@PLT
		testl	%eax, %eax
		jne	.L34
		leaq	$sock3(%rbp), %rax
		movq	%rax, %rdi
		call	close_socket
		## FD_CLR(sock3, &gesamt_sock);  
			movl	$sock3(%rbp), %eax
			leal	63(%rax), %edx
			testl	%eax, %eax
			cmovs	%edx, %eax
			sarl	$6, %eax
			movl	%eax, %esi
			movslq	%esi, %rax
			movq	$gesamt_sock(%rbp,%rax,8), %rdi
			movl	$sock3(%rbp), %eax
			cltd
			shrl	$26, %edx
			addl	%edx, %eax
			andl	$63, %eax
			subl	%edx, %eax
			movl	$1, %edx
			movl	%eax, %ecx
			salq	%cl, %rdx
			movq	%rdx, %rax
			notq	%rax
			andq	%rax, %rdi
			movq	%rdi, %rdx
			movslq	%esi, %rax
			movq	%rdx, $gesamt_sock(%rbp,%rax,8)


		movl	-4(%rbp), %eax
		cltq
		movl	$-1, $client_sock(%rbp,%rax,4)
		leaq	.LC9(%rip), %rdi
		call	puts@PLT
	 .L34:
	 	##  if( --ready <= 0 ) break;
			subl	$1, $ready(%rbp)
			cmpl	$0, $ready(%rbp)
			jle	.L39
			jmp	.L33
	 .L38:
		nop
	 .L33:
		addl	$1, -4(%rbp)
	 .L31:
		movl	-4(%rbp), %eax
		cmpl	$max(%rbp), %eax
		jle	.L35



	jmp	.L36
 .L37:
	nop
	jmp	.L36
 .L39:
	nop
	jmp	.L36
	.cfi_endproc
 .LFE9:
	.size	main, .-main
	.ident	"GCC: (Debian 6.3.0-18+deb9u1) 6.3.0 20170516"
	.section	.note.GNU-stack,"",@progbits
