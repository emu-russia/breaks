#include "pch.h"

using namespace BaseLogic;

namespace M6502Core
{
	void ExtraCounter::sim(TriState inputs[], TriState outputs[])
	{
		TriState PHI1 = inputs[(size_t)ExtraCounter_Input::PHI1];
		TriState PHI2 = inputs[(size_t)ExtraCounter_Input::PHI2];
		TriState T1 = inputs[(size_t)ExtraCounter_Input::T1];
		TriState TRES2 = inputs[(size_t)ExtraCounter_Input::TRES2];
		TriState n_ready = inputs[(size_t)ExtraCounter_Input::n_ready];

		t1_latch.set(T1, PHI2);

		t2_latch2.set(MUX(n_ready, t1_latch.nget(), t2_latch1.nget()), PHI1);
		t2_latch1.set(NOR(t2_latch2.get(), TRES2), PHI2);

		t3_latch2.set(MUX(n_ready, t2_latch1.nget(), t3_latch1.nget()), PHI1);
		t3_latch1.set(NOR(t3_latch2.get(), TRES2), PHI2);

		t4_latch2.set(MUX(n_ready, t3_latch1.nget(), t4_latch1.nget()), PHI1);
		t4_latch1.set(NOR(t4_latch2.get(), TRES2), PHI2);

		t5_latch2.set(MUX(n_ready, t4_latch1.nget(), t5_latch1.nget()), PHI1);
		t5_latch1.set(NOR(t5_latch2.get(), TRES2), PHI2);

		outputs[(size_t)ExtraCounter_Output::n_T2] = NOT(NOR(t2_latch2.get(), TRES2));
		outputs[(size_t)ExtraCounter_Output::n_T3] = NOT(NOR(t3_latch2.get(), TRES2));
		outputs[(size_t)ExtraCounter_Output::n_T4] = NOT(NOR(t4_latch2.get(), TRES2));
		outputs[(size_t)ExtraCounter_Output::n_T5] = NOT(NOR(t5_latch2.get(), TRES2));

		if (trace)
		{
			printf("ExtraCounter: PHI1: %d, PHI2: %d, /ready: %d, T1: %d, /T2: %d, /T3: %d, /T4: %d, /T5: %d\n",
				PHI1, PHI2, n_ready, T1,
				outputs[(size_t)ExtraCounter_Output::n_T2],
				outputs[(size_t)ExtraCounter_Output::n_T3],
				outputs[(size_t)ExtraCounter_Output::n_T4],
				outputs[(size_t)ExtraCounter_Output::n_T5]);
		}
	}
}
