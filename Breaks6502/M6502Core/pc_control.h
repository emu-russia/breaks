#pragma once

namespace M6502Core
{
	class PC_Control
	{
		BaseLogic::DLatch pcl_db_latch1;
		BaseLogic::DLatch pcl_db_latch2;
		BaseLogic::DLatch pch_db_latch1;
		BaseLogic::DLatch pch_db_latch2;
		BaseLogic::DLatch nready_latch;
		BaseLogic::DLatch pcl_adl_latch;
		BaseLogic::DLatch pch_adh_latch;
		BaseLogic::DLatch pcl_pcl_latch;
		BaseLogic::DLatch adl_pcl_latch;
		BaseLogic::DLatch adh_pch_latch;
		BaseLogic::DLatch pch_pch_latch;

		M6502* core = nullptr;

		Thread* pc_control_thread = nullptr;
		volatile bool running = false;
		bool mt;

	public:

		PC_Control(M6502* parent, bool MT)
		{
			mt = MT;
			core = parent;
			if (mt)
				pc_control_thread = new Thread(sim, false, this, "pc_control_thread");
		}
		~PC_Control()
		{
			if (mt)
				delete pc_control_thread;
		}

		static void sim(void* inst);

		void mt_run();
		void mt_wait();
	};
}
