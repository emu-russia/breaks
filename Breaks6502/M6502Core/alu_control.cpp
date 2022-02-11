#include "pch.h"

using namespace BaseLogic;

namespace M6502Core
{
	ALUControl::ALUControl(M6502* parent)
	{
		core = parent;

		size_t maxVal = 1 << 19;
		for (size_t n = 0; n < maxVal; n++)
		{
			uint8_t ir = n & 0xff;
			bool n_T0 = (n >> 8) & 1;
			bool n_T1X = (n >> 9) & 1;
			bool n_T2 = (n >> 10) & 1;
			bool n_T3 = (n >> 11) & 1;
			bool n_T4 = (n >> 12) & 1;
			bool n_T5 = (n >> 13) & 1;
			bool n_ready = (n >> 14) & 1;
			bool T0 = (n >> 15) & 1;
			bool T5 = (n >> 16) & 1;
			bool BRFW = (n >> 17) & 1;
			bool n_C_OUT = (n >> 18) & 1;

			temp_tab1[n] = PreCalc1(ir, n_T0, n_T1X, n_T2, n_T3, n_T4, n_T5, 
				n_ready, T0, T5, BRFW, n_C_OUT);
		}

		prev_temp1.bits = 0xff;
	}

	void ALUControl::sim()
	{
		TriState* d = core->decoder_out;
		TriState PHI1 = core->wire.PHI1;
		TriState PHI2 = core->wire.PHI2;
		TriState n_ready = core->wire.n_ready;
		TriState T5 = core->wire.T5;
		TriState n_C_OUT = core->random->flags->getn_C_OUT();

		nready_latch.set(n_ready, PHI1);

		if (PHI2)
		{
			TriState n3[6];
			n3[0] = d[21];
			n3[1] = d[22];
			n3[2] = d[23];
			n3[3] = d[24];
			n3[4] = d[25];
			n3[5] = d[26];
			STKOP = NOR(nready_latch.get(), NOR6(n3));
		}

		sim_CarryBCD();

		sim_ALUInput();

		sim_ALUOps();

		// ADD/SB7

		TriState SR = NOT(NOR(d[75], AND(d[76], T5)));
		TriState n_ROR = NOT(d[27]);
		cout_latch.set(NOT(n_C_OUT), PHI2);
		mux_latch1.set(NOR(nready_latch.get(), NOT(SR)), PHI2);
		sr_latch1.set(SR, PHI2);
		sr_latch2.set(sr_latch1.nget(), PHI1);
		ff_latch1.set(NOT(MUX(mux_latch1.get(), ff_latch2.get(), cout_latch.nget())), PHI1);
		ff_latch2.set(ff_latch1.nget(), PHI2);
		n_ADD_SB7 = NOR3(ff_latch1.nget(), sr_latch2.get(), n_ROR);

		sim_ADDOut();

		// Outputs

		if (PHI2 == TriState::One)
		{
			core->cmd.NDB_ADD = 0;
			core->cmd.DB_ADD = 0;
			core->cmd.Z_ADD = 0;
			core->cmd.SB_ADD = 0;
			core->cmd.ADL_ADD = 0;
		}
		else
		{
			core->cmd.NDB_ADD = NOT(ndbadd_latch.get());
			core->cmd.DB_ADD = NOT(dbadd_latch.get());
			core->cmd.Z_ADD = NOT(zadd_latch.get());
			core->cmd.SB_ADD = NOT(sbadd_latch.get());
			core->cmd.ADL_ADD = NOT(adladd_latch.get());
		}

		core->cmd.ADD_SB7 = addsb7_latch.get();	// care!
		core->cmd.ADD_SB06 = addsb06_latch.nget();
		core->cmd.ADD_ADL = addadl_latch.nget();

		core->cmd.ANDS = ands_latch2.nget();
		core->cmd.EORS = eors_latch2.nget();
		core->cmd.ORS = ors_latch2.nget();
		core->cmd.SRS = srs_latch2.nget();
		core->cmd.SUMS = sums_latch2.nget();

		core->cmd.n_ACIN = NOT(acin_latch5.nget());
		core->cmd.n_DAA = daa_latch2.nget();
		core->cmd.n_DSA = dsa_latch2.nget();
	}

	void ALUControl::sim_CarryBCD()
	{
		TriState* d = core->decoder_out;
		TriState PHI1 = core->wire.PHI1;
		TriState PHI2 = core->wire.PHI2;
		TriState n_ready = core->wire.n_ready;
		TriState T0 = core->wire.T0;
		TriState T5 = core->wire.T5;
		TriState BRFW = core->random->branch_logic->getBRFW();
		TriState n_C_OUT = core->random->flags->getn_C_OUT();
		TriState n_D_OUT = core->random->flags->getn_D_OUT();

		TriState SBC0 = d[51];

		// Additional signals (/ACIN, /DAA, /DSA)

		if (PHI2 == TriState::One)
		{
			// Vector: IR+TX, n_ready, T0, T5, BRFW, n_C_OUT  (lsb -> msb)

			size_t n = 0;
			n |= core->ir->IROut;
			n |= ((size_t)core->TxBits << 8);
			n |= ((size_t)n_ready << 14);
			n |= ((size_t)T0 << 15);
			n |= ((size_t)T5 << 16);
			n |= ((size_t)BRFW << 17);
			n |= ((size_t)n_C_OUT << 18);

			CarryBCD_TempWire temp = temp_tab1[n];

			if (prev_temp1.bits != temp.bits)
			{
				acin_latch1.set(temp.n_ADL_ADD_Derived ? TriState::One : TriState::Zero, PHI2);
				acin_latch2.set(temp.INC_SB ? TriState::One : TriState::Zero, PHI2);
				acin_latch3.set(temp.BRX ? TriState::One : TriState::Zero, PHI2);
				acin_latch4.set(temp.CSET ? TriState::One : TriState::Zero, PHI2);
				prev_temp1.bits = temp.bits;
			}

			n_ADL_ADD = prev_temp1.n_ADL_ADD ? TriState::One : TriState::Zero;
			INC_SB = prev_temp1.INC_SB ? TriState::One : TriState::Zero;
			BRX = prev_temp1.BRX ? TriState::One : TriState::Zero;
		}
		else
		{
			TriState acin[4];
			acin[0] = acin_latch1.get();
			acin[1] = acin_latch2.get();
			acin[2] = acin_latch3.get();
			acin[3] = acin_latch4.get();
			TriState n_ACIN = NOR4(acin);
			acin_latch5.set(n_ACIN, PHI1);
		}

		TriState D_OUT = NOT(n_D_OUT);
		daa_latch1.set(NOT(NOR(NAND(d[52], D_OUT), SBC0)), PHI2);
		daa_latch2.set(daa_latch1.nget(), PHI1);

		dsa_latch1.set(NAND(SBC0, D_OUT), PHI2);
		dsa_latch2.set(dsa_latch1.nget(), PHI1);
	}

	void ALUControl::sim_ALUInput()
	{
		TriState* d = core->decoder_out;
		TriState PHI2 = core->wire.PHI2;
		TriState n_ready = core->wire.n_ready;
		TriState BRK6E = core->wire.BRK6E;

		TriState SBC0 = d[51];
		TriState JSR_5 = d[56];
		TriState JSR2 = d[48];
		TriState RET = d[47];

		// Setting the ALU input values (NDB/ADD, DB/ADD, 0/ADD, SB/ADD, ADL/ADD)

		if (PHI2 == TriState::One)
		{
			TriState n_NDB_ADD = NAND(OR3(BRX, JSR_5, SBC0), NOT(n_ready));
			ndbadd_latch.set(n_NDB_ADD, PHI2);
			dbadd_latch.set(NAND(n_NDB_ADD, n_ADL_ADD), PHI2);
			adladd_latch.set(n_ADL_ADD, PHI2);

			TriState sbadd[9];
			sbadd[0] = STKOP;
			sbadd[1] = d[30];
			sbadd[2] = d[31];
			sbadd[3] = d[45];
			sbadd[4] = JSR2;
			sbadd[5] = INC_SB;
			sbadd[6] = RET;
			sbadd[7] = BRK6E;
			sbadd[8] = n_ready;
			TriState SB_ADD = NOR9(sbadd);
			sbadd_latch.set(NOT(SB_ADD), PHI2);
			zadd_latch.set(SB_ADD, PHI2);
		}
	}

	void ALUControl::sim_ALUOps()
	{
		TriState* d = core->decoder_out;
		TriState PHI1 = core->wire.PHI1;
		TriState PHI2 = core->wire.PHI2;
		TriState n_ready = core->wire.n_ready;
		TriState T5 = core->wire.T5;

		TriState EOR = d[29];
		TriState _OR = NOT(NOR(d[32], n_ready));
		TriState _AND = NOT(NOR(d[69], d[70]));
		TriState SR = NOT(NOR(d[75], AND(d[76], T5)));

		// ALU operation commands (ANDS, EORS, ORS, SRS, SUMS)

		if (PHI2 == TriState::One)
		{
			ands_latch1.set(_AND, PHI2);
			eors_latch1.set(EOR, PHI2);
			ors_latch1.set(_OR, PHI2);
			srs_latch1.set(SR, PHI2);

			TriState sums[4];
			sums[0] = _AND;
			sums[1] = EOR;
			sums[2] = _OR;
			sums[3] = SR;
			sums_latch1.set(NOR4(sums), PHI2);
		}
		else
		{
			ands_latch2.set(ands_latch1.nget(), PHI1);
			eors_latch2.set(eors_latch1.nget(), PHI1);
			ors_latch2.set(ors_latch1.nget(), PHI1);
			srs_latch2.set(srs_latch1.nget(), PHI1);

			sums_latch2.set(sums_latch1.nget(), PHI1);
		}
	}

	void ALUControl::sim_ADDOut()
	{
		TriState* d = core->decoder_out;
		TriState PHI2 = core->wire.PHI2;
		TriState T1 = core->disp->getT1();
		TriState T6 = core->wire.T6;

		TriState RTS_5 = d[84];
		TriState RTI_5 = d[26];
		TriState JSR_5 = d[56];

		TriState BR0 = AND(d[73], NOT(core->wire.n_PRDY));
		TriState PGX = NAND(NOR(d[71], d[72]), NOT(BR0));

		// Control commands of the intermediate ALU result (ADD/SB06, ADD/SB7, ADD/ADL)

		if (PHI2 == TriState::One)
		{
			TriState sb06[5];
			sb06[0] = T6;
			sb06[1] = STKOP;
			sb06[2] = JSR_5;
			sb06[3] = T1;
			sb06[4] = PGX;
			TriState n_ADD_SB06 = NOR5(sb06);
			addsb06_latch.set(n_ADD_SB06, PHI2);

			addsb7_latch.set(NOR(n_ADD_SB06, n_ADD_SB7), PHI2);

			TriState noadl[7];
			noadl[0] = RTS_5;
			noadl[1] = d[85];
			noadl[2] = d[86];
			noadl[3] = d[87];
			noadl[4] = d[88];
			noadl[5] = d[89];
			noadl[6] = RTI_5;
			TriState NOADL = NOR7(noadl);
			addadl_latch.set(NOT(NOR(NOADL, PGX)), PHI2);
		}
	}

	CarryBCD_TempWire ALUControl::PreCalc1(uint8_t ir, bool n_T0, bool n_T1X, bool n_T2, bool n_T3, bool n_T4, bool n_T5,
		bool n_ready, bool T0, bool T5, bool BRFW, bool n_C_OUT)
	{
		TriState* d;
		DecoderInput decoder_in;
		decoder_in.packed_bits = 0;
		CarryBCD_TempWire temp;
		temp.bits = 0;

		TriState IR0 = ir & 0b00000001 ? TriState::One : TriState::Zero;
		TriState IR1 = ir & 0b00000010 ? TriState::One : TriState::Zero;
		TriState IR2 = ir & 0b00000100 ? TriState::One : TriState::Zero;
		TriState IR3 = ir & 0b00001000 ? TriState::One : TriState::Zero;
		TriState IR4 = ir & 0b00010000 ? TriState::One : TriState::Zero;
		TriState IR5 = ir & 0b00100000 ? TriState::One : TriState::Zero;
		TriState IR6 = ir & 0b01000000 ? TriState::One : TriState::Zero;
		TriState IR7 = ir & 0b10000000 ? TriState::One : TriState::Zero;

		decoder_in.n_IR0 = NOT(IR0);
		decoder_in.n_IR1 = NOT(IR1);
		decoder_in.IR01 = OR(IR0, IR1);
		decoder_in.n_IR2 = NOT(IR2);
		decoder_in.IR2 = IR2;
		decoder_in.n_IR3 = NOT(IR3);
		decoder_in.IR3 = IR3;
		decoder_in.n_IR4 = NOT(IR4);
		decoder_in.IR4 = IR4;
		decoder_in.n_IR5 = NOT(IR5);
		decoder_in.IR5 = IR5;
		decoder_in.n_IR6 = NOT(IR6);
		decoder_in.IR6 = IR6;
		decoder_in.n_IR7 = NOT(IR7);
		decoder_in.IR7 = IR7;

		decoder_in.n_T0 = n_T0;
		decoder_in.n_T1X = n_T1X;
		decoder_in.n_T2 = n_T2;
		decoder_in.n_T3 = n_T3;
		decoder_in.n_T4 = n_T4;
		decoder_in.n_T5 = n_T5;

		core->decoder->sim(decoder_in.packed_bits, &d);

		// Wires

		TriState RET = d[47];
		TriState BR3 = d[93];

		TriState adladd[7];
		adladd[0] = AND(d[33], NOT(d[34]));
		adladd[1] = d[35];	// STK2
		adladd[2] = d[36];
		adladd[3] = d[37];
		adladd[4] = d[38];
		adladd[5] = d[39];
		adladd[6] = n_ready ? TriState::One : TriState::Zero;
		temp.n_ADL_ADD = NOR7(adladd);

		TriState incsb[6];
		incsb[0] = d[39];
		incsb[1] = d[40];
		incsb[2] = d[41];
		incsb[3] = d[42];
		incsb[4] = d[43];
		incsb[5] = AND(T5 ? TriState::One : TriState::Zero, d[44]);
		temp.INC_SB = NOT(NOR6(incsb));

		temp.BRX = NOT(NOR3(d[49], d[50], NOR(NOT(BR3), BRFW ? TriState::One : TriState::Zero)));

		temp.CSET = NAND(NAND(NOR(n_C_OUT ? TriState::One : TriState::Zero, NOR(T0 ? TriState::One : TriState::Zero, T5 ? TriState::One : TriState::Zero)), OR(d[52], d[53])), NOT(d[54]));

		temp.n_ADL_ADD_Derived = NOR(temp.n_ADL_ADD ? TriState::One : TriState::Zero, NOT(RET));

		return temp;
	}

}
