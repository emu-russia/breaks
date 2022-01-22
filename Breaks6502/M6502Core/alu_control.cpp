#include "pch.h"

using namespace BaseLogic;

namespace M6502Core
{
	void ALUControl::sim(void* param)
	{
		ALUControl* inst = (ALUControl *)param;

		if (!inst->running && inst->mt)
			return;

		M6502* core = inst->core;
		TriState* d = core->decoder_out;
		TriState PHI1 = core->wire.PHI1;
		TriState PHI2 = core->wire.PHI2;
		TriState BRFW = core->random->branch_logic->getBRFW();
		TriState n_ready = core->wire.n_ready;
		TriState BRK6E = core->wire.BRK6E;
		TriState T0 = core->wire.T0;
		TriState T1 = core->disp->getT1();
		TriState T5 = core->wire.T5;
		TriState T6 = core->wire.T6;
		TriState n_D_OUT = core->random->flags->getn_D_OUT();
		TriState n_C_OUT = core->random->flags->getn_C_OUT();

		inst->nready_latch.set(n_ready, PHI1);

		TriState n3[6];
		n3[0] = d[21];
		n3[1] = d[22];
		n3[2] = d[23];
		n3[3] = d[24];
		n3[4] = d[25];
		n3[5] = d[26];
		TriState STKOP = NOR(inst->nready_latch.get(), NOR6(n3));

		TriState BR0 = AND(d[73], NOT(core->wire.n_PRDY));
		TriState PGX = NAND(NOR(d[71], d[72]), NOT(BR0));

		TriState n_ROR = NOT(d[27]);
		TriState EOR = d[29];
		TriState BR3 = d[93];
		TriState _AND = NOT(NOR(d[69], d[70]));
		TriState SR = NOT(NOR(d[75], AND(d[76], T5)));
		TriState RTS_5 = d[84];
		TriState RTI_5 = d[26];
		TriState _OR = NOT(NOR(d[32], n_ready));
		TriState RET = d[47];
		TriState JSR2 = d[48];
		TriState SBC0 = d[51];
		TriState JSR_5 = d[56];

		// Additional signals (/ACIN, /DAA, /DSA)

		TriState adladd[7];
		adladd[0] = AND(d[33], NOT(d[34]));
		adladd[1] = d[35];	// STK2
		adladd[2] = d[36];
		adladd[3] = d[37];
		adladd[4] = d[38];
		adladd[5] = d[39];
		adladd[6] = n_ready;
		TriState n_ADL_ADD = NOR7(adladd);

		TriState incsb[6];
		incsb[0] = d[39];
		incsb[1] = d[40];
		incsb[2] = d[41];
		incsb[3] = d[42];
		incsb[4] = d[43];
		incsb[5] = AND(T5, d[44]);
		TriState INC_SB = NOT(NOR6(incsb));

		TriState BRX = NOT(NOR3(d[49], d[50], NOR(NOT(BR3), BRFW)));

		TriState CSET = NAND( NAND( NOR(n_C_OUT, NOR(T0, T5)), OR(d[52], d[53])), NOT(d[54]));

		inst->acin_latch1.set(NOR(n_ADL_ADD, NOT(RET)), PHI2);
		inst->acin_latch2.set(INC_SB, PHI2);
		inst->acin_latch3.set(BRX, PHI2);
		inst->acin_latch4.set(CSET, PHI2);
		
		TriState acin[4];
		acin[0] = inst->acin_latch1.get();
		acin[1] = inst->acin_latch2.get();
		acin[2] = inst->acin_latch3.get();
		acin[3] = inst->acin_latch4.get();
		TriState n_ACIN = NOR4(acin);
		inst->acin_latch5.set(n_ACIN, PHI1);

		TriState D_OUT = NOT(n_D_OUT);
		inst->daa_latch1.set(NOT(NOR(NAND(d[52], D_OUT), SBC0)), PHI2);
		inst->daa_latch2.set(inst->daa_latch1.nget(), PHI1);
		
		inst->dsa_latch1.set(NAND(SBC0, D_OUT), PHI2);
		inst->dsa_latch2.set(inst->dsa_latch1.nget(), PHI1);

		// Setting the ALU input values (NDB/ADD, DB/ADD, 0/ADD, SB/ADD, ADL/ADD)

		if (PHI2 == TriState::One)
		{
			TriState n_NDB_ADD = NAND(OR3(BRX, JSR_5, SBC0), NOT(n_ready));
			inst->ndbadd_latch.set(n_NDB_ADD, PHI2);
			inst->dbadd_latch.set(NAND(n_NDB_ADD, n_ADL_ADD), PHI2);
			inst->adladd_latch.set(n_ADL_ADD, PHI2);

			TriState sbadd[9];
			sbadd[0] = STKOP;
			sbadd[1] = d[30];
			sbadd[2] = d[31];
			sbadd[3] = d[45];
			sbadd[4] = JSR2;
			sbadd[5] = INC_SB;
			sbadd[6] = RET;
			sbadd[7] = BRK6E;
			sbadd[8] = n_ready;
			TriState SB_ADD = NOR9(sbadd);
			inst->sbadd_latch.set(NOT(SB_ADD), PHI2);
			inst->zadd_latch.set(SB_ADD, PHI2);
		}

		// ALU operation commands (ANDS, EORS, ORS, SRS, SUMS)

		inst->ands_latch1.set(_AND, PHI2);
		inst->ands_latch2.set(inst->ands_latch1.nget(), PHI1);
		inst->eors_latch1.set(EOR, PHI2);
		inst->eors_latch2.set(inst->eors_latch1.nget(), PHI1);
		inst->ors_latch1.set(_OR, PHI2);
		inst->ors_latch2.set(inst->ors_latch1.nget(), PHI1);
		inst->srs_latch1.set(SR, PHI2);
		inst->srs_latch2.set(inst->srs_latch1.nget(), PHI1);

		TriState sums[4];
		sums[0] = _AND;
		sums[1] = EOR;
		sums[2] = _OR;
		sums[3] = SR;
		inst->sums_latch1.set(NOR4(sums), PHI2);
		inst->sums_latch2.set(inst->sums_latch1.nget(), PHI1);

		// ADD/SB7

		inst->cout_latch.set(NOT(n_C_OUT), PHI2);
		inst->mux_latch1.set(NOR(inst->nready_latch.get(), NOT(SR)), PHI2);
		inst->sr_latch1.set(SR, PHI2);
		inst->sr_latch2.set(inst->sr_latch1.nget(), PHI1);
		inst->ff_latch1.set(NOT(MUX(inst->mux_latch1.get(), inst->ff_latch2.get(), inst->cout_latch.nget())), PHI1);
		inst->ff_latch2.set(inst->ff_latch1.nget(), PHI2);
		TriState n_ADD_SB7 = NOR3(inst->ff_latch1.nget(), inst->sr_latch2.get(), n_ROR);

		// Control commands of the intermediate ALU result (ADD/SB06, ADD/SB7, ADD/ADL)

		if (PHI2 == TriState::One)
		{
			TriState sb06[5];
			sb06[0] = T6;
			sb06[1] = STKOP;
			sb06[2] = JSR_5;
			sb06[3] = T1;
			sb06[4] = PGX;
			TriState n_ADD_SB06 = NOR5(sb06);
			inst->addsb06_latch.set(n_ADD_SB06, PHI2);

			inst->addsb7_latch.set(NOR(n_ADD_SB06, n_ADD_SB7), PHI2);

			TriState noadl[7];
			noadl[0] = RTS_5;
			noadl[1] = d[85];
			noadl[2] = d[86];
			noadl[3] = d[87];
			noadl[4] = d[88];
			noadl[5] = d[89];
			noadl[6] = RTI_5;
			TriState NOADL = NOR7(noadl);
			inst->addadl_latch.set(NOT(NOR(NOADL, PGX)), PHI2);
		}

		// Outputs

		core->cmd.NDB_ADD = NOR(inst->ndbadd_latch.get(), PHI2);
		core->cmd.DB_ADD = NOR(inst->dbadd_latch.get(), PHI2);
		core->cmd.Z_ADD = NOR(inst->zadd_latch.get(), PHI2);
		core->cmd.SB_ADD = NOR(inst->sbadd_latch.get(), PHI2);
		core->cmd.ADL_ADD = NOR(inst->adladd_latch.get(), PHI2);
		core->cmd.ADD_SB7 = inst->addsb7_latch.get();	// care!
		core->cmd.ADD_SB06 = inst->addsb06_latch.nget();
		core->cmd.ADD_ADL = inst->addadl_latch.nget();

		core->cmd.ANDS = inst->ands_latch2.nget();
		core->cmd.EORS = inst->eors_latch2.nget();
		core->cmd.ORS = inst->ors_latch2.nget();
		core->cmd.SRS = inst->srs_latch2.nget();
		core->cmd.SUMS = inst->sums_latch2.nget();

		core->cmd.n_ACIN = NOT(inst->acin_latch5.nget());
		core->cmd.n_DAA = inst->daa_latch2.nget();
		core->cmd.n_DSA = inst->dsa_latch2.nget();

		inst->running = false;
	}

	void ALUControl::mt_run()
	{
		running = true;
	}

	void ALUControl::mt_wait()
	{
		while (running);
	}
}
