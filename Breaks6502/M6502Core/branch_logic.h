#pragma once

namespace M6502Core
{
	class BranchLogic
	{
		BaseLogic::DLatch br2_latch;
		BaseLogic::DLatch brfw_latch1;
		BaseLogic::DLatch brfw_latch2;

		M6502* core = nullptr;

	public:

		BranchLogic(M6502* parent) { core = parent; }

		void sim();

		BaseLogic::TriState getBRFW();
	};
}
