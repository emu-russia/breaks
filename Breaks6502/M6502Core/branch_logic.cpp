#include "pch.h"

using namespace BaseLogic;

namespace M6502Core
{
	void BranchLogic::sim()
	{
		TriState* d = core->decoder_out;
		TriState PHI1 = core->wire.PHI1;
		TriState PHI2 = core->wire.PHI2;
		TriState n_IR5 = core->wire.n_IR5;
		TriState n_C_OUT = core->random->flags->getn_C_OUT();
		TriState n_V_OUT = core->random->flags->getn_V_OUT();
		TriState n_N_OUT = core->random->flags->getn_N_OUT();
		TriState n_Z_OUT = core->random->flags->getn_Z_OUT();
		TriState DB7 = core->DB & 0x80 ? TriState::One : TriState::Zero;
		TriState BR2 = d[80];

		// BRTAKEN

		TriState n_IR6 = d[121];
		TriState n_IR7 = d[126];

		TriState res_C = NOR3(n_C_OUT, NOT(n_IR6), n_IR7);
		TriState res_V = NOR3(n_V_OUT, n_IR6, NOT(n_IR7));
		TriState res_N = NOR3(n_N_OUT, NOT(n_IR6), NOT(n_IR7));
		TriState res_Z = NOR3(n_Z_OUT, n_IR6, n_IR7);

		TriState in1[4];
		in1[0] = res_C;
		in1[1] = res_V;
		in1[2] = res_N;
		in1[3] = res_Z;
		TriState n_BRTAKEN = XOR(NOR4(in1), n_IR5);

		// BRFW

		TriState n_DB7 = DB7 == TriState::Z ? TriState::One : NOT(DB7);
		brfw_latch1.set(NOT(MUX(br2_latch.get(), brfw_latch2.get(), n_DB7)), PHI1);
		br2_latch.set(BR2, PHI2);
		brfw_latch2.set(brfw_latch1.nget(), PHI2);
		TriState BRFW = NOT(brfw_latch1.nget());

		core->wire.n_BRTAKEN = n_BRTAKEN;
		core->wire.BRFW = BRFW;
	}

	TriState BranchLogic::getBRFW()
	{
		return NOT(brfw_latch1.nget());
	}
}
