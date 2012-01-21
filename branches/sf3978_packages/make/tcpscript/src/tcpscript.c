/*
 * Copyright (c) 1980 Regents of the University of California.
 * All rights reserved.
 *
 * Redistribution and use in source and binary forms, with or without
 * modification, are permitted provided that the following conditions
 * are met:
 * 1. Redistributions of source code must retain the above copyright
 *    notice, this list of conditions and the following disclaimer.
 * 2. Redistributions in binary form must reproduce the above copyright
 *    notice, this list of conditions and the following disclaimer in the
 *    documentation and/or other materials provided with the distribution.
 * 3. All advertising materials mentioning features or use of this software
 *    must display the following acknowledgement:
 *	This product includes software developed by the University of
 *	California, Berkeley and its contributors.
 * 4. Neither the name of the University nor the names of its contributors
 *    may be used to endorse or promote products derived from this software
 *    without specific prior written permission.
 *
 * THIS SOFTWARE IS PROVIDED BY THE REGENTS AND CONTRIBUTORS ``AS IS'' AND
 * ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
 * IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE
 * ARE DISCLAIMED.  IN NO EVENT SHALL THE REGENTS OR CONTRIBUTORS BE LIABLE
 * FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL
 * DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS
 * OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION)
 * HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT
 * LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY
 * OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF
 * SUCH DAMAGE.
 */

/*
 * 1999-02-22 Arkadiusz Mi¶kiewicz <misiek@pld.ORG.PL>
 * - added Native Language Support
 *
 * 2000-07-30 Per Andreas Buer <per@linpro.no> - added "q"-option
 */

/*
 * tcpscript - Modified from 'script' - 2007 Lluis Batlle i Rossell
 */
#include <stdio.h>
#include <stdlib.h>
#include <sys/types.h>
#include <sys/stat.h>
#include <termios.h>
#include <sys/ioctl.h>
#include <sys/time.h>
#include <sys/signal.h>
#include <sys/socket.h>
#include <netinet/in.h>

#ifdef __linux__
#include <unistd.h>
#include <string.h>
#endif

#define HAVE_openpty
#define _PATH_BSHELL "/bin/sh"
#ifdef HAVE_openpty
#include <pty.h>
#endif

void finish(int);
void done(void);
void fail(void);
void resize(int);
void fixtty(void);
void getmaster(void);
void getslave(void);
void doinput(void);
void dooutput(void);
void doshell(void);
void resize_clients(void);

char	*shell;
int	master;
int	slave;
int	child;
int	subchild;
char	*fname;

struct	termios tt;
struct	winsize win;
int	lb;
int	l;
#ifndef HAVE_openpty
char	line[] = "/dev/ptyXX";
#endif
char	*cflg = NULL;
int	qflg = 0;
int	tcp_port = 4000;
int	limit_conns = 1;

enum {
    MAXCONNS = 10
};
static int accept_socket;
const char version[] = "0.2";

int conns[MAXCONNS];
int nconns = 0;

static char *progname;

static void
die_if_link(char *fn) {
	struct stat s;

	if (lstat(fn, &s) == 0 && (S_ISLNK(s.st_mode) || s.st_nlink > 1)) {
		fprintf(stderr,
			"Warning: `%s' is a link.\n"
			  "Use `%s [options] %s' if you really "
			  "want to use it.\n"
			  "Script not started.\n",
			fn, progname, fn);
		exit(1);
	}
}

/*
 * script -t prints time delays as floating point numbers
 * The example program (scriptreplay) that we provide to handle this
 * timing output is a perl script, and does not handle numbers in
 * locale format (not even when "use locale;" is added).
 * So, since these numbers are not for human consumption, it seems
 * easiest to set LC_NUMERIC here.
 */

int
main(int argc, char **argv) {
	extern int optind;
	char *p;
	int ch;

	progname = argv[0];
	if ((p = strrchr(progname, '/')) != NULL)
		progname = p+1;


	if (argc == 2) {
		if (!strcmp(argv[1], "-V") || !strcmp(argv[1], "--version")) {
			printf("%s %s, modification of 'script' by %s\n",
			       progname, version,
                   "Lluis Batlle i Rossell 2007");
			return 0;
		}
	}

	while ((ch = getopt(argc, argv, "c:qp:l:")) != -1)
		switch((char)ch) {
		case 'c':
			cflg = optarg;
			break;
		case 'p':
			tcp_port = atoi(optarg);
			break;
		case 'l':
			limit_conns = atoi(optarg);
			break;
		case 'q':
			qflg++;
			break;
		case '?':
		default:
			fprintf(stderr,
				"usage: tcpscript [-l nconns] [-p port] [-q] [-t] \n");
			exit(1);
		}
	argc -= optind;
	argv += optind;

	shell = getenv("SHELL");
	if (shell == NULL)
		shell = _PATH_BSHELL;

	getmaster();
	fixtty();

    accept_socket = listen_tcp();

	(void) signal(SIGCHLD, finish);
	child = fork();
	if (child < 0) {
		perror("fork");
		fail();
	}
	if (child == 0) {
		subchild = child = fork();
		if (child < 0) {
			perror("fork");
			fail();
		}
		if (child)
			dooutput();
		else
        {
            close(accept_socket);
			doshell();
        }
	} else
    {
        close(accept_socket);
		(void) signal(SIGWINCH, resize);
    }
	doinput();

	return 0;
}

void
doinput() {
	register int cc;
	char ibuf[BUFSIZ];

	while ((cc = read(0, ibuf, BUFSIZ)) > 0)
		(void) write(master, ibuf, cc);
	done();
}

#include <sys/wait.h>

void
finish(int dummy) {
	int status;
	register int pid;
	register int die = 0;

	while ((pid = wait3(&status, WNOHANG, 0)) > 0)
		if (pid == child)
			die = 1;

	if (die)
		done();
}

void
resize(int dummy) {
	/* transmit window change information to the child */
	(void) ioctl(0, TIOCGWINSZ, (char *)&win);
	(void) ioctl(slave, TIOCSWINSZ, (char *)&win);

	kill(child, SIGWINCH);
}

void fatal()
{
    done();
    exit(-1);
}

int set_reusable(int s)
{
    int boolean = 1;
    int res;

    res = setsockopt(s, SOL_SOCKET, SO_REUSEADDR, &boolean, sizeof(boolean));
    if (res != 0)
        perror("Setsockopt REUSE failed"), fatal();
}

void sig_resize_clients(int x)
{
  resize_clients();
}

void resize_clients()
{
  int rows, cols;
  char tmp[100];
  int i;
  int len;

  /* Get rows and cols from our connection to the terminal: fd 1 */
	(void) ioctl(0, TIOCGWINSZ, (char *)&win);
  rows = win.ws_row;
  cols = win.ws_col;

  /* Prepare the xterm resize string */
  snprintf(tmp, 100, "\033[8;%i;%it\n", rows, cols, rows, cols);
  len = strlen(tmp);
  for (i = 0; i < nconns; ++i)
  {
    send(conns[i], tmp, len, 0);
  }
}

void send_noecho(int fd)
{
  char seq[] = { 255 /*IAC*/, 251 /*WILL*/, 1 /*ECHO*/ };
  send(fd, seq, sizeof seq, 0);
}

int listen_tcp()
{
    int s;
    struct sockaddr_in addr;
    int res;

    s = socket(PF_INET, SOCK_STREAM, 0);
    if (s == -1)
        perror("Failed socket()"), fatal();

    set_reusable(s);

    addr.sin_family = AF_INET;
    addr.sin_port = htons(tcp_port);
    addr.sin_addr.s_addr = INADDR_ANY;
    res = bind(s, (struct sockaddr *) &addr, sizeof(addr));
    if (res != 0)
        perror("Failed bind()"), fatal();

    res = listen(s, 1);
    if (res != 0)
        perror("Failed listen()"), fatal();

    if (!qflg)
        printf("Listening on port %i\r\n", tcp_port);
    return s;
}

void remove_element(int index, int *array, int total)
{
    int i;
    for (i = index; i < (total - 1); ++i)
        array[i] = array[i+1];
}

void
dooutput() {
	int cc;
	char obuf[BUFSIZ];
    int i;

/*	(void) close(0); lets use it in resize*/
#ifdef HAVE_openpty
	(void) close(slave);
#endif
    fd_set read_set;
    fd_set should_read_set;
    fd_set tcp_set;

    FD_ZERO(&should_read_set);
    FD_SET(accept_socket, &should_read_set);
    FD_SET(master, &should_read_set);
    nconns = 0;
		(void) signal(SIGWINCH, sig_resize_clients);
	for (;;) {
        int max;
        read_set = should_read_set;

        /* Calculate max fd */
        max = accept_socket;
        if (master > max)
            max = master;
        for (i = 0; i < nconns; ++i)
            if (conns[i] > max)
                max = conns[i];
        
        i = select(max + 1, &read_set, 0, 0, 0);
        if (i == -1)
          continue;

        if (FD_ISSET(master, &read_set))
        {
            cc = read(master, obuf, sizeof (obuf));
            if (cc <= 0)
                break;
            /* Write to the terminal output */
            (void) write(1, obuf, cc);
            /* Broadcast messages */
            for (i = 0; i < nconns; ++i)
                (void) write(conns[i], obuf, cc);
        }
        for (i = 0; i < nconns; ++i)
        {
            if (FD_ISSET(conns[i], &read_set))
            {
                int size;
                size = recv(conns[i], obuf, sizeof(obuf), 0);
                if (size == 0)
                {
                    close(conns[i]);
                    FD_CLR(conns[i], &should_read_set);
                    remove_element(i, conns, nconns);
                    nconns--;
                }
            }
        }
        if (FD_ISSET(accept_socket, &read_set))
        {
            int s;
            s = accept(accept_socket, 0, 0);
            if (s == -1)
            {
                perror("accept() failed");
                break;
            }
            if (nconns < (MAXCONNS - 1) && nconns < limit_conns)
            {
                FD_SET(s, &should_read_set);
                conns[nconns] = s;
                nconns++;
                send_noecho(s);
                resize_clients();
            } else
                close(s);
        }
	}

    close(accept_socket);
    for (i = 0; i < nconns; ++i)
        close(conns[i]);

	done();
}

void
doshell() {
	char *shname;

#if 0
	int t;

	t = open(_PATH_TTY, O_RDWR);
	if (t >= 0) {
		(void) ioctl(t, TIOCNOTTY, (char *)0);
		(void) close(t);
	}
#endif

	getslave();
	(void) close(master);
	(void) dup2(slave, 0);
	(void) dup2(slave, 1);
	(void) dup2(slave, 2);
	(void) close(slave);

	shname = strrchr(shell, '/');
	if (shname)
		shname++;
	else
		shname = shell;

	if (cflg)
		execl(shell, shname, "-c", cflg, 0);
	else
		execl(shell, shname, "-i", 0);

	perror(shell);
	fail();
}

void
fixtty() {
	struct termios rtt;

	rtt = tt;
	cfmakeraw(&rtt);
	rtt.c_lflag &= ~ECHO;
	(void) tcsetattr(0, TCSAFLUSH, &rtt);
}

void
fail() {

	(void) kill(0, SIGTERM);
	done();
}

void
done() {
	time_t tvec;

	if (subchild) {
		(void) close(master);
	} else {
		(void) tcsetattr(0, TCSAFLUSH, &tt);
	}
	exit(0);
}

void
getmaster() {
#ifdef HAVE_openpty
	(void) tcgetattr(0, &tt);
	(void) ioctl(0, TIOCGWINSZ, (char *)&win);
	if (openpty(&master, &slave, NULL, &tt, &win) < 0) {
		fprintf(stderr, "openpty failed\n");
		fail();
	}
#else
	char *pty, *bank, *cp;
	struct stat stb;

	pty = &line[strlen("/dev/ptyp")];
	for (bank = "pqrs"; *bank; bank++) {
		line[strlen("/dev/pty")] = *bank;
		*pty = '0';
		if (stat(line, &stb) < 0)
			break;
		for (cp = "0123456789abcdef"; *cp; cp++) {
			*pty = *cp;
			master = open(line, O_RDWR);
			if (master >= 0) {
				char *tp = &line[strlen("/dev/")];
				int ok;

				/* verify slave side is usable */
				*tp = 't';
				ok = access(line, R_OK|W_OK) == 0;
				*tp = 'p';
				if (ok) {
					(void) tcgetattr(0, &tt);
				    	(void) ioctl(0, TIOCGWINSZ, 
						(char *)&win);
					return;
				}
				(void) close(master);
			}
		}
	}
	fprintf(stderr, "Out of pty's\n");
	fail();
#endif /* not HAVE_openpty */
}

void
getslave() {
#ifndef HAVE_openpty
	line[strlen("/dev/")] = 't';
	slave = open(line, O_RDWR);
	if (slave < 0) {
		perror(line);
		fail();
	}
	(void) tcsetattr(slave, TCSAFLUSH, &tt);
	(void) ioctl(slave, TIOCSWINSZ, (char *)&win);
#endif
	(void) setsid();
	(void) ioctl(slave, TIOCSCTTY, 0);
}
