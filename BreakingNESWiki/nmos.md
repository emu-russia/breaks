# NMOS

Раздел для того чтобы обучить @Wind схемотехнике, чтобы он реверсил схемы чипов вместе с нами.

## DFF

![D Flip-Flop](/BreakingNESWiki/imgstore/nmos/DFF.png)

## Multiplexed Transparent Latch

![PlexedTranspLatch](/BreakingNESWiki/imgstore/nmos/PlexedTranspLatch.png)

Данный элемент выполняет роль конструкции switch-case, если говорить терминами C++.

Группа Pass-gate транзисторов с общим выходом формируют chained мультиплексор, выход которого представляет собой Transparent D-Latch.

Обычно схема строится таким образом, что селектирующие входы являются одноединичными (только один из них может принимать значение `1`).

Если все селектирующие входы закрыты - последнее значение с цепочки мультиплексоров хранится на защёлке.

Конструкции подобного рода широкого используются в счётчиках.

## NXOR

![NXOR](/BreakingNESWiki/imgstore/nmos/NXOR.png)

## Разряд счётчика

![NMOS_CounterBit](/BreakingNESWiki/imgstore/nmos/NMOS_CounterBit.png)

## Разряд обратного счётчика

![NMOS_DOWN_CounterBit](/BreakingNESWiki/imgstore/nmos/NMOS_DOWN_CounterBit.png)

## AOI

And-Or-Inverted:

![AOI](/BreakingNESWiki/imgstore/nmos/AOI.png)

## OAI

Or-And-Inverted:

![OAI](/BreakingNESWiki/imgstore/nmos/OAI.png)
