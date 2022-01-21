#include "pch.h"

using namespace BaseLogic;

namespace M6502Core
{
	void FlagsControl::sim(TriState inputs[], TriState d[], TriState outputs[])
	{
		TriState PHI2 = inputs[(size_t)FlagsControl_Input::PHI2];
		TriState n_ready = inputs[(size_t)FlagsControl_Input::n_ready];
		TriState DB_P;

		if (PHI2 == TriState::One)
		{
			TriState T6 = inputs[(size_t)FlagsControl_Input::T6];
			TriState ZTST = inputs[(size_t)FlagsControl_Input::ZTST];
			TriState SR = inputs[(size_t)FlagsControl_Input::SR];

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

			pdb_latch.set(n_POUT, PHI2);
			iri_latch.set(NOT(d[108]), PHI2);
			irc_latch.set(NOT(d[110]), PHI2);
			ird_latch.set(NOT(d[120]), PHI2);
			zv_latch.set(NOT(d[127]), PHI2);
			acrc_latch.set(n_ARIT, PHI2);
			dbz_latch.set(NOR3(acrc_latch.nget(), ZTST, d[109]), PHI2);
			dbn_latch.set(d[109], PHI2);
			pin_latch.set(n_PIN, PHI2);
			DB_P = NOR(pin_latch.get(), n_ready);
			dbc_latch.set(NOR(DB_P, SR), PHI2);
			bit_latch.set(NOT(d[113]), PHI2);
		}
		else
		{
			DB_P = NOR(pin_latch.get(), n_ready);
		}

		// Outputs

		outputs[(size_t)FlagsControl_Output::P_DB] = pdb_latch.nget();
		outputs[(size_t)FlagsControl_Output::IR5_I] = iri_latch.nget();
		outputs[(size_t)FlagsControl_Output::IR5_C] = irc_latch.nget();
		outputs[(size_t)FlagsControl_Output::IR5_D] = ird_latch.nget();
		outputs[(size_t)FlagsControl_Output::Z_V] = zv_latch.nget();
		outputs[(size_t)FlagsControl_Output::ACR_C] = acrc_latch.nget();
		outputs[(size_t)FlagsControl_Output::DBZ_Z] = dbz_latch.nget();
		outputs[(size_t)FlagsControl_Output::DB_N] = NOR(AND(dbz_latch.get(), pin_latch.get()), dbn_latch.get());
		outputs[(size_t)FlagsControl_Output::DB_P] = DB_P;
		outputs[(size_t)FlagsControl_Output::DB_C] = dbc_latch.nget();
		outputs[(size_t)FlagsControl_Output::DB_V] = NAND(pin_latch.get(), bit_latch.get());
	}
}
