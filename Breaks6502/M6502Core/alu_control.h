#pragma once

namespace M6502Core
{
	class ALUControl
	{
		BaseLogic::DLatch acin_latch1;
		BaseLogic::DLatch acin_latch2;
		BaseLogic::DLatch acin_latch3;
		BaseLogic::DLatch acin_latch4;
		BaseLogic::DLatch acin_latch5;

		BaseLogic::DLatch ndbadd_latch;
		BaseLogic::DLatch dbadd_latch;
		BaseLogic::DLatch zadd_latch;
		BaseLogic::DLatch sbadd_latch;
		BaseLogic::DLatch adladd_latch;
		
		BaseLogic::DLatch ands_latch1;
		BaseLogic::DLatch ands_latch2;
		BaseLogic::DLatch eors_latch1;
		BaseLogic::DLatch eors_latch2;
		BaseLogic::DLatch ors_latch1;
		BaseLogic::DLatch ors_latch2;
		BaseLogic::DLatch srs_latch1;
		BaseLogic::DLatch srs_latch2;
		BaseLogic::DLatch sums_latch1;
		BaseLogic::DLatch sums_latch2;

		BaseLogic::DLatch addsb7_latch;
		BaseLogic::DLatch addsb06_latch;
		BaseLogic::DLatch addadl_latch;

		BaseLogic::DLatch daa_latch1;
		BaseLogic::DLatch daa_latch2;
		BaseLogic::DLatch dsa_latch1;
		BaseLogic::DLatch dsa_latch2;

		// ADD/SB7 latches

		BaseLogic::DLatch cout_latch;
		BaseLogic::DLatch nready_latch;
		BaseLogic::DLatch mux_latch1;
		BaseLogic::DLatch ff_latch1;
		BaseLogic::DLatch ff_latch2;
		BaseLogic::DLatch sr_latch1;
		BaseLogic::DLatch sr_latch2;

		M6502* core = nullptr;

		Thread* alu_control_thread = nullptr;
		volatile bool running = false;
		bool mt;

	public:

		ALUControl(M6502* parent, bool MT)
		{
			mt = MT;
			core = parent;
			if (mt)
				alu_control_thread = new Thread(sim, false, this, "alu_control_thread");
		}
		~ALUControl()
		{
			if (mt)
				delete alu_control_thread;
		}

		static void sim(void* inst);

		void mt_run();
		void mt_wait();
	};
}
