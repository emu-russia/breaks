# Famicom

Список ревизиий материнских плат:

|Плата|Описание|
|---|---|
|HVC-CPU-01| |
|HVC-CPU-02| |
|HVC-CPU-03| |
|HVC-CPU-04| |
|HVC-CPU-05| |
|HVC-CPU-06| |
|HVC-CPU-07| |
|HVC-CPU-08| |
|HVC-CPU-GPM-02a| |
|HVC-CPU-GPM-02b| |
|HVC-CPU-GPM-02c| |
|HVC-CPU-GPM-02d| |
|HVC-CPU-GPM-02e| |
|HVC-CPU-GPM-02f| |
|HVC-CPU-GPM-02g| |
|HVC-CPU-GPM-02h| |
|HVC-CPU-GPM-02i| |
|HVC-CPU-GPM-02j| |
|HVC-CPU-GPM-02k (?)| |

TBD: По возможности указать значимые отличия между ревизиями. В плане логики особых изменений быть не должно.

Источник: http://jpx72web.blogspot.com/2016/11/famicom-av-mod-new.html

## Generic Famicom

Представлена "общая" логическая схема для всех ревизий, где не используется JIO чип.

![fami_logisim](/BreakingNESWiki/MB/imgstore/fami_logisim.jpg)

- Резисторы подтяжки (RM1) подтягивают до `1` провода, если на них `z` (в особенности это касается прерываний `/IRQ` и `/NMI`).
- Кнопка RESET SW принимает значение `0` при нажатии, чтобы инициировать `/RES`. В исходной схеме длительность уровня /RES определяется конденсатором.

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

## JIO

В некоторых версиях Famicom все мелкие микросхемы и резисторы подтяжки объединены в одну IC.

TBD: 32-пин чип, в котором находится вся "рассыпуха".

TBD: Схема с JIO чипом.

Источник: https://forums.nesdev.org/viewtopic.php?t=16764

## Sound

![fami_sound](/BreakingNESWiki/MB/imgstore/fami_sound.png)

Инвертор из U7 используется в качестве усилителя с резистором для отрицательной обратной связи.

## Игры с микрофоном

https://www.youtube.com/watch?v=Mv7-5z1Itqg
