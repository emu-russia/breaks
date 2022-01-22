#pragma once

namespace M6502Core
{
	class BusControl
	{
		BaseLogic::DLatch z_adh0_latch;
		BaseLogic::DLatch z_adh17_latch;
		BaseLogic::DLatch sb_ac_latch;
		BaseLogic::DLatch adl_abl_latch;
		BaseLogic::DLatch ac_sb_latch;
		BaseLogic::DLatch sb_db_latch;
		BaseLogic::DLatch ac_db_latch;
		BaseLogic::DLatch sb_adh_latch;
		BaseLogic::DLatch adh_abh_latch;
		BaseLogic::DLatch dl_adh_latch;
		BaseLogic::DLatch dl_adl_latch;
		BaseLogic::DLatch dl_db_latch;
		BaseLogic::DLatch nready_latch;

		M6502* core = nullptr;

	public:

		BusControl(M6502* parent) { core = parent; }

		void sim();
	};
}
