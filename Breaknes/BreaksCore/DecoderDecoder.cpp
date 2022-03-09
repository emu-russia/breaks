#include "pch.h"

using namespace BaseLogic;

void DumpDecoderStates()
{
	M6502Core::Decoder* decoder = new M6502Core::Decoder;

	static const char* inames[] = {
		 "BRK",     "ORA X,ind", "??? ---", "??? ---", "??? ---",   "ORA zpg  ", "ASL zpg  ", "??? ---", "PHP", "ORA #    ", "ASL A  ", "??? ---", "??? ---",   "ORA abs  ", "ASL abs  ", "??? ---",
		 "BPL rel", "ORA ind,Y", "??? ---", "??? ---", "??? ---",   "ORA zpg,X", "ASL zpg,X", "??? ---", "CLC", "ORA abs,Y", "??? ---", "??? ---", "??? ---",   "ORA abs,X", "ASL abs,X", "??? ---",
		 "JSR abs", "AND X,ind", "??? ---", "??? ---", "BIT zpg",   "AND zpg  ", "ROL zpg  ", "??? ---", "PLP", "AND #    ", "ROL A  ", "??? ---", "BIT abs",   "AND abs  ", "ROL abs  ", "??? ---",
		 "BMI rel", "AND ind,Y", "??? ---", "??? ---", "??? ---",   "AND zpg,X", "ROL zpg,X", "??? ---", "SEC", "AND abs,Y", "??? ---", "??? ---", "??? ---",   "AND abs,X", "ROL abs,X", "??? ---",
		 "RTI",     "EOR X,ind", "??? ---", "??? ---", "??? ---",   "EOR zpg  ", "LSR zpg  ", "??? ---", "PHA", "EOR #    ", "LSR A  ", "??? ---", "JMP abs",   "EOR abs  ", "LSR abs  ", "??? ---",
		 "BVC rel", "EOR ind,Y", "??? ---", "??? ---", "??? ---",   "EOR zpg,X", "LSR zpg,X", "??? ---", "CLI", "EOR abs,Y", "??? ---", "??? ---", "??? ---",   "EOR abs,X", "LSR abs,X", "??? ---",
		 "RTS",     "ADC X,ind", "??? ---", "??? ---", "??? ---",   "ADC zpg  ", "ROR zpg  ", "??? ---", "PLA", "ADC #    ", "ROR A  ", "??? ---", "JMP ind",   "ADC abs  ", "ROR abs  ", "??? ---",
		 "BVS rel", "ADC ind,Y", "??? ---", "??? ---", "??? ---",   "ADC zpg,X", "ROR zpg,X", "??? ---", "SEI", "ADC abs,Y", "??? ---", "??? ---", "??? ---",   "ADC abs,X", "ROR abs,X", "??? ---",
		 "??? ---", "STA X,ind", "??? ---", "??? ---", "STY zpg",   "STA zpg  ", "STX zpg  ", "??? ---", "DEY", "??? ---  ", "TXA    ", "??? ---", "STY abs",   "STA abs  ", "STX abs  ", "??? ---",
		 "BCC rel", "STA ind,Y", "??? ---", "??? ---", "STY zpg,X", "STA zpg,X", "STX zpg,Y", "??? ---", "TYA", "STA abs,Y", "TXS    ", "??? ---", "??? ---",   "STA abs,X", "??? ---  ", "??? ---",
		 "LDY #",   "LDA X,ind", "LDX #",   "??? ---", "LDY zpg",   "LDA zpg  ", "LDX zpg  ", "??? ---", "TAY", "LDA #    ", "TAX    ", "??? ---", "LDY abs",   "LDA abs  ", "LDX abs  ", "??? ---",
		 "BCS rel", "LDA ind,Y", "??? ---", "??? ---", "LDY zpg,X", "LDA zpg,X", "LDX zpg,Y", "??? ---", "CLV", "LDA abs,Y", "TSX    ", "??? ---", "LDY abs,X", "LDA abs,X", "LDX abs,Y", "??? ---",
		 "CPY #",   "CMP X,ind", "??? ---", "??? ---", "CPY zpg",   "CMP zpg  ", "DEC zpg  ", "??? ---", "INY", "CMP #    ", "DEX    ", "??? ---", "CPY abs",   "CMP abs  ", "DEC abs  ", "??? ---",
		 "BNE rel", "CMP ind,Y", "??? ---", "??? ---", "??? ---",   "CMP zpg,X", "DEC zpg,X", "??? ---", "CLD", "CMP abs,Y", "??? ---", "??? ---", "??? ---",   "CMP abs,X", "DEC abs,X", "??? ---",
		 "CPX #",   "SBC X,ind", "??? ---", "??? ---", "CPX zpg",   "SBC zpg  ", "INC zpg  ", "??? ---", "INX", "SBC #    ", "NOP    ", "??? ---", "CPX abs",   "SBC abs  ", "INC abs  ", "??? ---",
		 "BEQ rel", "SBC ind,Y", "??? ---", "??? ---", "??? ---",   "SBC zpg,X", "INC zpg,X", "??? ---", "SED", "SBC abs,Y", "??? ---", "??? ---", "??? ---",   "SBC abs,X", "INC abs,X", "??? ---",
	};

	static const char * decoder_out_name[130] = {
		"STY (TX)",
		"OP ind, Y (T3)",
		"OP abs, Y (T2)",
		"DEY INY (T0)",
		"TYA (T0)",
		"CPY INY (T0)",

		"OP zpg, X/Y & OP abs, X/Y (T2)",
		"LDX STX A<->X S<->X (TX)",
		"OP ind, X (T2)",
		"TXA (T0)",
		"DEX (T0)",
		"CPX INX (T0)",
		"STX TXA TXS (TX)",
		"TXS (T0)",
		"LDX TAX TSX (T0)",
		"DEX (T1)",
		"INX (T1)",
		"TSX (T0)",
		"DEY INY (T1)",
		"LDY (T0)",
		"LDY TAY (T0)",

		"JSR (T0)",
		"BRK5",
		"Push (T0)",
		"RTS (T4)",
		"Pull (T3)",
		"RTI/5",
		"ROR (TX)",
		"T2",
		"EOR (T0)",
		"JMP (excluder for D31) (TX)",
		"ALU absolute (T2)",
		"ORA (T0)",
		"LEFT_ALL (T2)",
		"T0 ANY",
		"STK2",
		"BRK JSR RTI RTS Push/pull + BIT JMP (T3)",

		"BRK JSR (T4)",
		"RTI (T4)",
		"OP X, ind (T3)",
		"OP ind, Y (T4)",
		"OP ind, Y (T2)",
		"RIGHT ODD (T3)",
		"Pull (TX)",
		"INC NOP (TX)",
		"OP X, ind (T4)",
		"OP ind, Y (T3)",
		"RET (TX)",
		"JSR2",
		"CPY CPX INY INX (T0)",
		"CMP (T0)",
		"SBC0 (T0)",
		"ADC SBC (T0)",
		"ROL (TX)",

		"JMP ind (T3)",
		"ASL ROL (TX)",
		"JSR/5",
		"BRK JSR RTI RTS Push/pull (T2)",
		"TYA (T0)",
		"UPPER ODD (T1)",
		"ADC SBC (T1)",
		"ASL ROL LSR ROR (T1)",
		"TXA (T0)",
		"PLA (T0)",
		"LDA (T0)",
		"ALL ODD (T0)",
		"TAY (T0)",
		"ASL ROL LSR ROR (T0)",
		"TAX (T0)",
		"BIT0",
		"AND0",
		"OP abs,XY (T4)",
		"OP ind,Y (T5)",

		"BR0",
		"PHA (T2)",
		"LSR ROR (T0)",
		"LSR ROR (TX)",
		"BRK (T2)",
		"JSR (T3)",
		"STA (TX)",
		"BR2",
		"zero page (T2)",
		"ALU indirect (T2)",
		"ABS/2",
		"RTS/5",
		"T4 ANY",
		"T3 ANY",
		"BRK RTI (T0)",
		"JMP (T0)",
		"OP X, ind (T5)",
		"RIGHT_ALL (T3)",

		"OP ind, Y (T4)",
		"RIGHT ODD (T3)",
		"BR3",
		"BRK RTI (TX)",
		"JSR (TX)",
		"JMP (TX)",
		"STORE (TX)",
		"BRK (T4)",
		"PHP (T2)",
		"Push (T2)",
		"JMP/4",
		"RTI RTS (T5)",
		"JSR (T5)",

		"JMP abs (T2)",
		"Pull (T3)",
		"LSR ROR DEC INC DEX NOP (4x4 bottom right) (TX)",
		"ASL ROL (TX)",
		"CLI SEI (T0)",
		"BIT (T1)",
		"CLC SEC (T0)",
		"Memory zero page X/Y (T3)",
		"ADC SBC (T1)",
		"BIT (T0)",
		"PLP (T0)",
		"RTI (T4)",
		"CMP (T1)",
		"CPY CPX abs (T1)",
		"ASL ROL (T1)",
		"CPY CPX zpg/immed (T1)",

		"CLD SED (T0)",
		"/IR6",
		"Memory absolute (T3)",
		"Memory zero page (T2)",
		"Memory indirect (T5)",
		"Memory absolute X/Y (T4)",
		"/IR7",
		"CLV",
		"IMPL",
		"pp",
	};

	FILE* f;
	fopen_s(&f, "decoder_tab.md", "wt");

	fprintf(f, "|IR|T0|T1|T2|T3|T4|T5|TX|\n");
	fprintf(f, "|---|---|---|---|---|---|---|---|\n");

	for (size_t ir = 0; ir < 0x100; ir++)
	{
		fprintf(f, "|0x%02X: %s|", (uint8_t)ir, inames[ir]);

		for (size_t Tx = 0; Tx < 7; Tx++)
		{
			M6502Core::DecoderInput decoder_in;
			TriState *outputs;

			decoder_in.packed_bits = 0;

			decoder_in.n_T0 = Tx == 0 ? 0 : 1;
			decoder_in.n_T1X = Tx == 1 ? 0 : 1;
			decoder_in.n_T2 = Tx == 2 ? 0 : 1;
			decoder_in.n_T3 = Tx == 3 ? 0 : 1;
			decoder_in.n_T4 = Tx == 4 ? 0 : 1;
			decoder_in.n_T5 = Tx == 5 ? 0 : 1;
			// Tx = 7: Any

			TriState IR[8];
			Unpack((uint8_t)ir, IR);

			decoder_in.n_IR0 = NOT(IR[0]);
			decoder_in.n_IR1 = NOT(IR[1]);
			decoder_in.IR01 = OR(IR[0], IR[1]);
			decoder_in.IR2 = IR[2];
			decoder_in.n_IR2 = NOT(IR[2]);
			decoder_in.IR3 = IR[3];
			decoder_in.n_IR3 = NOT(IR[3]);
			decoder_in.IR4 = IR[4];
			decoder_in.n_IR4 = NOT(IR[4]);
			decoder_in.IR5 = IR[5];
			decoder_in.n_IR5 = NOT(IR[5]);
			decoder_in.IR6 = IR[6];
			decoder_in.n_IR6 = NOT(IR[6]);
			decoder_in.IR7 = IR[7];
			decoder_in.n_IR7 = NOT(IR[7]);

			decoder->sim(decoder_in.packed_bits, &outputs);

			bool comma = false;

			for (int n = 0; n < M6502Core::Decoder::outputs_count; n++)
			{
				if (outputs[n] == TriState::One && !(n == 121 || n == 126))
				{
					if (comma)
					{
						fprintf(f, ", ");
					}

					fprintf(f, "%d: %s", n, decoder_out_name[n]);

					if (!comma)
					{
						comma = true;
					}
				}
			}

			fprintf(f, "|");
		}

		fprintf(f, "\n");
	}

	fclose(f);
}
