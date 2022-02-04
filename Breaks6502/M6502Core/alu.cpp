#include "pch.h"

using namespace BaseLogic;

namespace M6502Core
{
	void ALU::sim()
	{
		TriState PHI2 = core->wire.PHI2;
		bool ANDS = core->cmd.ANDS;
		bool EORS = core->cmd.EORS;
		bool ORS = core->cmd.ORS;
		bool SRS = core->cmd.SRS;
		bool SUMS = core->cmd.SUMS;
		bool SB_AC = core->cmd.SB_AC;
		TriState n_ACIN = core->cmd.n_ACIN ? TriState::One : TriState::Zero;
		TriState n_DAA = core->cmd.n_DAA ? TriState::One : TriState::Zero;
		TriState n_DSA = core->cmd.n_DSA ? TriState::One : TriState::Zero;

		if (BCD_Hack)
		{
			n_DAA = n_DSA = TriState::One;
		}

		// Computational Part

		// The computational part saves its result on ADD only during PHI2.
		// The previous result from ADD (+BCD correction) is saved to the accumulator during PHI1.
		// This is done so that during PHI1 you can load new operands and simultaneously save the previous calculation result to AC.

		if (PHI2 == TriState::One)
		{
			TriState nors[8], nands[8], eors[8], sums[8], n_res[8] = { TriState::Z };
			TriState carry[8];		// Inverted carry chain. Even bits in direct logic, odd bits in inverted logic.
			TriState DC3, DC7;
			TriState n4[4], t1, t2;

			TriState cin = n_ACIN;

			for (size_t n = 0; n < 8; n++)
			{
				TriState AIn = AI & (1 << n) ? TriState::One : TriState::Zero;
				TriState BIn = BI & (1 << n) ? TriState::One : TriState::Zero;

				nands[n] = NAND(AIn, BIn);
				nors[n] = NOR(AIn, BIn);
				eors[n] = XOR(AIn, BIn);		// In a real processor, eors alternate with enors to calculate sums. But we will omit that.

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

				if (n == 3 && !BCD_Hack)
				{
#if 0 // ttlworks
					TriState Ci1_ = AND( NOT(nors[0]), OR(NOT(n_ACIN), NOT(nands[0])) );
					t1 = AND3(Ci1_, NOT(nors[2]), NOT(nands[1]));
					n4[0] = Ci1_;
					n4[1] = NOT(nands[1]);
					n4[2] = eors[1];
					n4[3] = eors[2];
					t2 = OR(NOT(nands[2]), eors[3]);
					DC3 = AND( NOT(n_DAA), OR(t1, AND(NOT(NOR4(n4)), t2)) );
#else
					n4[0] = AND(NAND(n_ACIN, nands[0]), NOT(nors[0]));
					n4[1] = NOR(NOT(nands[2]), nors[2]);
					n4[2] = NOT(nands[1]);
					n4[3] = eors[1];
					t1 = NOR(NOR(NOT(nands[2]), eors[3]), NOR4(n4));
					t2 = NOR(nors[2], NAND(NOT(nands[1]), n4[0]));
					DC3 = AND(OR(t1, t2), NOT(n_DAA));
#endif

					carry[3] = AND(carry[3], NOT(DC3));
				}

				if (n == 7)
				{
					if (!BCD_Hack)
					{
#if 0 // ttlworks
						t1 = AND3(carry[4], NOT(nands[5]), eors[6]);
						n4[0] = carry[4];
						n4[1] = NOT(nands[5]);
						n4[2] = eors[6];
						n4[3] = eors[5];
						t2 = OR(NOT(nands[6]), eors[7]);
						DC7 = AND( NOT(n_DAA), OR(t1, AND(NOT(NOR4(n4)), t2)) );
#else
						n4[0] = carry[4];
						n4[1] = NOT(nands[5]);
						n4[2] = eors[5];
						n4[3] = eors[6];
						t1 = NOR(NOR(eors[7], NOT(nands[6])), NOR4(n4));
						t2 = NOR(NOT(eors[6]), NAND(NOT(nands[5]), carry[4]));
						DC7 = AND(OR(t1, t2), NOT(n_DAA));
#endif
					}
					else
					{
						DC7 = TriState::Zero;
					}
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

				if (ANDS == TriState::One)
				{
					n_res[n] = nands[n];
				}
				if (EORS == TriState::One)
				{
					n_res[n] = NOT(eors[n]);
				}
				if (ORS == TriState::One)
				{
					n_res[n] = nors[n];
				}
				if (SRS == TriState::One)
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
				if (SUMS == TriState::One)
				{
					n_res[n] = sums[n];
				}

				// Technically it may happen that no ALU operation has been set and `res` is in floating state.
				// In this case the value of the latch does not change.

				n_ADD = 0;
				for (size_t n = 0; n < 8; n++)
				{
					if (n_res[n])
					{
						n_ADD |= 1 << n;
					}
				}
			}

			// ACR, AVR

			DCLatch.set(DC7, PHI2);
			ACLatch.set(NOT(carry[7]), PHI2);
			AVRLatch.set(AND(NAND(carry[6], nors[7]), NOT(NOR(carry[6], carry[7]))), PHI2);

			if (!BCD_Hack)
			{
				daal_latch.set(NAND(NOT(n_DAA), NOT(carry[3])), PHI2);
				daah_latch.set(NOT(n_DAA), PHI2);
				dsal_latch.set(NOR(NOT(carry[3]), n_DSA), PHI2);
				dsah_latch.set(NOT(n_DSA), PHI2);
			}

			//AC[n].set(NOT(AC[n].nget()), PHI2);
		}
		else
		{
			TriState ACR = NOT(NOR(DCLatch.get(), ACLatch.get()));
			TriState AVR = AVRLatch.nget();

			// BCD Correction

			if (!BCD_Hack)
			{
				TriState bcd_out[8];

				TriState DAAL = daal_latch.nget();
				TriState DAAH = NOR(NOT(ACR), daah_latch.nget());
				TriState DSAL = dsal_latch.get();
				TriState DSAH = NOR(ACR, dsah_latch.nget());

				TriState SB0 = core->SB & 0b00000001 ? TriState::One : TriState::Zero;
				TriState SB1 = core->SB & 0b00000010 ? TriState::One : TriState::Zero;
				TriState SB2 = core->SB & 0b00000100 ? TriState::One : TriState::Zero;
				TriState SB3 = core->SB & 0b00001000 ? TriState::One : TriState::Zero;
				TriState SB4 = core->SB & 0b00010000 ? TriState::One : TriState::Zero;
				TriState SB5 = core->SB & 0b00100000 ? TriState::One : TriState::Zero;
				TriState SB6 = core->SB & 0b01000000 ? TriState::One : TriState::Zero;
				TriState SB7 = core->SB & 0b10000000 ? TriState::One : TriState::Zero;

				TriState n_ADD0 = n_ADD & 0b00000001 ? TriState::One : TriState::Zero;
				TriState n_ADD1 = n_ADD & 0b00000010 ? TriState::One : TriState::Zero;
				TriState n_ADD2 = n_ADD & 0b00000100 ? TriState::One : TriState::Zero;
				TriState n_ADD3 = n_ADD & 0b00001000 ? TriState::One : TriState::Zero;
				TriState n_ADD4 = n_ADD & 0b00010000 ? TriState::One : TriState::Zero;
				TriState n_ADD5 = n_ADD & 0b00100000 ? TriState::One : TriState::Zero;
				TriState n_ADD6 = n_ADD & 0b01000000 ? TriState::One : TriState::Zero;
				TriState n_ADD7 = n_ADD & 0b10000000 ? TriState::One : TriState::Zero;

				bcd_out[0] = SB0;
				bcd_out[1] = XOR(NOR(DSAL, DAAL), NOT(SB1));
				bcd_out[2] = XOR(AND(NAND(n_ADD1, DAAL), NAND(NOT(n_ADD1), DSAL)), NOT(SB2));
				bcd_out[3] = XOR(AND(NAND(NOT(NOR(n_ADD1, n_ADD2)), DSAL), NAND(NAND(n_ADD1, n_ADD2), DAAL)), NOT(SB3));

				bcd_out[4] = SB4;
				bcd_out[5] = XOR(NOR(DAAH, DSAH), NOT(SB5));
				bcd_out[6] = XOR(AND(NAND(n_ADD5, DAAH), NAND(NOT(n_ADD5), DSAH)), NOT(SB6));
				bcd_out[7] = XOR(AND(NAND(NAND(n_ADD5, n_ADD6), DAAH), NAND(NOT(NOR(n_ADD5, n_ADD6)), DSAH)), NOT(SB7));

				// BCD correction via SB bus: SB_AC

				if (SB_AC)
				{
					AC = 0;

					for (size_t n = 0; n < 8; n++)
					{
						if (bcd_out[n])
						{
							AC |= (1 << n);
						}
					}
				}
			}
			else
			{
				if (SB_AC)
				{
					AC = core->SB;
				}
			}
		}
	}

	void ALU::sim_HLE()
	{
		if (!BCD_Hack)
		{
			sim();
			return;
		}

		TriState PHI2 = core->wire.PHI2;
		bool ANDS = core->cmd.ANDS;
		bool EORS = core->cmd.EORS;
		bool ORS = core->cmd.ORS;
		bool SRS = core->cmd.SRS;
		bool SUMS = core->cmd.SUMS;
		bool SB_AC = core->cmd.SB_AC;
		TriState n_ACIN = core->cmd.n_ACIN ? TriState::One : TriState::Zero;

		if (PHI2 == TriState::One)
		{
			int resInt = 0;
			uint8_t res = 0;
			bool saveRes = false;

			if (ANDS == TriState::One)
			{
				res = AI & BI;
				saveRes = true;
			}
			if (EORS == TriState::One)
			{
				res = AI ^ BI;
				saveRes = true;
			}
			if (ORS == TriState::One)
			{
				res = AI | BI;
				saveRes = true;
			}
			if (SRS == TriState::One)
			{
				res = (AI & BI) >> 1;
				saveRes = true;
			}
			if (SUMS == TriState::One)
			{
				resInt = (uint16_t)AI + (uint16_t)BI + (n_ACIN == TriState::Zero ? 1 : 0);
				res = (uint8_t)resInt;
				saveRes = true;
			}

			if (saveRes)
			{
				n_ADD = ~res;
			}

			// ACR, AVR

			DCLatch.set(TriState::Zero, PHI2);
			ACLatch.set((resInt >> 8) != 0 ? TriState::One : TriState::Zero, PHI2);
			AVRLatch.set((~(AI ^ BI) & (AI ^ resInt) & 0x80) != 0 ? TriState::Zero : TriState::One, PHI2);
		}
		else
		{
			if (SB_AC)
			{
				AC = core->SB;
			}
		}
	}

	void ALU::sim_BusMux()
	{
		bool SB_DB = core->cmd.SB_DB;
		bool SB_ADH = core->cmd.SB_ADH;

		// This is where the very brainy construction related to the connection of the busses is located.

		if (SB_DB)
		{
			if (core->SB_Dirty && !core->DB_Dirty)
			{
				core->DB = core->SB;
				core->DB_Dirty = true;
			}
			else if (!core->SB_Dirty && core->DB_Dirty)
			{
				core->SB = core->DB;
				core->SB_Dirty = true;
			}
			else if (!core->SB_Dirty && !core->DB_Dirty)
			{
				// z
			}
			else
			{
				uint8_t tmp = core->SB & core->DB;
				core->SB = tmp;
				core->DB = tmp;
			}
		}

		if (SB_ADH)
		{
			if (core->SB_Dirty && !core->ADH_Dirty)
			{
				core->ADH = core->SB;
				core->ADH_Dirty = true;
			}
			else if (!core->SB_Dirty && core->ADH_Dirty)
			{
				core->SB = core->ADH;
				core->SB_Dirty = true;
			}
			else if (!core->SB_Dirty && !core->ADH_Dirty)
			{
				// z
			}
			else
			{
				uint8_t tmp = core->SB & core->ADH;
				core->SB = tmp;
				core->ADH = tmp;
			}
		}
	}

	void ALU::sim_Load()
	{
		bool NDB_ADD = core->cmd.NDB_ADD;
		bool DB_ADD = core->cmd.DB_ADD;
		bool Z_ADD = core->cmd.Z_ADD;
		bool SB_ADD = core->cmd.SB_ADD;
		bool ADL_ADD = core->cmd.ADL_ADD;

		// Special case when SB/ADD and 0/ADD are active at the same time (this only happens with Power Up).

		if (SB_ADD == TriState::One && Z_ADD == TriState::One)
		{
			core->SB = 0;
			core->SB_Dirty = true;
		}

		// ALU input value loading commands are active only during PHI1.
		// Although the ALU "counts", its output value is not saved on ADD. Saving to ADD happens during PHI2 (when all operand loading commands are inactive).

		if (SB_ADD)
		{
			AI = core->SB;
		}
		if (Z_ADD)
		{
			AI = 0;
		}
		if (DB_ADD)
		{
			BI = core->DB;
		}
		if (NDB_ADD)
		{
			BI = ~core->DB;
		}
		if (ADL_ADD)
		{
			BI = core->ADL;
		}
	}

	void ALU::sim_StoreADD()
	{
		bool ADD_SB06 = core->cmd.ADD_SB06;
		bool ADD_SB7 = core->cmd.ADD_SB7;
		bool ADD_ADL = core->cmd.ADD_ADL;

		// Intermediate Result (ADD) Output

		if (ADD_ADL)
		{
			if (core->ADL_Dirty)
			{
				core->ADL = core->ADL & ~n_ADD;
			}
			else
			{
				core->ADL = ~n_ADD;
				core->ADL_Dirty = true;
			}
		}

		if (ADD_SB06)
		{
			core->SB &= 0x80;
			core->SB |= ~n_ADD & 0x7f;
			core->SB_Dirty = true;
		}

		if (ADD_SB7)
		{
			core->SB &= ~0x80;
			core->SB |= ~n_ADD & 0x80;
			core->SB_Dirty = true;
		}
	}

	void ALU::sim_StoreAC()
	{
		bool AC_SB = core->cmd.AC_SB;
		bool AC_DB = core->cmd.AC_DB;

		// Accumulator (AC) Output

		if (AC_SB)
		{
			if (core->SB_Dirty)
			{
				core->SB = core->SB & AC;
			}
			else
			{
				core->SB = AC;
				core->SB_Dirty = true;
			}
		}

		if (AC_DB)
		{
			if (core->DB_Dirty)
			{
				core->DB = core->DB & AC;
			}
			else
			{
				core->DB = AC;
				core->DB_Dirty = true;
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

	uint8_t ALU::getAI()
	{
		return AI;
	}

	uint8_t ALU::getBI()
	{
		return BI;
	}

	uint8_t ALU::getADD()
	{
		return ~n_ADD;
	}

	uint8_t ALU::getAC()
	{
		return AC;
	}
}
