/*
 * file:    getText.c
 * purpose: fetch text from htmltext-database for given key
 * created: 2010-05-24
 * author:  Reinhard Mantey
 * license: (c) 2010 - Schwarzrot-Design, all rights reserved
 *
 */
#include <stdio.h>
#include <unistd.h>
#include <getopt.h>
#include <stdlib.h>
#include <string.h>
#include <sys/stat.h>
#include <fcntl.h>
#define EMBEDDED
#define PLACE_GLOBALS_HERE
#include "htmltext.h"
#define DEFAULT_DB "/var/htmltext.fa"

struct option ga_long_options[] = {
   { "db",   required_argument, 0, 'd' },
   { "key",  required_argument, 0, 'k' },
   { "help", no_argument, 0, 'h' },
   {0, 0, 0, 0}
};
const char *gs_short_options = "+hd:k:";

void
usage(void) {
   fputs("getText [options]\n"
         "  -d --db       the htmltext database file\n"
         "  -k --key      the message-key to search for\n"
         "                found message will be written to stdout,\n"
         "                or key if key is not found in database.\n"
         "  -h --help     the text you are reading\n", stderr);
   exit(1);
}

void
parseCommandLine(int argc, char *argv[]) {
   int c;
   int option_index = 0;

   optopt = 0;
   optind = 0;
   while (optind >= 0 && optind < argc) {
         c = getopt_long(argc, argv, gs_short_options, 
                        ga_long_options, &option_index);
         switch (c) {
         case 'd':
            if (optarg) global.inFilename = optarg;
            break;
         case 'k':
            if (optarg) global.outFilename = optarg;
            break;
         case 'h':
            usage();
            break;
         case -1:
            if (optind < argc)
               global.outFilename = argv[optind++];
            break;
         }
   }
   if (!global.inFilename)
      global.inFilename = DEFAULT_DB;
}

int 
textncmp(const char * p0, const char * p1, int len) {
   int i=0;

   for (i=0; i < len; i++) {
       if (*(p0 + i) < *(p1 + i)) return -1;
       else if (*(p0 + i) > *(p1 + i)) return 1;
   }
   return 0;
}

int
findEntry(void) {
   int   curEntry = global.header.count >> 1;
   int   stepSize = curEntry;
   char  dir=0;
   const char * last = global.scratch + global.header.count * sizeof(textentry_t); 
   const char * p;
   const char * pK;

   if (curEntry + stepSize < global.header.count) stepSize++;
   for (p = global.scratch + curEntry * sizeof(textentry_t);
        ; 
        p = global.scratch + curEntry * sizeof(textentry_t)) {
       pK = ((textentry_t *)p)->key;
       if (stepSize) {
          if (p >= last) {
             curEntry -= stepSize;
             stepSize >>= 1;
             continue;
          }
          if (p <= global.scratch) {
             curEntry += stepSize;
             stepSize >>= 1;
             continue;
          }
          if ((dir = textncmp(global.outFilename, pK, sizeof(global.entry.key))) < 0) {
             if (!stepSize) curEntry--;
             else curEntry -= stepSize; 
             stepSize >>= 1;
          } else if (dir > 0) {
             if (!stepSize) curEntry++;
             else curEntry += stepSize; 
             stepSize >>= 1;
          } else return ((textentry_t *)pK)->off; // match
       } else {
          char ndir = textncmp(global.outFilename, pK, sizeof(global.entry.key));

          if (ndir == 0)   return ((textentry_t *)pK)->off; // match
          if (p >= last || p <= global.scratch || ndir != dir) 
             return -1; // no match
          curEntry += dir;
       }
   }
   return -1;
}

void 
run(void) {
   int offset = 0;
   int bufSize = 0;
   int bytesRead = 0;

   if (read(global.fdIn, &global.header, sizeof(global.header)) != sizeof(global.header)) {
      fputs("failed to read database header!\n", stderr);
      exit(4);
   }
   if (*global.header.id != 'F' || *(global.header.id + 1) != 'A') {
      fputs("invalid database given!\n", stderr);
      exit(5);
   }
   bufSize = (global.header.count + 1) * sizeof(textentry_t);
   if (global.scratch = malloc(bufSize)) {
      memset(global.scratch, 0, bufSize);
   } else {
      fputs("could not allocate scratch buffer!\n", stderr);
      exit(6);
   }
   if ((bytesRead = read(global.fdIn, global.scratch, bufSize)) != bufSize) {
      fputs("failed to read database header", stderr);
      exit(7);
   }
   if ((offset = findEntry()) < 0) {
      fputs(global.outFilename, stdout); 
   } else {
      lseek(global.fdIn, offset, SEEK_SET);
      if ((bytesRead = read(global.fdIn, global.scratch, bufSize)) > 0) {
         global.scratch[bytesRead] = 0;
         fputs(global.scratch, stdout);
      }
   }
   free(global.scratch);
}

int
main(int argc, char *argv[]) {
   parseCommandLine(argc, argv);
   if (global.inFilename == NULL || global.outFilename == NULL)
      usage();

   if (global.outFilename == 0 || 
       strlen(global.outFilename) < 1 || 
       strlen(global.outFilename) > sizeof(global.entry.key)) {
      fputs("invalid key given!\n", stderr);
      exit(2);
   }
   if (!(global.fdIn = open(global.inFilename, O_NONBLOCK + O_RDONLY))) {
      fputs("could not open htmltext database for reading. "
            "Please check path and permissions\n", stderr);
      exit(3);
   }
   run();
   close(global.fdIn);

   return 0;
}
