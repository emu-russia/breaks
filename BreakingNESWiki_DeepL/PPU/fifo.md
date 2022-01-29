# OAM FIFO

Location on a chip:

![OAM_FIFO_preview](/BreakingNESWiki/imgstore/OAM_FIFO_preview.jpg)

The sprite FIFO is used to temporarily store up to 8 sprites that hit the current row.

It does not actually store the entire sprite, but only one sprite line (8 pixels), the priority bit, and 2 bits of overall color.

Note on the term "FIFO": in fact, this component is not explicitly called that anywhere, but the authors considered it convenient to use this term in the perspective of the order in which sprites are displayed on the screen.

## How it works

The FIFO consists of 3 parts: a reverse pixel counter, sprite attributes and a paired shift register.

The down-counter is loaded by the horizontal offset of the sprite and counts down to 0 at the same time as the pixels are rendered. Once the counter reaches 0, it means that you can start rendering the pixels of the sprite.

The attributes store 2 bits of the total color of the sprite and 1 bit of the priority over the background. These values are used for the entire output line.

The shift register is used to "push out" the next pixel in the sprite. It is paired because 2 bits of color are used for the pixel.

The sprite FIFO is loaded from the special temporary OAM memory (the one which is 32 bytes), during the horizontal synchronization (HBlank).

## Transistor Circuit

The transistor circuits show only the sprite #0 pipelines. All other pipelines differ only in the name of the signals.

### Countdown Counter

The circuit shown is for sprite #0. For all others (1-7) you must replace the name of the 0/EN signals with x/EN.

![fifo_counter_control](/BreakingNESWiki/imgstore/fifo_counter_control.jpg)

![fifo_counter](/BreakingNESWiki/imgstore/fifo_counter.jpg)

![ppu_logisim_fifo_counter](/BreakingNESWiki/imgstore/ppu_logisim_fifo_counter.jpg)

### Pipeline Control

The circuit for sprite #0 is shown. For all others (1-7) the signal names 0/EN, 0/COL2, 0/COL3 and 0/PRIO must be changed to x/EN, x/COL2, x/COL3 and x/PRIO.

In addition the control lines H3'', H4'' and H5'' are used as follows for the different pipelines:

|Sprite number (pipeline)|Signal logic H3'', H4'' and H5''|
|---|---|
|0|H3'' H4'' H5''| 
|1|/H3'' H4'' H5''|
|2|H3'' /H4'' H5''|
|3|/H3'' /H4'' H5''|
|4|H3'' H4'' /H5''|
|5|/H3'' H4'' /H5''|
|6|H3'' /H4'' /H5''|
|7|/H3'' /H4'' /H5''|

![fifo_attr](/BreakingNESWiki/imgstore/fifo_attr.jpg)

### Paired Shift Register

The circuit shown is for sprite #0. For all others (1-7) you must replace the signal names 0/COL0 and 0/COL1 with x/COL0 and x/COL1.

![fifo_sr](/BreakingNESWiki/imgstore/fifo_sr.jpg)

TBD: The unsigned transistors receive the `EN` signal from the Pipeline control circuit.

### Sprite Priority

The priority circuit is in "sparse" layout. The individual pieces of this circuit are shown below.
Presumably the circuit works according to the principle of the majority element.

![fifo_prio0](/BreakingNESWiki/imgstore/fifo_prio0.jpg)

![fifo_prio1](/BreakingNESWiki/imgstore/fifo_prio1.jpg)

![fifo_prio2](/BreakingNESWiki/imgstore/fifo_prio2.jpg)

![fifo_prio3](/BreakingNESWiki/imgstore/fifo_prio3.jpg)

![fifo_prio4](/BreakingNESWiki/imgstore/fifo_prio4.jpg)

The result of the circuit operation (output) is the `SPR0HIT` signal, which goes to the corresponding Sprite 0 Hit circuit (see [multiplexer](mux.md))

### H. Inversion

![ppu_hinv](/BreakingNESWiki/imgstore/ppu_hinv.jpg)

HINV and HDIR are two complementary signals (they can never take the same value). In essence these two signals are one multiplexer control signal that selects between the two PD bus bits. If HINV = 1, it means that the PD bus is output in inverted to the T0-7 outputs. If HDIR = 1 it means that the PD bus is outputted in direct way to T0-7 outputs.

![ppu_logisim_hinv](/BreakingNESWiki/imgstore/ppu_logisim_hinv.jpg)

### Sprite H

It was also decided to include a small circuit for getting SHx values (Sprite H) as part of the FIFO. The circuit is above the multiplexer, but most of the SHx outputs are used only in the OAM FIFO (`SH2` is also used in the Data Reader).

![sprite_h](/BreakingNESWiki/imgstore/sprite_h.jpg)

![ppu_logisim_sprite_h](/BreakingNESWiki/imgstore/ppu_logisim_sprite_h.jpg)

:warning: The SH2/3/5/7 signals are actually in inverse logic, but you don't want to rename everywhere anymore.
