#include "pch.h"

using namespace BaseLogic;

namespace M6502Core
{
	void IR::sim(TriState PHI1, TriState FETCH, TriState n_in[8])
	{
		for (size_t n = 0; n < 8; n++)
		{
			ir_latch[n].set(n_in[n], AND(PHI1, FETCH));
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
