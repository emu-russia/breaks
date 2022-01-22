#pragma once

namespace M6502Core
{
	class BRKProcessing
	{
		BaseLogic::DLatch brk5_latch;
		BaseLogic::DLatch brk6_latch1;
		BaseLogic::DLatch brk6_latch2;
		BaseLogic::DLatch res_latch1;
		BaseLogic::DLatch res_latch2;
		BaseLogic::DLatch brk6e_latch;
		BaseLogic::DLatch brk7_latch;
		BaseLogic::DLatch nmip_latch;
		BaseLogic::DLatch donmi_latch;
		BaseLogic::DLatch ff1_latch;
		BaseLogic::DLatch ff2_latch;
		BaseLogic::DLatch delay_latch1;
		BaseLogic::DLatch delay_latch2;
		BaseLogic::DLatch b_latch1;
		BaseLogic::DLatch b_latch2;

		BaseLogic::DLatch zadl_latch[3];

		M6502* core = nullptr;

	public:

		BRKProcessing(M6502* parent) { core = parent; }

		void sim_BeforeRandom();
		void sim_AfterRandom();

		BaseLogic::TriState getDORES();
		BaseLogic::TriState getB_OUT(BaseLogic::TriState BRK6E);
		BaseLogic::TriState getn_BRK6_LATCH2();
	};
}
