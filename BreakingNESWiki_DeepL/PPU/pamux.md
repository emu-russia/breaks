# PPU Address Multiplexer (PAMUX)

![ppu_locator_pamux](/BreakingNESWiki/imgstore/ppu/ppu_locator_pamux.jpg)

![PAMUX](/BreakingNESWiki/imgstore/ppu/PAMUX.png)

The patent doesn't mention this circuit in any way; it's assumed to be contained in the "sausage" shown in this diagram from the patent:

![pamux_patent](/BreakingNESWiki/imgstore/ppu/pamux_patent.png)

The address multiplexer stores the final value for the external address bus (`/PA0-13`) (14 bits).

Sources for writing to PAMUX output latches:
- A pattern address (`PAD0-12`) from PAR (13 bit)
- The value from the data bus (`DB0-7`) (8 bit)
- Value from tile counters. Tile counters, in turn, are loaded from scroll registers.

## PAMUX Control

The control circuit is designed to select one of the sources for writing into the output latches of the multiplexer.

![ppu_dataread_pamux_control](/BreakingNESWiki/imgstore/ppu/ppu_dataread_pamux_control.jpg)

![PamuxControl](/BreakingNESWiki/imgstore/ppu/PamuxControl.png)

## PAMUX Outputs

![ppu_dataread_pamux_low](/BreakingNESWiki/imgstore/ppu/ppu_dataread_pamux_low.jpg)

![ppu_dataread_pamux_high](/BreakingNESWiki/imgstore/ppu/ppu_dataread_pamux_high.jpg)

![PamuxLowBit](/BreakingNESWiki/imgstore/ppu/PamuxLowBit.png)

![PamuxHighBit](/BreakingNESWiki/imgstore/ppu/PamuxHighBit.png)