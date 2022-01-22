#include "pch.h"

using namespace BaseLogic;

namespace M6502Core
{
	FlagsControl::FlagsControl(M6502* parent)
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
			bool T5 = (n >> 14) & 1;
			bool T6 = (n >> 15) & 1;

			temp_tab[n] = PreCalc(ir, n_T0, n_T1X, n_T2, n_T3, n_T4, n_T5, T5, T6);
		}

		prev_temp.bits = 0xff;
	}

	void FlagsControl::sim()
	{
		TriState* d = core->decoder_out;
		TriState PHI2 = core->wire.PHI2;
		TriState n_ready = core->wire.n_ready;
		TriState DB_P;

		if (PHI2 == TriState::One)
		{
			TriState T5 = core->wire.T5;
			TriState T6 = core->wire.T6;

			size_t n = 0;
			n |= core->ir->IROut;
			n |= ((size_t)core->TxBits << 8);
			n |= ((size_t)T5 << 14);
			n |= ((size_t)T6 << 15);

			FlagsControl_TempWire temp = temp_tab[n];

			// Latches

			if (prev_temp.bits != temp.bits)
			{
				pdb_latch.set(temp.n_POUT ? TriState::One : TriState::Zero, PHI2);
				acrc_latch.set(temp.n_ARIT ? TriState::One : TriState::Zero, PHI2);
				pin_latch.set(temp.n_PIN ? TriState::One : TriState::Zero, PHI2);
				prev_temp.bits = temp.bits;
			}

			iri_latch.set(NOT(d[108]), PHI2);
			irc_latch.set(NOT(d[110]), PHI2);
			ird_latch.set(NOT(d[120]), PHI2);
			zv_latch.set(NOT(d[127]), PHI2);
			dbz_latch.set(NOR3(acrc_latch.nget(), temp.ZTST ? TriState::One : TriState::Zero, d[109]), PHI2);
			dbn_latch.set(d[109], PHI2);
			DB_P = NOR(pin_latch.get(), n_ready);
			dbc_latch.set(NOR(DB_P, temp.SR ? TriState::One : TriState::Zero), PHI2);
			bit_latch.set(NOT(d[113]), PHI2);
		}
		else
		{
			DB_P = NOR(pin_latch.get(), n_ready);
		}

		// Outputs

		core->cmd.P_DB = pdb_latch.nget();
		core->cmd.IR5_I = iri_latch.nget();
		core->cmd.IR5_C = irc_latch.nget();
		core->cmd.IR5_D = ird_latch.nget();
		core->cmd.AVR_V = d[112];
		core->cmd.Z_V = zv_latch.nget();
		core->cmd.ACR_C = acrc_latch.nget();
		core->cmd.DBZ_Z = dbz_latch.nget();
		core->cmd.DB_N = NOR(AND(dbz_latch.get(), pin_latch.get()), dbn_latch.get());
		core->cmd.DB_P = DB_P;
		core->cmd.DB_C = dbc_latch.nget();
		core->cmd.DB_V = NAND(pin_latch.get(), bit_latch.get());
	}

	FlagsControl_TempWire FlagsControl::PreCalc(uint8_t ir, bool n_T0, bool n_T1X, bool n_T2, bool n_T3, bool n_T4, bool n_T5, bool T5, bool T6)
	{
		TriState* d;
		DecoderInput decoder_in;
		decoder_in.packed_bits = 0;
		FlagsControl_TempWire temp;
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

		TriState sbac[7];
		sbac[0] = d[58];
		sbac[1] = d[59];
		sbac[2] = d[60];
		sbac[3] = d[61];
		sbac[4] = d[62];
		sbac[5] = d[63];
		sbac[6] = d[64];
		TriState n_SB_AC = NOR7(sbac);

		TriState _AND = NOT(NOR(d[69], d[70]));

		TriState n_SB_X = NOR3(d[14], d[15], d[16]);
		TriState n_SB_Y = NOR3(d[18], d[19], d[20]);
		TriState SBXY = NAND(n_SB_X, n_SB_Y);

		TriState ztst[4];
		ztst[0] = SBXY;
		ztst[1] = NOT(n_SB_AC);
		ztst[2] = T6 ? TriState::One : TriState::Zero;
		ztst[3] = _AND;
		TriState n_ZTST = NOR4(ztst);

		temp.ZTST = NOT(n_ZTST);
		temp.SR = NOT(NOR(d[75], AND(d[76], T5 ? TriState::One : TriState::Zero)));

		temp.n_POUT = NOR(d[98], d[99]);
		temp.n_PIN = NOR(d[114], d[115]);

		TriState n1[6];
		n1[0] = AND(d[107], T6 ? TriState::One : TriState::Zero);
		n1[1] = d[112];		// AVR/V
		n1[2] = d[116];
		n1[3] = d[117];
		n1[4] = d[118];
		n1[5] = d[119];
		temp.n_ARIT = NOR6(n1);

		return temp;
	}
}
