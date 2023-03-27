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

Source: https://forums.nesdev.org/viewtopic.php?p=196688#p196688

## Generic NES

![nes](/BreakingNESWiki/MB/imgstore/nes.png)

## CIC

TBD.

## Expansion Port

TBD.

## 40H368

Данная IC представляет собой массив TriState:

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
