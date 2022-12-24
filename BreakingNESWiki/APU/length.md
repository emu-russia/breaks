# Счётчики длительности

![apu_locator_length](/BreakingNESWiki/imgstore/apu/apu_locator_length.jpg)

![length_sm](/BreakingNESWiki/imgstore/apu/length_sm.jpg)

![LengthCounters](/BreakingNESWiki/imgstore/apu/LengthCounters.jpg)

## Сигналы

|Сигнал|Откуда|Куда|Описание|
|---|---|---|---|
|/LFO2|SoftCLK|Length Counters|Сигнал низкочастотной осцилляции|
|SQA_LC|Square 0|Length Counters|Входной перенос для Square0 LC|
|SQB_LC|Square 1|Length Counters|Входной перенос для Square1 LC|
|TRI_LC|Triangle|Length Counters|Входной перенос для Triangle LC|
|RND_LC|Noise|Length Counters|Входной перенос для Noise LC|
|NOSQA|Length Counters|Square 0|Square0 LC не считает / отключен|
|NOSQB|Length Counters|Square 1|Square1 LC не считает / отключен|
|NOTRI|Length Counters|Triangle|Triangle LC не считает / отключен|
|NORND|Length Counters|Noise|Noise LC не считает / отключен|

## Length Decoder

![length_decoder_tran](/BreakingNESWiki/imgstore/apu/length_decoder_tran.jpg)

![Length_Decoder](/BreakingNESWiki/imgstore/apu/Length_Decoder.jpg)

|Decoder In|Decoder Out|
|---|---|
|0|0x9|
|1|0xfd|
|2|0x13|
|3|0x1|
|4|0x27|
|5|0x3|
|6|0x4f|
|7|0x5|
|8|0x9f|
|9|0x7|
|10|0x3b|
|11|0x9|
|12|0xd|
|13|0xb|
|14|0x19|
|15|0xd|
|16|0xb|
|17|0xf|
|18|0x17|
|19|0x11|
|20|0x2f|
|21|0x13|
|22|0x5f|
|23|0x15|
|24|0xbf|
|25|0x17|
|26|0x47|
|27|0x19|
|28|0xf|
|29|0x1b|
|30|0x1f|
|31|0x1d|

Первая стадия декодера (демультиплексор 5-to-32):

```
1010101010
1001101010
1010011010
1001011010
1010100110
1001100110
1010010110
1001010110

1010101001
1001101001
1010011001
1001011001
1010100101
1001100101
1010010101
1001010101

0110101010
0101101010
0110011010
0101011010
0110100110
0101100110
0110010110
0101010110

0110101001
0101101001
0110011001
0101011001
0110100101
0101100101
0110010101
0101010101
```

Битовая маска топологическая. 1 означает есть транзистор, 0 означает нет транзистора.

![Length_Decoder1](/BreakingNESWiki/imgstore/apu/Length_Decoder1.jpg)

Вторая стадия декодера:

```
01000111
00100111
01100111
00010111
01010111
00110111
01110111
00001111

01001111
00101111
01101111
00011111
01011111
00111111
01111111
01000000

00000111
00001111
00011101
00000010
00000101
00001011
00010111
00101111

01100111
01001111
00100011
00000110
00001101
00011011
00110111
01101111
```

Битовая маска топологическая. 1 означает есть транзистор, 0 означает нет транзистора.

![Length_Decoder2](/BreakingNESWiki/imgstore/apu/Length_Decoder2.jpg)

## Length Counter Control

![length_counter_control_tran](/BreakingNESWiki/imgstore/apu/length_counter_control_tran.jpg)

![Length_Control](/BreakingNESWiki/imgstore/apu/Length_Control.jpg)

## Length Counter

Обычный обратный счётчик.

![length_counter_tran](/BreakingNESWiki/imgstore/apu/length_counter_tran.jpg)

![Length_Counter](/BreakingNESWiki/imgstore/apu/Length_Counter.jpg)
