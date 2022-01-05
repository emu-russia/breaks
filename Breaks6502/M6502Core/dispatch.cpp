#include "pch.h"

using namespace BaseLogic;

namespace M6502Core
{
	void Dispatcher::sim_BeforeDecoder(TriState inputs[], TriState outputs[])
	{
		TriState PHI1 = inputs[(size_t)Dispatcher_Input::PHI1];
		TriState PHI2 = inputs[(size_t)Dispatcher_Input::PHI2];
		TriState RDY = inputs[(size_t)Dispatcher_Input::RDY];
		TriState DORES = inputs[(size_t)Dispatcher_Input::DORES];
		TriState B_OUT = inputs[(size_t)Dispatcher_Input::B_OUT];

		// Processor Readiness

		ready_latch1.set(NOR(RDY, ready_latch2.get()), PHI2);
		rdy_ff.set(NOT(ready_latch1.nget()));
		TriState WR = NOR3(rdy_ff.get(), wr_latch.get(), DORES);
		ready_latch2.set(WR, PHI1);
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
		outputs[(size_t)Dispatcher_Output::WR] = WR;
	}

	void Dispatcher::sim_BeforeRandomLogic(TriState inputs[], TriState d[], TriState outputs[])
	{
		// TODO..
	}

	void Dispatcher::sim_AfterRandomLogic(TriState inputs[], TriState d[], TriState outputs[])
	{
		TriState PHI1 = inputs[(size_t)Dispatcher_Input::PHI1];
		TriState PHI2 = inputs[(size_t)Dispatcher_Input::PHI2];
		TriState BRK6E = inputs[(size_t)Dispatcher_Input::BRK6E];
		TriState RESP = inputs[(size_t)Dispatcher_Input::RESP];
		TriState ACR = inputs[(size_t)Dispatcher_Input::ACR];
		TriState BRFW = inputs[(size_t)Dispatcher_Input::BRFW];
		TriState n_BRTAKEN = inputs[(size_t)Dispatcher_Input::n_BRTAKEN];
		TriState n_TWOCYCLE = inputs[(size_t)Dispatcher_Input::n_TWOCYCLE];
		TriState n_IMPLIED = inputs[(size_t)Dispatcher_Input::n_IMPLIED];
		TriState PC_DB = inputs[(size_t)Dispatcher_Input::PC_DB];
		TriState n_ADL_PCL = inputs[(size_t)Dispatcher_Input::n_ADL_PCL];
		TriState n_ready = inputs[(size_t)Dispatcher_Input::n_ready];
		TriState T0 = inputs[(size_t)Dispatcher_Input::T0];
		TriState B_OUT = inputs[(size_t)Dispatcher_Input::B_OUT];

		TriState BR2 = d[80];
		TriState BR3 = d[93];

		TriState n_SHIFT = NOR(d[106], d[107]);

		TriState memop_in[5];

		memop_in[0] = d[111];
		memop_in[1] = d[122];
		memop_in[2] = d[123];
		memop_in[3] = d[124];
		memop_in[4] = d[125];

		TriState n_MemOp = NOR5(memop_in);

		TriState n_STORE = NOT(d[97]);
		TriState STOR = NOR(n_MemOp, n_STORE);
		TriState REST = NAND(n_SHIFT, n_STORE);

		// Ready Delay

		rdydelay_latch1.set(n_ready, PHI1);
		rdydelay_latch2.set(rdydelay_latch1.nget(), PHI2);
		TriState NotReadyPhi1 = rdydelay_latch2.nget();

		// ACRL

		TriState ACRL1 = NOR( AND(NOT(ACR), NOT(NotReadyPhi1)), NOR(NOT(NotReadyPhi1), acrl_ff.get()) );
		acr_latch1.set(ACRL1, PHI1);
		acr_latch2.set(acr_latch1.nget(), PHI2);
		acrl_ff.set(acr_latch2.nget());
		TriState ACRL2 = acrl_ff.get();

		// Increment PC

		br_latch1.set(NOR(AND(n_BRTAKEN, BR2), NOR(n_ADL_PCL, NOT(NOR(BR2, BR3)))), PHI2);
		br_latch2.set(NOR(NOT(BR3), NotReadyPhi1), PHI2);
		TriState ipc_temp = NOR(XOR(BRFW, ACR), br_latch2.nget());
		ipc_latch1.set(B_OUT, PHI1);
		ipc_latch2.set(ipc_temp, PHI1);
		ipc_latch3.set(NOR3(n_ready, br_latch1.get(), NOT(n_IMPLIED)), PHI1);
		TriState n_1PC = NAND(ipc_latch1.get(), OR(ipc_latch2.get(), ipc_latch3.get()));

		// Step T1

		nready_latch.set(NOT(n_ready), PHI1);
		step_latch1.set(NOR3(nready_latch.get(), RESP, step_latch2.get()), PHI2);
		step_ff.set(NOR(step_latch1.get(), ipc_temp));
		step_latch2.set(step_ff.get(), PHI1);

		// T5 / T6

		t56_latch.set(NOR3(n_SHIFT, n_MemOp, n_ready), PHI2);
		t5_latch2.set(t5_ff.get(), PHI2);
		t5_latch1.set(NOR(AND(t5_latch2.get(), n_ready), t56_latch.get()), PHI1);
		t5_ff.set(t5_latch1.get());
		TriState T5 = t5_ff.get();

		t6_latch1.set(NAND(T5, NOT(n_ready)), PHI2);
		t6_latch2.set(t6_latch1.nget(), PHI1);
		TriState T6 = NOT(t6_latch2.nget());

		// Instruction Completion

		ends_latch1.set(MUX(n_ready, NOR(T0, AND(n_BRTAKEN, BR2)), NOT(t1_ff.get())), PHI2);
		ends_latch2.set(RESP, PHI2);
		TriState ENDS = NOR(ends_latch1.get(), ends_latch2.get());
		TriState n_TRES1 = NOR(NOR(step_ff.get(), n_ready), ENDS);
		t1_latch.set(n_TRES1, PHI1);
		TriState TRES1 = NOT(n_TRES1);
		TriState T1 = t1_latch.nget();
		t1_ff.set(T1);

		tresx_latch1.set(NOR(d[91], d[92]), PHI2);

		TriState endx_1[6];

		endx_1[0] = d[100];
		endx_1[1] = d[101];
		endx_1[2] = d[102];
		endx_1[3] = d[103];
		endx_1[4] = d[104];
		endx_1[5] = d[105];

		TriState endx_2[4];

		endx_2[0] = NOR3(d[96], NOT(n_SHIFT), n_MemOp);
		endx_2[1] = T6;
		endx_2[2] = NOT(NOR6(endx_1));
		endx_2[3] = BR3;

		TriState ENDX = NOR4(endx_2);

		tresx_latch2.set(NOR3(RESP, ENDS, NOR(n_ready, ENDX)), PHI2);

		TriState tresx_nor[4];

		tresx_nor[0] = ACRL1;
		tresx_nor[1] = tresx_latch1.get();
		tresx_nor[2] = n_ready;
		tresx_nor[3] = REST;

		TriState TRESX = NOR3(NOR4(tresx_nor), BRK6E, tresx_latch2.nget());
		tres2_latch.set(TRESX, PHI1);

		comp_latch1.set(TRES1, PHI1);
		comp_latch2.set(n_TWOCYCLE, PHI1);
		comp_latch3.set(TRESX, PHI1);

		// WR

		TriState wr_in[6];

		wr_in[0] = STOR;
		wr_in[1] = PC_DB;
		wr_in[2] = d[98];
		wr_in[3] = d[100];
		wr_in[4] = T5;
		wr_in[5] = T6;

		wr_latch.set(NOR6(wr_in), PHI2);

		// Outputs

		outputs[(size_t)Dispatcher_Output::ACRL2] = ACRL2;
		outputs[(size_t)Dispatcher_Output::T1] = T1;
		outputs[(size_t)Dispatcher_Output::T5] = T5;
		outputs[(size_t)Dispatcher_Output::T6] = T6;
		outputs[(size_t)Dispatcher_Output::n_1PC] = n_1PC;
	}

	TriState Dispatcher::getTRES2()
	{
		return tres2_latch.nget();
	}

	TriState Dispatcher::getT1()
	{
		return t1_ff.get();
	}
}
