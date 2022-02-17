# LFO

![apu_locator_lfo](/BreakingNESWiki/imgstore/apu/apu_locator_lfo.jpg)

Low-frequency oscillator (LFO) или Frame Counter - это специальный таймер внутри APU, который по определению работает на сравнительно низкой частоте, приближенной к кадровой частоте PPU.

Назначение этого устройства заключается в снабжении программиста инструментом для добавления периодичных действий в игровую программу, повторяющихся примерно каждый кадр.

Возможности LFO:
- Режимы работы PAL/NTSC
- Генерирование прерываний
- Тактирование остальных тональных генераторов APU низкочастотными сигналами (/LFO1, /LFO2)
- Формирование внутреннего тактового сигнала ACLK (APU CLK), на базе тактовой частоты 6502 CPU

## Программная модель

LFO управляется регистром $4017 (write-only):
- $4017\[6\]: маскирует прерывание от LFO (1-LFO interrupt disable, 0-enable)
- $4017\[7\]: Запись в этот бит выбирает режим NTSC/PAL (0/1).

Разряд регистра $4015\[6\] содержит статус прерывания.

## Генератор ACLK

![lfo_aclk_gen_tran](/BreakingNESWiki/imgstore/apu/lfo_aclk_gen_tran.jpg)

## Управление LFO

![lfo_control_tran](/BreakingNESWiki/imgstore/apu/lfo_control_tran.jpg)

- /R4015 и W4017: приходят из селектора регистров при чтении $4015 и записи в $4017 регистры соответственно
- D6 и D7: 6й и 7й биты внутренней шины данных
- /LFO1 и /LFO2: выходные низкочастотные сигналы
- DMCINT: прерывание от DPCM
- INT: общий сигнал прерывания от LFO или DPCM
- RES: внутренний сигнал сброса (получается из контакта /RES)

## Счетчик LFO

![lfo_counter_tran](/BreakingNESWiki/imgstore/apu/lfo_counter_tran.jpg)

## Управление счетчиком LFO

![lfo_counter_control_tran](/BreakingNESWiki/imgstore/apu/lfo_counter_control_tran.jpg)
