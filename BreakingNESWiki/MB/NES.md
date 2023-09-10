# NES

Список ревизий материнских плат:

|Плата|Описание|
|---|---|
|NES-CPU-02|2A03E/2C02E-0; 1985 copyright on PCB; VRAM and WRAM are NDIP-only; 3193 Non-A CIC; (This is the first one "released" in the USA, in the first 10,000? or so test release NES consoles, before wide release)|
|NES-CPU-03|unclear if this was even shipped|
|NES-CPU-04|2A03E/2C02E-0; 1986 copyright on PCB; VRAM and WRAM are NDIP-only; 3193 Non-A or 3193A CIC (release day consoles?, not sure of pcb changes to above); some have a 74HC139 at U3 instead of 74LS139|
|NES-CPU-05|2A03G/2C02G-0; 1986 copyright on PCB; VRAM and WRAM are NDIP-only; 3193A CIC (not sure of changes to above)|
|NES-CPU-06|2A03G/2C02G-0; 1987 copyright on PCB; VRAM and WRAM are NDIP or DIP|
|NES-CPU-07|2A03G/2C02G-0; 1987 copyright on PCB; VRAM and WRAM are NDIP or DIP (not sure of changes to above)|
|NES-CPU-08|2A03G/2C02G-0; 1989 copyright on PCB; VRAM and WRAM are NDIP or DIP|
|NES-CPU-09|2A03G/2C02G-0 or 2A07/2C07-0; 1987 copyright on PCB; VRAM and WRAM are NDIP or DIP; Has one resistor between CIC pin (data?) and cart connector to thwart some CIC STUN attacks|
|NES-CPU-10|2A03G/2C02G; 1987 copyright on PCB; VRAM and WRAM are NDIP or DIP; Has two resistors between CIC pins (clock and data?) and cart connector to thwart more CIC STUN attacks, some later pcbs have a hand-added-at-factory diode or diodes to nearby GND vias as well to prevent the -5V attack|
|NES-CPU-11|2A03G/2C02G or 2A07A/2C07A; 1987 Copyright on PCB; VRAM and WRAM are NDIP or DIP; Has two resistors and two diodes between CIC pins, cart connector and GND to prevent CIC STUN and -5V attacks|
|NESN-CPU-01 (1993)|U1: RAM: LH5216AD-10L; U2: HD74LS373P; U3: HD74LS139P; U5: PPU: RP2C02G-0; U6: CPU: RP2A03G; U7, U8: SN74HC368N; U9: +5V Regulator: 7805|
|NESN-CPU-JI0-01 (1993)|U1: WRAM: LH5216AD-10L; U2: SN74LS373N; U3: BU3266S; U4: VRAM: LH5216AD-10L; U5: PPU: RP2C02H-0; U6: CPU: RP2A03H; U7: +5V Regulator: 7805|
|NESN-CPU-AV-01 (1994)|U1: RAM: BR6216B-10LL; U2: MB74LS373; U3: BU3270S; U4: RAM: BR6216B-10LL; U5: PPU: RP2C02H-0; U6: CPU: RP2A03H; U7: +5V Regulator: 7805|

TODO: PAL versions, ребрендинги типа индийского SAMURAI.

Source: https://forums.nesdev.org/viewtopic.php?p=196688#p196688

Source: https://wiki.console5.com/tw/index.php?title=Nintendo_NES-101

## Generic NES

![nes](/BreakingNESWiki/MB/imgstore/nes.png)

## CIC

CIC - это специальная микросхема для реализации Copy Protection. Микросхема на материнской плате "общается" с аналогичной микросхемой на картридже и если проверка не пройдена - система уходит в бесконечный RESET.

В новых ревизиях NES (TopLoader) данная защита отсутствует, т.к. она обходится с минимальными усилиями.

TBD.

## Expansion Port

Порт расширения находится на задней части приставки под крышкой и также пробрасывается на контакты картриджа (в отличии от порта расширения Famicom, который соединяется только с I/O терминалами CPU).

TBD.

## 40H368

Данная IC представляет собой массив TriState (терминами Verilog - массив элементов notif0):

![40H368](/BreakingNESWiki/MB/imgstore/40H368.jpg)

## LS139

Спаренный демультиплексор с инверсными выходами:

![LS139](/BreakingNESWiki/MB/imgstore/LS139.jpg)

Используется для управления Chip Select в зависимости от значения адреса.

## LS373

8-разрядная защелка для мультиплексирования шины PPU A/D:

![LS373](/BreakingNESWiki/MB/imgstore/LS373.jpg)

Схема защелки:

![LS373_Transparent_Latch](/BreakingNESWiki/MB/imgstore/LS373_Transparent_Latch.jpg)
