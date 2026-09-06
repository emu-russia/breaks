# Временные диаграммы

В данном разделе собраны временные развёртки сигналов для разных модулей PPU. Инженеры-схемотехники любят такое вдумчиво поизучать.

Исходники всех тестов, с помощью которых были сделаны диаграммы находятся в папке `/HDL/Framework/Icarus`.

## PCLK

Делитель CLK на 4 (PCLK) и фазовый расщепитель:

![pclk](/BreakingNESWiki/imgstore/ppu/waves/pclk.png)

## H/V Counters

Счётчики H/V в пределах одной строки:

![hv_counters](/BreakingNESWiki/imgstore/ppu/waves/hv_counters.png)

## H/V Decoders

Выходы PLA H/V декодеров:

![hv_decoders](/BreakingNESWiki/imgstore/ppu/waves/hv_decoders.png)

## FSM Delayed H Outputs

Задержанные выходы счётчика H (H0_D, H0_DD, H1_DD...):

![fsm_delayed_h](/BreakingNESWiki/imgstore/ppu/waves/fsm_delayed_h.png)

## FSM State Signals

Состояния внутри сканлайна:

![fsm_scan](/BreakingNESWiki/imgstore/ppu/waves/fsm_scan.png)

Состояния внутри VBlank:

![fsm_vblank](/BreakingNESWiki/imgstore/ppu/waves/fsm_vblank.png)

Обратите внимание, что для изображения со сканлайнами масштаб увеличен (это видно по изменению счётчика пикселей H), по сравнению с масштабом на картинке, где изображен VBlank (это видно по изменению счётчика строк V).

## Object Evaluate

## OAM Comparator

## SpriteH Signals

## Object FIFO Lane

## VRAM Controller

Циклы записи/чтения $2007:

![vram_control](/BreakingNESWiki/imgstore/ppu/waves/vram_control.png)

## Video Output

Демонстрация выхода фазовращателя, с фазами, расставленными в соответствии с цветами палитры PPU (рамкой выделен 1 "пиксель"):

![phase_shifter](/BreakingNESWiki/imgstore/ppu/waves/phase_shifter.png)

![phase_shifter2](/BreakingNESWiki/imgstore/ppu/waves/phase_shifter2.png)

Демонстрация выбора 1 из 12 фазы цвета (сигнал `/PZ`):

![phase_color](/BreakingNESWiki/imgstore/ppu/waves/phase_color.png)