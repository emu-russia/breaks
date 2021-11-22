# Логика установки флагов

![6502_locator_flags_control](/BreakingNESWiki/imgstore/6502_locator_flags_control.jpg)

Схемы управления флагами для удобства разделены на две части:
- Промежуточные контрольные сигналы с декодера (выбор опкодов)
- Контрольные сигналы управления флагами

## Выбор опкодов

|![flags_control_tran1](/BreakingNESWiki/imgstore/flags_control_tran1.jpg)|![flags_control_tran2](/BreakingNESWiki/imgstore/flags_control_tran2.jpg)|![flags_control_tran3](/BreakingNESWiki/imgstore/flags_control_tran3.jpg)|
|---|---|---|

|Сигнал|Выходы декодера|Связанные инструкции|
|---|---|---|
|!POUT|98,99|Работа с флагами наружу (сохранение контекста после прерывания, инструкция `PHP`)|
|/CSI|108|Инструкции `CLI`, `SEI`|
|BIT1|109|Инструкция `BIT`, цикл T1|
|X110|110|110-й выход декодера (инструкции `CLC`, `SEC`), для удобства оставленный в этих схемах. Он просто идёт дальше на основную схему управления флагами.|
|AVR/V|112|Инструкции `ADC`, `SBC`|
|/ARIT|107,112,116-119|Матрица инструкций сравнения (`CMP`, `CPX`, `CPY`) и сдвига (`ASL`, `ROL`), где используются флаги|
|BIT0|113|Инструкция `BIT`, цикл T0|
|!PIN|114,115|Работа с флагами внутрь (загрузка контекста после `RTI`, инструкция `PLP`|
|/CSD|120|Инструкции `CLD`, `SED`|
|CLV|127|Инструкция CLV|

Все эти контрольные сигналы являются промежуточными и нигде кроме схемы управления флагами больше не используются.

## Управление флагами

|![flags_control_tran1](/BreakingNESWiki/imgstore/flags_control_tran4.jpg)|![flags_control_tran1](/BreakingNESWiki/imgstore/flags_control_tran5.jpg)|
|---|---|
