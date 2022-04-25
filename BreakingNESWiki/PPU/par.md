# Регистр адреса PAR

![ppu_locator_par](/BreakingNESWiki/imgstore/ppu/ppu_locator_par.jpg)

![PAR_All](/BreakingNESWiki/imgstore/ppu/PAR_All.png)

Регистр адреса PAR хранит значение для внешней шины адреса (`/PA0-13`) (14 бит).

Источники для записи в PAR:
- Адрес паттерна (`PAD0-12`) (13 бит)
- Значение с шины данных (`DB0-7`) (8 бит)
- Значение со счётчиков PAR, которые также являются частью данной схемы. Счётчики PAR загружаются с регистров скроллинга.

## Счётчики PAR

Режимы работы счётчиков:

|Счётчик|Разрядность|Предел счёта|Предел счёта (Blank)|Источник входного переноса|Источник входного переноса (Blank)|Источник сброса счётчика|Выход переноса|Выход переноса (Blank)|
|---|---|---|---|---|---|---|---|---|
|Tile Horizontal|5	|32	|32	|!(BLNK & I1/32)		|!(BLNK & I1/32)		|нет					|разрешен	|разрешен|
|Tile Vertical	|5	|30	|32	|Fine Vertical CNT		|Tile Horizontal CNT	|carry TVZ + 1 TVSTEP	|разрешен	|разрешен|
|Name Table H	|1	|2	|2	|Tile Horizontal CNT	|Tile Vertical CNT		|нет					|запрещен	|разрешен|
|Name Table V	|1	|2	|2	|Tile Vertical CNT		|Name Table H  CNT		|нет					|запрещен	|разрешен|
|Fine Vertical	|3	|8	|8	|Tile Horizontal CNT	|Name Table V  CNT		|нет					|разрешен	|запрещен|

### Схема управления счётчиками PAR

![ppu_dataread_par_counters_control_top](/BreakingNESWiki/imgstore/ppu/ppu_par_counters_control_top.jpg)

![ppu_dataread_par_counters_control_bot](/BreakingNESWiki/imgstore/ppu/ppu_par_counters_control_bot.jpg)

![PAR_CountersControl](/BreakingNESWiki/imgstore/ppu/PAR_CountersControl.png)

![PAR_CountersControl2](/BreakingNESWiki/imgstore/ppu/PAR_CountersControl2.png)

### Разряд счётчиков

![PAR_CounterBit](/BreakingNESWiki/imgstore/ppu/PAR_CounterBit.png)

Для счётчика TV используется вариация со сбросом:

![PAR_CounterBitReset](/BreakingNESWiki/imgstore/ppu/PAR_CounterBitReset.png)

### Счётчик FV

![ppu_dataread_par_counters_fv](/BreakingNESWiki/imgstore/ppu/ppu_par_counters_fv.jpg)

![PAR_FVCounter](/BreakingNESWiki/imgstore/ppu/PAR_FVCounter.png)

### Счётчики NT

![ppu_dataread_par_counters_nt](/BreakingNESWiki/imgstore/ppu/ppu_par_counters_nt.jpg)

![PAR_NTCounters](/BreakingNESWiki/imgstore/ppu/PAR_NTCounters.png)

### Счётчик TV

![ppu_dataread_par_counters_tv](/BreakingNESWiki/imgstore/ppu/ppu_par_counters_tv.jpg)

![PAR_TVCounter](/BreakingNESWiki/imgstore/ppu/PAR_TVCounter.png)

### Счётчик TH

![ppu_dataread_par_counters_th](/BreakingNESWiki/imgstore/ppu/ppu_par_counters_th.jpg)

![PAR_THCounter](/BreakingNESWiki/imgstore/ppu/PAR_THCounter.png)

## PAR

![PAR](/BreakingNESWiki/imgstore/ppu/PAR.png)

Схема выглядит страшновато, это из-за большого количества входных источников для загрузки в разряды регистра PAR.

### Схема контроля PAR

Схема контроля предназначена для выбора одного из источников для записи в PAR.

![ppu_dataread_par_control](/BreakingNESWiki/imgstore/ppu/ppu_par_control.jpg)

![PAR_Control](/BreakingNESWiki/imgstore/ppu/PAR_Control.png)

### Разряды PAR

![ppu_dataread_par_low](/BreakingNESWiki/imgstore/ppu/ppu_par_low.jpg)

![ppu_dataread_par_high](/BreakingNESWiki/imgstore/ppu/ppu_par_high.jpg)

![PAR_LowBit](/BreakingNESWiki/imgstore/ppu/PAR_LowBit.png)

![PAR_HighBit](/BreakingNESWiki/imgstore/ppu/PAR_HighBit.png)
