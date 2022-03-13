# Famicom

List of motherboard revisions:

|Board|Description|
|---|---|
|HVC-CPU-01| |
|HVC-CPU-02| |
|HVC-CPU-03| |
|HVC-CPU-04| |
|HVC-CPU-05| |
|HVC-CPU-06| |
|HVC-CPU-07| |
|HVC-CPU-08| |
|HVC-CPU-GPM-02a| |
|HVC-CPU-GPM-02b| |
|HVC-CPU-GPM-02c| |
|HVC-CPU-GPM-02d| |
|HVC-CPU-GPM-02e| |
|HVC-CPU-GPM-02f| |
|HVC-CPU-GPM-02g| |
|HVC-CPU-GPM-02h| |
|HVC-CPU-GPM-02i| |
|HVC-CPU-GPM-02j| |
|HVC-CPU-GPM-02k (?)| |

TBD: Specify significant differences between revisions, if possible. In terms of logic, there shouldn't be much change.

Source: http://jpx72web.blogspot.com/2016/11/famicom-av-mod-new.html

## Generic Famicom

A "common" logic diagram is presented for all revisions where no JIO chip is used.

![fami_logisim](/BreakingNESWiki/MB/imgstore/fami_logisim.jpg)

- The pull-up resistors (RM1) pull up to `1` wire if they have `z` on them (especially the interrupts `/IRQ` and `/NMI`).
- The RESET SW button takes a value of `0` when pressed to initiate `/RES`. In the original circuit the duration of the /RES level is determined by the capacitor.

## 40H368

This IC is a TriState array:

![40H368](/BreakingNESWiki/MB/imgstore/40H368.jpg)

## LS139

Coupled demultiplexers with inverse outputs:

![LS139](/BreakingNESWiki/MB/imgstore/LS139.jpg)

Used to control the Chip Select depending on the address value.

## LS373

8-bit latch for PPU A/D bus multiplexing:

![LS373](/BreakingNESWiki/MB/imgstore/LS373.jpg)

Schematic of the latch:

![LS373_Transparent_Latch](/BreakingNESWiki/MB/imgstore/LS373_Transparent_Latch.jpg)

## JIO

In some versions of the Famicom all the small ICs and pull-up resistors are combined into a single IC.

TBD: The 32-pin chip that holds all the smaller chips.

TBD: Circuit with a JIO chip.

Source: https://forums.nesdev.org/viewtopic.php?t=16764

## Sound

![fami_sound](/BreakingNESWiki/MB/imgstore/fami_sound.png)

The inverter from U7 is used as an amplifier with a negative feedback resistor.

## Games using a microphone

https://www.youtube.com/watch?v=Mv7-5z1Itqg
