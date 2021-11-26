# Управление шинами

![6502_locator_bus_control](/BreakingNESWiki/imgstore/6502_locator_bus_control.jpg)

Управление шинами больше всего "раскидано" по поверхности процессора. Проще всего будет вначале дать описание всех [команд управления](context_control.md) шинами, а потом по отдельности рассмотреть соответствующие схемы.

Команды управления шинами:

|Команда|Описание|
|---|---|
|Управление внешней шиной адреса||
|ADH/ABH|Установить старшие 8 разрядов внешней шины адреса, в соотвествии со значением внутренней шины ADH|
|ADL/ABL|Установить младшине 8 разрядов внешней шины адреса, в соотвествии со значением внутренней шины ADL|
|Управление внутренними шинами SB, DB и ADH||
|SB/DB|Соединить шины SB и DB|
|SB/ADH|Соединить шины SB и ADH|
|0/ADH0|Принудительно очистить разряд ADH\[0\]|
|0/ADH17|Принудительно очистить разряды ADH\[1-7\]|
|Управление внешней шиной данных||
|DL/ADL|Записать значение DL на шину ADL|
|DL/ADH|Записать значение DL на шину ADH|
|DL/DB|Обменять значение DL и внутренней шины DB. Направление обмена зависит от режима работы внешней шины данных (чтение/запись)|

## Вспомогательные сигналы

Схема для получения вспомогательных сигналов `NOADL` и `IND`:

![bus_noadl_ind_tran](/BreakingNESWiki/imgstore/bus_noadl_ind_tran.jpg)

Остальные вспомогательные и промежуточные сигналы:

|Сигнал|Описание|
|---|---|
|RTS/5| |
|RTI/5| |
|BR0| |
|T5| |
|T6| |
|PGX| |
|JSR/5| |
|T2| |
|!PCH/PCH| |
|SBA|Сигнал выходит из схемы получения #SB/ADH|
|/ready| |
|BR3| |
|0/ADL0| |
|#SB/AC| |
|SBXY| |
|JSXY| |
|AND| |
|T1| |
|BR2| |
|ZTST| |
|BR3| |
|ACRL2| |
|T0| |
|ABS/2| |
|JMP/4| |
|IMPL| |
|JSR2| |
|BRK6E| |
|INC_SB| |
|DL/PCH| |

## Управление внешней шиной адреса

Схема для формирования промежуточного сигнала #ADL/ABL:

![bus_adlabl_tran](/BreakingNESWiki/imgstore/bus_adlabl_tran.jpg)

Схема для формирования промежуточного сигнала #ADH/ABH:

![bus_adhabh_tran1](/BreakingNESWiki/imgstore/bus_adhabh_tran1.jpg)

![bus_adhabh_tran2](/BreakingNESWiki/imgstore/bus_adhabh_tran2.jpg)

Выходные защелки команд управления ADL/ABL и ADH/ABH

![bus_addr_bus_commands_tran](/BreakingNESWiki/imgstore/bus_addr_bus_commands_tran.jpg)

## Управление внутренними шинами SB, DB и ADH

Схемы для формирования промежуточных сигналов (для 0/ADH0 получается сразу управляющая команда):

|#SB/DB (также #0/ADH17)|0/ADH0|#SB/ADH|
|---|---|---|
|![bus_control_tran1](/BreakingNESWiki/imgstore/bus_control_tran1.jpg)|![bus_0adh0_tran](/BreakingNESWiki/imgstore/bus_0adh0_tran.jpg)|![bus_sbadh_tran](/BreakingNESWiki/imgstore/bus_sbadh_tran.jpg)|

Выходные защелки команд управления SB/DB, SB/ADH, 0/ADH17:

![bus_sb_commands_tran](/BreakingNESWiki/imgstore/bus_sb_commands_tran.jpg)

(Схема получения команды и защелка 0/ADH0 выше)

## Управление внешней шиной данных

Схема для формирования промежуточного сигнала #DL/ADL:

![bus_dladl_tran](/BreakingNESWiki/imgstore/bus_dladl_tran.jpg)

Схема для формирования промежуточного сигнала #DL/DB:

![bus_dldb_tran](/BreakingNESWiki/imgstore/bus_dldb_tran.jpg)

(Кусок рядом со схемой `ACR Latch`)

![bus_dldb_tran2](/BreakingNESWiki/imgstore/bus_dldb_tran2.jpg)

(Кусок в схеме управления АЛУ. Сигнал #DL/DB соединяется напрямую между этими двумя частями)

Выходные защелки команд управления DL/ADL, DL/ADH, DL/DB:

![bus_data_latch_commands_tran](/BreakingNESWiki/imgstore/bus_data_latch_commands_tran.jpg)
