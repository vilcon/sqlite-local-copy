/*
** 2022-11-18
**
** The author disclaims copyright to this source code.  In place of
** a legal notice, here is a blessing:
**
**    May you do good and not evil.
**    May you find forgiveness for yourself and forgive others.
**    May you share freely, never taking more than you give.
**
*************************************************************************
**
** This is a SQLite extension for converting in either direction
** between a (binary) blob and base64 text. Base64 can transit a
** sane USASCII channel unmolested. It also plays nicely in CSV or
** written as TCL brace-enclosed literals or SQL string literals,
** and can be used unmodified in XML-like documents.
**
** This is an independent implementation of conversions specified in
** RFC 4648, done on the above date by the author (Larry Brasfield)
** who thereby has the right to put this into the public domain.
**
** The conversions meet RFC 4648 requirements, provided that this
** C source specifies that line-feeds are included in the encoded
** data to limit visible line lengths to 72 characters.
**
** Length limitations are not imposed except that the runtime
** SQLite string or blob length limits are respected. Otherwise,
** any length binary sequence can be represented and recovered.
** Generated base64 sequences, with their line-feeds included,
** can be concatenated; the result converted back to binary will
** be the concatenation of the represented binary sequences.
**
** This SQLite3 extension creates a function, base64(x), which
** either: converts text x containing base64 to a returned blob;
** or converts a blob x to returned text containing base64. An
** error will be thrown for other input argument types.
**
** This code relies on UTF-8 encoding only with respect to the
** meaning of the first 128 (7-bit) codes matching that of USASCII.
** It will fail miserably if somehow made to try to convert EBCDIC.
** Because it is table-driven, it could be enhanced to handle that,
** but the world and SQLite have moved on from that anachronism.
**
** To build the extension:
** Set shell variable SQDIR=<your favorite SQLite checkout directory>
** *Nix: gcc -O2 -shared -I$SQDIR -fPIC -o base64.so base64.c
** OSX: gcc -O2 -dynamiclib -fPIC -I$SQDIR -o base64.dylib base64.c
** Win32: gcc -O2 -shared -I%SQDIR% -o base64.dll base64.c
** Win32: cl /Os -I%SQDIR% base64.c -link -dll -out:base64.dll
*/

#include <assert.h>

#ifndef SQLITE_SHELL_EXTFUNCS /* Guard for #include as built-in extension. */
#include "sqlite3ext.h"
#endif

SQLITE_EXTENSION_INIT1;

#define PC 0x80 /* pad character */
#define WS 0x81 /* whitespace */
#define ND 0x82 /* Not above or digit-value */
#define PAD_CHAR '='

typedef unsigned char ubyte;

static const ubyte b64DigitValues[128] = {
  /*                             HT LF VT  FF CR       */
    ND,ND,ND,ND, ND,ND,ND,ND, ND,WS,WS,WS, WS,WS,ND,ND,
  /*                                                US */
    ND,ND,ND,ND, ND,ND,ND,ND, ND,ND,ND,ND, ND,ND,ND,ND,
  /*sp                                  +            / */
    WS,ND,ND,ND, ND,ND,ND,ND, ND,ND,ND,62, ND,ND,ND,63,
  /* 0  1            5            9            =       */
    52,53,54,55, 56,57,58,59, 60,61,ND,ND, ND,PC,ND,ND,
  /*    A                                            O */
    ND, 0, 1, 2,  3, 4, 5, 6,  7, 8, 9,10, 11,12,13,14,
  /* P                               Z                 */
    15,16,17,18, 19,20,21,22, 23,24,25,ND, ND,ND,ND,ND,
  /*    a                                            o */
    ND,26,27,28, 29,30,31,32, 33,34,35,36, 37,38,39,40,
  /* p                               z                 */
    41,42,43,44, 45,46,47,48, 49,50,51,ND, ND,ND,ND,ND
};

static const char b64Numerals[64]
= "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/";

#define BX_DV_PROTO(c) ((((ubyte)(c))<0x80)? b64DigitValues[c] : 0x80)
#define IS_BX_DIGIT(bdp) (((ubyte)(bdp))<0x80)
#define IS_BX_WS(bdp) ((bdp)==WS)
#define IS_BX_PAD(bdp) ((bdp)==PC)
#define BX_NUMERAL(dv) (b64Numerals[dv])
/* Width of base64 lines. Should be an integer multiple of 4. */
#define B64_DARK_MAX 72

/* Encode a byte buffer into base64 text. If pSep!=0, it's a C string
** to be appended to encoded groups to limit their length to B64_DARK_MAX
** or to terminate the last group (to aid concatenation.)
*/
static char* toBase64( ubyte *pIn, int nbIn, char *pOut, char *pSep ){
  int nCol = 0;
  *pOut = 0;
  while( nbIn > 0 ){
    static signed char ncio[] = { 0, 2, 3, 4 };
    int nbi = (nbIn > 3)? 3 : nbIn;
    signed char nc;
    int nbe;
    unsigned long qv = (ubyte)*pIn++;
    for( nbe=1; nbe<3; ++nbe ){
      ubyte b = (nbe<nbi)? *pIn++ : 0;
      qv = (qv<<8) | b;
    }
    nc = ncio[nbi];
    nbIn -= nbi;
    for( nbe=3; nbe>=0; --nbe ){
      char ce = (nbe<nc)? BX_NUMERAL((ubyte)(qv & 0x3f)) : PAD_CHAR;
      qv >>= 6;
      pOut[nbe] = ce;
    }
    pOut += 4;
    if( pSep && ((nCol += 4)>=B64_DARK_MAX || nbIn<=0) ){
      char *p = pSep;
      while( *p ) *pOut++ = *p++;
      nCol = 0;
    }
    *pOut = 0;
  }
  return pOut;
}

/* Skip over text which is not base64 numeral(s). */
static char * skipNonB64( char *s ){
  char c;
  while( (c = *s) && !IS_BX_DIGIT(BX_DV_PROTO(c)) ) ++s;
  return s;
}

/* Decode base64 text into a byte buffer. */
static ubyte* fromBase64( char *pIn, int ncIn, ubyte *pOut ){
  if( ncIn>0 && pIn[ncIn-1]=='\n' ) --ncIn;
  while( ncIn>0 && *pIn!=PAD_CHAR ){
    static signed char nboi[] = { 0, 0, 1, 2, 3 };
    char *pUse = skipNonB64(pIn);
    unsigned long qv = 0L;
    int nti, nbo, nac;
    ncIn -= (pUse - pIn);
    pIn = pUse;
    nti = (ncIn>4)? 4 : ncIn;
    nbo = nboi[nti];
    if( nbo==0 ) break;
    for( nac=0; nac<4; ++nac ){
      char c = (nac<=nti)? *pIn++ : PAD_CHAR;
      ubyte bdp = BX_DV_PROTO(c);
      --ncIn;
      switch( bdp ){
      case WS:
      case ND:
        nti = 0;
        break;
      case PC:
        bdp = 0;
        --nbo;
         /* fall thru */
      default: /* bdp is the digit value. */
        qv = qv<<6 | bdp;
        break;
      }
    }
    nti = 2;
    while( nbo-- > 0 ){
      *pOut++ = (qv >> (8*nti--))&0xff;
    }
  }
  return pOut;
}

/* This function does the work for the SQLite base64(x) UDF. */
static void base64(sqlite3_context *context, int na, sqlite3_value *av[]){
  int nb, nc, nv = sqlite3_value_bytes(av[0]);
  int nvMax = sqlite3_limit(sqlite3_context_db_handle(context),
                            SQLITE_LIMIT_LENGTH, -1);
  char *cBuf;
  ubyte *bBuf;
  assert(na==1);
  switch( sqlite3_value_type(av[0]) ){
  case SQLITE_BLOB:
    nb = nv;
    nc = 4*(nv+2/3); /* quads needed */
    nc += (nc+(B64_DARK_MAX-1))/B64_DARK_MAX + 1; /* LFs and a 0-terminator */
    if( nvMax < nc ){
      sqlite3_result_error(context, "blob expanded to base64 too big.", -1);
    }
    cBuf = sqlite3_malloc(nc);
    if( !cBuf ) goto memFail;
    bBuf = (ubyte*)sqlite3_value_blob(av[0]);
    nc = (int)(toBase64(bBuf, nb, cBuf, "\n") - cBuf);
    sqlite3_result_text(context, cBuf, nc, sqlite3_free);
    break;
  case SQLITE_TEXT:
    nc = nv;
    nb = 3*((nv+3)/4); /* may overestimate due to LF and padding */
    if( nvMax < nb ){
      sqlite3_result_error(context, "blob from base64 may be too big.", -1);
    }else if( nb<1 ){
      nb = 1;
    }
    bBuf = sqlite3_malloc(nb);
    if( !bBuf ) goto memFail;
    cBuf = (char *)sqlite3_value_text(av[0]);
    nb = (int)(fromBase64(cBuf, nc, bBuf) - bBuf);
    sqlite3_result_blob(context, bBuf, nb, sqlite3_free);
    break;
  default:
    sqlite3_result_error(context, "base64 accepts only blob or text.", -1);
    break;
  }
  return;
 memFail:
  sqlite3_result_error(context, "base64 OOM", -1);
}

/*
** Establish linkage to running SQLite library.
*/
#ifndef SQLITE_SHELL_EXTFUNCS
#ifdef _WIN32
__declspec(dllexport)
#endif
int sqlite3_base_init
#else
static int sqlite3_base64_init
#endif
(sqlite3 *db, char **pzErr, const sqlite3_api_routines *pApi){
  SQLITE_EXTENSION_INIT2(pApi);
  (void)pzErr;
  return sqlite3_create_function
    (db, "base64", 1,
     SQLITE_DETERMINISTIC|SQLITE_INNOCUOUS|SQLITE_DIRECTONLY|SQLITE_UTF8,
     0, base64, 0, 0);
}

/*
** Define some macros to allow this extension to be built into the shell
** conveniently, in conjunction with use of SQLITE_SHELL_EXTFUNCS. This
** allows shell.c, as distributed, to have this extension built in.
*/
#define BASE64_INIT(db) sqlite3_base64_init(db, 0, 0)
#define BASE64_EXPOSE(db, pzErr) /* Not needed, ..._init() does this. */
