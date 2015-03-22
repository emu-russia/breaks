# General information #

6502 schematics is divided on two major parts : "top" and "bottom", as found on 6502 blueprints:

![http://ogamespec.com/imgstore/whc507fbde796d65.jpg](http://ogamespec.com/imgstore/whc507fbde796d65.jpg) ![http://ogamespec.com/imgstore/whc507fbdf01fb25.jpg](http://ogamespec.com/imgstore/whc507fbdf01fb25.jpg)
<br>Source: <a href='http://visual6502.org/wiki/index.php?title=650X_Schematic_Notes'>http://visual6502.org/wiki/index.php?title=650X_Schematic_Notes</a>

Дональд Хенсон зажал схемы, поэтому качество сканов очень низкое и разобрать в деталях их невозможно.<br>
<br>
<b>Top part components</b>
<ul><li>Instruction register (IR)<br>
</li><li>Cycle counter (T)<br>
</li><li>PLA decoder<br>
</li><li>Predecoder<br>
</li><li>Random logic (heavy tangle) including flags<br>
</li><li>Miscellaneous logic: IRQ, NMI, reset handling and output pads</li></ul>

<b>Bottom part components</b>
<ul><li>Address bus outputs<br>
</li><li>Data latch and read/write tri-state logic<br>
</li><li>Registers X, Y, S<br>
</li><li>Program Counter<br>
</li><li>ALU</li></ul>

Bottom part is controlled by top part through special control lines - drivers.<br>
<br>
<h1>Family photo</h1>

In wild nature:<br>
<br>
<img src='http://ogamespec.com/imgstore/resized_whc503b820d9d535.jpg' />

Cooked:<br>
<br>
<a href='http://breaknes.com/files/6502/6502.jpg'><img src='http://breaknes.com/files/6502/6502_sm.jpg' /></a>

<h1>Top part</h1>

<table><thead><th> <img src='http://ogamespec.com/imgstore/whc507fc09d29765.jpg' /> </th><th> <img src='http://ogamespec.com/imgstore/whc507fc0aa43d45.jpg' /> </th><th> <img src='http://ogamespec.com/imgstore/whc507fc0b53df85.jpg' /> </th></thead><tbody>
<tr><td> Instruction Register (IR) </td><td> T-counter </td><td> PLA </td></tr></tbody></table>

<table><thead><th> <img src='http://ogamespec.com/imgstore/whc507fc0bfebcc5.jpg' /> </th><th> <img src='http://ogamespec.com/imgstore/whc507fc0cb92ee5.jpg' /> </th><th> <img src='http://ogamespec.com/imgstore/whc507fc0e0a1945.jpg' /> </th></thead><tbody>
<tr><td> Predecode (PD) </td><td> Random Logic </td><td> Interrupt handling </td></tr></tbody></table>

<table><thead><th> <img src='http://ogamespec.com/imgstore/whc507fc0d65c3e5.jpg' /> </th></thead><tbody>
<tr><td> Misc&pads </td></tr></tbody></table>

Images (should be) clickable<br>
<br>
<h1>Bottom part</h1>

<table><thead><th> <img src='http://ogamespec.com/imgstore/whc507fc498cc8c5.jpg' /> </th><th> <img src='http://ogamespec.com/imgstore/whc507fc49f6bde5.jpg' /> </th><th> <img src='http://ogamespec.com/imgstore/whc507fc4a6c99e5.jpg' /> </th></thead><tbody>
<tr><td> Address Bus </td><td> Data latch / data bus </td><td> Registers Y, X, S </td></tr></tbody></table>

<table><thead><th> <img src='http://ogamespec.com/imgstore/whc507fc4c14ba45.jpg' /> </th><th> <img src='http://ogamespec.com/imgstore/whc507fc4b07e6c5.jpg' /> </th><th> <img src='http://ogamespec.com/imgstore/whc507fc4b897d05.jpg' /> </th></thead><tbody>
<tr><td> ALU </td><td> Program Counter High (PCH) </td><td> Program Counter Low (PCL) </td></tr></tbody></table>

Images (should be) clickable