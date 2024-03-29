# Обзор APU

:warning: В настоящий момент на нашей Wiki происходит массовое перименование сигналов /ACLK=ACLK1 и ACLK=/ACLK2, в соответствии с Visual2A03, чтобы не было недоразумений. Просьба отнеститсь с пониманием, если где-то найдёте старые обозначения сигналов (/ACLK и ACLK). Со временем всё переименуется.

**APU** - неофициальное название специализированного центрального процессора NES.

Официальное название - просто CPU, но мы будем придерживаться неофициального термина.

Разработкой микросхемы занималась [Ricoh](../Ricoh.md), кодовое обозначение - RP 2A03 для NTSC и RP 2A07 для PAL.

![APU](/BreakingNESWiki/imgstore/apu/APU.jpg)

В состав APU входят:
- Ядро процессора MOS 6502, с отключенной схемой десятичной коррекции (BCD)
- Делитель входной тактовой частоты
- Программный таймер ("Frame counter")
- Звуковые генераторы: 2 прямоугольных канала, треугольный, генератор шума, Delta PCM
- DMA для выборки DPCM-сэмплов
- ЦАП для преобразования цифровых выходов синтезированного звука в аналоговые уровни
- DMA для отправки спрайтов (жестко настроено на внешний регистр PPU $2004) и небольшой специализированный DMA-контроллер
- Порты ввода-вывода (которые в NES обычно используются для получения данных с контроллеров)
- Отладочные регистры (недоступные в Retail-консолях)

Наличие ЦАП переводит APU в разряд полу-аналоговых схем.

Также необходимо принимать в расчёт тот факт, что ядро 6502, входящее в состав APU находится под управлением DMA-контроллера и соответственно является "рядовым" устройством, разделяющим шину с другими устройствами, использующими DMA.

![apu_blocks](/BreakingNESWiki/imgstore/apu/apu_blocks.jpg)

## Примечание по транзисторным схемам

Транзисторные схемы каждого компонента напилены на составные части, чтобы не занимали много места.

Чтобы вы не заблудились, каждый раздел включает в начале специальный "локатор", где отмечено приблизительное расположение изучаемого компонента.

Пример локатора:

![apu_locator_dma](/BreakingNESWiki/imgstore/apu/apu_locator_dma.jpg)

## Примечание по логическим схемам

Логические схемы в основном сделаны в программе Logisim. Для обозначения DLatch применяется такой элемент:

|DLatch (транзисторная схема)|DLatch (логический эквивалент)|
|---|---|
|![dlatch_tran](/BreakingNESWiki/imgstore/dlatch_tran.jpg)|![dlatch_logic](/BreakingNESWiki/imgstore/dlatch_logic.jpg)|

Для удобства логический вариант DLatch имеет два выхода (`out` и `/out`), так как текущее значение DLatch (out) нередко используется как вход для операции NOR.
