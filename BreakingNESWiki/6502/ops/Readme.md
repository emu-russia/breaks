# Операции

Данный раздел содержит описание выполнения различных операций:
- Сброс процессора, прерывания и BRK-последовательность
- Описание работы различных инструкций
- Реакция на внешние сигналы (контакты RDY, SO)
- Undefined Behaviour (выполнение опкодов, не предусмотренных разработчиками процессора)

Мотив описания операций:
- Операция разбивается на циклы (T0, T1 и так далее)
- Каждый цикл рассматривается в двух состояниях-полуциклах (PHI1 / PHI2)
- Состояние внутренностей процессора (сигналов, регистров, шин) описывается таблицами на каждом шаге

Рассмотрение работы инструкций производится в контексте между двумя операциями `nop`:

```
nop
<instr>
nop
```

Это связано с тем, что из-за оверлапа некоторые инструкции "доделывают" свою работу на первом полу-такте (PHI1) следующей инструкции.
Поэтому используется обертка в виде `nop`, как максимально неинвазивный вариант работы.

Таблица опкодов:

|   |00     |01        |02   |03 |04        |05        |06        |07 |
|---|-------|----------|-----|---|----------|----------|----------|---|
|00 |BRK    |ORA X, ind|     |   |          |ORA zpg   |ASL zpg   |   |
|10 |BPL rel|ORA ind, Y|     |   |          |ORA zpg, X|ASL zpg, X|   |
|20 |JSR abs|AND X, ind|     |   |BIT zpg   |AND zpg   |ROL zpg   |   |
|30 |BMI rel|AND ind, Y|     |   |          |AND zpg, X|ROL zpg, X|   |
|40 |RTI    |EOR X, ind|     |   |          |EOR zpg   |LSR zpg   |   |
|50 |BVC rel|EOR ind, Y|     |   |          |EOR zpg, X|LSR zpg, X|   |
|60 |RTS    |ADC X, ind|     |   |          |ADC zpg   |ROR zpg   |   |
|70 |BVS rel|ADC ind, Y|     |   |          |ADC zpg, X|ROR zpg, X|   |
|80 |       |STA X, ind|     |   |STY zpg   |STA zpg   |STX zpg   |   |
|90 |BCC rel|STA ind, Y|     |   |STY zpg, X|STA zpg, X|STX zpg, Y|   |
|A0 |LDY #  |LDA X, ind|LDX #|   |LDY zpg   |LDA zpg   |LDX zpg   |   |
|B0 |BCS rel|LDA ind, Y|     |   |LDY zpg, X|LDA zpg, X|LDX zpg, Y|   |
|C0 |CPY #  |CMP X, ind|     |   |CPY zpg   |CMP zpg   |DEC zpg   |   |
|D0 |BNE rel|CMP ind, Y|     |   |          |CMP zpg, X|DEC zpg, X|   |
|E0 |CPX #  |SBC X, ind|     |   |CPX zpg   |SBC zpg   |INC zpg   |   |
|F0 |BEQ rel|SBC ind, Y|     |   |          |SBC zpg, X|INC zpg, X|   |

|   |08 |09        |0A   |0B |0C        |0D        |0E        |0F |
|---|---|----------|-----|---|----------|----------|----------|---|
|00 |PHP|ORA #     |ASL A|   |          |ORA abs   |ASL abs   |   |
|10 |CLC|ORA abs, Y|     |   |          |ORA abs, X|ASL abs, X|   |
|20 |PLP|AND #     |ROL A|   |BIT abs   |AND abs   |ROL abs   |   |
|30 |SEC|AND abs, Y|     |   |          |AND abs, X|ROL abs, X|   |
|40 |PHA|EOR #     |LSR A|   |JMP abs   |EOR abs   |LSR abs   |   |
|50 |CLI|EOR abs, Y|     |   |          |EOR abs, X|LSR abs, X|   |
|60 |PLA|ADC #     |ROR A|   |JMP ind   |ADC abs   |ROR abs   |   |
|70 |SEI|ADC abs, Y|     |   |          |ADC abs, X|ROR abs, X|   |
|80 |DEY|          |TXA  |   |STY abs   |STA abs   |STX abs   |   |
|90 |TYA|STA abs, Y|TXS  |   |          |STA abs, X|          |   |
|A0 |TAY|LDA #     |TAX  |   |LDY abs   |LDA abs   |LDX abs   |   |
|B0 |CLV|LDA abs, Y|TSX  |   |LDY abs, X|LDA abs, X|LDX abs, Y|   |
|C0 |INY|CMP #     |DEX  |   |CPY abs   |CMP abs   |DEC abs   |   |
|D0 |CLD|CMP abs, Y|     |   |          |CMP abs, X|DEC abs, X|   |
|E0 |INX|SBC #     |NOP  |   |CPX abs   |SBC abs   |INC abs   |   |
|F0 |SED|SBC abs, Y|     |   |          |SBC abs, X|INC abs, X|   |

(Ссылки на каждый опкод делать не буду, чтобы таблица не стала монструозной. Используйте меню навигации)
