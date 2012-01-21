/**
 * tranSOCKS_ev
 * ------------
 * libevent-based non-forking transparent SOCKS5-Proxy
 * 
 * This is mainly inspired by transocks, available at
 * http://transocks.sourceforge.net/ and written by
 * Mike Fisk <mefisk@gmail.com>.
 * 
 * This work is distributed within the terms of
 * creative commons attribution-share alike 3.0 germany
 * 
 * See http://creativecommons.org/licenses/by-sa/3.0/ for more information
 * 
 * @author Bernd Holzmueller <bernd@tiggerswelt.net>
 * @revision 01
 * @license http://creativecommons.org/licenses/by-sa/3.0/de/ Creative Commons Attribution-Share Alike 3.0 Germany
 * @homepage http://oss.tiggerswelt.net/transocks_ev/
 * @copyright Copyright &copy; 2008 tiggersWelt.net (and others, see above)
 */

#include <sys/types.h>
#include <sys/socket.h>
#include <netinet/in.h>
#include <arpa/inet.h>
#include <stdio.h>
#include <signal.h>
#include <event.h>
#include <stdlib.h>
#include <string.h>
#include <getopt.h>

/* This caused errors on my maschine */
/* #include <linux/netfilter_ipv4.h> */

#ifndef SO_ORIGINAL_DST
# define SO_ORIGINAL_DST 80
#endif

#define READ_BUFFER	4096

enum {
  SOCKS5_HELLO,
  SOCKS5_CONNECT,
  SOCKS5_CONNECTED
};

struct proxy_con {
  int client;
  int server;
  int status;
  struct sockaddr_in dest;
  struct event ev_client;
  struct event ev_server;
};

struct sockaddr_in socks_addr;

void client_remove (struct proxy_con *con, char *reason) {
  event_del (&con->ev_client);
  event_del (&con->ev_server);
  
  close (con->client);
  close (con->server);
  
  free (con);
}

void client_read (int fd, short event, void *arg) {
  struct proxy_con *con = arg;
  char buffer [READ_BUFFER];
  int len = 0;
  
  /* Reschedule ourself */
  event_add (&con->ev_client, NULL);
  
  /* Read incomming data */
  if ((len = read (fd, &buffer, READ_BUFFER)) <= 0)
    return client_remove (con, "client-connection was closed");
  
  /* Forward data to the server (we asume that the connection is ready for this) */
  write (con->server, &buffer, len);
}
 
void server_read (int fd, short event, void *arg) {
  struct proxy_con *con = arg;
  char buffer [READ_BUFFER];
  int len = 0;
  
  /* Reschedule ourself */
  event_add (&con->ev_server, NULL);
  
  /* Read incomming data */
  if ((len = read (fd, &buffer, READ_BUFFER)) <= 0)
    return client_remove (con, "server-connection was closed");
  
  switch (con->status) {
    case SOCKS5_HELLO:
      /* Check length of packet */
      if (len < 2)
        return client_remove (con, "invalid length in SOCKS5 HELLO");
      
      /* Check for a SOCKS5-Signature */
      if (buffer [0] != 0x05)
        return client_remove (con, "bad reply in SOCKS5 HELLO-State");
      
      /* Handle authentication */
      switch (buffer [1]) {
        case 0x00:	/* No authentication needed */
          break;
        
        case 0xFF:	/* Our request were rejected */
        default:	/* Anything else is unsupported */
          return client_remove (con, "Unsupported authentication");
      }
      
      char resp [10];
      
      resp [0] = 0x05; /* We are SOCKS5 */
      resp [1] = 0x01; /* Create a TCP-Connection */
      resp [2] = 0x00;
      resp [3] = 0x01; /* Address is IPv4 */
      resp [4] = (con->dest.sin_addr.s_addr & 0xFF); /* 4-byte IPv4 */
      resp [5] = (con->dest.sin_addr.s_addr >> 8) & 0xFF;
      resp [6] = (con->dest.sin_addr.s_addr >> 16) & 0xFF;
      resp [7] = (con->dest.sin_addr.s_addr >> 24);
      resp [8] = con->dest.sin_port & 0xff; /* 2-Byte Port-Number */
      resp [9] = con->dest.sin_port >> 8;
      
      write (fd, &resp, 10);
      
      con->status = SOCKS5_CONNECT;
      
      break;
    case SOCKS5_CONNECT:
      /* Check for a SOCKS5-Signature */
      if (buffer [0] != 0x05)
        return client_remove (con, "bad reply in SOCKS5 CONNECT-State");
      
      /* Check for success */
      if (buffer [1] != 0x00)
        return client_remove (con, ("SOCKS5 Connection failed with reason %d", buffer [1]));
      
      /* We are connected */
      con->status = SOCKS5_CONNECTED;
      
      /* Honor events on client, e.g. forward through socket */
      event_add (&con->ev_client, NULL);
      
      break;
    case SOCKS5_CONNECTED:
      /* Pass data to the client */
      write (con->client, &buffer, len);
      
      break;
  }
}

void new_connection (int fd, short event, void *arg) {
  struct sockaddr_in client_addr;
  struct proxy_con *con;
  int len = 0;
  
  /* Allocate memory for new structure */
  con = malloc (sizeof (struct proxy_con));
  bzero (con, sizeof (struct proxy_con));
  
  /* Reschedule ourself */
  event_add (arg, NULL);
  
  /* Accept incoming connection */
  if ((con->client = accept (fd, (struct sockaddr *)&client_addr, &len)) <= 0) {
    free (con);
    return;
  }
  
  /* Determine where we should connect to */
  if (getsockopt (con->client, SOL_IP, SO_ORIGINAL_DST, (struct sockaddr *)&con->dest, &len) != 0) {
    perror ("Could not determine socket-destination");
    close (con->client);
    free (con);
    return;
  }
  
  /* Create the SOCKS-Client */
  if (((con->server = socket (AF_INET, SOCK_STREAM, 0)) < 0) ||
      (connect (con->server, (struct sockaddr *)&socks_addr, sizeof (socks_addr)) != 0)) {
    close (con->client);
    free (con);
    return;
  }
  
  /* Setup events for this new connection */
  event_set (&con->ev_client, con->client, EV_READ, client_read, con);
  event_set (&con->ev_server, con->server, EV_READ, server_read, con);
  event_add (&con->ev_server, NULL);
  
  /* Submit a SOCKS5 Hello */
  con->status = SOCKS5_HELLO;
  
  write (con->server, "\x05\x01\x00", 3);
}


int main (int argc, char **argv) {
  struct sockaddr_in addr;
  struct event ev_server;
  int addrlen = sizeof (addr);
  int serverfd = 0;
  int on = 1;
  int foreground = 0;
  
  short bindport = 1211;
  char *bindhost = "0.0.0.0";
  
  short socksport = 9050;
  char *sockshost = "85.116.219.0";
  
  char c;
  
  /* Parse the commandline */
  while ((c = getopt (argc, argv, "fp:H:s:S:h")) != EOF)
    switch (c) {
      case 'f': /* Keep in foreground */
        foreground = 1;
        break;
      
      case 'p': /* Try to bind to this port */
        if (!(bindport = atoi (optarg))) {
          fprintf (stderr, "Invalid port %s\n", optarg);
          return 1;
        }
        
        break;
      
      case 'H': /* Try to bind to this IP */
        bindhost = optarg;
        break;
      
      case 's': /* Use this port on the SOCKS5-Proxy */
        if (!(socksport = atoi (optarg))) {
          fprintf (stderr, "Invalid port %s\n", optarg);
          return 1;
        }
        
        break;
      
      case 'S': /* Use this IP for the SOCKS5-Proxy */
        sockshost = optarg;
        break;
      
      case 'h': /* Print help */
        printf ("tranSOCKS-ev - libevent-based transparent SOCKS5-Proxy\n");
        printf ("Usage: %s [-f] [-p Port] [-H IP-Address] [-s port] [-S IP-Address]\n\n", argv [0]);
        printf ("\t-f\tDo not fork into background upon execution\n");
        printf ("\t-p\tBind our server-socket to this port\n");
        printf ("\t-H\tListen on this IP-Address for incomming connections\n");
        printf ("\t-s\tExpect SOCKS5-Server on this Port\n");
        printf ("\t-S\tExpect SOCKS5-Server on this IP-Address\n");
        printf ("\n");
        
        return 0;
    }
  
  /* Handle the forking stuff */
  if (foreground != 1) {
    /* Try to fork into background */
    if ((foreground = fork ()) < 0) {
      perror("fork");
      return 1;
    }
    
    /* Fork was successfull and we are the parent */
    if (foreground)
      return 0;
    
    /* Close our filehandles */
    fclose (stdin);
    fclose (stdout);
    fclose (stderr);
    
    setsid ();
    setpgrp ();
    
    signal (SIGCHLD, SIG_IGN);
  }
  
  /* Prepare address of SOCKS5-Server */
  bzero (&socks_addr, sizeof (socks_addr));
  socks_addr.sin_family = AF_INET;
  socks_addr.sin_port = htons (socksport);
  
  if (inet_pton (AF_INET, sockshost, &socks_addr.sin_addr.s_addr) <= 0) {
    perror ("Could not parse SOCKS-Host");
    return 1;
  }
  
  /* Create our server socket */
  if ((serverfd = socket (AF_INET, SOCK_STREAM, 0)) < 0) {
    perror ("Could not create socket");
    return 1;
  }
  
  bzero (&addr, sizeof (addr));
  addr.sin_family = AF_INET;
  addr.sin_port = htons (bindport);
  
  if (inet_pton (AF_INET, bindhost, &addr.sin_addr.s_addr) <= 0) {
    perror ("Could not parse Host");
    return 1;
  }
  
  setsockopt (serverfd, SOL_SOCKET, SO_REUSEADDR, &on, sizeof (on));
  
  if (bind (serverfd, (struct sockaddr *)&addr, sizeof (addr)) < 0) {
    perror ("Could not bind our socket");
    return 1;
  }
  
  if (listen (serverfd, SOMAXCONN) < 0) {
    perror ("listen failed");
    return 1;
  }
  
  /* Setup Event-Handing */
  event_init ();
  
  event_set (&ev_server, serverfd, EV_READ, new_connection, &ev_server);
  event_add (&ev_server, NULL);
  
  event_dispatch ();
  
  return 0;
}
