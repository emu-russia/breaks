#include "pch.h"

using namespace BaseLogic;

// The dispatcher simulation is divided into three stages: before decoder, before random logic, and after random logic.

// So far in this form (critical mass of code). In the process of debugging, it is possible to rearrange some sections.

namespace M6502Core
{
	void Dispatcher::sim_BeforeDecoder()
	{
		TriState PHI1 = core->wire.PHI1;
		TriState PHI2 = core->wire.PHI2;
		TriState RDY = core->wire.RDY;
		TriState DORES = core->brk->getDORES();
		TriState ACR = core->alu->getACR();

		// Processor Readiness

		TriState WR = NOR3(NOT(ready_latch1.nget()), wr_latch.get(), DORES);
		ready_latch2.set(WR, PHI1);
		ready_latch1.set(NOR(RDY, ready_latch2.get()), PHI2);
		TriState n_ready = NOT(ready_latch1.nget());

		// Ready Delay

		rdydelay_latch1.set(n_ready, PHI1);
		rdydelay_latch2.set(rdydelay_latch1.nget(), PHI2);
		TriState NotReadyPhi1 = rdydelay_latch2.nget();

		// ACRL

		TriState ACRL1 = NOR(AND(NOT(ACR), NOT(NotReadyPhi1)), NOR(NOT(NotReadyPhi1), acr_latch2.nget()));
		acr_latch1.set(ACRL1, PHI1);
		acr_latch2.set(acr_latch1.nget(), PHI2);
		TriState ACRL2 = acr_latch2.nget();

		// Short Cycle Counter

		t1x_latch.set(NOR(t0_latch.get(), n_ready), PHI1);
		TriState n_T0 = NOR(NOR(comp_latch1.get(), AND(comp_latch2.get(), comp_latch3.get())), NOR(t0_latch.get(), t1x_latch.get()));
		t0_latch.set(n_T0, PHI2);
		TriState T0 = NOT(n_T0);
		TriState n_T1X = t1x_latch.nget();

		// Opcode Fetch

		TriState BRK6E = NOR(core->brk->getn_BRK6_LATCH2(), n_ready);
		TriState B_OUT = core->brk->getB_OUT(BRK6E);

		TriState T1 = t1_latch.nget();
		fetch_latch.set(T1, PHI2);
		TriState FETCH = NOR(fetch_latch.nget(), n_ready);
		TriState Z_IR = NAND(B_OUT, FETCH);

		// Outputs

		core->wire.T0 = T0;
		core->wire.n_T0 = n_T0;
		core->wire.n_T1X = n_T1X;
		core->wire.Z_IR = Z_IR;
		core->wire.FETCH = FETCH;
		core->wire.n_ready = n_ready;
		core->wire.ACRL1 = ACRL1;
		core->wire.ACRL2 = ACRL2;
	}

	void Dispatcher::sim_BeforeRandomLogic()
	{
		TriState* d = core->decoder_out;
		TriState PHI1 = core->wire.PHI1;
		TriState PHI2 = core->wire.PHI2;
		TriState n_ready = core->wire.n_ready;

		TriState n_SHIFT = NOR(d[106], d[107]);

		TriState memop_in[5];
		memop_in[0] = d[111];
		memop_in[1] = d[122];
		memop_in[2] = d[123];
		memop_in[3] = d[124];
		memop_in[4] = d[125];
		TriState n_MemOp = NOR5(memop_in);

		// T5 / T6

		t5_latch1.set(NOR(AND(t5_latch2.get(), n_ready), t56_latch.get()), PHI1);
		t6_latch2.set(t6_latch1.nget(), PHI1);
		t56_latch.set(NOR3(n_SHIFT, n_MemOp, n_ready), PHI2);
		t5_latch2.set(t5_latch1.nget(), PHI2);
		TriState T5 = t5_latch1.nget();
		t6_latch1.set(NAND(T5, NOT(n_ready)), PHI2);
		TriState T6 = NOT(t6_latch2.nget());

		core->wire.T5 = T5;
		core->wire.T6 = T6;
	}

	void Dispatcher::sim_AfterRandomLogic()
	{
		TriState* d = core->decoder_out;
		TriState PHI1 = core->wire.PHI1;
		TriState PHI2 = core->wire.PHI2;
		TriState BRK6E = core->wire.BRK6E;
		TriState RESP = core->wire.RESP;
		TriState ACR = core->alu->getACR();
		TriState BRFW = core->wire.BRFW;
		TriState n_BRTAKEN = core->wire.n_BRTAKEN;
		TriState n_TWOCYCLE = core->wire.n_TWOCYCLE;
		TriState n_IMPLIED = core->wire.n_IMPLIED;
		TriState PC_DB = core->wire.PC_DB;
		TriState n_ADL_PCL = core->wire.n_ADL_PCL;
		TriState n_ready = core->wire.n_ready;
		TriState T0 = core->wire.T0;
		TriState B_OUT = core->brk->getB_OUT(BRK6E);
		TriState T5 = core->wire.T5;
		TriState T6 = core->wire.T6;
		TriState ACRL1 = core->wire.ACRL1;
		TriState ACRL2 = core->wire.ACRL2;
		TriState RDY = core->wire.RDY;
		TriState DORES = core->wire.DORES;

		TriState BR2 = d[80];
		TriState BR3 = d[93];

		TriState n_SHIFT = NOR(d[106], d[107]);

		TriState n_STORE = NOT(d[97]);
		TriState REST = NAND(n_SHIFT, n_STORE);

		// Ready Delay (get)

		TriState NotReadyPhi1 = rdydelay_latch2.nget();

		// Increment PC

		br_latch1.set(NOR(AND(n_BRTAKEN, BR2), NOR(n_ADL_PCL, NOT(NOR(BR2, BR3)))), PHI2);
		br_latch2.set(NOR(NOT(BR3), NotReadyPhi1), PHI2);
		TriState ipc_temp = AND(XOR(BRFW, NOT(ACR)), NOT(br_latch2.nget()));
		ipc_latch1.set(B_OUT, PHI1);
		ipc_latch2.set(ipc_temp, PHI1);
		ipc_latch3.set(NOR3(n_ready, br_latch1.get(), NOT(n_IMPLIED)), PHI1);
		TriState n_1PC = NAND(ipc_latch1.get(), OR(ipc_latch2.get(), ipc_latch3.get()));

		// Step T1

		nready_latch.set(NOT(n_ready), PHI1);
		step_latch2.set(NOR(step_latch1.get(), ipc_temp), PHI1);
		step_latch1.set(NOR3(nready_latch.get(), RESP, step_latch2.get()), PHI2);

		// Instruction Completion

		TriState ENDS = NOR(ends_latch1.get(), ends_latch2.get());
		TriState n_TRES1 = NOR(NOR(NOR(step_latch1.get(), ipc_temp), n_ready), ENDS);
		t1_latch.set(n_TRES1, PHI1);
		TriState T1 = t1_latch.nget();
		ends_latch1.set(MUX(n_ready, NOR(T0, AND(n_BRTAKEN, BR2)), NOT(T1)), PHI2);
		ends_latch2.set(RESP, PHI2);
		TriState TRES1 = NOT(n_TRES1);

		tresx_latch1.set(NOR(d[91], d[92]), PHI2);

		TriState ENDX;
		TriState n_MemOp;

		if (PHI2)
		{
			TriState memop_in[5];
			memop_in[0] = d[111];
			memop_in[1] = d[122];
			memop_in[2] = d[123];
			memop_in[3] = d[124];
			memop_in[4] = d[125];
			n_MemOp = NOR5(memop_in);

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

			ENDX = NOR4(endx_2);

			tresx_latch2.set(NOR3(RESP, ENDS, NOR(n_ready, ENDX)), PHI2);
		}
		else
		{
			ENDX = core->wire.ENDX;
		}

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

		if (PHI2)
		{
			TriState STOR = NOR(n_MemOp, n_STORE);

			TriState wr_in[6];
			wr_in[0] = STOR;
			wr_in[1] = PC_DB;
			wr_in[2] = d[98];
			wr_in[3] = d[100];
			wr_in[4] = T5;
			wr_in[5] = T6;
			wr_latch.set(NOR6(wr_in), PHI2);
		}

		// Processor Readiness

		TriState WR = NOR3(NOT(ready_latch1.nget()), wr_latch.get(), DORES);
		ready_latch2.set(WR, PHI1);
		ready_latch1.set(NOR(RDY, ready_latch2.get()), PHI2);

		// Outputs

		core->wire.n_1PC = n_1PC;
		core->wire.WR = WR;

		core->wire.ENDS = ENDS;
		core->wire.ENDX = ENDX;
		core->wire.TRES1 = TRES1;
		core->wire.TRESX = TRESX;
	}

	TriState Dispatcher::getTRES2()
	{
		return tres2_latch.nget();
	}

	TriState Dispatcher::getT1()
	{
		return t1_latch.nget();
	}

	TriState Dispatcher::getSTOR(TriState d[])
	{
		TriState memop_in[5];
		memop_in[0] = d[111];
		memop_in[1] = d[122];
		memop_in[2] = d[123];
		memop_in[3] = d[124];
		memop_in[4] = d[125];
		TriState n_MemOp = NOR5(memop_in);

		TriState n_STORE = NOT(d[97]);
		TriState STOR = NOR(n_MemOp, n_STORE);

		return STOR;
	}
}
