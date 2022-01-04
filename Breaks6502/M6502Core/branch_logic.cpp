#include "pch.h"

using namespace BaseLogic;

namespace M6502Core
{
	BranchLogic::BranchLogic()
	{
	}

	BranchLogic::~BranchLogic()
	{
	}

	void BranchLogic::sim(TriState inputs[], TriState outputs[])
	{
		TriState PHI1 = inputs[(size_t)BranchLogic_Input::PHI1];
		TriState PHI2 = inputs[(size_t)BranchLogic_Input::PHI2];

		TriState n_IR5 = inputs[(size_t)BranchLogic_Input::n_IR5];
		TriState D121 = inputs[(size_t)BranchLogic_Input::D121];
		TriState D126 = inputs[(size_t)BranchLogic_Input::D126];

		TriState n_C_OUT = inputs[(size_t)BranchLogic_Input::n_C_OUT];
		TriState n_V_OUT = inputs[(size_t)BranchLogic_Input::n_V_OUT];
		TriState n_N_OUT = inputs[(size_t)BranchLogic_Input::n_N_OUT];
		TriState n_Z_OUT = inputs[(size_t)BranchLogic_Input::n_Z_OUT];

		TriState DB7 = inputs[(size_t)BranchLogic_Input::DB7];
		TriState BR2 = inputs[(size_t)BranchLogic_Input::BR2];

		// BRTAKEN

		TriState res_C = NOR3(n_C_OUT, D126, NOT(D121));
		TriState res_V = NOR3(n_V_OUT, D121, NOT(D126));
		TriState res_N = NOR3(n_N_OUT, NOT(D126), NOT(D121));
		TriState res_Z = NOR3(n_Z_OUT, D126, D121);

		TriState in1[4];

		in1[0] = res_C;
		in1[1] = res_V;
		in1[2] = res_N;
		in1[3] = res_Z;

		TriState nor_res = NOR4(in1);
		TriState n_BRTAKEN = XOR(nor_res, n_IR5);

		outputs[(size_t)BranchLogic_Output::n_BRTAKEN] = n_BRTAKEN;

		// BRFW

		br2_latch.set(BR2, PHI2);
		brfw_latch2.set(brfw_ff.get(), PHI2);
		brfw_latch1.set(NOT(MUX(br2_latch.get(), brfw_latch2.get(), NOT(DB7))), PHI1);
		brfw_ff.set(brfw_latch1.nget());
		TriState BRFW = NOT(brfw_ff.get());

		outputs[(size_t)BranchLogic_Output::BRFW] = BRFW;
	}

	TriState BranchLogic::getBRFW()
	{
		return NOT(brfw_ff.get());
	}
}
