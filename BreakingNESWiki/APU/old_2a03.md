# Отличия Letterless 2A03

Letterless 2A03 - это какая-то старая ревизия APU, декап которой есть на Silicon Pr0n: https://siliconpr0n.org/map/nintendo/rp2a03/

## PIT

Вместо тестового паттерна находится отключенная схема программируемого таймера с прерыванием.

<img width="618" height="935" alt="int timer" src="https://github.com/user-attachments/assets/75a7a83d-e6a9-468b-bf21-9eab2fa46a23" />


## LFO Generator

В ранней ревизии 2а03 ресет не перезагружает лфо, отсуствует дополнительный вход в норке.

![0001](/BreakingNESWiki/imgstore/apu/old_2a03/0001.png)

## NOISE

В ранней ревизии отсутствует режим тонального шума. Защелка w400e (d7) и управляемый ею мультиплексор отсуствуют. Обратная связь не переключается 
между выходами Random LFSR R8 и R13, а поcтупает напрямую с R13.

![noise_dif](https://github.com/user-attachments/assets/3fc891e7-af98-438c-bed6-12186c935860)
![noise_dif2](https://github.com/user-attachments/assets/a5d38196-2fc3-412a-9585-8644f590b28a)

FREQUENCY LFSR немного отличается, сдвиговый регистр LFSR короче на одну стадию, обратная связь LFSR также подверглась изменениям, режим работы 
не зависит от сигнала Reset и точки подключения обратной свяки к выводам сдвигового регистра другие.

<img width="1115" height="1375" alt="NOISE EARLY" src="https://github.com/user-attachments/assets/42152463-ee02-453e-aa85-553438db7a6b" />

Также из-за укорачивания сдвигового регистра изменилась и таблица частот шумового канала, она стала короче на один бит и данные таблицы совершенно иные.

<img width="685" height="98" alt="image" src="https://github.com/user-attachments/assets/d0df4f88-c6a2-4360-a35f-a4d478253dd3" />


<img width="339" height="440" alt="NOISE TABLE EARLY" src="https://github.com/user-attachments/assets/61c236ea-bd05-435f-830e-792d003a94f0" />


## DPCM

В ранней ревизии в схеме DPCM FREQ LFSR  сигнал RES не влияет на управление перезагрузкой сдвигового регистра LFSR.

![FREQ_DPCM_DIFF](https://github.com/user-attachments/assets/bf5e8b10-4419-4629-bdb6-3106e1f7ae9f)

## OAM DMA 

В ранней ревизии триггер START DMA не обнуляется сигналом RES (дополнительный вход отсуствует).

![0002](/BreakingNESWiki/imgstore/apu/old_2a03/0002.png)

## ACLK Generator

Еще отличие в делителе АЦЛК.  Сигнал RES не влияет на делитель клока. (отсуствует дополнительный вход NOR)

![0003](/BreakingNESWiki/imgstore/apu/old_2a03/0003.png)

## PHI0 Divider

Делитель раннего 2а03 отличается измененной скважностью сигнала М2, 15/24 вместо 17/24. Схемотехнически это делается очень просто:
берется сигнал для м2 c SR3, тогда как в 2a03G этот сигнал идет от SR4.

![div_letterless](https://github.com/user-attachments/assets/a60ee82e-b434-4ef7-9ae6-aeb1b0de0343)
![wawe_divs](https://github.com/user-attachments/assets/6a49a09d-85b6-4ae3-b257-1cc82278e72d)
![2a03 letter div](https://github.com/user-attachments/assets/2aefecfd-ad24-488f-84de-69c27f7f5487)

## DEBUG

Данный чип не имеет отладочных регистров и их вспомогательных цепей, поэтому сигнал LOCK и его регистр отсуствует
Из этого также следует, что выходной счетчик треугольного канала не имеет DEBUG режима и входы для записи W401A имеются но сам сигнал W401A подключен на землю.

<img width="625" height="693" alt="triangle debug erly" src="https://github.com/user-attachments/assets/5f6ed8ec-c0bd-4a5c-b7b8-4936dc26a297" />

