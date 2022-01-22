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

	public:

		PC_Control(M6502* parent) { core = parent; }

		void sim();
	};
}
