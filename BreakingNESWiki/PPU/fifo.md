# OAM FIFO

Расположение на чипе:

![OAM_FIFO_preview](/BreakingNESWiki/imgstore/OAM_FIFO_preview.jpg)

Спрайтовый FIFO используется для временного хранения до 8 спрайтов, которые попали в текущую строку.

Хранится на самом деле не весь спрайт, а только одна его строка (8 пикселей), бит приоритета и 2 бита общего цвета.

From US patent 4824106:

![OAM_FIFO_pat](/BreakingNESWiki/imgstore/OAM_FIFO_pat.jpg)

```
The motion picture buffer memory 16 whose contents are rewritten during the horizontal blanking period also has the memory are capable of storing eight motion picture characters to be displayed on the next line, and, in the buffer memory 16, for each motion picture character, a horizontal position area (8 bits) 16-1, an attribute area (3 bits) 16-2 and a pair of shift registers (8 bits) 16-3 are allocated. The horizontal position are 16-1 stores a horizontal position data supplied from the temporary memory 15, and this area is structured in the form of a down-counter which downcount in accordance with the scanning along a horizontal line, and when the count has reached "0", the motion picture character is supplied as its output. The attribute area 16-2 stores a bit for determining the priority and two bits of color data and thus three bits in total among the attribute data stored in the temporary memory 15. Each of the shift registers 16-3 stores 8-bit data supplied as an output from the motion picture character pattern generator 12-1 in accordance with the character number of motion picture character in the temporary memory 15. The reason why a pair of shit registers 16-3 are provided in parallel is that a picture element is represented by two bits.
```

## Как это работает

FIFO состоит из 3х частей: обратного счетчика пикселей, атрибутов спрайта и спаренного сдвигового регистра.

Обратный счетчик загружается горизонтальным смещением спрайта и тикает вниз до 0, одновременно с рендерингом пикселей. Как только счетчик достигает 0, это означает что можно начинать выводить пиксели спрайта.

В атрибутах хранится 2 бита общей цветности спрайта и 1 бит приоритета над бекграундом. Эти значения используются для всей выводимой строки.

Сдвиговый регистр используется для "выталкивания" очередной точки спрайта. А спаренный он потому что для точки используется 2 бита цветности.

Загружается спрайтовый FIFO из специальной служебной области OAM (та которая 32 байта), во время горизонтальной синхронизации (hblank).

## Транзисторная схема

<img src="/Docs/PPU/OAM_FIFO.jpg" width="1000px">
