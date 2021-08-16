# Расширенный счетчик циклов

У 6502 есть 3 счетчика циклов. Один (базовый) используется для коротких инструкций (2 такта), второй - расширенный, о котором тут пойдёт речь - используется для длинных инструкций (до 6 тактов) и третий - используется для очень длинных инструкций, которые работают 6-7 тактов.

## Транзисторная схема

![extended_cycle_counter_trans](/BreakingNESWiki/imgstore/extended_cycle_counter_trans.jpg) ![extended_cycle_counter_flow](/BreakingNESWiki/imgstore/extended_cycle_counter_flow.jpg)

<img src="/BreakingNESWiki/imgstore/extended_cycle_counter_nice.jpg" width="400px">

Вся схема представляет собой сдвиговый регистр, на вход которого подается `T1` ((T0, T1, T2 и так далее - это названия циклов. Минимальное количество циклов инструкций процессора 6502 равно 2 (T0-T1), а максимальное - 7 (T0-T6) )). Потом этот T1 сдвигается и выходит на выход T2 и так далее. Причем выходы T2-T5 идут на декодер в инверсной логике.

Сброс регистра осуществляется командой `TRES2`, происходит это после завершения обработки инструкции.

В состав схемы входят мультиплексоры по сигналу `ready`. Сделано это для того, чтобы когда процессор не готов (ready=0) - регистр сдвига "залочивался" на текущем состоянии.

## Логическая схема

<img src="/BreakingNESWiki/imgstore/extended_cycle_counter_logic.jpg" width="700px">

## Симуляция

Для работы схемы необходимо наличие трёх контрольных линий: `T1`, `TRES2` и `ready`, которые генерирует рандомная логика.
Схема имеет одну входную защелку и 8 спаренных защелок, для формирования регистра сдвига.
На выходе мы получаем 4 контрольные линии /T2-T5, которые идут на декодер.

Ниже приведена небольшая программа, которая имитирует все режимы счетчика циклов:
- Вначале проверяется нормальная работа - сдвиг T1
- Затем производится сброс регистра сдвига и повторная работа
- Но на такте T3 проверяется способность регистра сдвига "залочиться", если вдруг процессор стал не готов (ready=0)

```c
// 6502 extended cycle counter test.

static int T1, TRES2, ready;    // controls
static int PHI0, PHI1, PHI2;

static int _T2, _T3, _T4, _T5;

// Basic logic
#define BIT(n)     ( (n) & 1 )
int NOT(int a) { return (~a & 1); }
int NAND(int a, int b) { return ~((a & 1) & (b & 1)) & 1; }
int NOR(int a, int b) { return ~((a & 1) | (b & 1)) & 1; }

void EXT_CYCLE_COUNTER ()
{
    static int input_latch;        // input latch
    static int SRin[4], SRout[4];      // shift register
    int shift_in, n, mux, tout[4];

    if (PHI2) input_latch = T1;    // shift register input
    shift_in = input_latch;

    for (n=0; n<4; n++) {       // shift register
        mux = ready ? NOT(shift_in) : NOT(SRout[n]);
        if (PHI1) SRin[n] = mux;
        tout[n] = SRin[n] | TRES2;
        if (PHI2) SRout[n] = NOT (tout[n]);
        shift_in = SRout[n];        
    }

    _T2 = tout[0];    // output current SR values
    _T3 = tout[1];
    _T4 = tout[2];
    _T5 = tout[3];
}

main ()
{
    int n = 20;

    TRES2 = 0;
    ready = 1;
    T1 = 1;

    PHI0 = 0;
    while (n--)
    {
        if ( n == 19 || n == 18 || n == 9 || n == 8 ) T1 = 1;   // proper cycle count
        else T1 = 0;

        if ( n == 9 || n == 8 ) TRES2 = 1;      // test shift register reset
        else TRES2 = 0;

        if ( n < 4 ) ready = 0;    // test 6502 not-ready
        else ready = 1;

        PHI1 = NOT (PHI0);
        PHI2 = BIT (PHI0);

        EXT_CYCLE_COUNTER ();
        printf ( "T1=%i TRES2=%i ready=%i PHI0=%i PHI1=%i PHI2=%i | %i %i %i %i\n", T1, TRES2, ready, PHI0, PHI1, PHI2, _T2, _T3, _T4, _T5 );

        PHI0 ^= 1;
    }

}
```

В результате этой симуляции мы получаем на выходе:
```
T1=1 TRES2=0 ready=1 PHI0=0 PHI1=1 PHI2=0 | 1 1 1 1  T1
T1=1 TRES2=0 ready=1 PHI0=1 PHI1=0 PHI2=1 | 1 1 1 1
T1=0 TRES2=0 ready=1 PHI0=0 PHI1=1 PHI2=0 | 0 1 1 1  T2
T1=0 TRES2=0 ready=1 PHI0=1 PHI1=0 PHI2=1 | 0 1 1 1
T1=0 TRES2=0 ready=1 PHI0=0 PHI1=1 PHI2=0 | 1 0 1 1  T3
T1=0 TRES2=0 ready=1 PHI0=1 PHI1=0 PHI2=1 | 1 0 1 1
T1=0 TRES2=0 ready=1 PHI0=0 PHI1=1 PHI2=0 | 1 1 0 1  T4
T1=0 TRES2=0 ready=1 PHI0=1 PHI1=0 PHI2=1 | 1 1 0 1
T1=0 TRES2=0 ready=1 PHI0=0 PHI1=1 PHI2=0 | 1 1 1 0  T5
T1=0 TRES2=0 ready=1 PHI0=1 PHI1=0 PHI2=1 | 1 1 1 0
T1=1 TRES2=1 ready=1 PHI0=0 PHI1=1 PHI2=0 | 1 1 1 1  reset shift register (TRES=1), T1
T1=1 TRES2=1 ready=1 PHI0=1 PHI1=0 PHI2=1 | 1 1 1 1
T1=0 TRES2=0 ready=1 PHI0=0 PHI1=1 PHI2=0 | 0 1 1 1  T2 again
T1=0 TRES2=0 ready=1 PHI0=1 PHI1=0 PHI2=1 | 0 1 1 1
T1=0 TRES2=0 ready=1 PHI0=0 PHI1=1 PHI2=0 | 1 0 1 1  T3 again
T1=0 TRES2=0 ready=1 PHI0=1 PHI1=0 PHI2=1 | 1 0 1 1
T1=0 TRES2=0 ready=0 PHI0=0 PHI1=1 PHI2=0 | 1 0 1 1  CPU not ready, shift register "locked" at T3 until not ready
T1=0 TRES2=0 ready=0 PHI0=1 PHI1=0 PHI2=1 | 1 0 1 1
T1=0 TRES2=0 ready=0 PHI0=0 PHI1=1 PHI2=0 | 1 0 1 1  T3..
T1=0 TRES2=0 ready=0 PHI0=1 PHI1=0 PHI2=1 | 1 0 1 1
```

В реальных боевых условиях симуляция на самом деле происходит в двух режимах: отдельно для PHI1 и отдельно для PHI2.
