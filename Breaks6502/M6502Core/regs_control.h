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

	public:

		RegsControl(M6502* parent) { core = parent; }

		void sim ();
	};
}
