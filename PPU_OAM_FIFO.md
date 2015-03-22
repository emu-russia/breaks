# Introduction #

Расположение на чипе :

<img src='http://breaknes.com/files/PPU/OAM_FIFO_preview.jpg'>

Спрайтовый FIFO используется для временного хранения до 8 спрайтов, которые попали в текущую строку.<br>
Хранится на самом деле не весь спрайт, а только одна его строка (8 пикселей), бит приоритета и 2 бита общего цвета.<br>
<br>
From US patent 4824106 :<br>
<br>
<img src='http://breaknes.com/files/PPU/OAM_FIFO_pat.jpg'>

<blockquote>The motion picture buffer memory <b>16</b> whose contents are rewritten during the horizontal blanking period also has the memory are capable of storing eight motion picture characters to be displayed on the next line, and, in the buffer memory <b>16</b>, for each motion picture character, a horizontal position area (8 bits) <b>16-1</b>, an attribute area (3 bits) <b>16-2</b> and a pair of shift registers (8 bits) <b>16-3</b> are allocated. The horizontal position are <b>16-1</b> stores a horizontal position data supplied from the temporary memory <b>15</b>, and this area is structured in the form of a down-counter which downcount in accordance with the scanning along a horizontal line, and when the count has reached "0", the motion picture character is supplied as its output. The attribute area <b>16-2</b> stores a bit for determining the priority and two bits of color data and thus three bits in total among the attribute data stored in the temporary memory <b>15</b>. Each of the shift registers <b>16-3</b> stores 8-bit data supplied as an output from the motion picture character pattern generator <b>12-1</b> in accordance with the character number of motion picture character in the temporary memory <b>15</b>. The reason why a pair of shit registers <b>16-3</b> are provided in parallel is that a picture element is represented by two bits. <code>*</code>munch<code>*</code> <code>*</code>munch<code>*</code> <code>*</code>munch<code>*</code> I understood....</blockquote>

<h1>Как это работает</h1>

FIFO состоит из 3х частей : обратного счетчика пикселей, атрибутов спрайта и спаренного сдвигового регистра.<br>
<br>
Обратный счетчик загружается горизонтальным смещением спрайта и тикает вниз до 0, одновременно с рендерингом пикселей. Как только счетчик достигает 0, это означает что можно начинать выводить пиксели спрайта.<br>
<br>
В атрибутах хранится 2 бита общей цветности спрайта и 1 бит приоритета над бекграундом. Эти значения используются для всей выводимой строки.<br>
<br>
Сдвиговый регистр используется для "выталкивания" очередной точки спрайта. А спаренный он потому что для точки используется 2 бита цветности.<br>
<br>
Загружается спрайтовый FIFO из специальной служебной области OAM (та которая 32 байта), во время горизонтальной синхронизации (hblank).