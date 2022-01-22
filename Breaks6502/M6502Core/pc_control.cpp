#include "pch.h"

using namespace BaseLogic;

namespace M6502Core
{
	void PC_Control::sim(void* param)
	{
		PC_Control* inst = (PC_Control*)param;

		if (!inst->running && inst->mt)
			return;

		M6502* core = inst->core;
		TriState* d = core->decoder_out;
		TriState PHI1 = core->wire.PHI1;
		TriState PHI2 = core->wire.PHI2;
		TriState n_ready = core->wire.n_ready;
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

		inst->nready_latch.set(n_ready, PHI1);

		// DB

		TriState n_PCH_DB = NOR(d[77], d[78]);
		inst->pch_db_latch1.set(n_PCH_DB, PHI2);
		inst->pcl_db_latch1.set(NOR(inst->pch_db_latch1.get(), n_ready), PHI1);
		TriState n_PCL_DB = inst->pcl_db_latch1.nget();
		TriState PC_DB = NAND(n_PCL_DB, n_PCH_DB);
		inst->pcl_db_latch2.set(n_PCL_DB, PHI2);
		inst->pch_db_latch2.set(n_PCH_DB, PHI2);

		// ADL

		TriState n1[5];
		n1[0] = T1;
		n1[1] = JSR_5;
		n1[2] = ABS_2;
		n1[3] = NOR(NOR(JB, inst->nready_latch.get()), NOT(T0));
		n1[4] = BR2;
		TriState n_PCL_ADL = NOR5(n1);
		inst->pcl_adl_latch.set(n_PCL_ADL, PHI2);

		TriState n2[4];
		n2[0] = NOT(n_PCL_ADL);
		n2[1] = RTS_5;
		n2[2] = T0;
		n2[3] = AND(NOT(inst->nready_latch.get()), BR3);
		TriState n_ADL_PCL = NOR4(n2);
		inst->pcl_pcl_latch.set(NOT(n_ADL_PCL), PHI2);
		inst->adl_pcl_latch.set(n_ADL_PCL, PHI2);

		// ADH

		TriState DL_PCH = NOR(NOT(T0), JB);
		TriState n_PCH_ADH = NOR(NOR3(n_PCL_ADL, DL_PCH, BR0), BR3);
		inst->pch_adh_latch.set(n_PCH_ADH, PHI2);

		TriState n3[6];
		n3[0] = RTS_5;
		n3[1] = ABS_2;
		n3[2] = T0;
		n3[3] = T1;
		n3[4] = BR2;
		n3[5] = BR3;
		TriState n_ADH_PCH = NOR6(n3);
		inst->adh_pch_latch.set(n_ADH_PCH, PHI2);
		TriState n_PCH_PCH = NOT(n_ADH_PCH);
		inst->pch_pch_latch.set(n_PCH_PCH, PHI2);

		// Outputs

		core->cmd.PCL_DB = inst->pcl_db_latch2.nget();
		core->cmd.PCH_DB = inst->pch_db_latch2.nget();
		core->cmd.PCL_ADL = inst->pcl_adl_latch.nget();
		core->cmd.PCH_ADH = inst->pch_adh_latch.nget();
		core->cmd.PCL_PCL = NOR(inst->pcl_pcl_latch.get(), PHI2);
		core->cmd.ADL_PCL = NOR(inst->adl_pcl_latch.get(), PHI2);
		core->cmd.ADH_PCH = NOR(inst->adh_pch_latch.get(), PHI2);
		core->cmd.PCH_PCH = NOR(inst->pch_pch_latch.get(), PHI2);

		// For dispatcher

		core->wire.PC_DB = PC_DB;
		core->wire.n_ADL_PCL = n_ADL_PCL;

		inst->running = false;
	}

	void PC_Control::mt_run()
	{
		running = true;
	}

	void PC_Control::mt_wait()
	{
		while (running);
	}
}
