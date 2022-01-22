#include "pch.h"

using namespace BaseLogic;

namespace M6502Core
{
	void FlagsControl::sim(FlagsControl *inst)
	{
		M6502* core = inst->core;
		TriState* d = core->decoder_out;
		TriState PHI2 = core->wire.PHI2;
		TriState n_ready = core->wire.n_ready;
		TriState DB_P;

		if (PHI2 == TriState::One)
		{
			TriState T5 = core->wire.T5;
			TriState T6 = core->wire.T6;

			TriState sbac[7];
			sbac[0] = d[58];
			sbac[1] = d[59];
			sbac[2] = d[60];
			sbac[3] = d[61];
			sbac[4] = d[62];
			sbac[5] = d[63];
			sbac[6] = d[64];
			TriState n_SB_AC = NOR7(sbac);

			TriState _AND = NOT(NOR(d[69], d[70]));

			TriState n_SB_X = NOR3(d[14], d[15], d[16]);
			TriState n_SB_Y = NOR3(d[18], d[19], d[20]);
			TriState SBXY = NAND(n_SB_X, n_SB_Y);

			TriState ztst[4];
			ztst[0] = SBXY;
			ztst[1] = NOT(n_SB_AC);
			ztst[2] = T6;
			ztst[3] = _AND;
			TriState n_ZTST = NOR4(ztst);

			TriState ZTST = NOT(n_ZTST);
			TriState SR = NOT(NOR(d[75], AND(d[76], T5)));

			TriState n_POUT = NOR(d[98], d[99]);
			TriState n_PIN = NOR(d[114], d[115]);

			TriState n1[6];
			n1[0] = AND(d[107], T6);
			n1[1] = d[112];		// AVR/V
			n1[2] = d[116];
			n1[3] = d[117];
			n1[4] = d[118];
			n1[5] = d[119];
			TriState n_ARIT = NOR6(n1);

			// Latches

			inst->pdb_latch.set(n_POUT, PHI2);
			inst->iri_latch.set(NOT(d[108]), PHI2);
			inst->irc_latch.set(NOT(d[110]), PHI2);
			inst->ird_latch.set(NOT(d[120]), PHI2);
			inst->zv_latch.set(NOT(d[127]), PHI2);
			inst->acrc_latch.set(n_ARIT, PHI2);
			inst->dbz_latch.set(NOR3(inst->acrc_latch.nget(), ZTST, d[109]), PHI2);
			inst->dbn_latch.set(d[109], PHI2);
			inst->pin_latch.set(n_PIN, PHI2);
			DB_P = NOR(inst->pin_latch.get(), n_ready);
			inst->dbc_latch.set(NOR(DB_P, SR), PHI2);
			inst->bit_latch.set(NOT(d[113]), PHI2);
		}
		else
		{
			DB_P = NOR(inst->pin_latch.get(), n_ready);
		}

		// Outputs

		core->cmd.P_DB = inst->pdb_latch.nget();
		core->cmd.IR5_I = inst->iri_latch.nget();
		core->cmd.IR5_C = inst->irc_latch.nget();
		core->cmd.IR5_D = inst->ird_latch.nget();
		core->cmd.AVR_V = d[112];
		core->cmd.Z_V = inst->zv_latch.nget();
		core->cmd.ACR_C = inst->acrc_latch.nget();
		core->cmd.DBZ_Z = inst->dbz_latch.nget();
		core->cmd.DB_N = NOR(AND(inst->dbz_latch.get(), inst->pin_latch.get()), inst->dbn_latch.get());
		core->cmd.DB_P = DB_P;
		core->cmd.DB_C = inst->dbc_latch.nget();
		core->cmd.DB_V = NAND(inst->pin_latch.get(), inst->bit_latch.get());
	}
}
