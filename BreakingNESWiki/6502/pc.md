# Счетчик инструкций (PC)

![6502_locator_pc](/BreakingNESWiki/imgstore/6502_locator_pc.jpg)

Из-за 8-битной природы процессора его счетчик инструкций разделен на две 8-битные половины: PCL (Program Counter Low) и PCH (Program Counter High).

Кроме этого PCH также разделен на 2 половины: младшую часть разрядов (0-3) и старшую (4-7).

PCL:

|PCL 0-3|PCL 4-7|
|---|---|
|![pcl03_tran](/BreakingNESWiki/imgstore/pcl03_tran.jpg)|![pcl47_tran](/BreakingNESWiki/imgstore/pcl47_tran.jpg)|

PCH:

|PCH 0-3|PCH 4-7|
|---|---|
|![pch03_tran](/BreakingNESWiki/imgstore/pch03_tran.jpg)|![pch47_tran](/BreakingNESWiki/imgstore/pch47_tran.jpg)|

Схема отмеченная как "patch" на самом деле находится между контрольными выходами `ADL/PCL` и `#1/PC`.

В промежутках между разрядами PC можно встретить транзисторы для подзарядки шин ADL и ADH:

![adl_adh_precharge_tran](/BreakingNESWiki/imgstore/adl_adh_precharge_tran.jpg)

(На изображении показаны precharge транзисторы для ADH4 и ADL5. Остальные аналогично)

## PCL

## PCH
