#include "pch.h"

using namespace BaseLogic;

namespace M6502Core
{
	void ExtraCounter::sim()
	{
		TriState PHI1 = core->wire.PHI1;
		TriState PHI2 = core->wire.PHI2;
		TriState T1 = core->disp->getT1();
		TriState TRES2 = core->disp->getTRES2();

		TriState T2;
		TriState T3;
		TriState T4;
		TriState T5;

		if (PHI1 == TriState::One)
		{
			TriState n_ready = core->wire.n_ready;

			t2_latch1.set(MUX(n_ready, t1_latch.nget(), t2_latch2.nget()), PHI1);
			t3_latch1.set(MUX(n_ready, t2_latch2.nget(), t3_latch2.nget()), PHI1);
			t4_latch1.set(MUX(n_ready, t3_latch2.nget(), t4_latch2.nget()), PHI1);
			t5_latch1.set(MUX(n_ready, t4_latch2.nget(), t5_latch2.nget()), PHI1);

			T2 = NOR(t2_latch1.get(), TRES2);
			T3 = NOR(t3_latch1.get(), TRES2);
			T4 = NOR(t4_latch1.get(), TRES2);
			T5 = NOR(t5_latch1.get(), TRES2);
		}
		else
		{
			t1_latch.set(T1, PHI2);

			T2 = NOR(t2_latch1.get(), TRES2);
			t2_latch2.set(T2, PHI2);

			T3 = NOR(t3_latch1.get(), TRES2);
			t3_latch2.set(T3, PHI2);

			T4 = NOR(t4_latch1.get(), TRES2);
			t4_latch2.set(T4, PHI2);

			T5 = NOR(t5_latch1.get(), TRES2);
			t5_latch2.set(T5, PHI2);
		}

		core->wire.n_T2 = NOT(T2);
		core->wire.n_T3 = NOT(T3);
		core->wire.n_T4 = NOT(T4);
		core->wire.n_T5 = NOT(T5);
	}
}
