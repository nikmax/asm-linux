# *******************************************************
# Server (daemon)
# by Broken Sword [HI-TECH]
# (for Linux based on Intel x86 only)

# brokensword@mail.ru
# www.wasm.ru

# Compile Instructions:
# -------------------------------------------------------
# as --32 server.s
# ld --strip-all -o server a.out
# *******************************************************

# *******************************************************

# этот файлик содержит выдранные из какого-то файла
# определения системных вызовов (см. FUCK #3)
.include		"syscalls.inc"		
# а этот – все остальные, которые только могут 
# встретиться

.include 	"def.inc"		        
		.text					    # начало сегмента кода
# метка, с которой все начинается (нужно чтоб она была 
# глобальной)
		.globl		_start		 	

_start:							
# итак, начинаем лепить нашего демона
# процесс создания демона в *.nix и создание резидента в DOS в корне различаются
# начинается любой демон с того, что нужно создать дочерний процесс.
# Создать дочерний процесс в линуксе проще 
# пареной репы – достаточно поместить номер сис.
# вызова в EAX и сделать «а-ля int 21h», т.е. int 80h
		movl		$SYS_fork,%EAX
		int		$0x80		
# все. 
# Теперь у нас параллельно сосуществуют ДВА процесса:
# родительский (в котором исполнялись все предыдущие 
# команды) и дочерний. Что же содержит дочерний код? 
# А все то же самое, что и родительский.
# Т.е. важно понять, что # весь нижеследующий (и выше тоже)
# код находиться в памяти в ДВУХ разных местах.
# Как процессор переключается между 
# ними (и всеми остальными живыми процессами) 
# – читайте «Переключение задач» в интеловском мануале. 
test		%EAX,%EAX		
# вот эту команду необходимо осознать.
# Прежде всего, важно понять, что данная команда
# существует и в родительском 
# и в дочернем процессах (об этом выше).
# Следовательно выполниться она и там и там.
# Все дело в том, что после 
# int 80h родительскому процессу вернется PID сына
# (в EAX ессесно, вообще все возвращается в EAX, как и в винде)
# а что же вернется сыне? Правильно, нолик.
# Именно поэтому следующий jmp будет выполнен
# в дочернем процессе и 
# не будет выполнен в родительском.

# ребенок улетает на метку _cont1
		jz		_cont1			
# ...а в это время, в родительском процессе:
		xorl		%EBX,%EBX		# EBX=status code
		xorl		%EAX,%EAX		#
		incl		%EAX			# SYS_exit 
# завершаем родительский процесс.
		int		$0x80			

# Теперь все дети 
# управляются процессом INIT


_cont1:
		movl		$SYS_setsid,%EAX
# сделаем нашего ребенка главным в группе
		int		$0x80			
		
		movl		$1,%EBX			# SIGHUP
		movl		$1,%ECX			# SIG_IGN
		movl		$SYS_signal,%EAX
# далее сигнал SIGHUP будет игнорироваться
		int		$0x80			
							
		movl		$SYS_fork,%EAX
# наш ребенок уже подрос и теперь сам может родить сына
		int		$0x80			
# (по сути – это уже внук нашему изначальному 
# родительскому процессу)

# EAX=0 в дочернем и EAX=PIDдочернего в родительском

		test		%EAX,%EAX		

jz		_cont2			

# внук нашего родительского (которого уже давно нет в 
# живых) улетает на метку _cont2, однако отец все еще 
# жив!!! (все как в мексиканском сериале)
		
		xorl		%EBX,%EBX		# EBX=status code
		xorl		%EAX,%EAX		#
		incl		%EAX			# SYS_exit
		int         $0x80			

# вот уже и отец отправлен к деду на небеса (да, 
# злостная программка, недаром демоном зовется)

# ..а в это время внучок получает все наследство и 

_cont2:

# продолжает жить
# далее, после того,
# как все кровавые разборки и отцеубийства благополучно завершены,
# внучок,продавший душу демону, 
# преспокойно создает сокет.
# Дело в том, что в линуксе есть такие системные вызовы,
# для вызова которых их номер не 
# помещается в EAX.
# Вместо этого в EAX помещается номер функции-мультиплексора,
# реализующий вызов конкретной 
# функции номер которой помещается в EBX.
# Так, например, происходит при вызове IPC и SOCKET-функций.
# Кроме того, 
# при вызове SOCKET-функций параметры располагаются не в регистрах,
# а в стеке. Смотри как все просто:

		pushl		$0			# протокол
		pushl		$SOCK_STREAM		# тип

		pushl		$AF_INET			# домен
# ECX должен указывать на кадр в стеке, содержащий 
		movl		%ESP,%ECX		
# параметры, такая уж у него судьба...
		movl		$SYS_SOCKET,%EBX		
# а вот это уже номер той самой конкретной функции
# SOCKET – создать сокет
							
		movl		$SYS_socketcall,%EAX
	
# в EAX - номер функции мультиплексора (по сути он 
# просто перенаправит вызов в функцию, указанную в EBX
		
       int         $0x80

# сокет создан! Ура товарищи. В EAX возвратиться его дескриптор.

# «очистим» стек (по сути это выражение придумано специально
# для HL-программистов, на самом деле ничего не 
# очищается, данную операцию необходимо производить только
# для того чтобы в дальнейшем не произошло переполнение 
# стека, но в таких маленьких программках это делать вовсе
# не обязательно):

		addl		$0xC,%ESP

		movl		%EAX,(sockfd)		

# сохраним дескриптор созданного сокета в переменной
# sockfd

# далее необходимо осуществить операцию BIND,
# которая называется «привязка имени сокету»,
# хотя суть этого названия 
# слабо отражает смысл происходящего на самом деле.
# На самом деле BIND просто назначает конкретному сокету IP-
# адрес и порт, через который с ним можно взаимодействовать:

# размер передаваемой структуры (вообще подобран 
		pushl		$0x10
# методом тыка, потому что логически непонятно почему 
# именно 16)

# указатель на структуру sockaddr_in

       pushl		$sockaddr_in
# дескриптор нашего сокета
		pushl		%EAX			
# ECX указывает на параметры в стеке
		movl		%ESP,%ECX		
# номер функции BIND – в EBX
		movl		$SYS_BIND,%EBX
# функция-мультиплексор
		movl		$SYS_socketcall,%EAX
		int		$0x80
# теперь сокет «привязан» к конкретному IP-шнику и порту
# поднимем ESP на место
		addl		$0xC,%ESP		
# далее что-либо подробно описывать я не вижу смысла,
# любой желающий сам без труда разберется, опираясь на 
# полученные выше знания.
		pushl		$0			# backlog
		movl		(sockfd),%EAX
		pushl		%EAX
		movl		%ESP,%ECX
		movl		$SYS_LISTEN,%EBX
		movl		$SYS_socketcall,%EAX
		int         $0x80
		addl		$0x8,%ESP

_wait_next_client:
		pushl		$0			# addrlen
		pushl		$0			# cliaddr
		movl		(sockfd),%EAX
		pushl		%EAX			# sockfd
		movl		%ESP,%ECX
		movl		$SYS_ACCEPT,%EBX
		movl		$SYS_socketcall,%EAX
		int		$0x80
		addl		$0xC,%ESP

		movl		%EAX,(connfd)
		
		movl		$SYS_fork,%EAX
		int		$0x80			# create child process
		test		%EAX,%EAX
		jnz		_wait_next_client

_next_plain_text:
		movl		(connfd),%EBX
		movl		$buf,%ECX		# ECX->buf
		movl		$1024,%EDX		# 1024 bytes
		movl		$SYS_read,%EAX
		int		$0x80			# wait plain_text

		movl		$buf,%ESI
		movl		%ESI,%EDI
		movl		%EAX,%ECX
		movl		%EAX,%EDX
_encrypt:
		lodsb
		cmp		$0x41,%AL		# A
		jb		_next
		cmp		$0x5A,%AL		# Z
		ja		_maybe_small
		incb		%AL
		incb		%AL			# encryption ;)
		cmp		$0x5A,%AL
		jle		_next
		sub		$26,%AL
_maybe_small:
		cmp		$0x61,%AL		# a
		jb		_next
		cmp		$0x7A,%AL		# z
		ja		_next
		incb		%AL
		incb		%AL			# encryption ;)
		cmp		$0x7A,%AL
		jle		_next
		sub		$26,%AL
_next:
		stosb
		loop		_encrypt
		
		movl		(connfd),%EBX
		movl		$buf,%ECX		# ECX->chiper_text
		movl		$SYS_write,%EAX
		int		$0x80			# send plain_text
		
		jmp		_next_plain_text
# *****************************************************
		.data
sockfd:		.long		0
connfd:		.long		0
sockaddr_in:	
sin_family:	.word		AF_INET
sin_port:	.word		0x3930			# port:12345
sin_addr:	.long		0			# INADDR_ANY
buf:
# *****************************************************



#Клиент пишется по аналогии с сервером,
# думаю сами без труда разберетесь:


# *********************************************************
# Client
# by Broken Sword [HI-TECH]
# (for Linux based on Intel x86 only)

# brokensword@mail.ru
# www.wasm.ru

# Compile Instructions:
# ---------------------------------------------------------
# as client.s
# ld --strip-all -o client a.out
# *********************************************************

# *********************************************************		
       .include		"syscalls.inc"
		.include 	"def.inc"
		.text
		.globl		_start
_start:
		pushl		$0			# protocol
		pushl		$SOCK_STREAM		# type
		pushl		$AF_INET			# domain
		movl		%ESP,%ECX
		movl		$SYS_SOCKET,%EBX
		movl		$SYS_socketcall,%EAX
		int		$0x80
		addl		$0xC,%ESP

		movl		%EAX,(sockfd)

		pushl		$0x10			# addrlen
		pushl		$sockaddr_in
		pushl		%EAX			# sockfd
		movl		%ESP,%ECX
		movl		$SYS_CONNECT,%EBX
		movl		$SYS_socketcall,%EAX
		int		$0x80
		addl		$0xC,%ESP

_next_plain_text:
		xorl		%EBX,%EBX		# stdin
		movl		$buf,%ECX		# ECX->buf
		movl		$1024,%EDX		# 1024 bytes
		movl		$SYS_read,%EAX
		int		$0x80			# read from stdin

		movl		(sockfd),%EBX
		movl		$buf,%ECX		# ECX->plain_text
		movl		%EAX,%EDX		# bytes read
		movl		$SYS_write,%EAX
		int		$0x80			# send plain_text

		movl		$SYS_read,%EAX
		int		$0x80			# wait chiper_text
		
		xorl		%EBX,%EBX
		incl		%EBX			# EBX=1 (stdout)
		movl		$SYS_write,%EAX
		int		$0x80			# disp chiper_text
		
		jmp		_next_plain_text
# *********************************************************
		.data
sockfd:		.long		0
sockaddr_in:	
sin_family:	.word		AF_INET
sin_port:	.word		0x3930			# port:12345
sin_addr:	.long		0x0100007F		# 127.0.0.1
buf:
# *********************************************************
