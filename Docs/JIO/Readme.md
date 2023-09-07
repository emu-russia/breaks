# JIO Chip

Source: https://gammy.void.nu/nesrgb/NES_pio_pinout.txt (with minor corrections)

There is a document I made for giving information about the custom Nintendo PIO chip found in the New Famicom (HVC-101). This replace the U3 (139), and the U7/U8 (368).

Chip Text:

```
    U3 JIO
     ___________________
    |   Nintendo        |
    |>  JIO A  BU3270S  |
    |   925  H39        |
     ___________________
```

Pinout:

```
            ________
      GND -|01 \/ 32|- +5v
       NC -|02    31|- NC
       M2 -|03    30|- NC
      A15 -|04    29|- /ROMSEL
      A14 -|05    28|- /DBE
      A13 -|06    27|- CS (U1)
    P1-D0 -|07    26|- INV-2I
    P0-D0 -|08    25|- INV-2O
    P1-D1 -|09    24|- D0
    P0-D1 -|10    23|- D1
    P1-D2 -|11    22|- /INP0
      +5v -|12    21|- /INP1
    P1-D3 -|13    20|- D2
    P1-D4 -|14    19|- D3
      GND -|15    18|- D4
   INV-1I -|16    17|- INV-1O
            ________
```

- INV-1I/O (16-17) = Audio Inverter
- INV-2I/O (25-26) = PA13 Inverter
- They are three unused pins maybe there are P0-D2,D3,D4 but I don't realy belive that. If this chip is also found in the Redesign NES (_toploader_), maybe someone can verify this.

Jacques Gagnon
darthcloud(at)gmail.com
