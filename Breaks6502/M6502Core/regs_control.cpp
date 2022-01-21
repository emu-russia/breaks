#include "pch.h"

using namespace BaseLogic;

namespace M6502Core
{
	void RegsControl::sim(TriState inputs[], TriState d[], TriState outputs[])
	{
		TriState PHI1 = inputs[(size_t)RegsControl_Input::PHI1];
		TriState PHI2 = inputs[(size_t)RegsControl_Input::PHI2];
		TriState STOR = inputs[(size_t)RegsControl_Input::STOR];
		TriState n_ready = inputs[(size_t)RegsControl_Input::n_ready];

		nready_latch.set(n_ready, PHI1);

		TriState TXS = d[13];

		// Register control commands and auxiliary signals for other parts of the random logic

		if (PHI2 == TriState::One)
		{
			TriState n1[7];
			n1[0] = d[1];
			n1[1] = d[2];
			n1[2] = d[3];
			n1[3] = d[4];
			n1[4] = d[5];
			n1[5] = AND(d[6], d[7]);
			n1[6] = AND(d[0], STOR);
			TriState n_Y_SB = NOR7(n1);
			ysb_latch.set(n_Y_SB, PHI2);

			TriState n2[7];
			n2[0] = AND(STOR, d[12]);
			n2[1] = AND(d[6], NOT(d[7]));
			n2[2] = d[8];
			n2[3] = d[9];
			n2[4] = d[10];
			n2[5] = d[11];
			n2[6] = TXS;
			TriState n_X_SB = NOR7(n2);
			xsb_latch.set(n_X_SB, PHI2);
		}

		TriState STXY = NOR(AND(STOR, d[0]), AND(STOR, d[12]));

		ssb_latch.set(NOT(d[17]), PHI2);

		TriState n_SB_X = NOR3(d[14], d[15], d[16]);
		sbx_latch.set(n_SB_X, PHI2);
		TriState n_SB_Y = NOR3(d[18], d[19], d[20]);
		sby_latch.set(n_SB_Y, PHI2);

		TriState SBXY = NAND(n_SB_X, n_SB_Y);

		TriState n3[6];
		n3[0] = d[21];
		n3[1] = d[22];
		n3[2] = d[23];
		n3[3] = d[24];
		n3[4] = d[25];
		n3[5] = d[26];
		TriState STKOP = NOR(nready_latch.get(), NOR6(n3));

		if (PHI2 == TriState::One)
		{
			TriState n_SB_S = NOR3(TXS, NOR(NOT(d[48]), n_ready), STKOP);
			sbs_latch.set(n_SB_S, PHI2);
			ss_latch.set(NOT(n_SB_S), PHI2);

			TriState n_S_ADL = NOR(AND(d[21], nready_latch.nget()), d[35]);
			sadl_latch.set(n_S_ADL, PHI2);
		}

		// Outputs

		outputs[(size_t)RegsControl_Output::Y_SB] = NOR(ysb_latch.get(), PHI2);
		outputs[(size_t)RegsControl_Output::X_SB] = NOR(xsb_latch.get(), PHI2);
		outputs[(size_t)RegsControl_Output::S_SB] = ssb_latch.nget();
		outputs[(size_t)RegsControl_Output::SB_X] = NOR(sbx_latch.get(), PHI2);
		outputs[(size_t)RegsControl_Output::SB_Y] = NOR(sby_latch.get(), PHI2);
		outputs[(size_t)RegsControl_Output::SB_S] = NOR(sbs_latch.get(), PHI2);
		outputs[(size_t)RegsControl_Output::S_S] = NOR(ss_latch.get(), PHI2);
		outputs[(size_t)RegsControl_Output::S_ADL] = sadl_latch.nget();

		outputs[(size_t)RegsControl_Output::STXY] = STXY;
		outputs[(size_t)RegsControl_Output::SBXY] = SBXY;
		outputs[(size_t)RegsControl_Output::STKOP] = STKOP;
	}
}
