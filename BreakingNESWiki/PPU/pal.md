# PAL PPU

Данный раздел содержит описание отличий в схемах версии PAL PPU (RP2C07) от референсной NTSC PPU (RP2C02).

## FSM

Found differences from NTSC PPU:

- Significantly different EVEN/ODD circuitry (located to the right of the V PLA). The signal to the sprite logic is not yet clear from this circuit
- Slightly different logic for clearing H/V counters
- Bit V0 for the phase generator comes out of the VCounter (see VideoOut schematic)
- BLACK and PICTURE signals are processed in a special way for PAL (with slight differences)
- H/V Decoders are also different (see [Декодер](hv_dec.md))

All other parts (Horizontal and vertical FSM logic, register selection circuit, H/V counters) are the same as NTSC PPU.

## Video Out

Of the notable differences from the NTSC version of the PPU:

- The color decoder is twice as big (due to the peculiarity of the PAL phase alteration)
- In addition, the V0 bit from the VCounter comes on the decoder to determine the parity of the current line (for phase alteration)
- The phase shifter is matched to a doubled decoder
- The PICTURE signal undergoes additional processing (DLATCH delay)
- DAC, Emphasis and Luma Decoder circuits are the same as NTSC

## Regs

Also found additional logic for processing the `BLACK` control signal ("rendering disabled").

Of the notable differences:

- The `/SLAVE` signal goes through 2 additional inverters for amplification
- The B/W signal goes by roundabout ways through the multiplexer
- The two signals O8/16 and I1/32 are output in inverse logic (there are additional inverters for them in the Data Reader)
- Additionally, the BLACK signal processing logic is screwed on
- The output of the VBL control signal is slightly different (an additional cutoff transistor is used which is not present in the NTSC PPU)

## Sprite Logic

В целом отличия минимальные, но есть ньюансы. Все различия отмечены восклицательным знаком.

- В логике компаратора изменений не обнаружено
- В схеме управления сравнением (самая нижняя) только одно мелкое изменение, связанное с тем, что сигнал O8/16 в PAL PPU уже в инверсной логике, поэтому инвертор для него не требуется
- Схемы разрядов счетчиком (OAM Counter и OAM2 Counter) изменены таким образом, что на выходе отсутствует инвертор. Поэтому выходы (индекс для доступа к памяти OAM) в прямой логике (`OAM0-7`), а не в инверсной как в NTSC PPU (`/OAM0-7`)
- Отличается схема обработки сигнала BLNK (находится чуть выше OAM2 Counter)
- Схема управления OAM Counter для получения контрольного сигнала `OMSTEP` дополнительно модифицирована сигналом `ZOMG_PAL`, который приходит со схемы EVEN/ODD (эта схема находится правее V PLA).

Ну и основное отличие: вместо обычного W3 Enabler, который используется в NTSC PPU используется целая большая схема, которая находится в самом верху, левее RW Decoder. Она формирует сигнал `W3'` аналогичный NTSC PPU, но в PAL PPU он проходит через линию задержки из DLatch.

## Data Reader

Для инверсных сигналов `#O8/16` и `#I1/32` добавлены 2 инвертора, в местах где эти сигналы заходят в схему.

|PAL|NTSC|
|---|---|
|![o816_inv](/BreakingNESWiki/imgstore/ppu/pal/o816_inv.jpg)|![o816_orig](/BreakingNESWiki/imgstore/ppu/pal/o816_orig.jpg)|
|![ppu_locator_dataread](/BreakingNESWiki/imgstore/ppu/pal/i132_inv.jpg)|![ppu_locator_dataread](/BreakingNESWiki/imgstore/ppu/pal/i132_orig.jpg)|

## Interconnects

Смотри [Межсоединения](rails.md)
