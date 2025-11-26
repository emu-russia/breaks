## Счётчики Тайлов

![ppu_locator_tilecnt](/BreakingNESWiki/imgstore/ppu/ppu_locator_tilecnt.jpg)

![TileCounters_All](/BreakingNESWiki/imgstore/ppu/TileCounters_All.png)

Режимы работы счётчиков:

|Счётчик|Разрядность|Предел счёта|Предел счёта (Blank)|Источник входного переноса|Источник входного переноса (Blank)|Источник сброса счётчика|Выход переноса|Выход переноса (Blank)|
|---|---|---|---|---|---|---|---|---|
|Tile Horizontal|5	|32	|32	|!(BLNK & I1/32)		|!(BLNK & I1/32)		|нет					|разрешен	|разрешен|
|Tile Vertical	|5	|30	|32	|Fine Vertical CNT		|Tile Horizontal CNT	|carry TVZ + 1 TVSTEP	|разрешен	|разрешен|
|Name Table H	|1	|2	|2	|Tile Horizontal CNT	|Tile Vertical CNT		|нет					|запрещен	|разрешен|
|Name Table V	|1	|2	|2	|Tile Vertical CNT		|Name Table H  CNT		|нет					|запрещен	|разрешен|
|Fine Vertical	|3	|8	|8	|Tile Horizontal CNT	|Name Table V  CNT		|нет					|разрешен	|запрещен|

### Схема управления счётчиками тайлов

![ppu_dataread_tile_counters_control_top](/BreakingNESWiki/imgstore/ppu/ppu_tile_counters_control_top.jpg)

![ppu_dataread_tile_counters_control_bot](/BreakingNESWiki/imgstore/ppu/ppu_tile_counters_control_bot.jpg)

![TileCountersControl](/BreakingNESWiki/imgstore/ppu/TileCountersControl.png)

![TileCountersControl2](/BreakingNESWiki/imgstore/ppu/TileCountersControl2.png)

### Разряд счётчиков

![TileCounterBit](/BreakingNESWiki/imgstore/ppu/TileCounterBit.png)

Для счётчика TV используется вариация со сбросом:

![TileCounterBitReset](/BreakingNESWiki/imgstore/ppu/TileCounterBitReset.png)

### Счётчик FV

![ppu_dataread_tile_counters_fv](/BreakingNESWiki/imgstore/ppu/ppu_tile_counters_fv.jpg)

![Tile_FVCounter](/BreakingNESWiki/imgstore/ppu/Tile_FVCounter.png)

### Счётчики NT

![ppu_dataread_tile_counters_nt](/BreakingNESWiki/imgstore/ppu/ppu_tile_counters_nt.jpg)

![Tile_NTCounters](/BreakingNESWiki/imgstore/ppu/Tile_NTCounters.png)

### Счётчик TV

![ppu_dataread_tile_counters_tv](/BreakingNESWiki/imgstore/ppu/ppu_tile_counters_tv.jpg)

![Tile_TVCounter](/BreakingNESWiki/imgstore/ppu/Tile_TVCounter.png)

Обратите внимание на хитрый сигнал `0/TV`. Этот сигнал очищает не только содержимое входного FF счётчика на Keep фазе, но и делает pulldown на его выходного значения, но НЕ комплементарного выхода.

### Счётчик TH

![ppu_dataread_tile_counters_th](/BreakingNESWiki/imgstore/ppu/ppu_tile_counters_th.jpg)

![Tile_THCounter](/BreakingNESWiki/imgstore/ppu/Tile_THCounter.png)