# Логика исполнения

![6502_locator_dispatch](/BreakingNESWiki/imgstore/6502/6502_locator_dispatch.jpg)

Логика исполнения (dispatcher или sequencer) - это ключевой механизм процессора, который "дирижирует" выполнением инструкций.

![DispatchUnit](/BreakingNESWiki/imgstore/6502/DispatchUnit.jpg)

В состав логики исполнения входят следующие схемы:
- Промежуточные сигналы
- Управление готовностью процессора и режимом R/W
- Счётчик циклов коротких инструкций (T0-T1)
- Счётчик циклов очень длинных инструкций (RMW T6-T7)
- Схема завершения выполнения инструкций
- Защёлка ACR
- Схема инкремента счётчика инструкций (PC)
- Схема загрузки кода операции (Fetch)

[Счётчик циклов длинных инструкций](extra_counter.md) (T2-T5) рассматривается в соответствующем разделе.

:warning: Данный модуль процессора очень запутанный и содержит много циклов. Сигналы в него приходят практически отовсюду и также уходят практически во все места. Транзисторные схемы "размазаны" равномерным слоем в промежутках между остальными частями рандомной логики.

## Промежуточные сигналы

Промежуточные сигналы получаются из выходов декодера без какой-либо закономерности. Очень сложно было их отделить от промежуточных сигналов остальных схем управления, по причине хаотичности соединений.

|BR2|BR3, D91_92|/MemOP|STORE, STOR|/SHIFT|
|---|---|---|---|---|
|![dispatch_br2_tran](/BreakingNESWiki/imgstore/6502/dispatch_br2_tran.jpg)|![dispatch_br3_tran](/BreakingNESWiki/imgstore/6502/dispatch_br3_tran.jpg)|![dispatch_memop_tran](/BreakingNESWiki/imgstore/6502/dispatch_memop_tran.jpg)|![dispatch_store_tran](/BreakingNESWiki/imgstore/6502/dispatch_store_tran.jpg)|![dispatch_shift_tran](/BreakingNESWiki/imgstore/6502/dispatch_shift_tran.jpg)|

## Управление готовностью процессора и режим R/W

В процессоре 6502 схемы управления готовностью и режимом R/W совмещены в одну. 

![dispatch_ready_tran](/BreakingNESWiki/imgstore/6502/dispatch_ready_tran.jpg)

![dispatch_rw_tran](/BreakingNESWiki/imgstore/6502/dispatch_rw_tran.jpg)

![DispReadyRW](/BreakingNESWiki/imgstore/6502/DispReadyRW.jpg)

- /ready: глобальный сигнал готовности процессора, получается из входного сигнала `RDY`, который приходит из соответствующего терминала
- REST: Сбросить счётчики циклов
- WR: Процессор находится в режиме записи

## Счётчик циклов коротких инструкций

![dispatch_short_cycle_tran](/BreakingNESWiki/imgstore/6502/dispatch_short_cycle_tran.jpg)

![DispShortCycle](/BreakingNESWiki/imgstore/6502/DispShortCycle.jpg)

- T0: Внутренний сигнал (процессор в цикле T0)
- /T0, /T1X: Поступают на вход [декодера](decoder.md)

## Счётчик циклов очень длинных инструкций

![dispatch_long_cycle_tran](/BreakingNESWiki/imgstore/6502/dispatch_long_cycle_tran.jpg)

![DispRMWCycle](/BreakingNESWiki/imgstore/6502/DispRMWCycle.jpg)

- T6, T7: Процессор находится в цикле RMW T6/T7

## Схема завершения выполнения

![dispatch_ends_tran](/BreakingNESWiki/imgstore/6502/dispatch_ends_tran.jpg)

- ENDS: Завершить выполнение коротких инструкций

![dispatch_endx_tran](/BreakingNESWiki/imgstore/6502/dispatch_endx_tran.jpg)

- ENDX: Завершить выполнение длинных инструкций

![dispatch_tresx_tran](/BreakingNESWiki/imgstore/6502/dispatch_tresx_tran.jpg)

- #TRESX: Сбросить счётчики циклов

![dispatch_tres2_tran](/BreakingNESWiki/imgstore/6502/dispatch_tres2_tran.jpg)

- TRES2: Сбросить [дополнительный счётчик инструкций](extra_counter.md)

![DispCompletionUnit](/BreakingNESWiki/imgstore/6502/DispCompletionUnit.jpg)

## Защёлка ACR

![dispatch_acr_latch_tran](/BreakingNESWiki/imgstore/6502/dispatch_acr_latch_tran.jpg)

![DispACRLatch](/BreakingNESWiki/imgstore/6502/DispACRLatch.jpg)

Выдает 2 внутренних промежуточных сигнала: ACRL1 и ACRL2.

## Инкремент PC

![dispatch_pc_tran](/BreakingNESWiki/imgstore/6502/dispatch_pc_tran.jpg)

![DispIncrementPC](/BreakingNESWiki/imgstore/6502/DispIncrementPC.jpg)

Схема содержит 3 "ветки" комбинаторной логики, которые в итоге формируют [команду управления](context_control.md) инкремента PC (`#1/PC`).

Также тут рядом находится схема для генерации следующих сигналов:
- T1: Процессор в цикле T1
- TRES1: Сбросить счётчик циклов коротких инструкций

## Загрузка опкода

![dispatch_fetch_tran](/BreakingNESWiki/imgstore/6502/dispatch_fetch_tran.jpg)

![DispFetch](/BreakingNESWiki/imgstore/6502/DispFetch.jpg)

- FETCH: Выполнить загрузку опкода на [регистр инструкций](ir.md)
- 0/IR: Инжектировать код операции `BRK`, для [обработки прерываний](interrupts.md)

## Логическая схема (старый вариант)

![dispatcher_logisim](/BreakingNESWiki/imgstore/logisim/dispatcher_logisim.jpg)

## Оптимизированная логическая схема

![13_dispatcher_logisim](/BreakingNESWiki/imgstore/6502/ttlworks/13_dispatcher_logisim.png)
