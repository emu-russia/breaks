# Регистр инструкций

Регистр инструкций (IR) хранит текущий код операции, для обработки на [[6502:decoder|декодере]]. Код операции загружается в IR с [[6502:predecode|логики предекодирования]].

## Транзисторная схема

Выходы на схеме слева, потому что с левой стороны топологически расположен декодер.

{{6502:ir_nice.jpg}}

  * IR0 и IR1 для экономии линий объединяются в одну общую линию IR01.
  * IR0 используется только для 128й линейки декодера (IMPL)
  * /IR5 дополнительно идёт на флаги и используется в инструкциях установки/сброса флагов (SEI/CLI, SED/CLD, SEC/CLC).

## Flow

{{6502:ir_flow.jpg}}

  * Во время PHI1 значение IR перегружается с защелки [[6502:predecode|Predecode (PD)]], но только если активна команда FETCH.
  * Во время PHI2 IR "рефрешится".

## Логическая схема

{{6502:ir_logic.jpg}}

Необходимо отметить, что на вход IR подается инвертированное значение кода операции (PD) и хранится оно на защелке также в инвертированном виде.

Сразу после включения питания значение кода операции 0xFF, так как на защелке будет 0x00.

## Симуляция

Симуляция относительно простая и самоописательная. Программный контекст :
  * Массив из 8 защелок, которые хранят текущее значение IR в инвертированной форме
  * Контрольный сигнал FETCH
  * Выходные значения с PD ([[6502:predecode|логика предекодирования]])

```c
static  int FETCH, IR01;
static  int PD[8], _IR[8];

if (PHI1)
{
        // load instruction register
        if ( FETCH )
        {
            for (n=0; n<8; n++) _IR[n] = NOT (PD[n]);
        }
        IR01 = NOT(_IR[0]) | NOT(_IR[1]);
}
```

## Verilog

```verilog
// ------------------
// Instruction Register (IR)

// Controls:
// FETCH: Load IR from PD (Predecode Latch)

module InstructionRegister (
    // Outputs
    IR,
    // Inputs
    PHI0, FETCH, _PD
);

    input PHI0, FETCH;
    input [7:0] _PD;        // Active-low!

    output [7:0] IR;

    // Clocks
    wire PHI1, PHI2;
    assign PHI1 = ~PHI0;
    assign PHI2 = PHI0;

    reg [7:0] IR = 8'b11111111;     // Power-up state (IR = 0xFF)

initial begin
    IR = 8'b11111111;       // For safety.
end

always @(PHI1) begin
    if (FETCH) IR = ~_PD;
end

endmodule   // InstructionRegister
```
