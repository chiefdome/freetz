/*
 * file:    htmltext.h
 * purpose: definitions for createDB
 * created: 2010-05-24
 * author:  Reinhard Mantey
 * license: (c) 2010 - Schwarzrot-Design, all rights reserved
 */
#ifndef CREATEDB_H
#define CREATEDB_H

#define MYBUFSIZE (1024 * 1024)
#define MAX_ENTRY_SIZE (10 * 1024)
#pragma pack(1)

#ifdef EXTERN
#undef EXTERN
#endif
#ifdef PLACE_GLOBALS_HERE
#define EXTERN
#else
#define EXTERN extern
#endif

typedef struct {
   char  id[2];
   short count;
} htid_t;

typedef struct {
   char key[5];
   int  off:24;
} textentry_t;

typedef struct {
   htid_t header;
   textentry_t entry;
   const char * inFilename;
   const char * outFilename;
#ifdef EMBEDDED   
   int    fdIn;
   int    fdOut;
#else   
   FILE * fpIn;
   FILE * fpOut;
#endif   
   char * scratch;
} htmltext_t;
EXTERN htmltext_t global;

#endif
