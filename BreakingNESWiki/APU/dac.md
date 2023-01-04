# ЦАП

![apu_locator_dac](/BreakingNESWiki/imgstore/apu/apu_locator_dac.jpg)

ЦАП не использует отдельные выводы для "аналогового" VDD/GND, а использует общие VDD/GND. Для разводки питания ЦАП используется топология типа "звезда".

@ttlworks сделал хорошее описание ЦАП:

![APU_2_dacs](/BreakingNESWiki/imgstore/apu/ttlworks/APU_2_dacs.png)

Source: http://forum.6502.org/viewtopic.php?p=94693#p94693

## Терминалы AUX A/B

Внутри процессора площадки для терминалов никак не нагружены и представляют собой просто пады.

Снаружи на плате обычно стоят небольшие резисторы подтяжки на GND (обычно 100 Ом на каждом выходе AUX).

## Square 0/1

![dac_square_tran](/BreakingNESWiki/imgstore/apu/dac_square_tran.jpg)

Замеры максимальной амплитуды ЦАП AUX A:
- Чип RP2A03G
- Внешнее сопротивление 75 Ом (необычное, но не сильно влияет на суть происходящего)
- Использовалась демка dac_square.nes (https://github.com/bbbradsmith/nes-audio-tests)
- SQA = 0xf, SQB = 0xf

![dac_auxa_max](/BreakingNESWiki/imgstore/apu/waves/dac_auxa_max.jpg)

Результаты:
- Максимальное напряжение AUX A: 272 mV
- Видно что нижний уровень также имеет небольшое напряжение относительно GND (момент спорный, т.к. щуп может вносить свои искажения)

Credits: @HardWareMan

## Triangle/Noise/DPCM

![dac_other_tran](/BreakingNESWiki/imgstore/apu/dac_other_tran.jpg)

TBD.
