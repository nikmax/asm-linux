.set 	stdout, 	1
.set 	stderr, 	2

.set    sys_read, 	0
.set    sys_write, 	1
.set    sys_open, 	2
.set    sys_close, 	3
.set    sys_exit, 	60

.set 	sys_socket, 41
.set 	sys_bind, 	49
.set 	sys_listen,	50
.set 	sys_accept, 43
.set 	sys_select, 23
.set 	sys_fork, 	57
.set 	sys_setsid,	112
.set 	sys_rt_sigaction, 174
# int,	const struct sigaction *,	struct sigaction *,	size_t
# sigaction	include/asm/signal.h:
# struct sigaction {
#     __sighandler_t sa_handler;
#     unsigned long sa_flags;
#     void (*sa_restorer)(void);
#     sigset_t sa_mask; /* mask last for extensibility */
# };

# size_t	include/asm/posix_types.h:typedef unsigned int __kernel_size_t;
# __sighandler_t	include/asm/signal.h:typedef void (*__sighandler_t)(int);
# sigset_t	include/asm/signal.h:typedef unsigned long sigset_t;
