#include "pch.h"

using namespace BaseLogic;

namespace M6502Core
{
	void Dispatcher::sim_BeforeDecoder(TriState inputs[], TriState outputs[])
	{
		TriState PHI1 = inputs[(size_t)Dispatcher_Input::PHI1];
		TriState PHI2 = inputs[(size_t)Dispatcher_Input::PHI2];
		TriState RDY = inputs[(size_t)Dispatcher_Input::RDY];
		TriState BRK6E = inputs[(size_t)Dispatcher_Input::BRK6E];
		TriState RESP = inputs[(size_t)Dispatcher_Input::RESP];
		TriState DORES = inputs[(size_t)Dispatcher_Input::DORES];
		TriState B_OUT = inputs[(size_t)Dispatcher_Input::B_OUT];

		// Processor Readiness

		ready_latch1.set(NOR(RDY, ready_latch2.get()), PHI2);
		rdy_ff.set(NOT(ready_latch1.nget()));
		ready_latch2.set(NOR3(rdy_ff.get(), wr_latch.get(), DORES), PHI1);
		TriState n_ready = rdy_ff.get();

		// Short Cycle Counter

		TriState n_T0 = NOR(NOR(comp_latch1.get(), AND(comp_latch2.get(), comp_latch3.get())), NOR(t0_ff.get(), t1x_latch.get()));
		t0_latch.set(n_T0, PHI2);
		t0_ff.set(t0_latch.get());
		t1x_latch.set(NOR(t0_ff.get(), n_ready), PHI1);
		TriState T0 = NOT(n_T0);
		TriState n_T1X = t1x_latch.nget();

		// Opcode Fetch

		TriState T1 = t1_latch.nget();
		fetch_latch.set(T1, PHI2);
		TriState FETCH = NOR(fetch_latch.nget(), n_ready);
		TriState Z_IR = NAND(B_OUT, FETCH);

		// Outputs

		outputs[(size_t)Dispatcher_Output::T0] = T0;
		outputs[(size_t)Dispatcher_Output::n_T0] = n_T0;
		outputs[(size_t)Dispatcher_Output::n_T1X] = n_T1X;
		outputs[(size_t)Dispatcher_Output::Z_IR] = Z_IR;
		outputs[(size_t)Dispatcher_Output::FETCH] = FETCH;
		outputs[(size_t)Dispatcher_Output::n_ready] = n_ready;
	}

	void Dispatcher::sim_AfterRandomLogic(TriState inputs[], TriState outputs[])
	{

	}

	TriState Dispatcher::getTRES2()
	{
		return tres2_latch.nget();
	}
}
