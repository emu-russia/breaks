# Временные диаграммы

В данном разделе собраны временные развёртки сигналов для разных модулей PPU. Инженеры-схемотехники любят такое вдумчиво поизучать.

Исходники всех тестов, с помощью которых были сделаны диаграммы находятся в папке `/HDL/Framework/Icarus`.

## PCLK

## H/V Counters

## H/V Decoders

## FSM Delayed H Outputs

## FSM State Signals

Состояния внутри сканлайна:

![fsm_scan](/BreakingNESWiki/imgstore/ppu/waves/fsm_scan.png)

Состояния внутри VBlank:

![fsm_vblank](/BreakingNESWiki/imgstore/ppu/waves/fsm_vblank.png)

Обратите внимание, что для изображения со сканлайнами масштаб увеличен (это видно по изменению счётчика пикселей H), по сравнению с масштабом на картинке, где изображен VBlank (это видно по изменению счётчика строк V).

## OAM Evaluate

## OAM Comparator

## SpriteH Signals

## PAR Control

## OAM FIFO Lane

## VRAM Controller
