# Отличия Letterless 2A03

Letterless 2A03 - это какая-то старая ревизия APU, декап которой есть на Silicon Pr0n: https://siliconpr0n.org/map/nintendo/rp2a03/

## PIT

Вместо тестового паттерна находится отключенная схема программируемого таймера с прерыванием.

## LFO Generator

В ранней ревизии 2а03 ресет не перезагружает лфо, отсуствует дополнительный вход в норке.

![0001](/BreakingNESWiki/imgstore/apu/old_2a03/0001.png)

## DPCM

еще одно отличие раннего 2А03, в DPCM FREQ LFSR  сигнал RES не влияет на управление перезагрузкой сдвигового регистра LFSR.

![FREQ_DPCM_DIFF](https://github.com/user-attachments/assets/bf5e8b10-4419-4629-bdb6-3106e1f7ae9f)

## DMA 

Вот еще отличие в ДМА контрол. Триггер START DMA не обнуляется сигналом RES (дополнительный вход отсуствует).

![0002](/BreakingNESWiki/imgstore/apu/old_2a03/0002.png)

## ACLK Generator

Еще отличие в делителе АЦЛК.  Сигнал RES не влияет на делитель клока. (отсуствует дополнительный вход NOR)

![0003](/BreakingNESWiki/imgstore/apu/old_2a03/0003.png)

## PHI0 Divider

Делитель раннего 2а03 отличается измененной скважность сигнала М2, 15/24 вместо of 17/24. Схемотехнически это делается очень просто:
берется сигнал для м2 c SR3, тогда как в 2a03D этот сигнал идет от SR4.

![div_letterless](https://github.com/user-attachments/assets/a60ee82e-b434-4ef7-9ae6-aeb1b0de0343)
![wawe_divs](https://github.com/user-attachments/assets/6a49a09d-85b6-4ae3-b257-1cc82278e72d)

## DEBUG

Данный чип не имеет отладочных регистров и их вспомогательных цепей, поэтому сигнал LOCK и его регистр отсуствует
