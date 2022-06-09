# Common

All sorts of general documentation and schematics of the general outline.

## NMOS Cheat Sheet

Typical NMOS circuits. (Logisim Evolution)

## PPUPlayer

Standalone PPU test circuit. (Logisim 2.7.1)

![PPUPlayer_All.png](PPUPlayer_All.png)

![PPUPlayer_NTSC.png](PPUPlayer_NTSC.png)

PPU RegDump entries format:

```c++
#pragma pack(push, 1)
struct PPULogEntry
{
	uint32_t	pclkDelta;	// Delta of previous PCLK counter value at the time of accessing to the register
	uint8_t 	reg; 		// PPU register index (0-7) + Flag (msb - 0: write, 1: read)
	uint8_t 	value;		// Written value. Not used for reading.
	uint16_t	padding;	// Not used (yet?)
};
#pragma pack(pop)
```
