#pragma once

namespace M6502Core
{
	class Flags
	{
		// There is no point in making FFs, the DLatch outputs will be their role.

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

		M6502* core = nullptr;

	public:

		Flags(M6502* parent) { core = parent; }

		void sim_Load();

		void sim_Store();

		BaseLogic::TriState getn_Z_OUT();
		BaseLogic::TriState getn_N_OUT();
		BaseLogic::TriState getn_C_OUT();
		BaseLogic::TriState getn_D_OUT();
		BaseLogic::TriState getn_I_OUT(BaseLogic::TriState BRK6E);
		BaseLogic::TriState getn_V_OUT();
	};
}
