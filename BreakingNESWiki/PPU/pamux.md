# Адресный мультиплексор (PPU Address Mux, PAMUX)

![ppu_locator_pamux](/BreakingNESWiki/imgstore/ppu/ppu_locator_pamux.jpg)

![PAMUX](/BreakingNESWiki/imgstore/ppu/PAMUX.png)

В патенте данная схема никак не упоминается, предполагается что она содержится в "колбаске", которая показана на данной картинке схемы из патента:

![pamux_patent](/BreakingNESWiki/imgstore/ppu/pamux_patent.png)

Адресный мультиплексор хранит финальное значение для внешней шины адреса (`/PA0-13`) (14 бит).

Источники для записи в выходные защёлки PAMUX:
- Адрес паттерна из PAR (`PAD0-12`) (13 бит)
- Значение с шины данных (`DB0-7`) (8 бит)
- Значение с тайловых счётчиков. Тайловые счётчики в свою очередь загружаются с регистров скроллинга.

### Схема контроля адресного мультиплексора

Схема контроля предназначена для выбора одного из источников для записи в выходные защёлки мультиплексора.

![ppu_dataread_pamux_control](/BreakingNESWiki/imgstore/ppu/ppu_pamux_control.jpg)

![PamuxControl](/BreakingNESWiki/imgstore/ppu/PamuxControl.png)

### Разряды адресного мультиплексора

![ppu_dataread_pamux_low](/BreakingNESWiki/imgstore/ppu/ppu_pamux_low.jpg)

![ppu_dataread_pamux_high](/BreakingNESWiki/imgstore/ppu/ppu_pamux_high.jpg)

![PamuxLowBit](/BreakingNESWiki/imgstore/ppu/PamuxLowBit.png)

![PamuxHighBit](/BreakingNESWiki/imgstore/ppu/PamuxHighBit.png)