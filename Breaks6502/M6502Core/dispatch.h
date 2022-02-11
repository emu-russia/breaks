#pragma once

namespace M6502Core
{
	class Dispatcher
	{
		BaseLogic::DLatch acr_latch1;
		BaseLogic::DLatch acr_latch2;

		BaseLogic::DLatch t56_latch;
		BaseLogic::DLatch t5_latch1;
		BaseLogic::DLatch t5_latch2;
		BaseLogic::DLatch t6_latch1;
		BaseLogic::DLatch t6_latch2;
		
		BaseLogic::DLatch tres2_latch;
		BaseLogic::DLatch tresx_latch1;
		BaseLogic::DLatch tresx_latch2;

		BaseLogic::DLatch fetch_latch;
		BaseLogic::DLatch wr_latch;
		BaseLogic::DLatch ready_latch1;
		BaseLogic::DLatch ready_latch2;

		BaseLogic::DLatch ends_latch1;
		BaseLogic::DLatch ends_latch2;

		BaseLogic::DLatch nready_latch;
		BaseLogic::DLatch step_latch1;
		BaseLogic::DLatch step_latch2;
		BaseLogic::DLatch t1_latch;

		BaseLogic::DLatch comp_latch1;
		BaseLogic::DLatch comp_latch2;
		BaseLogic::DLatch comp_latch3;

		BaseLogic::DLatch rdydelay_latch1;
		BaseLogic::DLatch rdydelay_latch2;

		BaseLogic::DLatch t0_latch;
		BaseLogic::DLatch t1x_latch;

		BaseLogic::DLatch br_latch1;
		BaseLogic::DLatch br_latch2;
		BaseLogic::DLatch ipc_latch1;
		BaseLogic::DLatch ipc_latch2;
		BaseLogic::DLatch ipc_latch3;

		M6502* core = nullptr;

	public:

		Dispatcher(M6502* parent) { core = parent; }
		
		void sim_BeforeDecoder();

		void sim_BeforeRandomLogic();

		void sim_AfterRandomLogic();

		BaseLogic::TriState getTRES2();

		BaseLogic::TriState getT1();

		BaseLogic::TriState getSTOR(BaseLogic::TriState d[]);
	};
}
