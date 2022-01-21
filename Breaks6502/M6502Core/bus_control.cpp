#include "pch.h"

using namespace BaseLogic;

namespace M6502Core
{
	void BusControl::sim(TriState inputs[], TriState d[], TriState outputs[])
	{
		TriState PHI2 = inputs[(size_t)BusControl_Input::PHI2];
		TriState BR0 = inputs[(size_t)BusControl_Input::BR0];
		TriState _AND = inputs[(size_t)BusControl_Input::AND];
		TriState T6 = inputs[(size_t)BusControl_Input::T6];
		TriState SBXY = inputs[(size_t)BusControl_Input::SBXY];
		
		TriState PGX = NAND(NOR(d[71], d[72]), NOT(BR0));
		TriState n_SB_AC;
		TriState n_ZTST;

		if (PHI2 == TriState::One)
		{
			TriState PHI1 = inputs[(size_t)BusControl_Input::PHI1];
			TriState STXY = inputs[(size_t)BusControl_Input::STXY];
			TriState STOR = inputs[(size_t)BusControl_Input::STOR];
			TriState Z_ADL0 = inputs[(size_t)BusControl_Input::Z_ADL0];
			TriState ACRL2 = inputs[(size_t)BusControl_Input::ACRL2];
			TriState DL_PCH = inputs[(size_t)BusControl_Input::DL_PCH];
			TriState n_ready = inputs[(size_t)BusControl_Input::n_ready];
			TriState INC_SB = inputs[(size_t)BusControl_Input::INC_SB];
			TriState BRK6E = inputs[(size_t)BusControl_Input::BRK6E];
			TriState n_PCH_PCH = inputs[(size_t)BusControl_Input::n_PCH_PCH];
			TriState T0 = inputs[(size_t)BusControl_Input::T0];
			TriState T1 = inputs[(size_t)BusControl_Input::T1];
			TriState T5 = inputs[(size_t)BusControl_Input::T5];
			TriState IR0 = inputs[(size_t)BusControl_Input::IR0];

			TriState n_DL_ADL = NOR(d[81], d[82]);
			TriState RTS_5 = d[84];
			TriState BR2 = d[80];
			TriState BR3 = d[93];
			TriState T2 = d[28];
			TriState JSR2 = d[48];
			TriState JSR_5 = d[56];
			TriState JMP_4 = d[101];
			TriState pp = d[129];
			TriState JSXY = NAND(NOT(JSR2), STXY);

			TriState ind[4];
			ind[0] = d[89];
			ind[1] = AND(d[90], NOT(pp));
			ind[2] = d[91];
			ind[3] = RTS_5;
			TriState IND = NOT(NOR4(ind));

			TriState IMPLIED = AND(d[128], NOT(pp));
			IMPLIED = AND(IMPLIED, NOT(IR0));
			TriState ABS_2 = AND(d[83], NOT(pp));
			TriState imp_abs = NOR(NOR(ABS_2, T0), IMPLIED);

			nready_latch.set(n_ready, PHI1);
			TriState n_SB_ADH = NOR(PGX, BR3);
			TriState SBA = NOR(n_SB_ADH, NAND(ACRL2, nready_latch.nget()));

			// External address bus control

			TriState n_ADL_ABL = NAND(NOR(T5, T6), NOR(NOT(NOR(d[71], d[72])), n_ready));
			adl_abl_latch.set(n_ADL_ABL, PHI2);

			TriState n1[4];
			n1[0] = IND;
			n1[1] = T2;
			n1[2] = n_PCH_PCH;
			n1[3] = JSR_5;
			TriState n_ADH_ABH = NOR(Z_ADL0, AND(OR(SBA, NOR(n_ready, NOR4(n1))), NOT(BR3)));
			adh_abh_latch.set(n_ADH_ABH, PHI2);

			// ALU connection to SB, DB buses (AC/DB, SB/AC, AC/SB)

			TriState sbac[7];
			sbac[0] = d[58];
			sbac[1] = d[59];
			sbac[2] = d[60];
			sbac[3] = d[61];
			sbac[4] = d[62];
			sbac[5] = d[63];
			sbac[6] = d[64];
			n_SB_AC = NOR7(sbac);
			sb_ac_latch.set(n_SB_AC, PHI2);

			TriState acsb[5];
			acsb[0] = AND(NOT(d[64]), d[65]);
			acsb[1] = d[66];
			acsb[2] = d[67];
			acsb[3] = d[68];
			acsb[4] = _AND;
			TriState n_AC_SB = NOR5(acsb);
			ac_sb_latch.set(n_AC_SB, PHI2);

			ac_db_latch.set(NOR(d[74], AND(d[79], STOR)), PHI2);

			// Control of the SB, DB and ADH internal buses (SB/DB, SB/ADH, 0/ADH0, 0/ADH17)

			z_adh0_latch.set(n_DL_ADL, PHI2);
			z_adh17_latch.set(NOR(d[57], NOT(n_DL_ADL)), PHI2);

			TriState ztst[4];
			ztst[0] = SBXY;
			ztst[1] = NOT(n_SB_AC);
			ztst[2] = T6;
			ztst[3] = _AND;
			n_ZTST = NOR4(ztst);

			TriState sbdb[6];
			sbdb[0] = NOT(NAND(T5, d[55]));
			sbdb[1] = NOR(n_ZTST, _AND);
			sbdb[2] = d[67];
			sbdb[3] = T1;
			sbdb[4] = BR2;
			sbdb[5] = JSXY;
			TriState n_SB_DB = NOR6(sbdb);
			sb_db_latch.set(n_SB_DB, PHI2);

			sb_adh_latch.set(n_SB_ADH, PHI2);

			// External data bus control

			dl_adh_latch.set(NOR(DL_PCH, IND), PHI2);
			dl_adl_latch.set(n_DL_ADL, PHI2);

			TriState n2[6];
			n2[0] = INC_SB;
			n2[1] = d[45];
			n2[2] = BRK6E;
			n2[3] = d[46];
			n2[4] = d[47];
			n2[5] = JSR2;

			TriState n3[5];
			n3[0] = BR2;
			n3[1] = imp_abs;
			n3[2] = NOT(NOR6(n2));
			n3[3] = JMP_4;
			n3[4] = T5;
			TriState n_DL_DB = NOR5(n3);
			dl_db_latch.set(n_DL_DB, PHI2);
		}
		else
		{
			TriState sbac[7];
			sbac[0] = d[58];
			sbac[1] = d[59];
			sbac[2] = d[60];
			sbac[3] = d[61];
			sbac[4] = d[62];
			sbac[5] = d[63];
			sbac[6] = d[64];
			n_SB_AC = NOR7(sbac);

			TriState ztst[4];
			ztst[0] = SBXY;
			ztst[1] = NOT(n_SB_AC);
			ztst[2] = T6;
			ztst[3] = _AND;
			n_ZTST = NOR4(ztst);
		}

		// Outputs

		outputs[(size_t)BusControl_Output::ADL_ABL] = adl_abl_latch.nget();
		outputs[(size_t)BusControl_Output::ADH_ABH] = adh_abh_latch.nget();

		outputs[(size_t)BusControl_Output::AC_DB] = NOR(ac_db_latch.get(), PHI2);
		outputs[(size_t)BusControl_Output::SB_AC] = NOR(sb_ac_latch.get(), PHI2);
		outputs[(size_t)BusControl_Output::AC_SB] = NOR(ac_sb_latch.get(), PHI2);

		outputs[(size_t)BusControl_Output::SB_DB] = sb_db_latch.nget();
		outputs[(size_t)BusControl_Output::SB_ADH] = sb_adh_latch.nget();
		outputs[(size_t)BusControl_Output::Z_ADH0] = z_adh0_latch.nget();
		outputs[(size_t)BusControl_Output::Z_ADH17] = z_adh17_latch.nget();

		outputs[(size_t)BusControl_Output::DL_ADL] = dl_adl_latch.nget();
		outputs[(size_t)BusControl_Output::DL_ADH] = dl_adh_latch.nget();
		outputs[(size_t)BusControl_Output::DL_DB] = dl_db_latch.nget();

		outputs[(size_t)BusControl_Output::ZTST] = NOT(n_ZTST);
		outputs[(size_t)BusControl_Output::PGX] = PGX;
	}

	TriState BusControl::getPGX(TriState d[], TriState BR0)
	{
		return NAND(NOR(d[71], d[72]), NOT(BR0));
	}
}
