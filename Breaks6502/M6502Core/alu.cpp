#include "pch.h"

using namespace BaseLogic;

namespace M6502Core
{
	void ALU::sim(TriState inputs[], TriState SB[], TriState DB[], TriState ADL[], TriState ADH[])
	{
		TriState PHI2 = inputs[(size_t)ALU_Input::PHI2];
		TriState NDB_ADD = inputs[(size_t)ALU_Input::NDB_ADD];
		TriState DB_ADD = inputs[(size_t)ALU_Input::DB_ADD];
		TriState Z_ADD = inputs[(size_t)ALU_Input::Z_ADD];
		TriState SB_ADD = inputs[(size_t)ALU_Input::SB_ADD];
		TriState ADL_ADD = inputs[(size_t)ALU_Input::ADL_ADD];
		TriState ADD_SB06 = inputs[(size_t)ALU_Input::ADD_SB06];
		TriState ADD_SB7 = inputs[(size_t)ALU_Input::ADD_SB7];
		TriState ADD_ADL = inputs[(size_t)ALU_Input::ADD_ADL];
		TriState ANDS = inputs[(size_t)ALU_Input::ANDS];
		TriState EORS = inputs[(size_t)ALU_Input::EORS];
		TriState ORS = inputs[(size_t)ALU_Input::ORS];
		TriState SRS = inputs[(size_t)ALU_Input::SRS];
		TriState SUMS = inputs[(size_t)ALU_Input::SUMS];
		TriState SB_AC = inputs[(size_t)ALU_Input::SB_AC];
		TriState AC_SB = inputs[(size_t)ALU_Input::AC_SB];
		TriState AC_DB = inputs[(size_t)ALU_Input::AC_DB];
		TriState SB_DB = inputs[(size_t)ALU_Input::SB_DB];
		TriState SB_ADH = inputs[(size_t)ALU_Input::SB_ADH];
		TriState Z_ADH0 = inputs[(size_t)ALU_Input::Z_ADH0];
		TriState Z_ADH17 = inputs[(size_t)ALU_Input::Z_ADH17];
		TriState n_ACIN = inputs[(size_t)ALU_Input::n_ACIN];
		TriState n_DAA = inputs[(size_t)ALU_Input::n_DAA];
		TriState n_DSA = inputs[(size_t)ALU_Input::n_DSA];

		if (BCD_Hack)
		{
			n_DAA = n_DSA = TriState::One;
		}

		TriState nors[8], nands[8], eors[8], sums[8], n_res[8] = { TriState::Z }, bcd_out[8];
		TriState carry[8];		// Inverted carry chain. Even bits in direct logic, odd bits in inverted logic.
		TriState DC3, DC7;
		TriState n4[4], t1, t2;

		// AI/BI Latches

		for (size_t n = 0; n < 8; n++)
		{
			AI[n].set(SB[n], SB_ADD);
			AI[n].set(TriState::Zero, Z_ADD);
			BI[n].set(DB[n], DB_ADD);
			BI[n].set(NOT(DB[n]), NDB_ADD);
			BI[n].set(ADL[n], ADL_ADD);
		}

		// Computational Part

		TriState cin = n_ACIN;

		for (size_t n = 0; n < 8; n++)
		{
			nands[n] = NAND(AI[n].get(), BI[n].get());
			nors[n] = NOR(AI[n].get(), BI[n].get());
			eors[n] = XOR(AI[n].get(), BI[n].get());		// In a real processor, eors alternate with enors to calculate sums. But we will omit that.

			if (n & 1)
			{
				// Odd
				carry[n] = AND(NAND(cin, NOT(nors[n])), NOT(NOT(nands[n])));
				sums[n] = XOR(NOT(cin), eors[n]);
			}
			else
			{
				// Even
				carry[n] = AND(NAND(cin, nands[n]), NOT(nors[n]));
				sums[n] = XOR(NOT(cin), NOT(eors[n]));
			}

			// Fast BCD Carry

			if (n == 3)
			{
				n4[0] = AND(NAND(n_ACIN, nands[0]), NOT(nors[0]));
				n4[1] = NOR(NOT(nands[2]), nors[2]);
				n4[2] = NOT(nands[1]);
				n4[3] = eors[1];
				t1 = NOR(NOR(NOT(nands[2]), eors[3]), NOR4(n4));
				t2 = NOR(nors[2], NAND(NOT(nands[1]), n4[0]));
				DC3 = AND(OR(t1, t2), NOT(n_DAA));

				carry[3] = AND(carry[3], NOT(DC3));
			}

			if (n == 7)
			{
				n4[0] = carry[4];
				n4[1] = NOT(nands[5]);
				n4[2] = eors[5];
				n4[3] = eors[6];
				t1 = NOR(NOR(eors[7], NOT(nands[6])), NOR4(n4));
				t2 = NOR(NOT(eors[6]), NAND(NOT(nands[5]), carry[4]));
				DC7 = AND(OR(t1, t2), NOT(n_DAA));
			}

			cin = carry[n];
		}

		for (size_t n = 0; n < 8; n++)
		{
			// The above random logic is arranged so that these commands are singleton (only one of them can be set).

#if _DEBUG
			size_t checkSum = (size_t)ANDS + (size_t)EORS + (size_t)ORS + (size_t)SRS + (size_t)SUMS;
			if (checkSum > 1)
			{
				throw "When simulating ALU Control, something went wrong. There should only be one ALU operation command.";
			}
#endif

			if (ANDS)
			{
				n_res[n] = nands[n];
			}
			if (EORS)
			{
				n_res[n] = NOT(eors[n]);
			}
			if (ORS)
			{
				n_res[n] = nors[n];
			}
			if (SRS)
			{
				if (n != 7)
				{
					n_res[n] = nands[n + 1];
				}
				else
				{
					n_res[n] = TriState::One;
				}
			}
			if (SUMS)
			{
				n_res[n] = sums[n];
			}
		}

		// ACR, AVR

		DCLatch.set(DC7, PHI2);
		ACLatch.set(NOT(carry[7]), PHI2);
		TriState ACR = NOT(NOR(DCLatch.get(), ACLatch.get()));

		AVRLatch.set(AND(NAND(carry[6], nors[7]), NOT(NOR(carry[6], carry[7]))), PHI2);
		TriState AVR = AVRLatch.nget();

		// Intermediate Result (ADD)

		for (size_t n = 0; n < 8; n++)
		{
			// Technically it may happen that no ALU operation has been set and `res` is in floating state.
			// In this case the value of the latch does not change.

			n_ADD[n].set(n_res[n], PHI2);

			if (ADD_ADL)
			{
				ADL[n] = n_ADD[n].nget();
			}
			if ((ADD_SB06 && n != 7) || (ADD_SB7 && n == 7))
			{
				SB[n] = n_ADD[n].nget();
			}
		}

		// BCD Correction

		daal_latch.set(NAND(NOT(n_DAA), NOT(carry[3])), PHI2);
		daah_latch.set(NOT(n_DAA), PHI2);
		dsal_latch.set(NOR(NOT(carry[3]), n_DSA), PHI2);
		dsah_latch.set(NOT(n_DSA), PHI2);

		TriState DAAL = daal_latch.nget();
		TriState DAAH = NOR(NOT(ACR), daah_latch.nget());
		TriState DSAL = dsal_latch.get();
		TriState DSAH = NOR(ACR, dsah_latch.nget());

		bcd_out[0] = SB[0];
		bcd_out[1] = XOR(NOR(DSAL, DAAL), NOT(SB[1]));
		bcd_out[2] = XOR(AND(NAND(n_ADD[1].get(), DAAL), NAND(NOT(n_ADD[1].get()), DSAL)), NOT(SB[2]));
		bcd_out[3] = XOR(AND(NAND(NOT(NOR(n_ADD[1].get(), n_ADD[2].get())), DSAL), NAND(NAND(n_ADD[1].get(), n_ADD[2].get()), DAAL)), NOT(SB[3]));

		bcd_out[4] = SB[4];
		bcd_out[5] = XOR(NOR(DAAH, DSAH), NOT(SB[5]));
		bcd_out[6] = XOR(AND(NAND(n_ADD[5].get(), DAAH), NAND(NOT(n_ADD[5].get()), DSAH)), NOT(SB[6]));
		bcd_out[7] = XOR(AND(NAND(NAND(n_ADD[5].get(), n_ADD[6].get()), DAAH), NAND(NOT(NOR(n_ADD[5].get(), n_ADD[6].get())), DSAH)), NOT(SB[7]));

		// Accumulator (AC)

		for (size_t n = 0; n < 8; n++)
		{
			if (PHI2)
			{
				AC[n].set(AC_FF[n].get(), PHI2);
			}
			else
			{
				AC[n].set(bcd_out[n], SB_AC);
			}
			AC_FF[n].set(NOT(AC[n].nget()));

			// This is where the very brainy construction related to the connection of the busses is located.

			if (AC_SB)
			{
				SB[n] = AC_FF[n].get();
			}
			if (AC_DB)
			{
				DB[n] = AC_FF[n].get();
			}
			if (SB_DB)
			{
				BusConnect(SB[n], DB[n]);
			}
			if ((Z_ADH0 && n == 0) || (Z_ADH17 && n != 0))
			{
				ADH[n] = TriState::Zero;
			}
			if (SB_ADH)
			{
				BusConnect(SB[n], ADH[n]);
			}
		}
	}

	TriState ALU::getACR()
	{
		return (NOT(NOR(DCLatch.get(), ACLatch.get())));
	}

	TriState ALU::getAVR()
	{
		return AVRLatch.nget();
	}
}
