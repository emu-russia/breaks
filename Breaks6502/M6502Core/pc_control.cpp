#include "pch.h"

using namespace BaseLogic;

namespace M6502Core
{
	void PC_Control::sim()
	{
		TriState* d = core->decoder_out;
		TriState PHI1 = core->wire.PHI1;
		TriState PHI2 = core->wire.PHI2;
		TriState n_ready = core->wire.n_ready;

		// These two wires are used in the dispatcher, but are only needed during PHI2.

		TriState PC_DB = TriState::Zero;
		TriState n_ADL_PCL = TriState::Zero;

		if (PHI2 == TriState::One)
		{
			TriState T0 = core->wire.T0;
			TriState T1 = core->disp->getT1();
			TriState BR0 = AND(d[73], NOT(core->wire.n_PRDY));

			TriState JSR_5 = d[56];
			TriState RTS_5 = d[84];
			TriState pp = d[129];
			TriState BR2 = d[80];
			TriState BR3 = d[93];

			TriState ABS_2 = AND(d[83], NOT(pp));
			TriState JB = NOR3(d[94], d[95], d[96]);

			// DB

			TriState n_PCH_DB = NOR(d[77], d[78]);
			pch_db_latch1.set(n_PCH_DB, PHI2);
			TriState n_PCL_DB = pcl_db_latch1.nget();
			PC_DB = NAND(n_PCL_DB, n_PCH_DB);
			pcl_db_latch2.set(n_PCL_DB, PHI2);
			pch_db_latch2.set(n_PCH_DB, PHI2);

			// ADL

			TriState n1[5];
			n1[0] = T1;
			n1[1] = JSR_5;
			n1[2] = ABS_2;
			n1[3] = NOR(NOR(JB, nready_latch.get()), NOT(T0));
			n1[4] = BR2;
			TriState n_PCL_ADL = NOR5(n1);
			pcl_adl_latch.set(n_PCL_ADL, PHI2);

			TriState n2[4];
			n2[0] = NOT(n_PCL_ADL);
			n2[1] = RTS_5;
			n2[2] = T0;
			n2[3] = AND(NOT(nready_latch.get()), BR3);
			n_ADL_PCL = NOR4(n2);
			pcl_pcl_latch.set(NOT(n_ADL_PCL), PHI2);
			adl_pcl_latch.set(n_ADL_PCL, PHI2);

			// ADH

			TriState DL_PCH = NOR(NOT(T0), JB);
			TriState n_PCH_ADH = NOR(NOR3(n_PCL_ADL, DL_PCH, BR0), BR3);
			pch_adh_latch.set(n_PCH_ADH, PHI2);

			TriState n3[6];
			n3[0] = RTS_5;
			n3[1] = ABS_2;
			n3[2] = T0;
			n3[3] = T1;
			n3[4] = BR2;
			n3[5] = BR3;
			TriState n_ADH_PCH = NOR6(n3);
			adh_pch_latch.set(n_ADH_PCH, PHI2);
			TriState n_PCH_PCH = NOT(n_ADH_PCH);
			pch_pch_latch.set(n_PCH_PCH, PHI2);
		}
		else
		{
			// All you have to do during PHI1 is to update these 2 latches.

			nready_latch.set(n_ready, PHI1);
			pcl_db_latch1.set(NOR(pch_db_latch1.get(), n_ready), PHI1);
		}

		// Outputs

		core->cmd.PCL_DB = pcl_db_latch2.nget();
		core->cmd.PCH_DB = pch_db_latch2.nget();
		core->cmd.PCL_ADL = pcl_adl_latch.nget();
		core->cmd.PCH_ADH = pch_adh_latch.nget();

		if (PHI2 == TriState::One)
		{
			core->cmd.PCL_PCL = 0;
			core->cmd.ADL_PCL = 0;
			core->cmd.ADH_PCH = 0;
			core->cmd.PCH_PCH = 0;
		}
		else
		{
			core->cmd.PCL_PCL = NOT(pcl_pcl_latch.get());
			core->cmd.ADL_PCL = NOT(adl_pcl_latch.get());
			core->cmd.ADH_PCH = NOT(adh_pch_latch.get());
			core->cmd.PCH_PCH = NOT(pch_pch_latch.get());
		}

		// For dispatcher

		core->wire.PC_DB = PC_DB;
		core->wire.n_ADL_PCL = n_ADL_PCL;
	}
}
