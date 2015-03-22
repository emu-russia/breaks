<img src='http://breaknes.com/images/dolbanem_6502.jpg'>

<h1>Overview</h1>

<b>English</b>

This is my NES emu made under influence of hard Breakbeat sounds.<br>
<br>
<b>Russian</b>

Цели и задачи этого эмулятора - сэмулировать NES и её аналоги (Famicom, Dendy) как можно точнее, и не просто на "тактовом уровне", а ещё ниже - на уровне логики, симулируя работу транзисторов.<br>
<br>
Конечно, мы не учитываем квантовые эффекты, но используемые методы достаточно точны, чтобы передать истинный дух 8-битной эры.<br>
<br>
Как же такое возможно ?<br>
<br>
Эму-сцена доооолго созревала. Но в какой-то момент смышлеными парням с Visual6502 надоело терпеть и они сказали: "Какого черта. Давай кислотой расплавим процессор и сделаем качественные фотки кристалла". Что из этого получилось можно посмотреть тут : <a href='http://visual6502.org'>http://visual6502.org</a>

Процессор, с которого они начали - это 6502. Ребята большие поклонники приставки Atari 2600, в которой используется этот процессор.<br>
<br>
К счастью их работа по цепочке вызвала общий интерес, и качественные фотки чипов посыпались одна за другой. Как оказалось это сделать совсем не сложно, достаточно иметь хороший микроскоп, немного кислоты и терпения :)<br>
<br>
На настоящий момент мы обладаем качественными фотографиями центрального процессора 6502 (который используется в процессоре NES), а также фотографиями двух основных чипов NES - 2a03(APU) и 2c02(PPU).<br>
<br>
Используя знания в механизме работы NMOS-микросхем и имея их послойные схемы, можно восстановить логику их работы на транзисторном уровне.<br>
<br>
Чем собственно и занимается этот проект.<br>
<br>
<img src='http://breaknes.com/images/wys/f13daa895e422fb6b1c72b90d6b71cfb.jpg' />

<h1>Progress</h1>

<ul><li>6502 schematics (<b>DONE</b>)<br>
</li><li>6502 simulation (<i>almost DONE</i>)<br>
</li><li>compare 6502 core with 2a03 to find difference and simulate it<br>
</li><li>6502 core integration in some freeware emulator for testing<br>
</li><li>2a03 schematics (<b>DONE</b>)<br>
</li><li>2a03 simulation<br>
</li><li>NSF player with own 6502 core, to test sound output<br>
</li><li>2c02 schematics (<b>DONE</b>)<br>
</li><li>2c02 simulation (<i>partial</i>)<br>
</li><li>TV signal output<br>
</li><li>joypads simulation<br>
</li><li>some cartridge boards simulation<br>
</li><li>compare PAL versions of NES chips to NTSC<br>
</li><li>compare Dendy chips with NES to find difference<br>
</li><li>join all pieces together to have fun</li></ul>

<h1>Some images</h1>

<table><thead><th> <img src='http://breaknes.com/files/6502/6502_med.jpg'> </th><th> <img src='http://breaknes.com/files/APU/2A03_med.jpg'> </th><th> <img src='http://ogamespec.com/imgstore/whc50a80a2367468.jpg'> </th></thead><tbody>
<tr><td> <a href='6502_Overview.md'>MOS6502 D</a> core, done </td><td> <a href='G2A03.md'>G2A03</a> (APU), ready for simulation </td><td> <a href='G2C02.md'>G2C02</a> (PPU), ready for simulation </td></tr>