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

typedef struct symbol_t
{
    char    rawstring[256];
    u32     hash;
    int     type;
    int     value;      // for parameters
} symbol_t;

static  symbol_t *symtab;
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

static symbol_t * add_symbol (char *name, int type, int value)     // добавить символ, вернуть описатель или NULL
{
    symbol_t *symbol;
    if ( strlen (name) > 255 ) {
        warning ( "Martin, your symbol \'%s\' name length exceeds 255 bytes and will be truncated!", name ); // выдаем предупреждение Мартину Корту
    }
    symtab = (symbol_t *)realloc (symtab, sizeof(symbol_t) * (sym_num + 1) );
    if ( !symtab ) {
        error ( "Cannot allocate symbol \'%s\', not enough memory", name );
        return NULL;
    }
    symbol = &symtab[sym_num];
    strncpy ( symbol->rawstring, name, 255 );
    symbol->type = type;
    symbol->hash = MurmurHash (symbol->rawstring);     // calculate hash for truncated name!
    symbol->value = value;
    sym_num++;
    return &symtab[sym_num - 1];
}

static void dump_symbols (void)
{
    int i;
    for (i=0; i<sym_num; i++) {
        if ( symtab[i].type < SYMBOL_NOT_KEYWORDS ) continue;   // don't dump keywords.
        if ( symtab[i].type == SYMBOL_PARAM ) printf ( "PARAM : %s, hash : %08X, value : %i\n", symtab[i].rawstring, symtab[i].hash, symtab[i].value );
        else if ( symtab[i].type == SYMBOL_INPUT ) printf ( "INPUT : %s, hash : %08X\n", symtab[i].rawstring, symtab[i].hash );
        else if ( symtab[i].type == SYMBOL_OUTPUT ) printf ( "OUTPUT : %s, hash : %08X\n", symtab[i].rawstring, symtab[i].hash );
        else if ( symtab[i].type == SYMBOL_INOUT ) printf ( "INOUT : %s, hash : %08X\n", symtab[i].rawstring, symtab[i].hash );
        else if ( symtab[i].type == SYMBOL_WIRE ) printf ( "WIRE : %s, hash : %08X\n", symtab[i].rawstring, symtab[i].hash );
        else if ( symtab[i].type == SYMBOL_REG ) printf ( "REG : %s, hash : %08X\n", symtab[i].rawstring, symtab[i].hash );
        else printf ( "SYMBOL : %s, hash : %08X, type : %i\n", symtab[i].rawstring, symtab[i].hash, symtab[i].type );
    }
}

/*

Часть стандарта Verilog будет тут. (в основном в этом блоке - описание формата лексем)

числа: общий формат записи такой : <size>[spaces]<'[bBoOdDhH]base>[spaces]<[0-9a-fA-F_]>
Размер числа не может быть = 0 или больше 64 бит.

строки: последовательность символов между "..." при этом "sdfsdf//тест" - будет являться строкой (комментарии внутри строки - это часть строки)
токен активируется при обнаружении ". Далее выбираются символы до следующего ", либо до конца строки '\n'. Если строка не закрылась, то вякаем предупреждением и закрываем строку.

имена: обычные правила для имён, но можно ещё использовать знак доллара $. 
Также если имя начинается с символа \ , то дальше могут идти вообще любой байт-код, до символа <= пробела.

операции : { } + - * /  %  > >= < <=  ! && || == != === !=== ~ & | ^ ^~ ~^ ~& ~| << >> <<< >>> ? : ( ) # = <=
приоритет операций :
    { } (конкатенация)
    + - ! ~ (унарные)
    * / %
    + - (бинарные)
    << >> <<< >>>
    == != === !===
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
    int     op;         // operation
} token_t;

enum OPS
{
    LBRACKET, RBRACKET,       // { }
    LSQUARE, RSQUARE,       // [ ]
    PLUS_UNARY, PLUS_BINARY,      // +
    MINUS_UNARY, MINUS_BINARY,    // -
    NOT, NEG,     // ! ~
    MUL, DIV, MOD,     // * / %
    SHL, SHR, ROTL, ROTR,   // << >> <<< >>>
    GREATER, GREATER_EQ, LESS, LESS_EQ,     // > >= < <=
    LOGICAL_AND, LOGICAL_OR,      // && ||
    LOGICAL_EQ, CASE_EQ, LOGICAL_NOTEQ, CASE_NOTEQ,     // == != === !===
    AND, OR, XOR, XNOR, // & | ^ ~^ ^~
    REDUCT_AND, REDUCT_NAND, REDUCT_OR, REDUCT_NOR, REDUCT_XOR, REDUCT_XNOR,  // & ~& | ~| ^ ^~ ~^
    HMMM, COLON,  // ? :
    LPAREN, RPAREN,   // ( )
    EQ, POST_EQ,  // = <=
    HASH, DOGGY,   // # @
    POINT, COMMA, SEMICOLON,  // . , ;
    BIN, OCT, DEC, HEX, // 'b 'B 'o 'O 'd 'D 'h 'H
};

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

static token_t * next_token (void)  // получить следующий токен или вернуть NULL, если конец файла
{
    int empty, international, ident_max_size, number_max_size;
    token_t * pt = &previous_token;
    u8 ch, ch2, ch3, ch4;
    u8 ident[1024], *ptr;
    symbol_t * sym;

    // ну просто дубовый алгоритм, выбираем символы и смотрим что получается )))

    current_token.type = TOKEN_NULL;

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
        ch2 = nextch (&empty);
        if (empty || ch2 != '/') {    // если дальше ничего нет или второй символ не / - вернуть просто как деление
            if (!empty) putback ();   // вернуть если не пусто
            current_token.type = TOKEN_OP;
            current_token.op = DIV;
            strcpy ( current_token.rawstring, "/" );
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
            sym = add_symbol (ident, SYMBOL_IDENT, 0);
            current_token.type = TOKEN_IDENT;
            strncpy ( current_token.rawstring, ident, 255 );
            current_token.sym = sym;
        }
    }

    // числа
    // если предыдущий токен не приставка системы счисления, то мы сканируем 0-9 и _ (но черточка не должна быть первой, иначе это будет идентификатор)
    // если приставка была, то :
    // для двоичных чисел : 0 1 _ x X z Z
    // для восьмеричных : 0 1 2 3 4 5 6 7 _ x X z Z
    // для десятичных : 0 1 2 3 4 5 6 7 8 9 _ x X z Z
    // для шестнаыфаысыых : 0 1 2 3 4 5 6 7 8 9 a A b B c C d D e E f F _ x X z Z
    if (current_token.type == TOKEN_NULL) 
    {
        if ( pt->type == TOKEN_OP && (pt->op == BIN || pt->op == OCT || pt->op == DEC || pt->op == HEX) ) {
        }
        else if (isdigit(ch)) {  // обычное число.
            number_max_size = 255;
            ptr = current_token.rawstring;
            *ptr++ = ch;
            while (!empty && number_max_size) {
                ch = nextch (&empty);
                if ( !isdigit(ch) && (ch != '_') ) {
                    *ptr++ = 0;
                    if (!empty) putback ();
                    break;
                }
                if ( !empty ) {
                    *ptr++ = ch;
                    number_max_size--;
                }
            }
            current_token.type = TOKEN_NUMBER;
        }
    }

    // однознаковые операции
    if ( current_token.type == TOKEN_NULL )
    {
        switch (ch)
        {
            case '[':
                current_token.type = TOKEN_OP;
                current_token.op = LSQUARE;
                strcpy ( current_token.rawstring, "[" );
                break;
            case ']':
                current_token.type = TOKEN_OP;
                current_token.op = RSQUARE;
                strcpy ( current_token.rawstring, "]" );
                break;
            case '{':
                current_token.type = TOKEN_OP;
                current_token.op = LBRACKET;
                strcpy ( current_token.rawstring, "{" );
                break;
            case '}':
                current_token.type = TOKEN_OP;
                current_token.op = RBRACKET;
                strcpy ( current_token.rawstring, "}" );
                break;
            case '(':
                current_token.type = TOKEN_OP;
                current_token.op = LPAREN;
                strcpy ( current_token.rawstring, "(" );
                break;
            case ')':
                current_token.type = TOKEN_OP;
                current_token.op = RPAREN;
                strcpy ( current_token.rawstring, ")" );
                break;
            case '?': 
                current_token.type = TOKEN_OP;
                current_token.op = HMMM;
                strcpy ( current_token.rawstring, "?" );
                break;
            case '.':
                current_token.type = TOKEN_OP;
                current_token.op = POINT;
                strcpy ( current_token.rawstring, "." );
                break;
            case ',':
                current_token.type = TOKEN_OP;
                current_token.op = COMMA;
                strcpy ( current_token.rawstring, "," );
                break;
            case ':':
                current_token.type = TOKEN_OP;
                current_token.op = COLON;
                strcpy ( current_token.rawstring, ":" );
                break;
            case ';':
                current_token.type = TOKEN_OP;
                current_token.op = SEMICOLON;
                strcpy ( current_token.rawstring, ";" );
                break;
            case '#':
                current_token.type = TOKEN_OP;
                current_token.op = HASH;
                strcpy ( current_token.rawstring, "#" );
                break;

            case '*':
                current_token.type = TOKEN_OP;
                current_token.op = MUL;
                strcpy ( current_token.rawstring, "*" );
                break;
            case '/':
                current_token.type = TOKEN_OP;
                current_token.op = DIV;
                strcpy ( current_token.rawstring, "/" );
                break;
            case '%':
                current_token.type = TOKEN_OP;
                current_token.op = MOD;
                strcpy ( current_token.rawstring, "%" );
                break;

            case '+':
                current_token.type = TOKEN_OP;
                if ( pt->type == TOKEN_OP || pt->type == TOKEN_NULL ) current_token.op = PLUS_UNARY;
                else current_token.op = PLUS_BINARY;
                strcpy ( current_token.rawstring, "+" );
                break;
            case '-':
                current_token.type = TOKEN_OP;
                if ( pt->type == TOKEN_OP || pt->type == TOKEN_NULL ) current_token.op = MINUS_UNARY;
                else current_token.op = MINUS_BINARY;
                strcpy ( current_token.rawstring, "-" );
                break;
        }
    }

    // многознаковые операции, потенциально  могут получаться из однознаковых типа '<' , '<='
    if ( current_token.type == TOKEN_NULL )
    {
        if ( ch == '>' ) {           // > >= >> >>>
        }
        else if ( ch == '<' ) {      // < <= << <<< <=(постприсваивание)
        }
        else if ( ch == '!' ) {      // ! != !===
        }
        else if ( ch == '=' ) {      // = == ===
        }
        else if ( ch == '&' ) {      // & && &(редукция)
        }
        else if ( ch == '|' ) {      // | || |(редукция)
        }
        else if ( ch == '^' ) {      // ^ ^~ ^(редукция) ^~(редукция)
        }
        else if ( ch == '~' ) {      // ~ ~^ ~| ~& ~^(редукция) ~|(редукция) ~^(редукция)
        }
        else if ( ch == '\'' ) {     // 'b 'B 'o 'O 'd 'D 'h 'H
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

// Парсим поток токенов в синтаксическое бинарное дерево. Узлами дерева могут быть либо выражения, либо операции.
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

Ну по ходу дела разберемся )

*/

// парсер выражений. точка с запятой означает конец выражения.
static void expr_parser (token_t * token)
{
}

// парсер параметров.
static void parameter_parser (token_t * token)
{
    push_parser (expr_parser);
    pop_parser ();  // возвращаемся в модуль
}

// парсер модуля.
static void module_parser (token_t * token)
{
    if ( token->type == TOKEN_KEYWORD && token->sym->type == SYMBOL_KEYWORD_PARAMETER ) {   // parameter <expr1>, <expr2>, ..., <exprN> ;
        push_parser ( parameter_parser );
    }
}

// наш отладочный парсер. ничего не делает - просто выводит поток токенов на экран, для диагностики.
static void dummy_parser (token_t * token)
{
    if ( token->type != TOKEN_NULL) {
        if (token->type == TOKEN_OP) printf ( "type: %s, op: %i, raw=\'%s\'\n", token_type(token->type), token->op, token->rawstring );
        else if (token->type == TOKEN_KEYWORD) printf ( "type: %s, keyword: %i, raw=\'%s\'\n", token_type(token->type), token->sym->type, token->rawstring );
        else printf ( "type: %s, raw=\'%s\'\n", token_type(token->type), token->rawstring );
    }
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
    push_parser ( dummy_parser );

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
        add_symbol ( "", SYMBOL_UNKNOWN, 0 );
        int i = 0;
        while ( keywords[i] ) {
            add_symbol ( keywords[i], keyword_ids[i], 0 );
            i++;
        }
    }

    tokenization_started = 0;

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
