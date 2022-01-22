#include "pch.h"

using namespace BaseLogic;

namespace M6502Core
{
	void IR::sim()
	{
		if (core->wire.PHI1 && core->wire.FETCH)
		{
			ir_latch = core->predecode->n_PD;
			IROut = ~ir_latch;
		}
	}
}
