#!/usr/bin/tclsh
#
# To build the
#
#   const char **azCompileOpt[]
#
# definition used in src/ctime.c, run this script from
# the checkout root. It generates src/ctime.c .
#
# Results are normally written into src/ctime.c.  But if an argument is
# provided, results are written there instead.  Examples:
#
#    tclsh tool/mkctimec.tcl                ;# <-- results to src/ctime.c
#
#    tclsh tool/mkctimec.tcl /dev/tty       ;# <-- results to the terminal
#


set ::headWarning {/* DO NOT EDIT!
** This file is automatically generated by the script in the canonical
** SQLite source tree at tool/mkctimec.tcl.
**
** To modify this header, edit any of the various lists in that script
** which specify categories of generated conditionals in this file.
*/}

# Make { and } easier to put into literals (even on EBCDIC machines.)
regexp {(\{)(\})} "{}" ma ::lb ::rb

set ::headCode "
/*
** 2010 February 23
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
** This file implements routines used to report what compile-time options
** SQLite was built with.
*/
#ifndef SQLITE_OMIT_COMPILEOPTION_DIAGS /* IMP: R-16824-07538 */

/*
** Include the configuration header output by 'configure' if we're using the
** autoconf-based build
*/
#if defined(_HAVE_SQLITE_CONFIG_H) && !defined(SQLITECONFIG_H)
#include \"sqlite_cfg.h\"
#define SQLITECONFIG_H 1
#endif

/* These macros are provided to \"stringify\" the value of the define
** for those options in which the value is meaningful. */
#define CTIMEOPT_VAL_(opt) #opt
#define CTIMEOPT_VAL(opt) CTIMEOPT_VAL_(opt)

/* Like CTIMEOPT_VAL, but especially for SQLITE_DEFAULT_LOOKASIDE. This
** option requires a separate macro because legal values contain a single
** comma. e.g. (-DSQLITE_DEFAULT_LOOKASIDE=\"100,100\") */
#define CTIMEOPT_VAL2_(opt1,opt2) #opt1 \",\" #opt2
#define CTIMEOPT_VAL2(opt) CTIMEOPT_VAL2_(opt)
#include \"sqliteInt.h\"

/*
** An array of names of all compile-time options.  This array should 
** be sorted A-Z.
**
** This array looks large, but in a typical installation actually uses
** only a handful of compile-time options, so most times this array is usually
** rather short and uses little memory space.
*/
static const char * const sqlite3azCompileOpt\[\] = $::lb
"

set ::tailCode "
$::rb ;

const char **sqlite3CompileOptions(int *pnOpt){
  *pnOpt = sizeof(sqlite3azCompileOpt) / sizeof(sqlite3azCompileOpt\[0\]);
  return (const char**)sqlite3azCompileOpt;
}

#endif /* SQLITE_OMIT_COMPILEOPTION_DIAGS */
"

# All Boolean compile time options which default to something
# other than 0 or empty. The default is paired with the PP
# symbol so that a differing define can be detected.
#
set boolean_defnnz_options {
  {SQLITE_HOMEGROWN_RECURSIVE_MUTEX 1}
  {SQLITE_POWERSAFE_OVERWRITE 1}
  {SQLITE_DEFAULT_MEMSTATUS 1}
  {SQLITE_OMIT_TRACE 1}
  {SQLITE_ALLOW_COVERING_INDEX_SCAN 1}
}

# All Boolean compile time options which default to 0 or empty.
#
set boolean_defnil_options {
  SQLITE_32BIT_ROWID
  SQLITE_4_BYTE_ALIGNED_MALLOC
  SQLITE_ALLOW_ROWID_IN_VIEW
  SQLITE_ALLOW_URI_AUTHORITY
  SQLITE_BUG_COMPATIBLE_20160819
  SQLITE_CASE_SENSITIVE_LIKE
  SQLITE_CHECK_PAGES
  SQLITE_COVERAGE_TEST
  SQLITE_DEBUG
  SQLITE_DEFAULT_AUTOMATIC_INDEX
  SQLITE_DEFAULT_AUTOVACUUM
  SQLITE_DEFAULT_CKPTFULLFSYNC
  SQLITE_DEFAULT_FOREIGN_KEYS
  SQLITE_DEFAULT_LOCKING_MODE
  SQLITE_DEFAULT_RECURSIVE_TRIGGERS
  SQLITE_DEFAULT_SYNCHRONOUS
  SQLITE_DEFAULT_WAL_SYNCHRONOUS
  SQLITE_DIRECT_OVERFLOW_READ
  SQLITE_DISABLE_DIRSYNC
  SQLITE_DISABLE_FTS3_UNICODE
  SQLITE_DISABLE_FTS4_DEFERRED
  SQLITE_DISABLE_INTRINSIC
  SQLITE_DISABLE_LFS
  SQLITE_DISABLE_PAGECACHE_OVERFLOW_STATS
  SQLITE_DISABLE_SKIPAHEAD_DISTINCT
  SQLITE_ENABLE_8_3_NAMES
  SQLITE_ENABLE_API_ARMOR
  SQLITE_ENABLE_ATOMIC_WRITE
  SQLITE_ENABLE_BATCH_ATOMIC_WRITE
  SQLITE_ENABLE_BYTECODE_VTAB
  SQLITE_ENABLE_COLUMN_METADATA
  SQLITE_ENABLE_COLUMN_USED_MASK
  SQLITE_ENABLE_COSTMULT
  SQLITE_ENABLE_CURSOR_HINTS
  SQLITE_ENABLE_DBPAGE_VTAB
  SQLITE_ENABLE_DBSTAT_VTAB
  SQLITE_ENABLE_EXPENSIVE_ASSERT
  SQLITE_ENABLE_EXPLAIN_COMMENTS
  SQLITE_ENABLE_FTS3
  SQLITE_ENABLE_FTS3_PARENTHESIS
  SQLITE_ENABLE_FTS3_TOKENIZER
  SQLITE_ENABLE_FTS4
  SQLITE_ENABLE_FTS5
  SQLITE_ENABLE_GEOPOLY
  SQLITE_ENABLE_HIDDEN_COLUMNS
  SQLITE_ENABLE_ICU
  SQLITE_ENABLE_IOTRACE
  SQLITE_ENABLE_LOAD_EXTENSION
  SQLITE_ENABLE_LOCKING_STYLE
  SQLITE_ENABLE_MATH_FUNCTIONS
  SQLITE_ENABLE_MEMORY_MANAGEMENT
  SQLITE_ENABLE_MEMSYS3
  SQLITE_ENABLE_MEMSYS5
  SQLITE_ENABLE_MULTIPLEX
  SQLITE_ENABLE_NORMALIZE
  SQLITE_ENABLE_NULL_TRIM
  SQLITE_ENABLE_OFFSET_SQL_FUNC
  SQLITE_ENABLE_OVERSIZE_CELL_CHECK
  SQLITE_ENABLE_PREUPDATE_HOOK
  SQLITE_ENABLE_QPSG
  SQLITE_ENABLE_RBU
  SQLITE_ENABLE_RTREE
  SQLITE_ENABLE_SESSION
  SQLITE_ENABLE_SNAPSHOT
  SQLITE_ENABLE_SORTER_REFERENCES
  SQLITE_ENABLE_SQLLOG
  SQLITE_ENABLE_STAT4
  SQLITE_ENABLE_STMT_SCANSTATUS
  SQLITE_ENABLE_STMTVTAB
  SQLITE_ENABLE_TREETRACE
  SQLITE_ENABLE_UNKNOWN_SQL_FUNCTION
  SQLITE_ENABLE_UNLOCK_NOTIFY
  SQLITE_ENABLE_UPDATE_DELETE_LIMIT
  SQLITE_ENABLE_URI_00_ERROR
  SQLITE_ENABLE_VFSTRACE
  SQLITE_ENABLE_WHERETRACE
  SQLITE_ENABLE_ZIPVFS
  SQLITE_EXPLAIN_ESTIMATED_ROWS
  SQLITE_EXTRA_IFNULLROW
  SQLITE_FTS5_ENABLE_TEST_MI
  SQLITE_FTS5_NO_WITHOUT_ROWID
  SQLITE_IGNORE_AFP_LOCK_ERRORS
  SQLITE_IGNORE_FLOCK_LOCK_ERRORS
  SQLITE_INLINE_MEMCPY
  SQLITE_INT64_TYPE
  SQLITE_LEGACY_JSON_VALID
  SQLITE_LIKE_DOESNT_MATCH_BLOBS
  SQLITE_LOCK_TRACE
  SQLITE_LOG_CACHE_SPILL
  SQLITE_MEMDEBUG
  SQLITE_MIXED_ENDIAN_64BIT_FLOAT
  SQLITE_MMAP_READWRITE
  SQLITE_MUTEX_NOOP
  SQLITE_MUTEX_OMIT
  SQLITE_MUTEX_PTHREADS
  SQLITE_MUTEX_W32
  SQLITE_NEED_ERR_NAME
  SQLITE_NO_SYNC
  SQLITE_OMIT_ALTERTABLE
  SQLITE_OMIT_ANALYZE
  SQLITE_OMIT_ATTACH
  SQLITE_OMIT_AUTHORIZATION
  SQLITE_OMIT_AUTOINCREMENT
  SQLITE_OMIT_AUTOINIT
  SQLITE_OMIT_AUTOMATIC_INDEX
  SQLITE_OMIT_AUTORESET
  SQLITE_OMIT_AUTOVACUUM
  SQLITE_OMIT_BETWEEN_OPTIMIZATION
  SQLITE_OMIT_BLOB_LITERAL
  SQLITE_OMIT_CAST
  SQLITE_OMIT_CHECK
  SQLITE_OMIT_COMPLETE
  SQLITE_OMIT_COMPOUND_SELECT
  SQLITE_OMIT_CONFLICT_CLAUSE
  SQLITE_OMIT_CTE
  SQLITE_OMIT_DECLTYPE
  SQLITE_OMIT_DEPRECATED
  SQLITE_OMIT_DESERIALIZE
  SQLITE_OMIT_DISKIO
  SQLITE_OMIT_EXPLAIN
  SQLITE_OMIT_FLAG_PRAGMAS
  SQLITE_OMIT_FLOATING_POINT
  SQLITE_OMIT_FOREIGN_KEY
  SQLITE_OMIT_GET_TABLE
  SQLITE_OMIT_HEX_INTEGER
  SQLITE_OMIT_INCRBLOB
  SQLITE_OMIT_INTEGRITY_CHECK
  SQLITE_OMIT_INTROSPECTION_PRAGMAS
  SQLITE_OMIT_JSON
  SQLITE_OMIT_LIKE_OPTIMIZATION
  SQLITE_OMIT_LOAD_EXTENSION
  SQLITE_OMIT_LOCALTIME
  SQLITE_OMIT_LOOKASIDE
  SQLITE_OMIT_MEMORYDB
  SQLITE_OMIT_OR_OPTIMIZATION
  SQLITE_OMIT_PAGER_PRAGMAS
  SQLITE_OMIT_PARSER_TRACE
  SQLITE_OMIT_POPEN
  SQLITE_OMIT_PRAGMA
  SQLITE_OMIT_PROGRESS_CALLBACK
  SQLITE_OMIT_QUICKBALANCE
  SQLITE_OMIT_REINDEX
  SQLITE_OMIT_SCHEMA_PRAGMAS
  SQLITE_OMIT_SCHEMA_VERSION_PRAGMAS
  SQLITE_OMIT_SEH
  SQLITE_OMIT_SHARED_CACHE
  SQLITE_OMIT_SHUTDOWN_DIRECTORIES
  SQLITE_OMIT_SUBQUERY
  SQLITE_OMIT_TCL_VARIABLE
  SQLITE_OMIT_TEMPDB
  SQLITE_OMIT_TEST_CONTROL
  SQLITE_OMIT_TRIGGER
  SQLITE_OMIT_TRUNCATE_OPTIMIZATION
  SQLITE_OMIT_UTF16
  SQLITE_OMIT_VACUUM
  SQLITE_OMIT_VIEW
  SQLITE_OMIT_VIRTUALTABLE
  SQLITE_OMIT_WAL
  SQLITE_OMIT_WSD
  SQLITE_OMIT_XFER_OPT
  SQLITE_PERFORMANCE_TRACE
  SQLITE_PREFER_PROXY_LOCKING
  SQLITE_PROXY_DEBUG
  SQLITE_REVERSE_UNORDERED_SELECTS
  SQLITE_RTREE_INT_ONLY
  SQLITE_SECURE_DELETE
  SQLITE_SMALL_STACK
  SQLITE_SOUNDEX
  SQLITE_SUBSTR_COMPATIBILITY
  SQLITE_TCL
  SQLITE_TEST
  SQLITE_UNLINK_AFTER_CLOSE
  SQLITE_UNTESTABLE
  SQLITE_USE_ALLOCA
  SQLITE_USE_FCNTL_TRACE
  SQLITE_USER_AUTHENTICATION
  SQLITE_USE_URI
  SQLITE_VDBE_COVERAGE
  SQLITE_WIN32_MALLOC
  SQLITE_ZERO_MALLOC
}

# All compile time options for which the assigned value is other than boolean
# and is a comma-separated scalar pair.
#
set value2_options {
  SQLITE_DEFAULT_LOOKASIDE
}

# All compile time options for which the assigned value is other than boolean
# and is a single scalar.
#
set value_options {
  SQLITE_ATOMIC_INTRINSICS
  SQLITE_BITMASK_TYPE
  SQLITE_DEFAULT_CACHE_SIZE
  SQLITE_DEFAULT_FILE_FORMAT
  SQLITE_DEFAULT_FILE_PERMISSIONS
  SQLITE_DEFAULT_JOURNAL_SIZE_LIMIT
  SQLITE_DEFAULT_LOCKING_MODE
  SQLITE_DEFAULT_MMAP_SIZE
  SQLITE_DEFAULT_PAGE_SIZE
  SQLITE_DEFAULT_PCACHE_INITSZ
  SQLITE_DEFAULT_PROXYDIR_PERMISSIONS
  SQLITE_DEFAULT_ROWEST
  SQLITE_DEFAULT_SECTOR_SIZE
  SQLITE_DEFAULT_SYNCHRONOUS
  SQLITE_DEFAULT_WAL_AUTOCHECKPOINT
  SQLITE_DEFAULT_WAL_SYNCHRONOUS
  SQLITE_DEFAULT_WORKER_THREADS
  SQLITE_DQS
  SQLITE_ENABLE_8_3_NAMES
  SQLITE_ENABLE_CEROD
  SQLITE_ENABLE_LOCKING_STYLE
  SQLITE_EXTRA_AUTOEXT
  SQLITE_EXTRA_INIT
  SQLITE_EXTRA_SHUTDOWN
  SQLITE_FTS3_MAX_EXPR_DEPTH
  SQLITE_INTEGRITY_CHECK_ERROR_MAX
  SQLITE_MALLOC_SOFT_LIMIT
  SQLITE_MAX_ATTACHED
  SQLITE_MAX_COLUMN
  SQLITE_MAX_COMPOUND_SELECT
  SQLITE_MAX_DEFAULT_PAGE_SIZE
  SQLITE_MAX_EXPR_DEPTH
  SQLITE_MAX_FUNCTION_ARG
  SQLITE_MAX_LENGTH
  SQLITE_MAX_LIKE_PATTERN_LENGTH
  SQLITE_MAX_MEMORY
  SQLITE_MAX_MMAP_SIZE
  SQLITE_MAX_MMAP_SIZE_
  SQLITE_MAX_PAGE_COUNT
  SQLITE_MAX_PAGE_SIZE
  SQLITE_MAX_SCHEMA_RETRY
  SQLITE_MAX_SQL_LENGTH
  SQLITE_MAX_TRIGGER_DEPTH
  SQLITE_MAX_VARIABLE_NUMBER
  SQLITE_MAX_VDBE_OP
  SQLITE_MAX_WORKER_THREADS
  SQLITE_SORTER_PMASZ
  SQLITE_STAT4_SAMPLES
  SQLITE_STMTJRNL_SPILL
  SQLITE_TEMP_STORE
}

# Options that require custom code.
#
set options(COMPILER) {
#if defined(__clang__) && defined(__clang_major__)
  "COMPILER=clang-" CTIMEOPT_VAL(__clang_major__) "."
                    CTIMEOPT_VAL(__clang_minor__) "."
                    CTIMEOPT_VAL(__clang_patchlevel__),
#elif defined(_MSC_VER)
  "COMPILER=msvc-" CTIMEOPT_VAL(_MSC_VER),
#elif defined(__GNUC__) && defined(__VERSION__)
  "COMPILER=gcc-" __VERSION__,
#endif
}
set options(HAVE_ISNAN) {
#if HAVE_ISNAN || SQLITE_HAVE_ISNAN
  "HAVE_ISNAN",
#endif
}
set options(OMIT_DATETIME_FUNCS) {
#if defined(SQLITE_OMIT_DATETIME_FUNCS) || defined(SQLITE_OMIT_FLOATING_POINT)
  "OMIT_DATETIME_FUNCS",
#endif
}
set options(SYSTEM_MALLOC) "\
#if (!defined(SQLITE_WIN32_MALLOC) \\
     && !defined(SQLITE_ZERO_MALLOC) \\
     && !defined(SQLITE_MEMDEBUG) \\
    ) || defined(SQLITE_SYSTEM_MALLOC)
  \"SYSTEM_MALLOC\",
#endif
"
set options(THREADSAFE) {
#if defined(SQLITE_THREADSAFE)
  "THREADSAFE=" CTIMEOPT_VAL(SQLITE_THREADSAFE),
#elif defined(THREADSAFE)
  "THREADSAFE=" CTIMEOPT_VAL(THREADSAFE),
#else
  "THREADSAFE=1",
#endif
}

set options(WAL2) { "WAL2", }

proc trim_name {in} {
  set ret $in
  if {[string range $in 0 6]=="SQLITE_"} {
    set ret [string range $in 7 end]
  }
  return $ret
}

foreach name_defval $boolean_defnnz_options {
  set b [lindex $name_defval 0]
  set defval [lindex $name_defval 1]
  set name [trim_name $b]
  set options($name) [subst {
#ifdef $b
# if $b != $defval
  "$name=" CTIMEOPT_VAL($b),
# endif
#endif
}]
}

foreach b $boolean_defnil_options {
  set name [trim_name $b]
  set options($name) [subst {
#ifdef $b
  "$name",
#endif
}]
}
  
foreach v $value_options {
  set name [trim_name $v]
  set options($name) [subst {
#ifdef $v
  "$name=" CTIMEOPT_VAL($v),
#endif
}]
}
  
foreach v $value2_options {
  set name [trim_name $v]
  set options($name) [subst {
#ifdef $v
  "$name=" CTIMEOPT_VAL2($v),
#endif
}]
}

if {$argc>0} {
  set destfile [lindex $argv 0]
} else {
  set destfile "[file dir [file dir [file normal $argv0]]]/src/ctime.c"
  puts "Overwriting $destfile..."
}

if {[catch {set cfd [open $destfile w]}]!=0} {
  puts stderr "File '$destfile' unwritable."
  exit 1;
}
fconfigure $cfd -translation binary

puts $cfd $::headWarning;
puts $cfd $::headCode;
foreach o [lsort [array names options]] {
  puts $cfd [string trim $options($o)]
}
puts -nonewline $cfd $::tailCode;

close $cfd
