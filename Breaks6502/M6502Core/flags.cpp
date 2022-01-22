#include "pch.h"

using namespace BaseLogic;

namespace M6502Core
{
	void Flags::sim_Load()
	{
		TriState PHI1 = core->wire.PHI1;
		TriState PHI2 = core->wire.PHI2;
		TriState SO = core->wire.SO;
		TriState ACR = core->alu->getACR();
		TriState AVR = core->alu->getAVR();
		TriState n_IR5 = core->wire.n_IR5;

		TriState DB_P = core->cmd.DB_P ? TriState::One : TriState::Zero;
		TriState AVR_V = core->cmd.AVR_V ? TriState::One : TriState::Zero;

		// Z

		if (PHI1)
		{
			TriState DBZ_Z = core->cmd.DBZ_Z ? TriState::One : TriState::Zero;
			TriState DB1 = core->DB & 0b00000010 ? TriState::One : TriState::Zero;
			TriState n_DBZ = NOT(core->DB == 0 ? TriState::One : TriState::Zero);
			TriState z[3];
			z[0] = AND(NOT(DB1), DB_P);
			z[1] = AND(n_DBZ, DBZ_Z);
			z[2] = AND(NOR(DB_P, DBZ_Z), z_latch2.get());

			z_latch1.set(NOR3(z[0], z[1], z[2]), PHI1);
		}
		else
		{
			z_latch2.set(z_latch1.nget(), PHI2);
		}

		// N

		if (PHI1)
		{
			TriState DB_N = core->cmd.DB_N ? TriState::One : TriState::Zero;
			TriState DB7 = core->DB & 0b10000000 ? TriState::One : TriState::Zero;
			TriState n[2];
			n[0] = AND(NOT(DB7), DB_N);
			n[1] = AND(NOT(DB_N), n_latch2.get());

			n_latch1.set(NOR(n[0], n[1]), PHI1);
		}
		else
		{
			n_latch2.set(n_latch1.nget(), PHI2);
		}

		// C

		if (PHI1)
		{
			TriState IR5_C = core->cmd.IR5_C ? TriState::One : TriState::Zero;
			TriState DB_C = core->cmd.DB_C ? TriState::One : TriState::Zero;
			TriState ACR_C = core->cmd.ACR_C ? TriState::One : TriState::Zero;
			TriState DB0 = core->DB & 0b00000001 ? TriState::One : TriState::Zero;
			TriState c[4];
			c[0] = AND(n_IR5, IR5_C);
			c[1] = AND(NOT(ACR), ACR_C);
			c[2] = AND(NOT(DB0), DB_C);
			c[3] = AND(NOR3(DB_C, IR5_C, ACR_C), c_latch2.get());

			c_latch1.set(NOR4(c), PHI1);
		}
		else
		{
			c_latch2.set(c_latch1.nget(), PHI2);
		}

		// D

		if (PHI1)
		{
			TriState IR5_D = core->cmd.IR5_D ? TriState::One : TriState::Zero;
			TriState DB3 = core->DB & 0b00001000 ? TriState::One : TriState::Zero;
			TriState d[3];
			d[0] = AND(IR5_D, n_IR5);
			d[1] = AND(NOT(DB3), DB_P);
			d[2] = AND(NOR(IR5_D, DB_P), d_latch2.get());

			d_latch1.set(NOR3(d[0], d[1], d[2]), PHI1);
		}
		else
		{
			d_latch2.set(d_latch1.nget(), PHI2);
		}

		// I

		if (PHI1)
		{
			TriState IR5_I = core->cmd.IR5_I ? TriState::One : TriState::Zero;
			TriState DB2 = core->DB & 0b00000100 ? TriState::One : TriState::Zero;
			TriState i[3];
			i[0] = AND(n_IR5, IR5_I);
			i[1] = AND(NOT(DB2), DB_P);
			i[2] = AND(NOR(DB_P, IR5_I), i_latch2.get());

			i_latch1.set(NOR3(i[0], i[1], i[2]), PHI1);
		}
		else
		{
			TriState BRK6E = core->wire.BRK6E;
			i_latch2.set(AND(i_latch1.nget(), NOT(BRK6E)), PHI2);
		}

		// V

		avr_latch.set(AVR_V, PHI2);
		so_latch1.set(NOT(SO), PHI1);
		so_latch2.set(so_latch1.nget(), PHI2);
		so_latch3.set(so_latch2.nget(), PHI1);
		vset_latch.set(NOR(so_latch1.nget(), so_latch3.get()), PHI2);

		if (PHI1)
		{
			TriState DB_V = core->cmd.DB_V ? TriState::One : TriState::Zero;
			TriState Z_V = core->cmd.Z_V ? TriState::One : TriState::Zero;
			TriState DB6 = core->DB & 0b01000000 ? TriState::One : TriState::Zero;
			TriState v[4];
			v[0] = AND(NOT(AVR), avr_latch.get());
			v[1] = AND(NOT(DB6), DB_V);
			v[2] = AND(NOR3(DB_V, avr_latch.get(), vset_latch.get()), v_latch2.get());
			v[3] = Z_V;

			v_latch1.set(NOR4(v), PHI1);
		}
		else
		{
			v_latch2.set(v_latch1.nget(), PHI2);
		}
	}

	void Flags::sim_Store()
	{
		if (core->cmd.P_DB)
		{
			core->DB &= 0b00100000;

			core->DB |= NOT(getn_C_OUT()) << 0;

			core->DB |= NOT(getn_Z_OUT()) << 1;

			core->DB |= NOT(getn_I_OUT(core->wire.BRK6E)) << 2;

			core->DB |= NOT(getn_D_OUT()) << 3;

			core->DB |= core->brk->getB_OUT(core->wire.BRK6E) << 4;

			//core->DB[5];

			core->DB |= NOT(getn_V_OUT()) << 6;

			core->DB |= NOT(getn_N_OUT()) << 7;

			core->DB_Dirty = true;
		}
	}

	BaseLogic::TriState Flags::getn_Z_OUT()
	{
		return z_latch1.nget();
	}

	BaseLogic::TriState Flags::getn_N_OUT()
	{
		return n_latch1.nget();
	}

	BaseLogic::TriState Flags::getn_C_OUT()
	{
		return c_latch1.nget();
	}

	BaseLogic::TriState Flags::getn_D_OUT()
	{
		return d_latch1.nget();
	}

	BaseLogic::TriState Flags::getn_I_OUT(TriState BRK6E)
	{
		return AND(i_latch1.nget(), NOT(BRK6E));
	}

	BaseLogic::TriState Flags::getn_V_OUT()
	{
		return v_latch1.nget();
	}
}
