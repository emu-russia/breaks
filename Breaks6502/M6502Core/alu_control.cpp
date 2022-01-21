#include "pch.h"

using namespace BaseLogic;

namespace M6502Core
{
	void ALUControl::sim(TriState inputs[], TriState d[], TriState outputs[])
	{
		TriState PHI1 = inputs[(size_t)ALUControl_Input::PHI1];
		TriState PHI2 = inputs[(size_t)ALUControl_Input::PHI2];
		TriState BRFW = inputs[(size_t)ALUControl_Input::BRFW];
		TriState n_ready = inputs[(size_t)ALUControl_Input::n_ready];
		TriState BRK6E = inputs[(size_t)ALUControl_Input::BRK6E];
		TriState STKOP = inputs[(size_t)ALUControl_Input::STKOP];
		TriState T0 = inputs[(size_t)ALUControl_Input::T0];
		TriState T1 = inputs[(size_t)ALUControl_Input::T1];
		TriState T5 = inputs[(size_t)ALUControl_Input::T5];
		TriState T6 = inputs[(size_t)ALUControl_Input::T6];
		TriState PGX = inputs[(size_t)ALUControl_Input::PGX];
		TriState n_D_OUT = inputs[(size_t)ALUControl_Input::n_D_OUT];
		TriState n_C_OUT = inputs[(size_t)ALUControl_Input::n_C_OUT];

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

		acin_latch1.set(NOR(n_ADL_ADD, NOT(RET)), PHI2);
		acin_latch2.set(INC_SB, PHI2);
		acin_latch3.set(BRX, PHI2);
		acin_latch4.set(CSET, PHI2);
		
		TriState acin[4];
		acin[0] = acin_latch1.get();
		acin[1] = acin_latch2.get();
		acin[2] = acin_latch3.get();
		acin[3] = acin_latch4.get();
		TriState n_ACIN = NOR4(acin);
		acin_latch5.set(n_ACIN, PHI1);

		TriState D_OUT = NOT(n_D_OUT);
		daa_latch1.set(NOT(NOR(NAND(d[52], D_OUT), SBC0)), PHI2);
		daa_latch2.set(daa_latch1.nget(), PHI1);
		
		dsa_latch1.set(NAND(SBC0, D_OUT), PHI2);
		dsa_latch2.set(dsa_latch1.nget(), PHI1);

		// Setting the ALU input values (NDB/ADD, DB/ADD, 0/ADD, SB/ADD, ADL/ADD)

		if (PHI2 == TriState::One)
		{
			TriState n_NDB_ADD = NAND(OR3(BRX, JSR_5, SBC0), NOT(n_ready));
			ndbadd_latch.set(n_NDB_ADD, PHI2);
			dbadd_latch.set(NAND(n_NDB_ADD, n_ADL_ADD), PHI2);
			adladd_latch.set(n_ADL_ADD, PHI2);

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
			sbadd_latch.set(NOT(SB_ADD), PHI2);
			zadd_latch.set(SB_ADD, PHI2);
		}

		// ALU operation commands (ANDS, EORS, ORS, SRS, SUMS)

		ands_latch1.set(_AND, PHI2);
		ands_latch2.set(ands_latch1.nget(), PHI1);
		eors_latch1.set(EOR, PHI2);
		eors_latch2.set(eors_latch1.nget(), PHI1);
		ors_latch1.set(_OR, PHI2);
		ors_latch2.set(ors_latch1.nget(), PHI1);
		srs_latch1.set(SR, PHI2);
		srs_latch2.set(srs_latch1.nget(), PHI1);

		TriState sums[4];
		sums[0] = _AND;
		sums[1] = EOR;
		sums[2] = _OR;
		sums[3] = SR;
		sums_latch1.set(NOR4(sums), PHI2);
		sums_latch2.set(sums_latch1.nget(), PHI1);

		// ADD/SB7

		cout_latch.set(NOT(n_C_OUT), PHI2);
		nready_latch.set(n_ready, PHI1);
		mux_latch1.set(NOR(nready_latch.get(), NOT(SR)), PHI2);
		sr_latch1.set(SR, PHI2);
		sr_latch2.set(sr_latch1.nget(), PHI1);
		ff_latch1.set(NOT(MUX(mux_latch1.get(), ff_latch2.get(), cout_latch.nget())), PHI1);
		ff_latch2.set(ff_latch1.nget(), PHI2);
		TriState n_ADD_SB7 = NOR3(ff_latch1.nget(), sr_latch2.get(), n_ROR);

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
			addsb06_latch.set(n_ADD_SB06, PHI2);

			addsb7_latch.set(NOR(n_ADD_SB06, n_ADD_SB7), PHI2);

			TriState noadl[7];
			noadl[0] = RTS_5;
			noadl[1] = d[85];
			noadl[2] = d[86];
			noadl[3] = d[87];
			noadl[4] = d[88];
			noadl[5] = d[89];
			noadl[6] = RTI_5;
			TriState NOADL = NOR7(noadl);
			addadl_latch.set(NOT(NOR(NOADL, PGX)), PHI2);
		}

		// Outputs

		outputs[(size_t)ALUControl_Output::NDB_ADD] = NOR(ndbadd_latch.get(), PHI2);
		outputs[(size_t)ALUControl_Output::DB_ADD] = NOR(dbadd_latch.get(), PHI2);
		outputs[(size_t)ALUControl_Output::Z_ADD] = NOR(zadd_latch.get(), PHI2);
		outputs[(size_t)ALUControl_Output::SB_ADD] = NOR(sbadd_latch.get(), PHI2);
		outputs[(size_t)ALUControl_Output::ADL_ADD] = NOR(adladd_latch.get(), PHI2);
		outputs[(size_t)ALUControl_Output::ADD_SB7] = addsb7_latch.get();	// care!
		outputs[(size_t)ALUControl_Output::ADD_SB06] = addsb06_latch.nget();
		outputs[(size_t)ALUControl_Output::ADD_ADL] = addadl_latch.nget();

		outputs[(size_t)ALUControl_Output::ANDS] = ands_latch2.nget();
		outputs[(size_t)ALUControl_Output::EORS] = eors_latch2.nget();
		outputs[(size_t)ALUControl_Output::ORS] = ors_latch2.nget();
		outputs[(size_t)ALUControl_Output::SRS] = srs_latch2.nget();
		outputs[(size_t)ALUControl_Output::SUMS] = sums_latch2.nget();

		outputs[(size_t)ALUControl_Output::n_ACIN] = NOT(acin_latch5.nget());
		outputs[(size_t)ALUControl_Output::n_DAA] = daa_latch2.nget();
		outputs[(size_t)ALUControl_Output::n_DSA] = dsa_latch2.nget();

		outputs[(size_t)ALUControl_Output::AND] = _AND;
		outputs[(size_t)ALUControl_Output::SR] = SR;
		outputs[(size_t)ALUControl_Output::INC_SB] = INC_SB;
	}
}
