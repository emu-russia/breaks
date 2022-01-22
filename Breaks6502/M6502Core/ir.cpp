#include "pch.h"

using namespace BaseLogic;

namespace M6502Core
{
	void IR::sim()
	{
		for (size_t n = 0; n < 8; n++)
		{
			ir_latch[n].set(core->predecode->n_PD[n], AND(core->wire.PHI1, core->wire.FETCH));
			IROut[n] = ir_latch[n].nget();
		}
	}

	void IR::get(TriState IR[8])
	{
		for (size_t n = 0; n < 8; n++)
		{
			IR[n] = ir_latch[n].nget();
		}
	}
}
