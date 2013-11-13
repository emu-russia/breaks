// Комментарии на русском (не вижу причин вообще писать комменты не на родном языке).
#include "breaksvm.h"
//#include <pthread.h>
#include <stdarg.h>
#include <stdio.h>

static char *VM_FILE;
static int  VM_LINE;
static int  VM_TERMINATE = 0;

static void error (char *fmt, ...)
{
    va_list arg;
    char buf[0x1000];
    va_start(arg, fmt);
    vsprintf(buf, fmt, arg);
    va_end(arg);
    printf ( "ERROR (%s, line %i): %s\n", VM_FILE, VM_LINE, buf );
    VM_TERMINATE = 1;
}

static void warning (char *fmt, ...)
{
    va_list arg;
    char buf[0x1000];
    va_start(arg, fmt);
    vsprintf(buf, fmt, arg);
    va_end(arg);
    printf ( "WARNING (%s, line %i): %s\n", VM_FILE, VM_LINE, buf );
}

// ------------------------------------------------------------------------------------
// verilog tokenizer

// Шо тут.
// Ну тут просто : у нас есть поток лексем, который мы пихаем в парсер. Если что-то пошло не так - выводим ошибку или warning.
// Все идентификаторы помещаются в таблицу символов, каждый элемент которой имеет свой ID.
// Хеширование для проверки есть ли уже такой идентификатор в таблице или нет - используется алгоритм быстрого хеширования строк Murmur3

enum TOKEN_TYPE
{
    TOKEN_NULL = 0,
    TOKEN_OP,
    TOKEN_NUMBER,
    TOKEN_STRING,
    TOKEN_IDENT,
    TOKEN_KEYWORD,
    TOKE_MAX_TYPE,
};

typedef struct token_t
{
    int     type;
    char    rawstring[256];
    u32     number;
    int     keyword;
    int     ident;
} token_t;

// Таблица символов.

enum SYMBOL_TYPE
{
    SYMBOL_UNKNOWN = 0,

    SYMBOL_KEYWORD_ALWAYS = 1, SYMBOL_KEYWORD_AND, SYMBOL_KEYWORD_BEGIN, SYMBOL_KEYWORD_BUF, SYMBOL_KEYWORD_BUFIF0, SYMBOL_KEYWORD_BUFIF1,
    SYMBOL_KEYWORD_CASE, SYMBOL_KEYWORD_CASEX, SYMBOL_KEYWORD_CASEZ, SYMBOL_KEYWORD_ELSE, SYMBOL_KEYWORD_END, SYMBOL_KEYWORD_ENDCASE, SYMBOL_KEYWORD_ENDMODULE,
    SYMBOL_KEYWORD_FOR, SYMBOL_KEYWORD_IF, SYMBOL_KEYWORD_INOUT, SYMBOL_KEYWORD_INPUT, SYMBOL_KEYWORD_INTEGER, SYMBOL_KEYWORD_MODULE,
    SYMBOL_KEYWORD_NAND, SYMBOL_KEYWORD_NEGEDGE, SYMBOL_KEYWORD_NOR, SYMBOL_KEYWORD_NOT, SYMBOL_KEYWORD_NOTIF0, SYMBOL_KEYWORD_NOTIF1,
    SYMBOL_KEYWORD_OR, SYMBOL_KEYWORD_OUTPUT, SYMBOL_KEYWORD_PARAMETER, SYMBOL_KEYWORD_POSEDGE, SYMBOL_KEYWORD_REG, SYMBOL_KEYWORD_SCALARED,
    SYMBOL_KEYWORD_SUPPLY0, SYMBOL_KEYWORD_SUPPLY1, SYMBOL_KEYWORD_TRI0, SYMBOL_KEYWORD_TRI1,
    SYMBOL_KEYWORD_TRI, SYMBOL_KEYWORD_TRIAND, SYMBOL_KEYWORD_TRIOR, SYMBOL_KEYWORD_TRIREG, SYMBOL_KEYWORD_VECTORED, SYMBOL_KEYWORD_WAND,
    SYMBOL_KEYWORD_WHILE, SYMBOL_KEYWORD_WIRE, SYMBOL_KEYWORD_WOR, SYMBOL_KEYWORD_XNOR, SYMBOL_KEYWORD_XOR,

    SYMBOL_INPUT = 200,
    SYMBOL_OUTPUT,
    SYMBOL_INOUT,
    SYMBOL_REG,
    SYMBOL_WIRE,
};

static char * keywords[] = {
    "always",       "for",          "or",           "tri",
    "and",          "if",           "output",       "triand",
    "begin",        "inout",        "parameter",    "trior",
    "buf",          "input",        "posedge",      "trireg",
    "bufif0",       "integer",      "reg",          "vectored",
    "bufif1",       "module",       "scalared",     "wand",
    "case",         "nand",                         "while",
    "casex",        "negedge",      "supply0",      "wire",
    "casez",        "nor",          "supply1",      "wor",
    "else",         "not",                          "xnor",
    "end",          "notif0",       "tri0",         "xor",
    "endcase",      "notif1",       "tri1",
    "endmodule",
    NULL,
};
static int keyword_ids[] = {    // должна соответствовать таблице keywords.
    SYMBOL_KEYWORD_ALWAYS, SYMBOL_KEYWORD_FOR, SYMBOL_KEYWORD_OR, SYMBOL_KEYWORD_TRI,
    SYMBOL_KEYWORD_AND, SYMBOL_KEYWORD_IF, SYMBOL_KEYWORD_OUTPUT, SYMBOL_KEYWORD_TRIAND,
    SYMBOL_KEYWORD_BEGIN, SYMBOL_KEYWORD_INOUT, SYMBOL_KEYWORD_PARAMETER, SYMBOL_KEYWORD_TRIOR,
    SYMBOL_KEYWORD_BUF, SYMBOL_KEYWORD_INPUT, SYMBOL_KEYWORD_POSEDGE, SYMBOL_KEYWORD_TRIREG,
    SYMBOL_KEYWORD_BUFIF0, SYMBOL_KEYWORD_INTEGER, SYMBOL_KEYWORD_REG, SYMBOL_KEYWORD_VECTORED,
    SYMBOL_KEYWORD_BUFIF1, SYMBOL_KEYWORD_MODULE, SYMBOL_KEYWORD_SCALARED, SYMBOL_KEYWORD_WAND,
    SYMBOL_KEYWORD_CASE, SYMBOL_KEYWORD_NAND, SYMBOL_KEYWORD_WHILE, 
    SYMBOL_KEYWORD_CASEX, SYMBOL_KEYWORD_NEGEDGE, SYMBOL_KEYWORD_SUPPLY0, SYMBOL_KEYWORD_WIRE,
    SYMBOL_KEYWORD_CASEZ, SYMBOL_KEYWORD_NOR, SYMBOL_KEYWORD_SUPPLY1, SYMBOL_KEYWORD_WOR,
    SYMBOL_KEYWORD_ELSE, SYMBOL_KEYWORD_NOT, SYMBOL_KEYWORD_XNOR,
    SYMBOL_KEYWORD_END, SYMBOL_KEYWORD_NOTIF0, SYMBOL_KEYWORD_TRI0, SYMBOL_KEYWORD_XOR,
    SYMBOL_KEYWORD_ENDCASE, SYMBOL_KEYWORD_NOTIF1, SYMBOL_KEYWORD_TRI1,
    SYMBOL_KEYWORD_ENDMODULE,
};

typedef struct symbol_t
{
    char    rawstring[256];
    u32     hash;
    int     type;
} symbol_t;

static  symbol_t *symtab;
static  int sym_num;

static u32 Murmur3Hash (char * string)
{
    return 333;
}

static int check_symbol (char *name)   // проверить есть ли в таблице символов указанный символ. Вернуть 0 если не найден, или ID если найден.
{
    symbol_t *symbol;
    int i;
    u32 hash = Murmur3Hash (name);
    for (i=0; i<sym_num; i++) {
        symbol = &symtab[i];
        if ( symbol->hash == hash ) return i;
    }
    return 0;
}

static int add_symbol (char *name, int type)     // добавить символ, вернуть ID
{
    symbol_t *symbol;
    if ( strlen (name) > 255 ) {
        warning ( "Symbol \'%s\' name length exceeds 255 bytes, will be truncated", name );
    }
    symtab = (symbol_t *)realloc (symtab, sizeof(symbol_t) * (sym_num + 1) );
    if ( !symtab ) {
        error ( "Cannot allocate symbol \'%s\', not enough memory", name );
        return 0;
    }
    symbol = &symtab[sym_num];
    strncpy ( symbol->rawstring, name, 255 );
    symbol->type = type;
    symbol->hash = Murmur3Hash (symbol->rawstring);     // calculate hash for truncated name!
    sym_num++;
}

static void dump_symbols (void)
{
    int i;
    for (i=0; i<sym_num; i++) {
        if ( symtab[i].type < 200 ) continue;   // don't dump keywords.
        printf ( "SYMBOL : %s, hash : %08X, type : %i\n", symtab[i].rawstring, symtab[i].hash, symtab[i].type );
    }
}

// ------------------------------------------------------------------------------------
// verilog syntax tree parser

// Парсим поток токенов в синтаксическое бинарное дерево. Узлами дерева могут быть либо выражения, либо операции.
// Выражения - это идентификаторы, числа или строки.
// Операции - это специальные команды, которые управляют "ростом" дерева.
// Ветки дерева могут расти рекурсивно, в виде поддеревьев (обычное дело).

//typedef struct wire_t
//{
//} wire_t;

int breaksvm_load (char *filename)
{
}

// ------------------------------------------------------------------------------------
// EDIF 2 0 0 nodelist generator

// ------------------------------------------------------------------------------------
// nodelist JIT-compiler (транслятор)

// ------------------------------------------------------------------------------------
// simulator and standard cells

// virtual devices

void breaksvm_input_real (char *input_name, void (*callback)(float *real))
{
}

void breaksvm_input_reg (char *input_name, void (*callback)(unsigned char *reg))
{
}

void breaksvm_output_real (char *output_name, void (*callback)(float *real))
{
}

void breaksvm_output_reg (char *output_name, void (*callback)(unsigned char *reg))
{
}

// runtime controls

void breaksvm_run (int timeout)
{
}

int breaksvm_status (void)
{
}

// ------------------------------------------------------------------------------------
// misc external API

// init/shutdown

static int breaksvm_initdone = 0;

int breaksvm_init (void)
{
    if ( breaksvm_initdone ) return 1;

    VM_TERMINATE = 0;   // если эта переменная выставляется в 1, то значит нужно прервать процесс компиляции или трансляции.

    // Добавим ключевые слова в таблицу символов.
    {
        add_symbol ( "", SYMBOL_UNKNOWN );
        int i = 0;
        while ( keywords[i] ) {
            add_symbol ( keywords[i], keyword_ids[i] );
            i++;
        }
    }

    breaksvm_initdone = 1;
}

void breaksvm_shutdown (void)
{
    if (breaksvm_initdone) {
        if ( symtab ) {
            free ( symtab );
            symtab = NULL;
            sym_num = 0;
        }
        breaksvm_initdone = 0;
    }
}
