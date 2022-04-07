# Логика исполнения

![6502_locator_dispatch](/BreakingNESWiki/imgstore/6502/6502_locator_dispatch.jpg)

Логика исполнения (dispatch) - это ключевой механизм процессора, который "дирижирует" выполнением инструкций.

В состав логики исполнения входят следующие схемы:
- Промежуточные сигналы
- Управление готовностью процессора
- Управление контактом R/W
- Счётчик циклов коротких инструкций (T0-T1)
- Счётчик циклов очень длинных инструкций (RMW T6-T7)
- Схема завершения выполнения инструкций
- Защелка ACR
- Схема инкремента счётчика инструкций (PC)
- Схема загрузки кода операции (Fetch)

[Счётчик циклов длинных инструкций](extra_counter.md) (T2-T5) рассматривается в соответствующем разделе.

## Промежуточные сигналы

Промежуточные сигналы получаются из выходов декодера без какой-либо закономерности. Очень сложно было их отделить от промежуточных сигналов остальных схем управления, по причине хаотичности соединений.

|BR2|BR3, D91_92|/MemOP|STORE, STOR|/SHIFT|
|---|---|---|---|---|
|![dispatch_br2_tran](/BreakingNESWiki/imgstore/dispatch_br2_tran.jpg)|![dispatch_br3_tran](/BreakingNESWiki/imgstore/dispatch_br3_tran.jpg)|![dispatch_memop_tran](/BreakingNESWiki/imgstore/dispatch_memop_tran.jpg)|![dispatch_store_tran](/BreakingNESWiki/imgstore/dispatch_store_tran.jpg)|![dispatch_shift_tran](/BreakingNESWiki/imgstore/dispatch_shift_tran.jpg)|

## Управление готовностью процессора

![dispatch_ready_tran](/BreakingNESWiki/imgstore/dispatch_ready_tran.jpg)

`/ready` - глобальный сигнал готовности процессора, получается из входного сигнала `RDY`, который приходит из соответствующего контакта.

## Управление R/W

![dispatch_rw_tran](/BreakingNESWiki/imgstore/dispatch_rw_tran.jpg)

- REST: Сбросить счётчики циклов
- WR: Процессор находится в режиме записи

## Счётчик циклов коротких инструкций

![dispatch_short_cycle_tran](/BreakingNESWiki/imgstore/dispatch_short_cycle_tran.jpg)

- T0: Внутренний сигнал (процессор в цикле T0)
- /T0, /T1X: Поступают на вход [декодера](decoder.md)

## Счётчик циклов очень длинных инструкций

![dispatch_long_cycle_tran](/BreakingNESWiki/imgstore/dispatch_long_cycle_tran.jpg)

- T5, T6: Процессор находится в цикле RMW T6/T7 (названия сигналов T5/T6 старые, но уже не будем переименовывать)

## Схема завершения выполнения

![dispatch_ends_tran](/BreakingNESWiki/imgstore/dispatch_ends_tran.jpg)

- ENDS: Завершить выполнение коротких инструкций

![dispatch_endx_tran](/BreakingNESWiki/imgstore/dispatch_endx_tran.jpg)

- ENDX: Завершить выполнение длинных инструкций

![dispatch_tresx_tran](/BreakingNESWiki/imgstore/dispatch_tresx_tran.jpg)

- TRESX: Сбросить счётчики циклов

![dispatch_tres2_tran](/BreakingNESWiki/imgstore/dispatch_tres2_tran.jpg)

- TRES2: Сбросить [дополнительный счётчик инструкций](extra_counter.md)

## Защелка ACR

![dispatch_acr_latch_tran](/BreakingNESWiki/imgstore/dispatch_acr_latch_tran.jpg)

Выдает 2 внутренних промежуточных сигнала: ACRL1 и ACRL2.

## Инкремент PC

![dispatch_pc_tran](/BreakingNESWiki/imgstore/dispatch_pc_tran.jpg)

Схема содержит 3 "ветки" комбинаторной логики, которые в итоге формируют [команду управления](context_control.md) инкремента PC (`#1/PC`).

Также схема формирует следующие сигналы:
- T1: Процессор в цикле T1
- TRES1: Сбросить счётчик циклов коротких инструкций

## Загрузка опкода

![dispatch_fetch_tran](/BreakingNESWiki/imgstore/dispatch_fetch_tran.jpg)

- FETCH: Выполнить загрузку опкода на [регистр инструкций](ir.md)
- 0/IR: Инжектировать код операции `BRK`, для [обработки прерываний](interrupts.md)

## Логическая схема

![dispatcher_logisim](/BreakingNESWiki/imgstore/logisim/dispatcher_logisim.jpg)

TBD: Распилить схему на составные части, чтобы не выглядела такой страшной.

## Оптимизированная логическая схема

![13_dispatcher_logisim](/BreakingNESWiki/imgstore/6502/ttlworks/13_dispatcher_logisim.png)
