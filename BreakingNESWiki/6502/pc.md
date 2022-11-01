# Счётчик инструкций (PC)

![6502_locator_pc](/BreakingNESWiki/imgstore/6502/6502_locator_pc.jpg)

Из-за 8-битной природы процессора его счётчик инструкций разделен на две 8-битные половины: PCL (Program Counter Low) и PCH (Program Counter High).

Кроме этого PCH также разделен на 2 половины: младшую часть разрядов (0-3) и старшую (4-7).

## PCL

Представляет собой младшие разряды PC\[0-7\].

|PCL 0-3|PCL 4-7|
|---|---|
|![pcl03_tran](/BreakingNESWiki/imgstore/6502/pcl03_tran.jpg)|![pcl47_tran](/BreakingNESWiki/imgstore/6502/pcl47_tran.jpg)|

- Схемы чередуются для четных и нечетных разрядов, так как используется оптимизация, известная как инвертированная цепочка переносов
- На разряд PCL0 приходит управляющий сигнал `#1/PC` (0: выполнить инкремент PC)
- PCLC (PCL Carry): Перенос с младших 8 разрядов (PC\[0-7\]) на старшие (PC\[8-15\])
- PCL соединяется с двумя шинами: ADL и DB
- PCL/PCL используется когда PCL не соединен ни с одной шиной (для поддержания текущего состояния)
- Каждый разряд содержит две защёлки (входная защёлка `PCLSx` и выходная защёлка `PCLx`), которые реализуют логику счётчика

## PCH

Представляет собой старшие разряды PC\[8-15\].

:warning: 
Схемы для четных битов (0, 2, ...) PCH повторяют схемы для нечетных битов (1, 3, ...) PCL.
Аналогично, схемы для нечетных битов (1, 3, ...) PCH повторяют схемы для четных битов (0, 2, ...) PCL.

|PCH 0-3|PCH 4-7|
|---|---|
|![pch03_tran](/BreakingNESWiki/imgstore/6502/pch03_tran.jpg)|![pch47_tran](/BreakingNESWiki/imgstore/6502/pch47_tran.jpg)|

Схема отмеченная как "patch" для формирования `PCHC` на самом деле находится между контрольными выходами `ADL/PCL` и `#1/PC`.

- Основные принципы устройства PCH повторяют PCL, только PCH разбит на 2 половины: младшую (PCH0-3) и старшую (PCH4-7)
- PCHC (PCH Carry): Перенос с младшей части PCH в старшую
- PCH соединяется с двумя шинами: ADH и DB
- PCH/PCH используется когда PCH не соединен ни с одной шиной (для поддержания текущего состояния)

## ADL/ADH Precharge

В промежутках между разрядами PC можно встретить транзисторы для подзарядки шин ADL и ADH:

![adl_adh_precharge_tran](/BreakingNESWiki/imgstore/6502/adl_adh_precharge_tran.jpg)

(На изображении показаны precharge транзисторы для ADH4 и ADL5. Остальные аналогично)

## Логическая схема

Имеет смысл показать только схемы разрядов (схемы чередуются между четными и нечетными разрядами PCL/PCH).

Данная схема используется, например, в PCL0 или PCH1:

![pc_even_bit_logisim](/BreakingNESWiki/imgstore/6502/pc_even_bit_logisim.jpg)

Данная схема используется, например, в PCL1 или PCH0:

![pc_odd_bit_logisim](/BreakingNESWiki/imgstore/6502/pc_odd_bit_logisim.jpg)

Чтобы данные схемы корректно работали в симуляторе, FF для разряда регистра PCL/PCH использует триггер по заднему фронту (posedge).

Оптимизированная логическая схема (Even):

![20_pc_even_bit_logisim](/BreakingNESWiki/imgstore/6502/ttlworks/20_pc_even_bit_logisim.png)

Оптимизированная логическая схема (Odd):

![21_pc_odd_bit_logisim](/BreakingNESWiki/imgstore/6502/ttlworks/21_pc_odd_bit_logisim.png)

Оптимизированная логическая схема для цепочки переноса:

![22_pc_carry_chain](/BreakingNESWiki/imgstore/6502/ttlworks/22_pc_carry_chain.png)
