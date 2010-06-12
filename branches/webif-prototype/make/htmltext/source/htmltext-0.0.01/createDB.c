/*
 * file:    createDB.c
 * purpose: build a compact database for html-text replacement/internationalization
 * created: 2010-05-24
 * author:  Reinhard Mantey
 * license: (c) 2010 - Schwarzrot-Design, all rights reserved
 */
#include <stdio.h>
#include <unistd.h>
#include <getopt.h>
#include <stdlib.h>
#include <string.h>
#define PLACE_GLOBALS_HERE
#include "htmltext.h"

struct option ga_long_options[] = {
   { "input", required_argument, 0, 'i' },
   { "output", required_argument, 0, 'o' },
   { "help", no_argument, 0, 'h' },
   {0, 0, 0, 0}
};
const char *gs_short_options = "+ho:i:";

void
usage(void) {
   fprintf(stderr, "createDB [options]\n"
                   "  -i --input    the properties file to process\n"
                   "  -o --output   the database to create\n"
                   "                existing files will be overwritten\n"
                   "  -h --help     the text you are reading\n");
   exit(1);
}

void
parseCommandLine(int argc, char *argv[]) {
   int c;
   int option_index = 0;

   optopt = 0;
   optind = 0;

   while ((c = getopt_long(argc, argv, gs_short_options,
                           ga_long_options, &option_index)) != -1) {
         switch (c) {
         case 'i':
            if (optarg) global.inFilename = optarg;
            break;
         case 'o':
            if (optarg) global.outFilename = optarg;
            break;
         case 'h':
            usage();
            break;
         }
   }
}

void 
countLines(void) {
   int bytesRead;
   char * p;

   while (bytesRead = fread(global.scratch, 1, MYBUFSIZE, global.fpIn)) {
         printf("read chunk of %d bytes from infile\n", bytesRead);
         for (p = global.scratch; p < global.scratch + bytesRead; p++) {
             if (*p == 0x0A) global.header.count++;
         }
   }
   printf("properties file has #%d entries\n", global.header.count);
   fseek(global.fpIn, 0, SEEK_SET);
}

void 
run(void) {
   int firstOffset;
   int curOffset;
   int bytesRead;
   int curEntry = 0;
   int i=0;
   char notReady = 0;
   char * entryBuf;
   char * pDstMax;
   char *sp, *dp;

   if (entryBuf = malloc(MAX_ENTRY_SIZE + 1)) {
      memset(entryBuf, 0, MAX_ENTRY_SIZE + 1);
   } else {
      fprintf(stderr, "could not allocate entry buffer!\n");
      exit(6);
   }
   *global.header.id = 'F';
   *(global.header.id + 1) = 'A';
   countLines();
   firstOffset = sizeof(global.header) + (global.header.count + 1) * sizeof(textentry_t);
   printf("sizeof text-entry is #%ld, first offset #%d\n", sizeof(textentry_t), firstOffset);

   fwrite(&global.header, sizeof(global.header), 1, global.fpOut);
   fseek(global.fpOut, firstOffset, SEEK_SET);

   while (bytesRead = fread(global.scratch, 1, MYBUFSIZE, global.fpIn)) {
         char * pSrcMax = global.scratch + bytesRead;

         for (sp = global.scratch; sp < pSrcMax; sp++) {
             for (i=0, dp=global.entry.key; i < sizeof(global.entry.key); i++) {
                 // relax formatting of properties file, so don't care about white space
                 if (*sp == ' ' || *sp == 0x09) sp++;

                 // allow both key value separators 
                 if (*sp == '=' || *sp == ':') {
                    for (; i < sizeof(global.entry.key); i++)
                        *dp++ = 0;
                    break;
                 }
                 *dp++ = *sp++;
             }
             // if we filled key but did not reach the separator, light key overflow  
             if (!(*sp == '=' || *sp == ':')) {
                fprintf(stderr, "parse error on line %d (key to big)!\n", curEntry);
                exit(7);
             }
             while (*sp == '=' || *sp == ':' || *sp == ' ' || *sp == 0x09) sp++;
             pDstMax = entryBuf + MAX_ENTRY_SIZE;
             
             for (dp=entryBuf; dp < pDstMax && sp < pSrcMax; ) {
                 if (*sp == 0x0A) {
                    *dp = 0;
                    break;
                 }
                 *dp++ = *sp++;
             }
             if (*sp == 0x0A) {
                global.entry.off = ftell(global.fpOut);
                fputs(entryBuf, global.fpOut);
                fputc(0, global.fpOut);
                curOffset = ftell(global.fpOut);
                fseek(global.fpOut, sizeof(htid_t) + curEntry * sizeof(global.entry), SEEK_SET);
                fwrite(&global.entry, sizeof(global.entry), 1, global.fpOut);
                fseek(global.fpOut, curOffset, SEEK_SET);
                curEntry++;
             } else notReady = 1; 
         }
   }
}

int 
main(int argc, char *argv[]) {
   parseCommandLine(argc, argv);
   if (global.inFilename == NULL || global.outFilename == NULL)
      usage();

   if (!(global.fpIn = fopen(global.inFilename, "r"))) {
      fprintf(stderr, "could not open properties file for reading. "
                      "Please check path and permissions\n");
      exit(2);
   }
   if (!(global.fpOut = fopen(global.outFilename, "w"))) {
      fprintf(stderr, "could not create database file. "
                      "Please check path and permissions\n");
      exit(3);
   }
   if (global.scratch = malloc(MYBUFSIZE)) {
      memset(global.scratch, 0, MYBUFSIZE);
   } else {
      fprintf(stderr, "could not allocate scratch buffer!\n");
      exit(5);
   }
   run();

   free(global.scratch);
   fclose(global.fpIn);
   fclose(global.fpOut);

   return 0;
}
