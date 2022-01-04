#include "pch.h"

namespace M6502Core
{
	IR::IR()
	{
	}

	IR::~IR()
	{
	}

	void IR::sim(BaseLogic::TriState PHI1, BaseLogic::TriState FETCH, BaseLogic::TriState n_in[8])
	{
		for (size_t n = 0; n < 8; n++)
		{
			ir_latch[n].set(n_in[n], AND(PHI1, FETCH));
		}
	}

	void IR::get(BaseLogic::TriState IR[8])
	{
		for (size_t n = 0; n < 8; n++)
		{
			IR[n] = ir_latch[n].nget();
		}
	}
}
