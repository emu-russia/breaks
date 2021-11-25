# Логика исполнения

![6502_locator_dispatch](/BreakingNESWiki/imgstore/6502_locator_dispatch.jpg)

Логика исполнения (dispatch) - это ключевой механизм процессора, который "дирижирует" выполнением инструкций.

В состав логики исполнения входят следующие схемы:
- Промежуточные сигналы
- Управление готовностью процессора
- Управление контактом R/W
- Счетчик циклов коротких инструкций (T0-T1)
- Счетчик циклов очень длинных инструкций (T5-T6)
- Схема завершения выполнения инструкций
- Защелка ACR
- Схема инкремента счетчика инструкций (PC)
- Схема загрузки кода операции (Fetch)

[Счетчик циклов длинных инструкций](extra_counter.md) (T2-T5) рассматривается в соответствующем разделе.

## Промежуточные сигналы

Промежуточные сигналы получаются из выходов декодера без какой-либо закономерности. Очень сложно было их отделить от промежуточных сигналов остальных схем управления, по причине хаотичности соединений.

|BR2|BR3|/MemOP|STORE, STOR|/SHIFT|
|---|---|---|---|---|
|![dispatch_br2_tran](/BreakingNESWiki/imgstore/dispatch_br2_tran.jpg)|![dispatch_br3_tran](/BreakingNESWiki/imgstore/dispatch_br3_tran.jpg)|![dispatch_memop_tran](/BreakingNESWiki/imgstore/dispatch_memop_tran.jpg)|![dispatch_store_tran](/BreakingNESWiki/imgstore/dispatch_store_tran.jpg)|![dispatch_shift_tran](/BreakingNESWiki/imgstore/dispatch_shift_tran.jpg)|

## Управление готовностью процессора

![dispatch_ready_tran](/BreakingNESWiki/imgstore/dispatch_ready_tran.jpg)

`/ready` - глобальный сигнал готовности процессора, получается из входного сигнала `RDY`, который приходит из соответствующего контакта.

## Управление R/W

![dispatch_rw_tran](/BreakingNESWiki/imgstore/dispatch_rw_tran.jpg)

- REST: Сбросить счетчики циклов
- WR: Процессор находится в режиме записи

## Счетчик циклов коротких инструкций

![dispatch_short_cycle_tran](/BreakingNESWiki/imgstore/dispatch_short_cycle_tran.jpg)

- T0: Внутренний сигнал (процессор в цикле T0)
- /T0, /T1X: Поступают на вход [декодера](decoder.md)

## Счетчик циклов очень длинных инструкций

![dispatch_long_cycle_tran](/BreakingNESWiki/imgstore/dispatch_long_cycle_tran.jpg)

- T5, T6: Процессор находится в цикле T5/T6

## Схема завершения выполнения

![dispatch_ends_tran](/BreakingNESWiki/imgstore/dispatch_ends_tran.jpg)

- ENDS: Завершить выполнение коротких инструкций

![dispatch_endx_tran](/BreakingNESWiki/imgstore/dispatch_endx_tran.jpg)

- ENDX: Завершить выполнение длинных инструкций

![dispatch_tresx_tran](/BreakingNESWiki/imgstore/dispatch_tresx_tran.jpg)

- TRESX: Сбросить счетчики циклов

![dispatch_tres2_tran](/BreakingNESWiki/imgstore/dispatch_tres2_tran.jpg)

- TRES2: Сбросить [дополнительный счетчик инструкций](extra_counter.md)

## Защелка ACR

![dispatch_acr_latch_tran](/BreakingNESWiki/imgstore/dispatch_acr_latch_tran.jpg)

Выдает 2 внутренних промежуточных сигнала: ACRL1 и ACRL2.

TBD: Проследить откуда получается сигнал `/ACR`. По идее он должен получаться из сигнала `ACR` (выходной перенос АЛУ).

## Инкремент PC

![dispatch_pc_tran](/BreakingNESWiki/imgstore/dispatch_pc_tran.jpg)

Схема содержит 3 "ветки" комбинаторной логики, которые в итоге формируют [команду управления](context_control.md) инкремента PC (`#1/PC`).

Также схема формирует следующие сигналы:
- T1: Процессор в цикле T1
- TRES1: Сбросить счетчик циклов коротких инструкций

## Загрузка опкода

![dispatch_fetch_tran](/BreakingNESWiki/imgstore/dispatch_fetch_tran.jpg)

- FETCH: Выполнить загрузку опкода на [регистр инструкций](ir.md)
- 0/IR: Инжектировать код операции `BRK`, для [обработки прерываний](interrupts.md)
