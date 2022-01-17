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

		t2_latch1.set(MUX(n_ready, t1_latch.nget(), t2_latch2.nget()), PHI1);
		TriState T2 = NOR(t2_latch1.get(), TRES2);
		t2_latch2.set(T2, PHI2);

		t3_latch1.set(MUX(n_ready, t2_latch2.nget(), t3_latch2.nget()), PHI1);
		TriState T3 = NOR(t3_latch1.get(), TRES2);
		t3_latch2.set(T3, PHI2);

		t4_latch1.set(MUX(n_ready, t3_latch2.nget(), t4_latch2.nget()), PHI1);
		TriState T4 = NOR(t4_latch1.get(), TRES2);
		t4_latch2.set(T4, PHI2);

		t5_latch1.set(MUX(n_ready, t4_latch2.nget(), t5_latch2.nget()), PHI1);
		TriState T5 = NOR(t5_latch1.get(), TRES2);
		t5_latch2.set(T5, PHI2);

		outputs[(size_t)ExtraCounter_Output::n_T2] = NOT(T2);
		outputs[(size_t)ExtraCounter_Output::n_T3] = NOT(T3);
		outputs[(size_t)ExtraCounter_Output::n_T4] = NOT(T4);
		outputs[(size_t)ExtraCounter_Output::n_T5] = NOT(T5);
	}
}
