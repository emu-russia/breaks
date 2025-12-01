# Адресный мультиплексор (PPU Address Mux, PAMUX)

![ppu_locator_pamux](/BreakingNESWiki/imgstore/ppu/ppu_locator_pamux.jpg)

![PAMUX_All](/BreakingNESWiki/imgstore/ppu/PAMUX_All.png)

В патенте данная схема никак не упоминается, предполагается что она содержится в "колбаске", которая показана на данной картинке схемы из патента:

![pamux_patent](/BreakingNESWiki/imgstore/ppu/pamux_patent.png)

Адресный мультиплексор хранит финальное значение для внешней шины адреса (`/PA0-13`) (14 бит).

Источники для записи в выходные защёлки PAMUX:
- Адрес паттерна из PAR (`PAT_ADR 0-13`) (14 бит)
- Значение с тайловых счётчиков: адрес Attribute Table (`AT_ADR`), адрес Name Table (`NT_ADR`) (14 бит оба). Тайловые счётчики в свою очередь загружаются с регистров скроллинга.
- Значение с шины данных (`DB0-7`) (8 бит)

## Схема управления адресным мультиплексором

Схема управления предназначена для выбора одного из источников для записи в выходные защёлки мультиплексора.

![ppu_dataread_pamux_control](/BreakingNESWiki/imgstore/ppu/ppu_pamux_control.jpg)

![PamuxControl](/BreakingNESWiki/imgstore/ppu/PamuxControl.png)

## Разряды адресного мультиплексора

![PAMUX](/BreakingNESWiki/imgstore/ppu/PAMUX.png)

![ppu_pamux_low](/BreakingNESWiki/imgstore/ppu/ppu_pamux_low.jpg)

![ppu_pamux_high](/BreakingNESWiki/imgstore/ppu/ppu_pamux_high.jpg)

![PamuxLowBit](/BreakingNESWiki/imgstore/ppu/PamuxLowBit.png)

![PamuxHighBit](/BreakingNESWiki/imgstore/ppu/PamuxHighBit.png)