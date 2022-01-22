#pragma once

namespace M6502Core
{
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

		Thread* regs_control_thread = nullptr;
		volatile bool running = false;
		bool mt;

	public:

		RegsControl(M6502* parent, bool MT)
		{
			mt = MT;
			core = parent;
			if (mt)
				regs_control_thread = new Thread(sim, false, this, "regs_control_thread");
		}
		~RegsControl()
		{
			if (mt)
				delete regs_control_thread;
		}

		static void sim (void* inst);

		void mt_run();
		void mt_wait();
	};
}
