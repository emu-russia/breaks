// Комментарии на русском (не вижу причин вообще писать комменты НЕ на родном языке).
#include "breaksvm.h"
//#include <pthread.h>
#include <stdarg.h>
#include <stdio.h>

static char VM_FILE[256] = "Not yet";
static int  VM_LINE = 0;
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
// Хеширование для проверки есть ли уже такой идентификатор в таблице или нет - используется алгоритм быстрого хеширования строк Murmur

// Пока что, для упрощения мы будем считать что мы уже внутри какого-то модуля. Мультимодульную среду можно легко создать, добавив обертку.

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

    SYMBOL_NOT_KEYWORDS = 100,
    SYMBOL_IDENT,   // просто идентификатор (пока неизвестно какого типа)
    SYMBOL_INPUT,
    SYMBOL_OUTPUT,
    SYMBOL_INOUT,
    SYMBOL_REG,
    SYMBOL_WIRE,
    SYMBOL_PARAM,
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

typedef struct number_t
{
    u32     value;
    u32     xmask;
    u32     zmask;
    int     lsb, msb, len;
} number_t;

typedef struct symbol_t
{
    char    rawstring[256];
    number_t    num;
    u32     hash;
    int     type;
} symbol_t;

static  symbol_t symtab[1000];
static  int sym_num;

static u32 MurmurHash (char * key)      // https://code.google.com/p/smhasher/
{
  int len = strlen (key);
  const unsigned int m = 0x5bd1e995;
  const unsigned int seed = 0;
  const int r = 24;
 
  unsigned int h = seed ^ len;
 
  const unsigned char * data = (const unsigned char *)key;
 
  while (len >= 4)
    {
      unsigned int k;
      k  = data[0];
      k |= data[1] << 8;
      k |= data[2] << 16;
      k |= data[3] << 24;
      k *= m;
      k ^= k >> r;
      k *= m;
      h *= m;
      h ^= k;
      data += 4;
      len -= 4;
    }
  switch (len)
    {
    case 3:
      h ^= data[2] << 16;
    case 2:
      h ^= data[1] << 8;
    case 1:
      h ^= data[0];
      h *= m;
    };
  h ^= h >> 13;
  h *= m;
  h ^= h >> 15;
  return h;
}

static symbol_t * check_symbol (char *name)   // проверить есть ли в таблице символов указанный символ. Вернуть NULL если не найден, или объект если найден.
{
    symbol_t *symbol;
    int i;
    u32 hash = MurmurHash (name);
    for (i=0; i<sym_num; i++) {
        symbol = &symtab[i];
        if ( symbol->hash == hash ) return symbol;
    }
    return NULL;
}

static symbol_t * add_symbol (char *name, int type)     // добавить символ, вернуть описатель или NULL
{
    symbol_t *symbol;
    if ( strlen (name) > 255 ) {
        warning ( "Martin, your symbol \'%s\' name length exceeds 255 bytes and will be truncated!", name ); // выдаем предупреждение Мартину Корту
    }
    symbol = &symtab[sym_num];
    strncpy ( symbol->rawstring, name, 255 );
    symbol->type = type;
    symbol->hash = MurmurHash (symbol->rawstring);     // calculate hash for truncated name!
    memset ( &symbol->num, 0, sizeof(number_t) );
    sym_num++;
    return &symtab[sym_num - 1];
}

static void dump_symbols (void)
{
    int i;
    for (i=0; i<sym_num; i++) {
        if ( symtab[i].type < SYMBOL_NOT_KEYWORDS ) continue;   // don't dump keywords.
        if ( symtab[i].type == SYMBOL_PARAM ) printf ( "PARAM : %s, value : %i\n", symtab[i].rawstring, symtab[i].num.value );
        else if ( symtab[i].type == SYMBOL_INPUT ) printf ( "INPUT : %s\n", symtab[i].rawstring );
        else if ( symtab[i].type == SYMBOL_OUTPUT ) printf ( "OUTPUT : %s\n", symtab[i].rawstring );
        else if ( symtab[i].type == SYMBOL_INOUT ) printf ( "INOUT : %s\n", symtab[i].rawstring );
        else if ( symtab[i].type == SYMBOL_WIRE ) printf ( "WIRE : %s\n", symtab[i].rawstring );
        else if ( symtab[i].type == SYMBOL_REG ) printf ( "REG : %s\n", symtab[i].rawstring );
        else printf ( "SYMBOL : %s\n", symtab[i].rawstring );
    }
}

/*

Часть стандарта Verilog будет тут. (в основном в этом блоке - описание формата лексем)

числа: общий формат записи такой : <size>[spaces]<'[bBoOdDhH]base>[spaces]<[0-9a-fA-F_]>
Размер числа не может быть = 0 или больше 32 бит.

строки: последовательность символов между "..." при этом "sdfsdf//тест" - будет являться строкой (комментарии внутри строки - это часть строки)
токен активируется при обнаружении ". Далее выбираются символы до следующего ", либо до конца строки '\n'. Если строка не закрылась, то вякаем предупреждением и закрываем строку.

имена: обычные правила для имён, но можно ещё использовать знак доллара $. 
Также если имя начинается с символа \ , то дальше могут идти вообще любой байт-код, до символа <= пробела.

операции : { } + - * /  %  > >= < <=  ! && || == != === !== ~ & | ^ ^~ ~^ ~& ~| << >> <<< >>> ? : ( ) # = <=
приоритет операций :
    { } (конкатенация) ( ) [ ]
    + - ! ~ (унарные)
    * / %
    + - 
    << >> <<< >>>
    == != === !==
    & ~&
    ^ ^~ ~^
    | ~|
    &&
    ||
    ?:

Ну теперь вроде всё готово, ключевые слова запихали в таблицу символов, типы токенов расставили, понеслась пизда по кочкам.

*/

enum TOKEN_TYPE
{
    TOKEN_NULL = 0,
    TOKEN_OP,
    TOKEN_NUMBER,
    TOKEN_STRING,
    TOKEN_IDENT,
    TOKEN_KEYWORD,
    TOKEN_MAX_TYPE,
};

typedef struct token_t
{
    int     type;
    char    rawstring[256];
    symbol_t * sym;
    number_t num;
    int     op;         // operation
} token_t;

enum OPS
{
    NOP=0,
    LBRACKET, RBRACKET,       // { }
    LSQUARE, RSQUARE,       // [ ]
    PLUS_UNARY, PLUS_BINARY,      // +
    MINUS_UNARY, MINUS_BINARY,    // -
    NOT, NEG,     // ! ~
    MUL, DIV, MOD,     // * / %
    SHL, SHR, ROTL, ROTR,   // << >> <<< >>>
    GREATER, GREATER_EQ, LESS, LESS_EQ,     // > >= < <=
    LOGICAL_AND, LOGICAL_OR,      // && ||
    LOGICAL_EQ, CASE_EQ, LOGICAL_NOTEQ, CASE_NOTEQ,     // == === != !==
    AND, OR, XOR, XNOR, // & | ^ ~^ ^~
    REDUCT_AND, REDUCT_NAND, REDUCT_OR, REDUCT_NOR, REDUCT_XOR, REDUCT_XNOR,  // & ~& | ~| ^ ^~ ~^
    HMMM, COLON,  // ? :
    LPAREN, RPAREN,   // ( )
    EQ, POST_EQ,  // = <=
    HASH, DOGGY,   // # @
    POINT, COMMA, SEMICOLON,  // . , ;
};

static char * opstr (int type)
{
    char *str[] = {
        "NOP", "{", "}", "[", "]", "+", "++", "-", "--", "!", "~", "*", "/", "%",
        "<<", ">>", "<<<", ">>>", ">", ">=", "<", "<=", "&&", "||",
        "==", "===", "!=", "!==", "&", "|", "^", "~^", "R&", "R~&", "R|", "R~|", "R^", "R~^", 
        "?", ":", "(", ")", "=", "POST=", "#", "@", ".", ",", ";", 
    };
    return str[type];
}

// Tokenizer выдает поток токенов потребителям.

static void (*parser_stack[1024])(token_t * token) ;
static int parser_stack_pointer;
static token_t previous_token, current_token;
static int tokenization_started = 0;
static u8 * token_source;
static int token_source_pointer, token_source_length;

static char * token_type (int type)
{
    switch (type)
    {
        case TOKEN_NULL : return "NULL";
        case TOKEN_OP : return "OP";
        case TOKEN_NUMBER : return "NUMBER";
        case TOKEN_STRING : return "STRING";
        case TOKEN_IDENT : return "IDENT";
        case TOKEN_KEYWORD : return "KEYWORD";
        default : return "UNKNOWN";
    }
}

static int isunary (int op)
{
    switch (op)
    {
        case PLUS_UNARY:
        case MINUS_UNARY:
        case NOT:
        case NEG:
        case REDUCT_AND:
        case REDUCT_NAND:
        case REDUCT_OR:
        case REDUCT_NOR:
        case REDUCT_XOR:
        case REDUCT_XNOR:
            return 1;
    }
    return 0;
}

static int isbinary (int op)
{
    switch (op)
    {
        case PLUS_BINARY:
        case MINUS_BINARY:
        case MUL: case DIV: case MOD:
        case SHL: case SHR: case ROTL: case ROTR:
        case GREATER: case GREATER_EQ: case LESS: case LESS_EQ:
        case LOGICAL_AND: case LOGICAL_OR:
        case LOGICAL_EQ: case CASE_EQ: case LOGICAL_NOTEQ: case CASE_NOTEQ:
        case AND: case OR: case XOR: case XNOR:
            return 1;
    }
    return 0;
}

static void tokenize_file ( unsigned char * content, int filesize )   // подключить загруженный файл 
{
    tokenization_started = 0;
    token_source = content;
    token_source_pointer = 0;
    token_source_length = filesize;
    parser_stack_pointer = 0;
    parser_stack[0] = NULL;
    memset ( &previous_token, 0, sizeof(token_t) );
}

static void push_parser ( void (*parser)(token_t * token) )  // подцепить парсер к потоку, старый положить в стек
{
    if ( parser_stack_pointer > 1023 ) error ( "Parser stack is full (too many nested blocks)!" );
    parser_stack[++parser_stack_pointer] = parser;
}

static void pop_parser (void)   // вернуть старый парсер из стека
{
    if (parser_stack_pointer > 0) parser_stack_pointer--;
}

static unsigned char nextch (int * empty)   // получить следующий символ
{
    if ( token_source_pointer < token_source_length && !VM_TERMINATE ) {
        *empty = 0;
        return token_source[token_source_pointer++];
    }
    else {
        *empty = 1;
        return 0;
    }
}

static void putback (void)   // положить назад где взяли
{
    if ( token_source_pointer > 0 ) token_source_pointer--;
}

static int allowed_char (char c, char *allowed)
{
    char *ptr = allowed;
    while (*ptr) {
        if ( *ptr == c ) return 1;
        ptr++;
    }
    return 0;
}

static void setop (int op)
{
    current_token.type = TOKEN_OP;
    current_token.op = op;
}

static void setopback (int op)
{
    putback ();
    current_token.type = TOKEN_OP;
    current_token.op = op;
}

// конвертирует строку в число. выполняет популяцию разрядов.
static void convertnum ( char *str, number_t *num, int base, int lsb, int msb)
{
    u32 lenmask;
    int len = abs(lsb-msb) + 1, bits = 0;
    char c, *ptr = str;

    num->lsb = lsb;
    num->msb = msb;
    num->len = len;
    if (len == 32) lenmask = 0xffffffff;
    else lenmask = (1 << len) - 1;

    if (base == 2) {
        num->value = num->zmask = num->xmask = 0;
        while (*ptr) {
            num->value <<= 1;
            num->zmask <<= 1;
            num->xmask <<= 1;
            bits++;
            c = *ptr++;
            if (c == '0') { num->value; }
            else if (c == '1') { num->value |= 1; }
            else if (c == 'x' || c == 'X' || c == '?') { num->xmask |= 1; }
            else if (c == 'z' || c == 'Z') { num->zmask |= 1; }
            else if (c == '_') continue;
            else break;
        }
    }
    else if (base == 8) {
        num->value = num->zmask = num->xmask = 0;
        while (*ptr) {
            num->value <<= 3;
            num->zmask <<= 3;
            num->xmask <<= 3;
            bits+=3;
            c = *ptr++;
            if (c == '0') { num->value; }
            else if (c == '1') { num->value |= 1; }
            else if (c == '2') { num->value |= 2; }
            else if (c == '3') { num->value |= 3; }
            else if (c == '4') { num->value |= 4; }
            else if (c == '5') { num->value |= 5; }
            else if (c == '6') { num->value |= 6; }
            else if (c == '7') { num->value |= 7; }
            else if (c == 'x' || c == 'X' || c == '?') { num->xmask |= 7; }
            else if (c == 'z' || c == 'Z') { num->zmask |= 7; }
            else if (c == '_') continue;
            else break;
        }
    }
    else if (base == 16) {
        num->value = num->zmask = num->xmask = 0;
        while (*ptr) {
            num->value <<= 4;
            num->zmask <<= 4;
            num->xmask <<= 4;
            bits+=4;
            c = *ptr++;
            if (c == '0') { num->value; }
            else if (c == '1') { num->value |= 1; }
            else if (c == '2') { num->value |= 2; }
            else if (c == '3') { num->value |= 3; }
            else if (c == '4') { num->value |= 4; }
            else if (c == '5') { num->value |= 5; }
            else if (c == '6') { num->value |= 6; }
            else if (c == '7') { num->value |= 7; }
            else if (c == '8') { num->value |= 8; }
            else if (c == '9') { num->value |= 9; }
            else if (c == 'a' || c == 'A') { num->value |= 0xa; }
            else if (c == 'b' || c == 'B') { num->value |= 0xb; }
            else if (c == 'c' || c == 'C') { num->value |= 0xc; }
            else if (c == 'd' || c == 'D') { num->value |= 0xd; }
            else if (c == 'e' || c == 'E') { num->value |= 0xe; }
            else if (c == 'f' || c == 'F') { num->value |= 0xf; }
            else if (c == 'x' || c == 'X' || c == '?') { num->xmask |= 0xf; }
            else if (c == 'z' || c == 'Z') { num->zmask |= 0xf; }
            else if (c == '_') continue;
            else break;
        }
    }
    else if (base == 10) {  // для десятичных чисел популяция не производится. ПНХ разработчики стандарта))) (как интересно они популируют десятичные числа...)
        num->value = strtoul (str, NULL, 10);
        num->zmask = num->xmask = 0;
    }

    num->value &= lenmask;
    num->zmask &= lenmask;
    num->xmask &= lenmask;

    // короче пох на популяцию.... кто пишет что заполняется нулями, кто пишет что заполняется MSB. бред короче, оставляем пока как есть.
}

// вывести число
static void dumpnum (number_t *num)
{
    printf ( "NUM: %08X, %i, size: [%i:%i] %i, Z:%08X, X:%08X\n", num->value, num->value, 
            num->lsb, num->msb, num->len, num->zmask, num->xmask );
}

static token_t * next_token (void)  // получить следующий токен или вернуть NULL, если конец файла
{
    int empty, international, ident_max_size, number_max_size, base;
    token_t * pt = &previous_token;
    u8 ch, size[32], number[256], ident[1024], *ptr;
    symbol_t * sym;
    char * allowed;

    // копируем текущий токен в предыдущий, только если он не пустышка.
    if (current_token.type != TOKEN_NULL) memcpy ( &previous_token, &current_token, sizeof(token_t) );

    // ну просто дубовый алгоритм, выбираем символы и смотрим что получается )))
    // иногда мы делаем look-ahead, для выборки длинных операций, а иногда делаем look-back (например для определения - унарный ли - или бинарный)

    current_token.type = TOKEN_NULL;
    current_token.rawstring[0] = 0;

    ch = nextch (&empty);
    if ( empty ) return NULL;

    // пропускаем пробелы
    if ( ch <= ' ' ) {
        while (!empty) {
            ch = nextch (&empty);
            if (ch == '\n') VM_LINE++;
            if (ch <= ' ') continue;
            else break;
        }
        if (empty) return NULL;
    }

    // пропускаем однострочные комментарии (потенциально - деление /)
    if (ch == '/') {
        ch = nextch (&empty);
        if (empty || ch != '/') {    // если дальше ничего нет или второй символ не / - вернуть просто как деление
            if (!empty) putback ();   // вернуть если не пусто
            setop (DIV);
        }
        else {   // пропустим все символы до конца строка '\n' или конца файла
            while (!empty) {
                ch = nextch (&empty);
                if (ch == '\n') { VM_LINE++; break; }
            }
            if (empty) return NULL;
        }
    }
    // .... если после пропуска однострочных комментариев в строке остались пробелы или табуляции, то дальнейшее исполнение ни к чему не приведёт и вернется TOKEN_NULL.

    // пропускаем многострочные комментарии (потенциально - деление /) 

    // .... если после пропуска многострочных комментариев в строке остались пробелы или табуляции, то дальнейшее исполнение ни к чему не приведёт и вернется TOKEN_NULL.

    // идентификаторы / ключевые слова
    if ( (ch >= 'a' && ch <= 'z') || (ch >= 'A' && ch <= 'Z') || (ch == '_') || (ch == '\\') )
    {
        ident_max_size = 1000;   // установить максимальный размер идентификатора
        ptr = ident;
        international = (ch == '\\');   // поддержка интернациональных идентификаторов.
        *ptr++ = ch;
        while (!empty && ident_max_size) {
            ch = nextch (&empty);
            if ( !international ) {
                if ( !isalpha(ch) && !isdigit(ch) && (ch != '_') && (ch != '$') ) {
                    if (!empty) putback ();
                    *ptr++ = 0;
                    break;
                }
            }
            else {
                if (ch <= ' ') {
                    if (!empty) putback ();
                    *ptr++ = 0;
                    break;
                }
            }
            if (!empty) {
                *ptr++ = ch;
                ident_max_size--;
            }
        }
        if (empty) *ptr++ = 0;
        if (ident_max_size == 0) warning ( "Identifier max. length exceeds limit" );

        // вернуть ключевое слово или идентификатор.
        sym = check_symbol (ident);
        if (sym) {
            if (sym->type > SYMBOL_NOT_KEYWORDS) current_token.type = TOKEN_IDENT;
            else current_token.type = TOKEN_KEYWORD;
            strncpy ( current_token.rawstring, ident, 255 );
            current_token.sym = sym;
        }
        else         // добавим идентификатор (параметром или чем либо ещё он может стать потом)
        {
            sym = add_symbol (ident, SYMBOL_IDENT);
            current_token.type = TOKEN_IDENT;
            strncpy ( current_token.rawstring, ident, 255 );
            current_token.sym = sym;
        }
    }

    // числа
    // если предыдущий токен не приставка системы счисления, то мы сканируем 0-9 и _ (но черточка не должна быть первой, иначе это будет идентификатор, но идентификаторы мы уже разобрали)
    // если приставка была, то :
    // для двоичных чисел : 0 1 _ x X z Z ?
    // для восьмеричных : 0 1 2 3 4 5 6 7 _ x X z Z ?
    // для десятичных : 0 1 2 3 4 5 6 7 8 9 _ 
    // для шестнаыфаысыых : 0 1 2 3 4 5 6 7 8 9 a A b B c C d D e E f F _ x X z Z ?
    // Популяцию цифр должна выполнять соответствующая операция. Что такое популяция - это заполнение пропущенных цифр - последней значащей.
    // Например 8'b1 -- популируется как 1111_1111, а 8'b0101 популируется уже как 0000_0101.
    if (current_token.type == TOKEN_NULL) 
    {
        if (isdigit(ch) || ch == '\'' ) {
            number[0] = 0;
            base = 0;

            // получить размер числа. если за размером не идёт уточняющий префикс, то вернуть размер как 10-чное число.
            allowed = "0123456789_";
            if ( allowed_char(ch, allowed) ) {
                ptr = size;
                *ptr++ = ch;
                while ( !empty && allowed_char(ch, allowed) ) {
                    ch = nextch (&empty);
                    if (ch != '_' && allowed_char(ch, allowed) ) *ptr++ = ch;
                }
                *ptr++ = 0;
            }
            else strcpy (size, "32");

            // пропустить пробелы.
            if ( ch <= ' ' ) {
                while (!empty) {
                    ch = nextch (&empty);
                    if (ch == '\n') VM_LINE++;
                    if (ch <= ' ') continue;
                    else break;
                }
                if (empty) {        // вернуть размер как число.
                    current_token.type = TOKEN_NUMBER;
                }
            }

            // получить основание числа
            if (ch == '\'' && current_token.type == TOKEN_NULL ) {
                ch = nextch (&empty);
                if (!empty) {
                    if ( ch == 'b' || ch == 'B' ) base = 2;
                    else if ( ch == 'o' || ch == 'O' ) base = 8;
                    else if ( ch == 'd' || ch == 'D' ) base = 10;
                    else if ( ch == 'h' || ch == 'H' ) base = 16;
                }
                if (base == 0) warning ("Unknown base : [%c]", ch);
                if (base == 2) allowed = "01xXzZ?_";
                else if (base == 8) allowed = "01234567xXzZ?_";
                else if (base == 10) allowed = "0123456789_";
                else if (base == 16) allowed = "0123456789abcdefABCDEFxXzZ?_";
                ch = nextch (&empty);
            }
            else {      // вернуть размер как число.
                putback ();
                current_token.type = TOKEN_NUMBER;
            }

            // пропустить пробелы.
            if ( ch <= ' ' && current_token.type == TOKEN_NULL ) {
                while (!empty) {
                    ch = nextch (&empty);
                    if (ch == '\n') VM_LINE++;
                    if (ch <= ' ') continue;
                    else break;
                }
                if (empty) {        // вернуть число 0, если за указанием основания числа ничего нет
                    current_token.type = TOKEN_NUMBER;
                    strcpy (size, "0");
                }
            }

            // выбрать цифры с указанной системой счисления.
            if ( allowed_char(ch, allowed) && current_token.type == TOKEN_NULL ) {
                ptr = number;
                *ptr++ = ch;
                while ( !empty && allowed_char(ch, allowed) ) {
                    ch = nextch (&empty);
                    if (ch != '_' && allowed_char(ch, allowed) ) *ptr++ = ch;
                }
                if (!empty) putback ();
                *ptr++ = 0;
                current_token.type = TOKEN_NUMBER;
            }

            // конвертировать число и выполнить популяцию 
            if ( current_token.type == TOKEN_NUMBER ) {
                if (base) convertnum (number, &current_token.num, base, 0, atoi(size) - 1);
                else convertnum (size, &current_token.num, 10, 0, 31);
            }
        }
    }

    // однознаковые операции
    if ( current_token.type == TOKEN_NULL )
    {
        switch (ch)
        {
            case '[': setop (LSQUARE); break;
            case ']': setop (RSQUARE); break;
            case '{': setop (LBRACKET); break;
            case '}': setop (RBRACKET); break;
            case '(': setop (LPAREN); break;
            case ')': setop (RPAREN); break;
            case '?': setop (HMMM); break;
            case '.': setop (POINT); break;
            case ',': setop (COMMA); break;
            case ':': setop (COLON); break;
            case ';': setop (SEMICOLON); break;
            case '#': setop (HASH); break;
            case '@': setop (DOGGY); break;

            case '*': setop (MUL); break;
            case '/': setop (DIV); break;
            case '%': setop (MOD); break;

            case '+':
                if ( pt->type == TOKEN_OP || pt->type == TOKEN_NULL ) setop (PLUS_UNARY);
                else setop (PLUS_BINARY);
                break;
            case '-':
                if ( pt->type == TOKEN_OP || pt->type == TOKEN_NULL ) setop (MINUS_UNARY);
                else setop (MINUS_BINARY);
                break;
        }
    }

    // многознаковые операции, потенциально  могут получаться из однознаковых типа '<' , '<='
    if ( current_token.type == TOKEN_NULL )
    {
        if ( ch == '>' ) {           // > >= >> >>>
            ch = nextch (&empty);
            if (!empty )
            {
                if ( ch == '=') setop (GREATER_EQ);
                else if (ch == '>') {
                    ch = nextch (&empty);
                    if (!empty) {
                        if (ch == '>') setop (ROTR);
                        else setopback (SHR);
                    }
                    else setop (SHR);
                }
                else setopback (GREATER);
            }
            else setop (GREATER);
        }
        else if ( ch == '<' ) {      // < <= << <<< <=(постприсваивание определяется expression parser, lexer всегда возвращает только меньше или равно)
            // постприсваивание всегда - самый первый оператор выражения.
            ch = nextch (&empty);
            if (!empty )
            {
                if ( ch == '=') setop (LESS_EQ);
                else if (ch == '<') {
                    ch = nextch (&empty);
                    if (!empty) {
                        if (ch == '<') setop (ROTL);
                        else setopback (SHL);
                    }
                    else setop (SHL);
                }
                else setopback (LESS);
            }
            else setop (LESS);
        }
        else if ( ch == '!' ) {      // ! != !==
            ch = nextch (&empty);
            if (!empty) {
                if (ch == '=') {
                    ch = nextch (&empty);
                    if (!empty) {
                        if (ch == '=') setop (CASE_NOTEQ);
                        else setopback (LOGICAL_NOTEQ);
                    }
                    else setop (LOGICAL_NOTEQ);
                }
                else setopback (NOT);
            }
            else setop (NOT);
        }
        else if ( ch == '=' ) {      // = == ===
            ch = nextch (&empty);
            if (!empty) {
                if (ch == '=') {
                    ch = nextch (&empty);
                    if (!empty) {
                        if (ch == '=') setop (CASE_EQ);
                        else setopback (LOGICAL_EQ);
                    }
                    else setop (LOGICAL_EQ);
                }
                else setopback (EQ);
            }
            else setop (EQ);
        }
        else if ( ch == '&' ) {      // & && &(редукция)  редукция будет когда предыдущий токен - операнд.
            ch = nextch (&empty);
            if (!empty) {
                if (ch == '&') setop (LOGICAL_AND);
                else {
                    if ( pt->type == TOKEN_OP || pt->type == TOKEN_NULL ) setopback (REDUCT_AND);
                    else setopback (AND);
                }
            }
            else {
                if ( pt->type == TOKEN_OP || pt->type == TOKEN_NULL ) setop (REDUCT_AND);
                else setop (AND);
            }
        }
        else if ( ch == '|' ) {      // | || |(редукция)
            ch = nextch (&empty);
            if (!empty) {
                if (ch == '|') setop (LOGICAL_OR);
                else {
                    if ( pt->type == TOKEN_OP || pt->type == TOKEN_NULL ) setopback (REDUCT_OR);
                    else setopback (OR);
                }
            }
            else {
                if ( pt->type == TOKEN_OP || pt->type == TOKEN_NULL ) setop (REDUCT_OR);
                else setop (OR);
            }
        }
        else if ( ch == '^' ) {      // ^ ^~ ^(редукция) ^~(редукция)
            ch = nextch (&empty);
            if (!empty) {
                if (ch == '~') {
                    if ( pt->type == TOKEN_OP || pt->type == TOKEN_NULL ) setop (REDUCT_XNOR);
                    else setop (XNOR);
                }
                else {
                    if ( pt->type == TOKEN_OP || pt->type == TOKEN_NULL ) setopback (REDUCT_XOR);
                    else setopback (XOR);
                }
            }
            else {
                if ( pt->type == TOKEN_OP || pt->type == TOKEN_NULL ) setop (REDUCT_XOR);
                else setop (XOR);
            }
        }
        else if ( ch == '~' ) {      // ~ ~^ ~^(редукция) ~|(редукция) ~&(редукция)
            ch = nextch (&empty);
            if (!empty) {
                if (ch == '^') {
                    if ( pt->type == TOKEN_OP || pt->type == TOKEN_NULL ) setop (REDUCT_XNOR);
                    else setop (XNOR);
                }
                else if (ch == '|') {
                    if ( pt->type == TOKEN_OP || pt->type == TOKEN_NULL ) setop (REDUCT_NOR);
                    else setopback (NEG);
                }
                else if (ch == '&') {
                    if ( pt->type == TOKEN_OP || pt->type == TOKEN_NULL ) setop (REDUCT_NAND);
                    else setopback (NEG);
                }
                else setopback (NEG);
            }
            else setop (NEG);            
        }
    }
    // все остальные токены мы просто игнорируем.

    tokenization_started = 1;
    return &current_token;
}

static token_t * prev_token (void)  // предыдущий токен (или NULL, если токена не было)
{
    if (!tokenization_started) return NULL;
    else return &previous_token;
}

static void feed_token (token_t * token)    // скормить токен подключенному парсеру
{
    if (token && parser_stack[parser_stack_pointer]) parser_stack[parser_stack_pointer] (token);
}

// ------------------------------------------------------------------------------------
// verilog syntax tree parser

// Парсим поток токенов в синтаксическое дерево. Узлами дерева могут быть либо выражения, либо операции.
// Выражения - это идентификаторы, числа или строки.
// Операции - это специальные команды, которые управляют "ростом" дерева.
// Ветки дерева могут расти рекурсивно, в виде поддеревьев (обычное дело).

/*

Как происходит синтаксический анализ :
    - во первых мы должны убедиться, что мы находимся в контексте модуля. Если мы вне модуля, то на любые поползновения мы выдаем предупреждение Outside module
    - Если мы попали в модуль (module) то теперь начинается магия:
        - открыть новый модуль мы не можем, пока не встретиться команда endmodule. Если кто-то попытается - то просто выдаем предупреждение и пропускаем вложенный  модуль до тех пор, пока не найдём endmodule. Далее будет считаться текст открытого изначально модуля.
        - Если после завершения разбора текста модуль остался открыт
        - формат предложений, который анализирует парсер следующий : verb [prefix] <expression1>, <expression2>, ..., <expressionN> ;

В качестве "глагола" могут выступать следующие выражения :
    netlist [prefix] <identifier> [postfix] : определяет входы-выходы-шины, wire и reg (в том числе и массивы)
Что значит "определить" регистр ? Это значит что в нет-лист просто пихается стандартная ячейка - регистр, пока ни с чем не соединенная.
Определить провод означает что в нет-лист добавляется провод, пока тоже ни с чем не соединенный.
Массивы - это просто регистровые файлы, такие можно увидеть на процессоре PlayStation по краям. Вообще говоря регистровый файл - это динамически генерируемая ячейка,
то есть своего рода "фабрика" для построения специальной ячейки. (см. шаблоны проектирования - Factory).

IO (input/output/inout) объявления связывают модуль с внешним миром. wire/reg - это его внутреннее состояние.
Наша реализация не поддерживает "scope" (область видимости), поэтому все вложенные блоки (always) видят внутреннее состояние модуля.
Однако внутреннее состояние между модулями понятно дело скрыто.

    parameter <expression1>, <expression2>, ..., <expressionN> : определяет константы. При этом внутри выражений могут использоваться тоже только константы (и числа)

    always @ ( {posedge|negedge} nodename1 {,|or} {posedge|negedge} nodename2 ... ) : открывает always блок и привязывает к нему реактивные входы (inputs, inouts).
Логично, что выход output текущего модуля на триггер блока always посадить нельзя, это будет тупо.
Блок always закрывается командой end.

    Между блоками always можно пихать netlist / parameter. Это всё что касается обработки модуля.

Always блок.
    
    Этот блок до безобразия простой. Всё что находится внутри блока - это :
        [expression1] ;
        [expression2] ;
        ...
        [expressionN] ;
    то есть непосредственно синтезиуемая логика.

Вложенные блоки.
    Внутри always блока может быть сколько угодно вложенные блоков :
        begin
        <expressions> ;
        end

Управляющие конструкции : if-else, case, for/while. А вто эти звери очень сильно влияют на синтезируемую логику. В частности for/while преобразуются в специальные if,
а реализацию самого if я ещё не продумал. Возможно это мультиплексор или типа того. case - реализует декодер ("монтажное-И/ИЛИ-НЕ").
Пока сделаем без них.

Expressions.

    Выражения определяют структуру ветки синтаксического дерева. Операции в выражениях могут управлять "ростом" дерева :
        ( : сделать новое ответвление (под-дерево)
        ) : вернуться в родительскую ветку
        ; : завершить рост дерева и вернуться в "ствол"
    Дерево растёт до тех пор, пока не будет найден токен ; или не закончится блок/модуль/программа (это ошибочный вариант).

Выражение могут быть синтезруемые и несинтезируемые. Синтезируемые выражения находятся в блоках always - они создают netlist. Пример несинтезируемых выражений -
это выражения в parameters, а также операция задания размера числа, типа: 8 'b 1. Все несинтезируемые выражения возвращают числа.

Ну по ходу дела разберемся )

*/

// приоритеты операций.
static int opprio[] = {
    1,      // nop
    12, 12,       // { }
    12, 12,       // [ ]
    11, 9,      // +
    11, 9,    // -
    11, 11,     // ! ~
    10, 10, 10,     // * / %
    8, 8, 8, 8,   // << >> <<< >>>
    7, 7, 7, 7,     // > >= < <=
    3, 2,      // && ||
    7, 7, 7, 7,     // == === != !==
    6, 4, 5, 5, // & | ^ ~^ ^~
    6, 6, 4, 4, 5, 5,  // & ~& | ~| ^ ^~ ~^
    1, 1,  // ? :
    12, 12,   // ( )
    9, 9,  // = <=
    1, 1,   // # @
    1, 1, 1,  // . , ;
};

typedef struct node_struct_t
{
    struct node_struct_t  *lvalue;
    struct node_struct_t  *rvalue;
    token_t token;
    int     depth;
} node_t;

static node_t  tree[10000];
static int     tree_nodes = 0;

static node_t * addnode (token_t * token, int depth)       // добавление новой ветки
{
    node_t * node;
    node = &tree[tree_nodes];
    node->lvalue = node->rvalue = NULL;
    node->depth = depth;
    memcpy ( &node->token, token, sizeof(token_t) );
    tree_nodes++;
    return node;
}

// наш отладочный парсер. ничего не делает - просто выводит поток токенов на экран, для диагностики.
static void dummy_parser (token_t * token)
{
    if ( token->type != TOKEN_NULL) {
        if (token->type == TOKEN_OP) printf ( "%s, op: %s\n", token_type(token->type), opstr(token->op) );
        else if (token->type == TOKEN_KEYWORD) printf ( "%s, keyword: %i, raw=\'%s\'\n", token_type(token->type), token->sym->type, token->rawstring );
        else if (token->type == TOKEN_NUMBER) dumpnum ( &token->num );
        else printf ( "%s, raw=\'%s\'\n", token_type(token->type), token->rawstring );
    }
}

// исполняем дерево (семанический анализ)
static node_t * evaluate (node_t * expr, symbol_t *lvalue)
{
    node_t * curr;
    symbol_t rvalue, *sym, mvalue;
    token_t * token;
    int uop = NOP, op = NOP;
    int debug = 1;

    if (debug) printf ( "[" );

    memset ( &rvalue, 0, sizeof(symbol_t) );

    // вложенные evaluations.  -- это чухня. надо переосмыслить a = b = ...  потому что lvalue может быть например reg[2] (reg [ 2 ])
/*
    if ( expr->token.type == TOKEN_IDENT && expr->rvalue->token.type == TOKEN_OP && expr->rvalue->token.op == EQ ) { 
        sym = check_symbol (expr->token.rawstring);
        if ( sym ) {
            evaluate (expr->rvalue->rvalue, sym);
            sym->type = SYMBOL_PARAM;
            memcpy ( &lvalue->num, &sym->num, sizeof(number_t) );
            printf ( "LVALUE(inner) : %i\n", sym->num.value );
        }
        else warning ( "Lvalue not defined : %s", expr->token.rawstring );
        return;
    }
*/

    // lvalue = { [uop] <ident|expr> [op] }
    curr = expr;
    while (curr) {

        if (curr->depth < expr->depth) break;

        // необязательная унарная операция или приравнивание.
        token = &curr->token;
        if ( token->type == TOKEN_OP && (isunary(token->op) || token->op == EQ || token->op == POST_EQ) ) {
            if ( curr->rvalue == NULL ) error ( "Missing identifier" );
            else {
                curr = curr->rvalue;
                uop = token->op;
            }
        }
        else uop = NOP;

        if (uop != NOP && debug) printf ( "%s ", opstr(uop) );

        // обязательный идентификатор или вложенное выражение.
        token = &curr->token;
        if ( token->type == TOKEN_IDENT || token->type == TOKEN_NUMBER || curr->depth > expr->depth ) {

            memset ( &mvalue, 0, sizeof(symbol_t) );

            if ( curr->depth > expr->depth ) {  // вложенное выражение
                if (debug) printf ( "SUBEVAL " );
                curr = evaluate (curr, &mvalue);
                //printf ( "SUB LVALUE : %i\n", mvalue.num.value );
            }
            else if ( token->type == TOKEN_IDENT ) { 
                curr = curr->rvalue;
                sym = check_symbol (token->rawstring);
                if (sym && sym->type == SYMBOL_PARAM) memcpy ( &mvalue.num, &sym->num, sizeof(number_t) );
                else warning ( "Undefined symbol : %s", token->rawstring );
                if (debug) printf ( "SYMBOL " );
            }
            else if ( token->type == TOKEN_NUMBER ) {
                curr = curr->rvalue;
                memcpy ( &mvalue.num, &token->num, sizeof(number_t) );
                if (debug) printf ( "NUMBER " );
            }

            // выполняем унарную операцию над MVALUE
            if (uop != NOP) {
                switch (uop)
                {
                    case MINUS_UNARY:
                        mvalue.num.value = -mvalue.num.value;
                        break;
                    case PLUS_UNARY:
                        break;
                    case NOT:
                        mvalue.num.value = !mvalue.num.value;
                        break;
                    case NEG:
                        mvalue.num.value = ~mvalue.num.value;
                        break;
                }
            }

            // выполняем бинарную операцию RVALUE = RVALUE op MVALUE
            if (op != NOP) {
                switch (op)
                {
                    case MINUS_BINARY:
                        rvalue.num.value -= mvalue.num.value;
                        break;
                    case PLUS_BINARY:
                        rvalue.num.value += mvalue.num.value;
                        break;
                    case MUL:
                        rvalue.num.value *= mvalue.num.value;
                        break;
                    case DIV:
                        if (mvalue.num.value) rvalue.num.value /= mvalue.num.value;
                        break;
                    case MOD:
                        if (mvalue.num.value) rvalue.num.value %= mvalue.num.value;
                        break;
                }
            }
            else memcpy ( &rvalue.num, &mvalue.num, sizeof(number_t) );
        }
        else error ( "Identifier required" );

        // необязательная бинарная операция.
        if (curr && curr->depth == expr->depth ) {
            token = &curr->token;
            if ( token->type == TOKEN_OP && isbinary(token->op) ) {
                curr = curr->rvalue;
                op = token->op;
            }
            else op = NOP;

            if (op != NOP && debug) printf ( "%s ", opstr(op) );
        }
    }

    if (debug) printf ( "]" );

    memcpy ( &lvalue->num, &rvalue.num, sizeof(number_t) );
    return curr;
}

// парсер несинтезируемых выражений. точка с запятой или запятая означает конец выражения. 
static void nonsynth_expr_parser (token_t * token)
{
    static node_t * expr = NULL, * curr, * node;
    static int depth = 0, prio = 0;
    token_t * tok;
    symbol_t * lvalue;

    if ( token->type == TOKEN_NULL ) return;

    if (token->type == TOKEN_OP && (token->op == COMMA || token->op == SEMICOLON) ) {   // исполняем дерево (семанический анализ)

        // задампим дерево.
#if 1
        curr = expr;
        while (curr) {
            tok = &curr->token;
            printf ( "(%i)", curr->depth );
            if (tok->type == TOKEN_OP) printf ("%s ", opstr(tok->op));
            else if (tok->type == TOKEN_NUMBER) printf ("%i ", tok->num.value );
            else printf ("%s ", tok->rawstring );
            curr = curr->rvalue;
        }
        printf ("\n");
#endif

        if ( expr->token.type != TOKEN_IDENT ) warning ( "Wrong lvalue!" );
        if ( expr->rvalue->token.type != TOKEN_OP && expr->rvalue->token.op != EQ ) warning ( "No assignment!" );
        lvalue = check_symbol (expr->token.rawstring);
        if ( lvalue ) {
            evaluate (expr->rvalue, lvalue);
            lvalue->type = SYMBOL_PARAM;
            printf ( "LVALUE : %i\n", lvalue->num.value );
        }
        else warning ( "Lvalue not defined : %s", expr->token.rawstring );

        expr = NULL;
        depth = prio = 0;
        pop_parser ();   // возвращаемся в парсер parameter
        if ( token->op == SEMICOLON ) pop_parser ();   // возвращаемся в парсер module
    }
    else {  // растим дерево (синтаксический анализ)

        //dummy_parser (token);

        node = addnode ( token, depth );

        if (expr == NULL)
        {
            expr = curr = node;
        }
        else {

            if ( token->type == TOKEN_OP ) {
                if ( token->op == LPAREN) { depth++; return; }
                else if ( token->op == RPAREN ) {
                    if (depth > 0) depth--;
                    else warning ( "Unmatched parenthesis" );
                    return;
                }
                else if ( opprio[token->op] > prio ) {
                    prio = opprio[token->op];
                    depth++;
                }
            }
            // незакрытые скобки и понижение приоритета операций мы просто игнорируем.

            curr->rvalue = node;
            node->lvalue = curr;
            curr = node;
        }

    }
}

// парсер выражений ключевого слова parameter.
static void parameter_parser (token_t * token)
{
    nonsynth_expr_parser (token);
    push_parser (nonsynth_expr_parser);
}

// парсер модуля.
static void module_parser (token_t * token)
{
    if ( token->type == TOKEN_KEYWORD && token->sym->type == SYMBOL_KEYWORD_PARAMETER ) {   // parameter <expr1>, <expr2>, ..., <exprN> ;
        push_parser ( parameter_parser );
    }
    //else dummy_parser (token);
}

int breaksvm_load (char *filename)
{
    token_t * token;
    int filesize;
    u8 * content;
    FILE * f = fopen (filename, "rb");  // откроем файл
    if (!f) {
        error ( "Cannot open input file : %s", filename);
        return 0;
    }
    fseek (f, 0, SEEK_END);      // получим размер
    filesize = ftell (f);
    fseek (f, 0, SEEK_SET);

    content = (u8 *)malloc (filesize + 1);      // загрузим   
    if (!content) {
        error ( "Cannot load input file : %s", filename);
        fclose (f);
        return 0;
    }
    fread ( content, 1, filesize, f );
    content[filesize] = 0;  // extra 0 for debug output
    fclose (f);

    strncpy ( VM_FILE, filename, 255 );
    VM_LINE = 1;

    tokenize_file ( content, filesize);
    push_parser ( module_parser );

    do {    // запустить лексический анализ.
        token = next_token ();
        if (token) feed_token ( token );
    } while (token);
    
    dump_symbols ();
    return 1;
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

    tokenization_started = 0;

    breaksvm_initdone = 1;
}

void breaksvm_shutdown (void)
{
    if (breaksvm_initdone) {
        sym_num = 0;
        tree_nodes = 0;
        breaksvm_initdone = 0;
    }
}
