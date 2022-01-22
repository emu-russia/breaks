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

		Thread* bus_control_thread = nullptr;
		volatile bool running = false;
		bool mt;

	public:

		BusControl(M6502* parent, bool MT)
		{
			mt = MT;
			core = parent;
			if (mt)	
				bus_control_thread = new Thread(sim, false, this, "bus_control_thread");
		}
		~BusControl()
		{
			if (mt)
				delete bus_control_thread;
		}

		static void sim(void* inst);

		void mt_run();
		void mt_wait();
	};
}
