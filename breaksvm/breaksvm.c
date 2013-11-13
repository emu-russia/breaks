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

static u32 MurmurHash (char * key)
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

static int add_symbol (char *name, int type, int value)     // добавить символ, вернуть ID
{
    symbol_t *symbol;
    if ( strlen (name) > 255 ) {
        warning ( "Martin, your symbol \'%s\' name length exceeds 255 bytes and will be truncated!", name ); // выдаем предупреждение Мартину Корту
    }
    symtab = (symbol_t *)realloc (symtab, sizeof(symbol_t) * (sym_num + 1) );
    if ( !symtab ) {
        error ( "Cannot allocate symbol \'%s\', not enough memory", name );
        return 0;
    }
    symbol = &symtab[sym_num];
    strncpy ( symbol->rawstring, name, 255 );
    symbol->type = type;
    symbol->hash = MurmurHash (symbol->rawstring);     // calculate hash for truncated name!
    symbol->value = value;
    sym_num++;
    return (sym_num - 1);
}

static void dump_symbols (void)
{
    int i;
    for (i=0; i<sym_num; i++) {
        if ( symtab[i].type < 200 ) continue;   // don't dump keywords.
        printf ( "SYMBOL : %s, hash : %08X, type : %i\n", symtab[i].rawstring, symtab[i].hash, symtab[i].type );
    }
}

/*

Часть стандарта Verilog будет тут.

числа: общий формат записи такой : <size>[spaces]<'[bBoOdDhH]base>[spaces]<[0-9a-fA-F_]>
Размер числа не может быть = 0 или больше 64 бит.

строки: последовательность символов между "..." при этом "sdfsdf//тест" - будет являться строкой (комментарии внутри строки - это часть строки)
токен активируется при обнаружении ". Далее выбираются символы до следующего ", либо до конца строки '\n'. Если строка не закрылась, то вякаем предупреждением и закрываем строку.

имена: обычные правила для имён, но можно ещё использовать знак доллара $

*/

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

//typedef struct wire_t
//{
//} wire_t;

int breaksvm_load (char *filename)
{
    dump_symbols ();
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
