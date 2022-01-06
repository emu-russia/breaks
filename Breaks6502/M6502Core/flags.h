#pragma once

namespace M6502Core
{
	enum class Flags_Input
	{
		PHI1 = 0,
		PHI2,
		SO,			// From SO terminal
		B_OUT,
		ACR,
		AVR,
		n_IR5,
		P_DB,
		DB_P,
		DBZ_Z,
		DB_N,
		IR5_C,
		DB_C,
		ACR_C,
		IR5_D,
		IR5_I,
		DB_V,
		AVR_V,		// D112
		Z_V,
		Max,
	};

	class Flags
	{
		BaseLogic::DLatch z_latch1;
		BaseLogic::DLatch z_latch2;
		BaseLogic::DLatch n_latch1;
		BaseLogic::DLatch n_latch2;
		BaseLogic::DLatch c_latch1;
		BaseLogic::DLatch c_latch2;
		BaseLogic::DLatch d_latch1;
		BaseLogic::DLatch d_latch2;
		BaseLogic::DLatch i_latch1;
		BaseLogic::DLatch i_latch2;
		BaseLogic::DLatch v_latch1;
		BaseLogic::DLatch v_latch2;
		BaseLogic::DLatch avr_latch;
		BaseLogic::DLatch so_latch1;
		BaseLogic::DLatch so_latch2;
		BaseLogic::DLatch so_latch3;
		BaseLogic::DLatch vset_latch;

		// There is no point in making FFs, the DLatch outputs will be their role.

	public:

		void sim(BaseLogic::TriState inputs[], BaseLogic::TriState DB[]);

		BaseLogic::TriState getn_Z_OUT();
		BaseLogic::TriState getn_N_OUT();
		BaseLogic::TriState getn_C_OUT();
		BaseLogic::TriState getn_D_OUT();
		BaseLogic::TriState getn_I_OUT();
		BaseLogic::TriState getn_V_OUT();
	};
}
