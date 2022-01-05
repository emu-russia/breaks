#pragma once

namespace M6502Core
{
	enum class PC_Control_Input
	{
		PHI1 = 0,
		PHI2,
		n_ready,
		T0,
		T1,
		BR0,		// BR0 is required as a separate input because it is modified by the /PRDY signal.
		Max,
	};

	enum class PC_Control_Output
	{
		PCL_DB = 0,
		PCH_DB,
		PCL_ADL,
		PCH_ADH,
		PCL_PCL,
		ADL_PCL,
		ADH_PCH,
		PCH_PCH,

		PC_DB,
		n_ADL_PCL,
		DL_PCH,
		n_PCH_PCH,

		Max,
	};

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

	public:

		void sim(BaseLogic::TriState inputs[], BaseLogic::TriState d[], BaseLogic::TriState outputs[]);
	};
}
