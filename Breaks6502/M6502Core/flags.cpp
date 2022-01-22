#include "pch.h"

using namespace BaseLogic;

namespace M6502Core
{
	void Flags::sim_Load()
	{
		TriState PHI1 = core->wire.PHI1;
		TriState PHI2 = core->wire.PHI2;
		TriState SO = core->wire.SO;
		TriState BRK6E = core->wire.BRK6E;
		TriState B_OUT = core->brk->getB_OUT(BRK6E);
		TriState ACR = core->alu->getACR();
		TriState AVR = core->alu->getAVR();
		TriState n_IR5 = NOT(core->ir->IROut[5]);

		TriState DB_P = core->cmd.DB_P ? TriState::One : TriState::Zero;
		TriState DBZ_Z = core->cmd.DBZ_Z ? TriState::One : TriState::Zero;
		TriState DB_N = core->cmd.DB_N ? TriState::One : TriState::Zero;
		TriState IR5_C = core->cmd.IR5_C ? TriState::One : TriState::Zero;
		TriState DB_C = core->cmd.DB_C ? TriState::One : TriState::Zero;
		TriState ACR_C = core->cmd.ACR_C ? TriState::One : TriState::Zero;
		TriState IR5_D = core->cmd.IR5_D ? TriState::One : TriState::Zero;
		TriState IR5_I = core->cmd.IR5_I ? TriState::One : TriState::Zero;
		TriState DB_V = core->cmd.DB_V ? TriState::One : TriState::Zero;
		TriState AVR_V = core->cmd.AVR_V ? TriState::One : TriState::Zero;
		TriState Z_V = core->cmd.Z_V ? TriState::One : TriState::Zero;

		// Z

		TriState n_DBZ = NOT(NOR8(core->DB));
		TriState z[3];
		z[0] = AND(NOT(core->DB[1]), DB_P);
		z[1] = AND(n_DBZ, DBZ_Z);
		z[2] = AND(NOR(DB_P, DBZ_Z), z_latch2.get());

		z_latch1.set(NOR3(z[0], z[1], z[2]), PHI1);
		z_latch2.set(z_latch1.nget(), PHI2);

		// N

		TriState n[2];
		n[0] = AND(NOT(core->DB[7]), DB_N);
		n[1] = AND(NOT(DB_N), n_latch2.get());

		n_latch1.set(NOR(n[0], n[1]), PHI1);
		n_latch2.set(n_latch1.nget(), PHI2);

		// C

		TriState c[4];
		c[0] = AND(n_IR5, IR5_C);
		c[1] = AND(NOT(ACR), ACR_C);
		c[2] = AND(NOT(core->DB[0]), DB_C);
		c[3] = AND(NOR3(DB_C, IR5_C, ACR_C), c_latch2.get());

		c_latch1.set(NOR4(c), PHI1);
		c_latch2.set(c_latch1.nget(), PHI2);

		// D

		TriState d[3];
		d[0] = AND(IR5_D, n_IR5);
		d[1] = AND(NOT(core->DB[3]), DB_P);
		d[2] = AND(NOR(IR5_D, DB_P), d_latch2.get());

		d_latch1.set(NOR3(d[0], d[1], d[2]), PHI1);
		d_latch2.set(d_latch1.nget(), PHI2);

		// I

		TriState i[3];
		i[0] = AND(n_IR5, IR5_I);
		i[1] = AND(NOT(core->DB[2]), DB_P);
		i[2] = AND(NOR(DB_P, IR5_I), i_latch2.get());

		i_latch1.set(NOR3(i[0], i[1], i[2]), PHI1);
		i_latch2.set(AND(i_latch1.nget(), NOT(BRK6E)), PHI2);

		// V

		avr_latch.set(AVR_V, PHI2);
		so_latch1.set(NOT(SO), PHI1);
		so_latch2.set(so_latch1.nget(), PHI2);
		so_latch3.set(so_latch2.nget(), PHI1);
		vset_latch.set(NOR(so_latch1.nget(), so_latch3.get()), PHI2);

		TriState v[4];
		v[0] = AND(NOT(AVR), avr_latch.get());
		v[1] = AND(NOT(core->DB[6]), DB_V);
		v[2] = AND(NOR3(DB_V, avr_latch.get(), vset_latch.get()), v_latch2.get());
		v[3] = Z_V;

		v_latch1.set(NOR4(v), PHI1);
		v_latch2.set(v_latch1.nget(), PHI2);
	}

	void Flags::sim_Store()
	{
		if (core->cmd.P_DB)
		{
			if (core->DB_Dirty[0])
			{
				core->DB[0] = AND(core->DB[0], NOT(getn_C_OUT()));
			}
			else
			{
				core->DB[0] = NOT(getn_C_OUT());
				core->DB_Dirty[0] = true;
			}

			if (core->DB_Dirty[1])
			{
				core->DB[1] = AND(core->DB[1], NOT(getn_Z_OUT()));
			}
			else
			{
				core->DB[1] = NOT(getn_Z_OUT());
				core->DB_Dirty[1] = true;
			}

			if (core->DB_Dirty[2])
			{
				core->DB[2] = AND(core->DB[2], NOT(getn_I_OUT(core->wire.BRK6E)));
			}
			else
			{
				core->DB[2] = NOT(getn_I_OUT(core->wire.BRK6E));
				core->DB_Dirty[2] = true;
			}

			if (core->DB_Dirty[3])
			{
				core->DB[3] = AND(core->DB[3], NOT(getn_D_OUT()));
			}
			else
			{
				core->DB[3] = NOT(getn_D_OUT());
				core->DB_Dirty[3] = true;
			}

			if (core->DB_Dirty[4])
			{
				core->DB[4] = AND(core->DB[4], core->brk->getB_OUT(core->wire.BRK6E));
			}
			else
			{
				core->DB[4] = core->brk->getB_OUT(core->wire.BRK6E);
				core->DB_Dirty[4] = true;
			}

			core->DB[5];

			if (core->DB_Dirty[6])
			{
				core->DB[6] = AND(core->DB[6], NOT(getn_V_OUT()));
			}
			else
			{
				core->DB[6] = NOT(getn_V_OUT());
				core->DB_Dirty[6] = true;
			}

			if (core->DB_Dirty[7])
			{
				core->DB[7] = AND(core->DB[7], NOT(getn_N_OUT()));
			}
			else
			{
				core->DB[7] = NOT(getn_N_OUT());
				core->DB_Dirty[7] = true;
			}
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
