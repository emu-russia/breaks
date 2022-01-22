#include "pch.h"

using namespace BaseLogic;

namespace M6502Core
{
	void RegsControl::sim(RegsControl *inst)
	{
		M6502* core = inst->core;
		TriState* d = core->decoder_out;
		TriState PHI1 = core->wire.PHI1;
		TriState PHI2 = core->wire.PHI2;
		TriState STOR = core->disp->getSTOR(d);
		TriState n_ready = core->wire.n_ready;

		inst->nready_latch.set(n_ready, PHI1);

		TriState TXS = d[13];

		// Register control commands and auxiliary signals for other parts of the random logic

		if (PHI2 == TriState::One)
		{
			TriState n1[7];
			n1[0] = d[1];
			n1[1] = d[2];
			n1[2] = d[3];
			n1[3] = d[4];
			n1[4] = d[5];
			n1[5] = AND(d[6], d[7]);
			n1[6] = AND(d[0], STOR);
			TriState n_Y_SB = NOR7(n1);
			inst->ysb_latch.set(n_Y_SB, PHI2);

			TriState n2[7];
			n2[0] = AND(STOR, d[12]);
			n2[1] = AND(d[6], NOT(d[7]));
			n2[2] = d[8];
			n2[3] = d[9];
			n2[4] = d[10];
			n2[5] = d[11];
			n2[6] = TXS;
			TriState n_X_SB = NOR7(n2);
			inst->xsb_latch.set(n_X_SB, PHI2);
		}

		TriState STXY = NOR(AND(STOR, d[0]), AND(STOR, d[12]));

		inst->ssb_latch.set(NOT(d[17]), PHI2);

		TriState n_SB_X = NOR3(d[14], d[15], d[16]);
		inst->sbx_latch.set(n_SB_X, PHI2);
		TriState n_SB_Y = NOR3(d[18], d[19], d[20]);
		inst->sby_latch.set(n_SB_Y, PHI2);

		TriState SBXY = NAND(n_SB_X, n_SB_Y);

		TriState n3[6];
		n3[0] = d[21];
		n3[1] = d[22];
		n3[2] = d[23];
		n3[3] = d[24];
		n3[4] = d[25];
		n3[5] = d[26];
		TriState STKOP = NOR(inst->nready_latch.get(), NOR6(n3));

		if (PHI2 == TriState::One)
		{
			TriState n_SB_S = NOR3(TXS, NOR(NOT(d[48]), n_ready), STKOP);
			inst->sbs_latch.set(n_SB_S, PHI2);
			inst->ss_latch.set(NOT(n_SB_S), PHI2);

			TriState n_S_ADL = NOR(AND(d[21], inst->nready_latch.nget()), d[35]);
			inst->sadl_latch.set(n_S_ADL, PHI2);
		}

		// Outputs

		core->cmd.Y_SB = NOR(inst->ysb_latch.get(), PHI2);
		core->cmd.X_SB = NOR(inst->xsb_latch.get(), PHI2);
		core->cmd.S_SB = inst->ssb_latch.nget();
		core->cmd.SB_X = NOR(inst->sbx_latch.get(), PHI2);
		core->cmd.SB_Y = NOR(inst->sby_latch.get(), PHI2);
		core->cmd.SB_S = NOR(inst->sbs_latch.get(), PHI2);
		core->cmd.S_S = NOR(inst->ss_latch.get(), PHI2);
		core->cmd.S_ADL = inst->sadl_latch.nget();
	}
}
