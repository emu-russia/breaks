#include "pch.h"

using namespace BaseLogic;

namespace M6502Core
{
	PreDecode::PreDecode(M6502* parent)
	{
		core = parent;

		// Pre-calculate the values for n_TWOCYCLE / n_IMPLIED

		for (size_t pd = 0; pd < 0x100; pd++)
		{
			TriState PD0 = pd & 0b00000001 ? TriState::One : TriState::Zero;
			TriState PD1 = pd & 0b00000010 ? TriState::One : TriState::Zero;
			TriState PD2 = pd & 0b00000100 ? TriState::One : TriState::Zero;
			TriState PD3 = pd & 0b00001000 ? TriState::One : TriState::Zero;
			TriState PD4 = pd & 0b00010000 ? TriState::One : TriState::Zero;
			TriState PD5 = pd & 0b00100000 ? TriState::One : TriState::Zero;
			TriState PD6 = pd & 0b01000000 ? TriState::One : TriState::Zero;
			TriState PD7 = pd & 0b10000000 ? TriState::One : TriState::Zero;

			TriState IMPLIED = NOR3(PD0, PD2, NOT(PD3));

			TriState res2 = NOR3(PD1, PD4, PD7);

			TriState in3[4];
			in3[0] = NOT(PD0);
			in3[1] = PD2;
			in3[2] = NOT(PD3);
			in3[3] = PD4;
			TriState res3 = NOR4(in3);

			TriState in4[5];
			in4[0] = PD0;
			in4[1] = PD2;
			in4[2] = PD3;
			in4[3] = PD4;
			in4[4] = NOT(PD7);
			TriState res4 = NOR5(in4);

			precalc_n_TWOCYCLE[pd] = AND(NAND(IMPLIED, NOT(res2)), NOR(res3, res4));
			precalc_n_IMPLIED[pd] = NOT(IMPLIED);
		}
	}

	void PreDecode::sim(uint8_t* data_bus)
	{
		TriState PHI2 = core->wire.PHI2;
		TriState Z_IR = core->wire.Z_IR;

		if (PHI2 != TriState::One)
		{
			PD = Z_IR ? 0 : ~pd_latch;
			n_PD = ~PD;
			return;
		}

		if (PHI2)
		{
			pd_latch = ~(*data_bus);
		}

		PD = Z_IR ? 0 : ~pd_latch;
		n_PD = ~PD;

		core->wire.n_TWOCYCLE = precalc_n_TWOCYCLE[PD];
		core->wire.n_IMPLIED = precalc_n_IMPLIED[PD];
	}
}
