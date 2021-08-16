# Предварительное декодирование

Схема предназначена для определения "класса" инструкции: 
  * Короткая инструкция, которая выполняется за 2 такта (**TWOCYCLE**)
  * Инструкция типа **IMPLIED**, у которых нет операндов (занимают 1 байт в памяти)

{{:6502:predecode_nice.jpg}}

Код операции, полученный с внешней шины данных (D0...D7) сохраняется на защелке PREDECODE (PD) во время PHI2, после чего логика предекодирования "на лету" определяет класс инструкции.

По команде FETCH значение с регистра PD загружается на регистр IR. [[6502:ir|Подробнее тут]].

Выход TWOCYCLE используется коротким счетчиком тактов. Выход IMPLIED используется логикой инкремента PC.

Также на вход Predecode-логики подается управляющая линия 0/IR, которая "инжектирует" в поток инструкций операцию BRK. Это происходит во время обработки прерываний, для инициализации BRK-последовательности (все прерывания просто имитируют инструкцию BRK, с небольшими изменениями).

## Логическая схема

{{:6502:predecode_logic.jpg?600}}

Особо тут добавить нечего.

В нижней части находится защелка PD, на базе 8 D-latch.

Логика предекодирования самоописательная:
  * 2-х тактовые инструкции это: Инструкции с непосредственным операндом ИЛИ все однобайтовые инструкции КРОМЕ инструкций push/pull
  * Однобайтовые инструкции задаются маской XXXX10X0 (где X = 0 или 1).

## Симуляция

Контекст - входные значения с шины данных **DATA**, контрольный сигнал **0/IR**, защелка **PDLatch**, выходные значения **PD**, выходные контрольные линии определяющие класс инструкции - **/IMPLIED** и **/TWOCYCLE**.

```c
    for (int n=0; n<8; n++) {
        if (PHI2) PDLatch[n] = DATA[n];
        PD[n] = PDLatch[n] & NOT(ZERO_IR);
    }
    _IMPLIED = PD[0] | PD[2] | NOT(PD[3]);
    _TWOCYCLE = NOT (  NOT( NOT(PD[0]) | PD[2] | NOT(PD[3]) | PD[4] ) |
                       NOT( PD[0] | PD[2] | PD[3] | PD[4] | NOT(PD[7]) ) |
                       (PD[1] | PD[4] | PD[7]) & NOT(_IMPLIED)    );
```

## Verilog

```verilog
// ------------------
// Predecode

// Controls:
// 0/IR : "Inject" BRK opcode after interrupt (force IR = 0x00), to initiate common "BRK-sequence" service
// #IMPLIED : NOT Implied instruction (has operands)
// #TWOCYCLE : NOT short two-cycle instruction (more than 2 cycles)

module Predecode (
    // Outputs
    PD, _IMPLIED, _TWOCYCLE,
    // Inputs
    PHI0, Z_IR,
    // Buses
    DATA
);

    input PHI0, Z_IR;

    output [7:0] PD;
    output _IMPLIED, _TWOCYCLE;

    inout [7:0] DATA;

    wire [7:0] DATA;

    reg [7:0] PD = 8'b00000000;     // Power-up state

    // Clocks
    wire PHI1, PHI2;
    assign PHI1 = ~PHI0;
    assign PHI2 = PHI0;

    wire temp1, temp2;
    wire [7:0] pdout;
    assign pdout = Z_IR ? 8'b00000000 : PD;

    assign _IMPLIED = (pdout[0] | pdout[2] | ~pdout[3]);

    assign temp1 = ~(~pdout[0] | pdout[2] | ~pdout[3] | pdout[4]);
    assign temp2 = ~(pdout[0] | pdout[2] | pdout[3] | pdout[4] | ~pdout[7]); 
    assign _TWOCYCLE = (~(temp1 | temp2) & ~(~_IMPLIED & (pdout[1] | pdout[4] | pdout[7])));

initial begin
    PD = 8'b00000000;       // For safety
end

always @(PHI2) begin        // D-latch array on real 6502
    PD <= DATA;
end

endmodule   // Predecode
```
