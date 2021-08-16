# Логика условных переходов

Логика условных переходов определяет:
- Произошёл ли переход вперёд или назад
- Произошёл ли переход вообще

Направление перехода определяется просто по 7-му разряду операнда инструкции перехода (относительному смещению), который хранится на внутренней шине данных (DB). Если 7й разряд равен 1, то это значит что переход производится "назад" (PC = PC - offset).

Ну а проверка перехода осуществляется в зависимости от инструкции перехода (которые отличаются 6 и 7 разрядами кода операции), а также от флагов: C, V, N, Z.

<img src="/BreakingNESWiki/imgstore/branch_nice.jpg" width="800px">

## Логическая схема

<img src="/BreakingNESWiki/imgstore/branch-logic.jpg" width="600px">

## Логика BRANCH FORWARD

Триггер BRFW обновляется значением D7 во время BR3.PHI1. В остальное время триггер хранит своё текущее значение.

Не забываем, что во время второго полутакта (PHI2) все внутренние шины подзаряжаются и имеют значение 0xff.

## Логика BRANCH TAKEN

Комбинаторная логика выбирает вначале по IR6/IR7 к какой группе принадлежит инструкция перехода (то есть какой флаг она проверяет), а последующий XOR выбирает каким образом инструкция перехода срабатывает (флаг установлен/сброшен). 
Выход /BRTAKEN в инверсной логике, то есть если переход сработал, то /BRTAKEN = 0.

Примечание: логика BRANCH TAKEN работает постоянно и значение контрольной линии /BRTAKEN обновляется каждый такт, причем в не зависимости от того, какая инструкция обрабатывается процессором в данный момент.

## Verilog

```verilog
// ------------------
// Branch Logic

module BranchLogic (
    // Outputs
    BRFW, _BRTAKEN,
    // Inputs
    PHI0, BR2, DB7, _IR5, _IR6, _IR7, _C_OUT, _V_OUT, _N_OUT, _Z_OUT
);

    input PHI0, BR2, DB7, _IR5, _IR6, _IR7, _C_OUT, _V_OUT, _N_OUT, _Z_OUT;

    output BRFW, _BRTAKEN;

    wire BRFW, _BRTAKEN;

    // Clocks
    wire PHI1, PHI2;
    assign PHI1 = ~PHI0;
    assign PHI2 = PHI0;

    // Branch Forward
    wire BR2Latch_Out, Latch1_Out, Latch2_Out;
    mylatch BR2Latch ( BR2Latch_Out, BR2, PHI2);
    mylatch Latch1 ( Latch1_Out, (~(~DB7 & BR2Latch_Out) & ~(~BR2Latch_Out & Latch2_Out)), PHI1);
    mylatch Latch2 ( Latch2_Out, ~Latch1_Out, PHI2);
    assign BRFW = Latch1_Out;

    // Branch Taken
    wire temp;
    assign temp = ~(
        ~(_C_OUT | ~_IR6 | _IR7) |
        ~(_V_OUT | _IR6 | ~_IR7) |
        ~(_N_OUT | ~_IR6 | ~_IR7) |
        ~(_Z_OUT | _IR6 | _IR7) );
    assign _BRTAKEN = ~(temp & _IR5) & (temp | _IR5);

endmodule   // BranchLogic
```
