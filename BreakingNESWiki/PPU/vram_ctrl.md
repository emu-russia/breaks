# Контроллер VRAM

![ppu_locator_vram_ctrl](/BreakingNESWiki/imgstore/ppu/ppu_locator_vram_ctrl.jpg)

Схема представляет собой "вспомогательный мозг" нижней части PPU для управления интерфейсом VRAM.

Кроме этого в состав контроллера также входит READ BUFFER (RB) - промежуточное хранилище данных для обмена с VRAM.

## Транзисторная схема

<img src="/BreakingNESWiki/imgstore/ppu/vram_control_tran.jpg" width="1000px">

Анатомически схема поделена на 2 большие половинки, левая больше связана с управляющим сигналом `WR`, а правая с `RD`.
В состав каждой половинки входит RS-триггер и линия задержки, которая автоматически устанавливает триггер.

Схема выдает наружу ряд контрольных линий:
- RD: на выход /RD
- WR: на выход /WR
- /ALE: на выход ALE (ALE=1, когда шина AD работает как адресная, ALE=0, когда AD работает как шина данных)
- TSTEP: на схему DATAREAD, позволяет TV/TH счетчикам выполнить инкремент
- DB/PAR: на схему DATAREAD, соединяет внутреннюю шину PPU DB с псевдорегистром PAR (PPU address register)
- PD/RB: соединяет внешнюю шину PPU с read buffer-ом, для загрузки в него нового значения
- TH/MUX: направить счетчик TH на вход MUX, в результате чего это значение уйдет в палитру в качестве индекса.
- XRB: включает tri-state логику, которая отсоединяет PPU read buffer от внутренней шины данных.

## Логическая схема

<img src="/BreakingNESWiki/imgstore/ppu/vram_control_logisim.jpg" width="1000px">

Чтобы сказать что-то более конкретное, нужно вначале разобрать остальные узлы PPU.

TBD.

## Read Buffer (RB)

Находится правее [OAM FIFO](fifo.md).

|Транзисторная схема|Логическая схема|
|---|---|
|![ppu_readbuffer](/BreakingNESWiki/imgstore/ppu/ppu_readbuffer.jpg)|![ppu_logisim_rb](/BreakingNESWiki/imgstore/ppu/ppu_logisim_rb.jpg)|
