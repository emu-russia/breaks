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
		TriState SB_AC = core->cmd.SB_AC ? TriState::One : TriState::Zero;
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

				if (n == 3 && !BCD_Hack)
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
					if (!BCD_Hack)
					{
						n4[0] = carry[4];
						n4[1] = NOT(nands[5]);
						n4[2] = eors[5];
						n4[3] = eors[6];
						t1 = NOR(NOR(eors[7], NOT(nands[6])), NOR4(n4));
						t2 = NOR(NOT(eors[6]), NAND(NOT(nands[5]), carry[4]));
						DC7 = AND(OR(t1, t2), NOT(n_DAA));
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

				n_ADD[n].set(n_res[n], PHI2);
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

				bcd_out[0] = core->SB[0];
				bcd_out[1] = XOR(NOR(DSAL, DAAL), NOT(core->SB[1]));
				bcd_out[2] = XOR(AND(NAND(n_ADD[1].get(), DAAL), NAND(NOT(n_ADD[1].get()), DSAL)), NOT(core->SB[2]));
				bcd_out[3] = XOR(AND(NAND(NOT(NOR(n_ADD[1].get(), n_ADD[2].get())), DSAL), NAND(NAND(n_ADD[1].get(), n_ADD[2].get()), DAAL)), NOT(core->SB[3]));

				bcd_out[4] = core->SB[4];
				bcd_out[5] = XOR(NOR(DAAH, DSAH), NOT(core->SB[5]));
				bcd_out[6] = XOR(AND(NAND(n_ADD[5].get(), DAAH), NAND(NOT(n_ADD[5].get()), DSAH)), NOT(core->SB[6]));
				bcd_out[7] = XOR(AND(NAND(NAND(n_ADD[5].get(), n_ADD[6].get()), DAAH), NAND(NOT(NOR(n_ADD[5].get(), n_ADD[6].get())), DSAH)), NOT(core->SB[7]));

				// BCD correction via SB bus: SB_AC

				for (size_t n = 0; n < 8; n++)
				{
					AC[n].set(bcd_out[n], SB_AC);
				}
			}
			else
			{
				for (size_t n = 0; n < 8; n++)
				{
					AC[n].set(core->SB[n], SB_AC);
				}
			}
		}
	}

	void ALU::sim_BusMux()
	{
		bool SB_DB = core->cmd.SB_DB;
		bool SB_ADH = core->cmd.SB_ADH;

		// This is where the very brainy construction related to the connection of the busses is located.

		if (SB_DB || SB_ADH)
		{
			for (size_t n = 0; n < 8; n++)
			{
				if (SB_DB)
				{
					if (core->SB_Dirty[n] && !core->DB_Dirty[n])
					{
						core->DB[n] = core->SB[n];
						core->DB_Dirty[n] = true;
					}
					else if (!core->SB_Dirty[n] && core->DB_Dirty[n])
					{
						core->SB[n] = core->DB[n];
						core->SB_Dirty[n] = true;
					}
					else if (!core->SB_Dirty[n] && !core->DB_Dirty[n])
					{
						// z
					}
					else
					{
						BusConnect(core->SB[n], core->DB[n]);
					}
				}
				if (SB_ADH)
				{
					if (core->SB_Dirty[n] && !core->ADH_Dirty[n])
					{
						core->ADH[n] = core->SB[n];
						core->ADH_Dirty[n] = true;
					}
					else if (!core->SB_Dirty[n] && core->ADH_Dirty[n])
					{
						core->SB[n] = core->ADH[n];
						core->SB_Dirty[n] = true;
					}
					else if (!core->SB_Dirty[n] && !core->ADH_Dirty[n])
					{
						// z
					}
					else
					{
						BusConnect(core->SB[n], core->ADH[n]);
					}
				}
			}
		}
	}

	void ALU::sim_Load()
	{
		TriState NDB_ADD = core->cmd.NDB_ADD ? TriState::One : TriState::Zero;
		TriState DB_ADD = core->cmd.DB_ADD ? TriState::One : TriState::Zero;
		TriState Z_ADD = core->cmd.Z_ADD ? TriState::One : TriState::Zero;
		TriState SB_ADD = core->cmd.SB_ADD ? TriState::One : TriState::Zero;
		TriState ADL_ADD = core->cmd.ADL_ADD ? TriState::One : TriState::Zero;

		// Special case when SB/ADD and 0/ADD are active at the same time (this only happens with Power Up).

		if (SB_ADD == TriState::One && Z_ADD == TriState::One)
		{
			for (size_t n = 0; n < 8; n++)
			{
				core->SB[n] = TriState::Zero;
				core->SB_Dirty[n] = true;
			}
		}

		// ALU input value loading commands are active only during PHI1.
		// Although the ALU "counts", its output value is not saved on ADD. Saving to ADD happens during PHI2 (when all operand loading commands are inactive).

		if (SB_ADD || Z_ADD || DB_ADD || NDB_ADD || ADL_ADD)
		{
			for (size_t n = 0; n < 8; n++)
			{
				// AI/BI Latches

				AI[n].set(core->SB[n], SB_ADD);
				AI[n].set(TriState::Zero, Z_ADD);
				BI[n].set(core->DB[n], DB_ADD);
				BI[n].set(NOT(core->DB[n]), NDB_ADD);
				BI[n].set(core->ADL[n], ADL_ADD);
			}
		}
	}

	void ALU::sim_StoreADD()
	{
		bool ADD_SB06 = core->cmd.ADD_SB06;
		bool ADD_SB7 = core->cmd.ADD_SB7;
		bool ADD_ADL = core->cmd.ADD_ADL;

		// Intermediate Result (ADD) Output

		if (ADD_ADL || ADD_SB06 || ADD_SB7)
		{
			for (size_t n = 0; n < 8; n++)
			{
				if (ADD_ADL)
				{
					if (core->ADL_Dirty[n])
					{
						core->ADL[n] = AND(core->ADL[n], n_ADD[n].nget());
					}
					else
					{
						core->ADL[n] = n_ADD[n].nget();
						core->ADL_Dirty[n] = true;
					}
				}
				if ((ADD_SB06 && n != 7) || (ADD_SB7 && n == 7))
				{
					if (core->SB_Dirty[n])
					{
						core->SB[n] = AND(core->SB[n], n_ADD[n].nget());
					}
					else
					{
						core->SB[n] = n_ADD[n].nget();
						core->SB_Dirty[n] = true;
					}
				}
			}
		}
	}

	void ALU::sim_StoreAC()
	{
		bool AC_SB = core->cmd.AC_SB;
		bool AC_DB = core->cmd.AC_DB;

		// Accumulator (AC) Output

		if (AC_SB || AC_DB)
		{
			for (size_t n = 0; n < 8; n++)
			{
				if (AC_SB)
				{
					if (core->SB_Dirty[n])
					{
						core->SB[n] = AND(core->SB[n], NOT(AC[n].nget()));
					}
					else
					{
						core->SB[n] = NOT(AC[n].nget());
						core->SB_Dirty[n] = true;
					}
				}
				if (AC_DB)
				{
					if (core->DB_Dirty[n])
					{
						core->DB[n] = AND(core->DB[n], NOT(AC[n].nget()));
					}
					else
					{
						core->DB[n] = NOT(AC[n].nget());
						core->DB_Dirty[n] = true;
					}
				}
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
		TriState v[8];

		for (size_t n = 0; n < 8; n++)
		{
			v[n] = AI[n].get();
		}

		return Pack(v);
	}

	uint8_t ALU::getBI()
	{
		TriState v[8];

		for (size_t n = 0; n < 8; n++)
		{
			v[n] = BI[n].get();
		}

		return Pack(v);
	}

	uint8_t ALU::getADD()
	{
		TriState v[8];

		for (size_t n = 0; n < 8; n++)
		{
			v[n] = n_ADD[n].nget();
		}

		return Pack(v);
	}

	uint8_t ALU::getAC()
	{
		TriState v[8];

		for (size_t n = 0; n < 8; n++)
		{
			v[n] = AC[n].get();
		}

		return Pack(v);
	}
}
