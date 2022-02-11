#include "pch.h"

using namespace BaseLogic;

namespace M6502Core
{
	RegsControl::RegsControl(M6502* parent)
	{
		core = parent;

		size_t maxVal = 1 << 16;
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
			bool n_ready_latch = (n >> 15) & 1;

			temp_tab[n] = PreCalc(ir, n_T0, n_T1X, n_T2, n_T3, n_T4, n_T5, n_ready, n_ready_latch);
		}

		prev_temp.bits = 0xff;
	}

	void RegsControl::sim()
	{
		TriState* d = core->decoder_out;
		TriState PHI1 = core->wire.PHI1;
		TriState PHI2 = core->wire.PHI2;
		TriState n_ready = core->wire.n_ready;

		nready_latch.set(n_ready, PHI1);

		// Register control commands and auxiliary signals for other parts of the random logic

		if (PHI2 == TriState::One)
		{
			bool nready_latch_val = nready_latch.get();

			size_t n = 0;
			n |= core->ir->IROut;
			n |= ((size_t)core->TxBits << 8);
			n |= ((size_t)n_ready << 14);
			n |= ((size_t)nready_latch_val << 15);

			RegsControl_TempWire temp = temp_tab[n];

			if (prev_temp.bits != temp.bits)
			{
				ysb_latch.set(temp.n_Y_SB ? TriState::One : TriState::Zero, PHI2);
				xsb_latch.set(temp.n_X_SB ? TriState::One : TriState::Zero, PHI2);
				sbx_latch.set(temp.n_SB_X ? TriState::One : TriState::Zero, PHI2);
				sby_latch.set(temp.n_SB_Y ? TriState::One : TriState::Zero, PHI2);
				sbs_latch.set(temp.n_SB_S ? TriState::One : TriState::Zero, PHI2);
				ss_latch.set(NOT(temp.n_SB_S ? TriState::One : TriState::Zero), PHI2);
				sadl_latch.set(temp.n_S_ADL ? TriState::One : TriState::Zero, PHI2);
				prev_temp.bits = temp.bits;
			}

			ssb_latch.set(NOT(d[17]), PHI2);
		}

		// Outputs

		if (PHI2 == TriState::One)
		{
			core->cmd.Y_SB = 0;
			core->cmd.X_SB = 0;
			core->cmd.SB_X = 0;
			core->cmd.SB_Y = 0;
			core->cmd.SB_S = 0;
			core->cmd.S_S = 0;
		}
		else
		{
			core->cmd.Y_SB = NOT(ysb_latch.get());
			core->cmd.X_SB = NOT(xsb_latch.get());
			core->cmd.SB_X = NOT(sbx_latch.get());
			core->cmd.SB_Y = NOT(sby_latch.get());
			core->cmd.SB_S = NOT(sbs_latch.get());
			core->cmd.S_S = NOT(ss_latch.get());
		}

		core->cmd.S_SB = ssb_latch.nget();
		core->cmd.S_ADL = sadl_latch.nget();
	}

	RegsControl_TempWire RegsControl::PreCalc(uint8_t ir, bool n_T0, bool n_T1X, bool n_T2, bool n_T3, bool n_T4, bool n_T5, bool n_ready, bool n_ready_latch)
	{
		TriState* d;
		DecoderInput decoder_in;
		decoder_in.packed_bits = 0;
		RegsControl_TempWire temp;
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

		TriState memop_in[5];
		memop_in[0] = d[111];
		memop_in[1] = d[122];
		memop_in[2] = d[123];
		memop_in[3] = d[124];
		memop_in[4] = d[125];
		TriState n_MemOp = NOR5(memop_in);

		TriState n_STORE = NOT(d[97]);
		TriState STOR = NOR(n_MemOp, n_STORE);

		TriState TXS = d[13];

		TriState n1[7];
		n1[0] = d[1];
		n1[1] = d[2];
		n1[2] = d[3];
		n1[3] = d[4];
		n1[4] = d[5];
		n1[5] = AND(d[6], d[7]);
		n1[6] = AND(d[0], STOR);
		temp.n_Y_SB = NOR7(n1);

		TriState n2[7];
		n2[0] = AND(STOR, d[12]);
		n2[1] = AND(d[6], NOT(d[7]));
		n2[2] = d[8];
		n2[3] = d[9];
		n2[4] = d[10];
		n2[5] = d[11];
		n2[6] = TXS;
		temp.n_X_SB = NOR7(n2);

		temp.n_SB_X = NOR3(d[14], d[15], d[16]);
		temp.n_SB_Y = NOR3(d[18], d[19], d[20]);

		TriState n3[6];
		n3[0] = d[21];
		n3[1] = d[22];
		n3[2] = d[23];
		n3[3] = d[24];
		n3[4] = d[25];
		n3[5] = d[26];
		TriState STKOP = NOR(n_ready_latch ? TriState::One : TriState::Zero, NOR6(n3));

		temp.n_SB_S = NOR3(TXS, NOR(NOT(d[48]), n_ready ? TriState::One : TriState::Zero), STKOP);

		temp.n_S_ADL = NOR(AND(d[21], n_ready_latch ? TriState::Zero : TriState::One), d[35]);

		return temp;
	}

}
