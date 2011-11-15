/* chatd.c
 * Chat Server (Daemon) fuer Linux
 * Autor: Andre Adrian
 * Version: 09jun2007
 *
 * Chat Server wartet auf TCP Port 51234 auf einen Verbindungsaufbau
 * von telnet Clients. Der Client sendet ASCII Meldungen an den Server.
 * Die Meldungen werden vom Server an alle anderen Clients gesendet.
 *
 * Aufruf Server:
 *  ./chatd &
 *
 * Aufruf Client:
 *  telnet IP_Adresse_Server 51234
 */
/* Geaendert am: 28.12.2010, von sf3978 mit
 * Port-Angabe moeglich und Usage-Meldung.
 * Aufruf Server:
 *  ./chatd <Port> &
 *
 * Aufruf Client:
 *  telnet IP_Adresse_Server <Port>
 *
 */

#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <unistd.h>
#include <syslog.h>
#include <fcntl.h>
#include <errno.h>
#include <netdb.h>
#include <sys/types.h>
#include <sys/socket.h>
#include <sys/select.h>

/* Die Makros exit_if() und return_if() realisieren das Error Handling
 * der Applikation. Wenn die exit_if() Bedingung wahr ist, wird
 * das Programm mit Fehlerhinweis Datei: Zeile: Funktion: errno beendet.
 * Wenn die return_if() Bedingung wahr ist, wird die aktuelle Funktion
 * beendet. Dabei wird der als Parameter 2 angegebene Returnwert benutzt.
 */

#define exit_if(expr) \
if(expr) { \
  syslog(LOG_WARNING, "exit_if() %s: %d: %s: Error %s\n", \
  __FILE__, __LINE__, __PRETTY_FUNCTION__, strerror(errno)); \
  exit(1); \
}

#define return_if(expr, retvalue) \
if(expr) { \
  syslog(LOG_WARNING, "return_if() %s: %d: %s: Error %s\n\n", \
  __FILE__, __LINE__, __PRETTY_FUNCTION__, strerror(errno)); \
  return(retvalue); \
}

#define MAXLEN 1024

#define OKAY 0
#define ERROR (-1)

int tcp_server_init(int port)
/* Server (listen) Port oeffnen - nur einmal ausfuehren
 * in port: TCP Server Portnummer
 * return: Socket Filedescriptor zum Verbindungsaufbau vom Client
 */
{
  int listen_fd;
  int ret;
  struct sockaddr_in sock;
  int yes = 1;

  listen_fd = socket(PF_INET, SOCK_STREAM, 0);
  exit_if(listen_fd < 0);

  /* vermeide "Error Address already in use" Fehlermeldung */
  ret = setsockopt(listen_fd, SOL_SOCKET, SO_REUSEADDR, &yes, sizeof(int));
  exit_if(ret < 0);

  memset((char *) &sock, 0, sizeof(sock));
  sock.sin_family = AF_INET;
  sock.sin_addr.s_addr = htonl(INADDR_ANY);
  sock.sin_port = htons(port);

  ret = bind(listen_fd, (struct sockaddr *) &sock, sizeof(sock));
  exit_if(ret != 0);

  ret = listen(listen_fd, 5);
  exit_if(ret < 0);

  return listen_fd;
}

int tcp_server_init2(int listen_fd)
/* communication (connection) oeffnen - fuer jeden neuen client ausfuehren
 * in listen_fd: Socket Filedescriptor zum Verbindungsaufbau vom Client
 * return: wenn okay Socket Filedescriptor zum lesen vom Client, ERROR sonst
 */
{
  int fd;
  struct sockaddr_in sock;
  socklen_t socklen;

  socklen = sizeof(sock);
  fd = accept(listen_fd, (struct sockaddr *) &sock, &socklen);
  return_if(fd < 0, ERROR);

  return fd;
}

int tcp_server_write(int fd, char buf[], int buflen)
/* Schreibe auf die Client Socket Schnittstelle
 * in fd: Socket Filedescriptor zum Schreiben zum Client
 * in buf: Meldung zum Schreiben
 * in buflen: Meldungslaenge
 * return: OKAY wenn Schreiben vollstaendig, ERROR sonst
 */
{
  int ret;

  ret = write(fd, buf, buflen);
  return_if(ret != buflen, ERROR);
  return OKAY;
}

int tcp_server_read(int fd, char buf[], int *buflen)
/* Lese von der Client Socket Schnittstelle
 * in fd: Socket Filedescriptor zum lesen vom Client
 * out buf: Gelesene Meldung
 * inout buflen: in = maximale Meldungslaenge, out = gelesene Meldungslaenge
 * return: OKAY wenn Lesen okay, ERROR sonst
 */
{
  /* lese Meldung */
  *buflen = read(fd, buf, *buflen);
  if (*buflen <= 0) {
    /* End of TCP Connection */
    close(fd);
    return ERROR;               /* bedeutet fd ist nicht mehr gueltig */
  }
  return OKAY;
}

void loop(int listen_fd)
/* Server Endlosschleife
 * in listen_fd: Socket Filedescriptor zum Verbindungsaufbau vom Client
 */
{
  fd_set the_state;
  int maxfd;

  FD_ZERO(&the_state);
  FD_SET(listen_fd, &the_state);
  maxfd = listen_fd;

  for (;;) {                    /* Endlosschleife */
    fd_set readfds;
    int ret;
    int rfd;

    readfds = the_state;        /* select() aendert readfds */
    ret = select(maxfd + 1, &readfds, NULL, NULL, NULL);
    if ((ret == -1) && (errno == EINTR)) {
      /* Ein Signal ist aufgetreten. Ignorieren */
      continue;
    }
    exit_if(ret < 0);

    /* TCP Server LISTEN Port (Client connect) pruefen */
    if (FD_ISSET(listen_fd, &readfds)) {
      rfd = tcp_server_init2(listen_fd);
      if (rfd >= 0) {
        FD_SET(rfd, &the_state);        /* neuen Client fd dazu */
        if (rfd > maxfd) {
          maxfd = rfd;
        }
      }
    }

    /* TCP Server CONNECT Ports (Clients communication) pruefen */
    for (rfd = listen_fd + 1; rfd <= maxfd; ++rfd) {
      if (FD_ISSET(rfd, &readfds)) {
        char msgbuf[MAXLEN];
        int msgbuflen;

        /* Meldung vom Client lesen */
        msgbuflen = sizeof(msgbuf);
        ret = tcp_server_read(rfd, msgbuf, &msgbuflen);
        if (ERROR == ret) {
          FD_CLR(rfd, &the_state);      /* toten Client rfd entfernen */
        } else {
          /* Meldung an alle anderen Clients schreiben */
          int wfd;

          for (wfd = listen_fd + 1; wfd <= maxfd; ++wfd) {
            if (FD_ISSET(wfd, &the_state) && (rfd != wfd)) {
              tcp_server_write(wfd, msgbuf, msgbuflen);
            }
          }
        }
      }
    }
  }
}

int main(int argc, char *argv[])
{
  /* Fehler Logging einschalten */
  openlog(NULL, LOG_PERROR, LOG_WARNING);
  
  if ( argc < 2 || strcmp(argv[1],"help") == 0 || strcmp(argv[1],"--help") == 0 || \
    strcmp(argv[1],"-h") == 0 || strcmp(argv[1],"?") == 0)
	{
	  printf("chatd version 0.1, 12/28/2010, Autor: Andre Adrian\n%s[%d] - \
Usage: ./chatd <port>\n", argv[0], getpid() );
                exit(0);
        }

  /* open Chat as TCP server */
  loop(tcp_server_init(atoi(argv[1])));

  return OKAY;
}
