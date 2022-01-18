using System;

namespace BreaksDebug
{
    class QuickDisasm
    {
        static string [] inames = new string [256] {
             "BRK",     "ORA X,ind", "??? ---", "??? ---", "??? ---",   "ORA zpg",   "ASL zpg",   "??? ---", "PHP", "ORA #",     "ASL A  ", "??? ---", "??? ---",   "ORA abs",   "ASL abs",   "??? ---",
             "BPL rel", "ORA ind,Y", "??? ---", "??? ---", "??? ---",   "ORA zpg,X", "ASL zpg,X", "??? ---", "CLC", "ORA abs,Y", "??? ---", "??? ---", "??? ---",   "ORA abs,X", "ASL abs,X", "??? ---",
             "JSR abs", "AND X,ind", "??? ---", "??? ---", "BIT zpg",   "AND zpg",   "ROL zpg",   "??? ---", "PLP", "AND #",     "ROL A  ", "??? ---", "BIT abs",   "AND abs",   "ROL abs",   "??? ---",
             "BMI rel", "AND ind,Y", "??? ---", "??? ---", "??? ---",   "AND zpg,X", "ROL zpg,X", "??? ---", "SEC", "AND abs,Y", "??? ---", "??? ---", "??? ---",   "AND abs,X", "ROL abs,X", "??? ---",
             "RTI",     "EOR X,ind", "??? ---", "??? ---", "??? ---",   "EOR zpg",   "LSR zpg",   "??? ---", "PHA", "EOR #",     "LSR A  ", "??? ---", "JMP abs",   "EOR abs",   "LSR abs",   "??? ---",
             "BVC rel", "EOR ind,Y", "??? ---", "??? ---", "??? ---",   "EOR zpg,X", "LSR zpg,X", "??? ---", "CLI", "EOR abs,Y", "??? ---", "??? ---", "??? ---",   "EOR abs,X", "LSR abs,X", "??? ---",
             "RTS",     "ADC X,ind", "??? ---", "??? ---", "??? ---",   "ADC zpg",   "ROR zpg",   "??? ---", "PLA", "ADC #",     "ROR A  ", "??? ---", "JMP ind",   "ADC abs",   "ROR abs",   "??? ---",
             "BVS rel", "ADC ind,Y", "??? ---", "??? ---", "??? ---",   "ADC zpg,X", "ROR zpg,X", "??? ---", "SEI", "ADC abs,Y", "??? ---", "??? ---", "??? ---",   "ADC abs,X", "ROR abs,X", "??? ---",
             "??? ---", "STA X,ind", "??? ---", "??? ---", "STY zpg",   "STA zpg",   "STX zpg",   "??? ---", "DEY", "??? ---",   "TXA",     "??? ---", "STY abs",   "STA abs",   "STX abs",   "??? ---",
             "BCC rel", "STA ind,Y", "??? ---", "??? ---", "STY zpg,X", "STA zpg,X", "STX zpg,Y", "??? ---", "TYA", "STA abs,Y", "TXS",     "??? ---", "??? ---",   "STA abs,X", "??? ---",   "??? ---",
             "LDY #",   "LDA X,ind", "LDX #",   "??? ---", "LDY zpg",   "LDA zpg",   "LDX zpg",   "??? ---", "TAY", "LDA #",     "TAX",     "??? ---", "LDY abs",   "LDA abs",   "LDX abs",   "??? ---",
             "BCS rel", "LDA ind,Y", "??? ---", "??? ---", "LDY zpg,X", "LDA zpg,X", "LDX zpg,Y", "??? ---", "CLV", "LDA abs,Y", "TSX",     "??? ---", "LDY abs,X", "LDA abs,X", "LDX abs,Y", "??? ---",
             "CPY #",   "CMP X,ind", "??? ---", "??? ---", "CPY zpg",   "CMP zpg",   "DEC zpg",   "??? ---", "INY", "CMP #",     "DEX",     "??? ---", "CPY abs",   "CMP abs",   "DEC abs",   "??? ---",
             "BNE rel", "CMP ind,Y", "??? ---", "??? ---", "??? ---",   "CMP zpg,X", "DEC zpg,X", "??? ---", "CLD", "CMP abs,Y", "??? ---", "??? ---", "??? ---",   "CMP abs,X", "DEC abs,X", "??? ---",
             "CPX #",   "SBC X,ind", "??? ---", "??? ---", "CPX zpg",   "SBC zpg",   "INC zpg",   "??? ---", "INX", "SBC #",     "NOP",     "??? ---", "CPX abs",   "SBC abs",   "INC abs",   "??? ---",
             "BEQ rel", "SBC ind,Y", "??? ---", "??? ---", "??? ---",   "SBC zpg,X", "INC zpg,X", "??? ---", "SED", "SBC abs,Y", "??? ---", "??? ---", "??? ---",   "SBC abs,X", "INC abs,X", "??? ---",
            };

        public static string Disasm (byte opcode)
        {
            return inames[opcode];
        }
    }
}
