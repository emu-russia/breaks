#pragma once

namespace M6502Core
{
	union RegsControl_TempWire
	{
		struct
		{
			unsigned n_Y_SB : 1;
			unsigned n_X_SB : 1;
			unsigned n_SB_X : 1;
			unsigned n_SB_Y : 1;
			unsigned n_SB_S : 1;
			unsigned n_S_ADL : 1;
		};
		uint8_t bits;
	};

	class RegsControl
	{
		BaseLogic::DLatch nready_latch;

		BaseLogic::DLatch ysb_latch;
		BaseLogic::DLatch xsb_latch;
		BaseLogic::DLatch ssb_latch;
		BaseLogic::DLatch sbx_latch;
		BaseLogic::DLatch sby_latch;
		BaseLogic::DLatch sbs_latch;
		BaseLogic::DLatch ss_latch;
		BaseLogic::DLatch sadl_latch;

		M6502* core = nullptr;

		RegsControl_TempWire temp_tab[0x10000];
		RegsControl_TempWire prev_temp;

		RegsControl_TempWire PreCalc(uint8_t ir, bool n_T0, bool n_T1X, bool n_T2, bool n_T3, bool n_T4, bool n_T5, bool n_ready, bool n_ready_latch);

	public:

		RegsControl(M6502* parent);

		void sim ();
	};
}
