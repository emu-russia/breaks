# Генератор тайминга

![apu_locator_clkgen](/BreakingNESWiki/imgstore/apu/apu_locator_clkgen.jpg)

Генератор тайминга содержит в своем составе следующие компоненты:
- Генератор ACLK
- Программный таймер (известный также как `Frame Counter`)

## Генератор ACLK

Генератор ACLK используется для формирования внутреннего тактового сигнала ACLK (APU CLK), на базе тактовой частоты 6502 CPU.

![aclk_gen_tran](/BreakingNESWiki/imgstore/apu/aclk_gen_tran.jpg)

![ACLK_Gen](/BreakingNESWiki/imgstore/apu/ACLK_Gen.jpg)

## Программный таймер

Из официальной документации известно что этот компонент называется `Soft CLK`.

Назначение этого устройства заключается в снабжении программиста инструментом для добавления периодичных действий в игровую программу, повторяющихся примерно каждый кадр.

Возможности Soft CLK:
- Режимы работы (обычный и расширенный)
- Генерирование прерываний
- Тактирование остальных тональных генераторов APU низкочастотными сигналами (`/LFO1`, `/LFO2`)

### Программная модель

Soft CLK управляется регистром $4017 (write-only):
- $4017\[6\]: Маскирует прерывание (1: interrupt disable, 0: enable)
- $4017\[7\]: Запись в этот бит выбирает режим (0: обычный режим, 1: расширенный режим)

Разряд регистра $4015\[6\] содержит статус прерывания.

### Управление Soft CLK

![softclk_control_tran](/BreakingNESWiki/imgstore/apu/softclk_control_tran.jpg)

- /R4015 и W4017: приходят из селектора регистров при чтении $4015 и записи в $4017 регистры соответственно
- D6 и D7: 6й и 7й биты внутренней шины данных
- /LFO1 и /LFO2: выходные низкочастотные сигналы
- DMCINT: прерывание от DPCM
- INT: общий сигнал прерывания от Soft CLK или DPCM
- RES: внутренний сигнал сброса (получается из контакта /RES)

### Счётчик Soft CLK

![softclk_counter_tran](/BreakingNESWiki/imgstore/apu/softclk_counter_tran.jpg)

### Управление счётчиком Soft CLK

![softclk_counter_control_tran](/BreakingNESWiki/imgstore/apu/softclk_counter_control_tran.jpg)
