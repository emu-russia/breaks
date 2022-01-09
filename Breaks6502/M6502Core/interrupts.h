#pragma once

namespace M6502Core
{
	enum class BRKProcessing_Input
	{
		PHI1 = 0,
		PHI2,
		BRK5,
		n_ready,
		RESP,
		n_NMIP,
		n_IRQP,
		T0,
		BR2,
		n_I_OUT,
		Max,
	};

	enum class BRKProcessing_Output
	{
		BRK6E = 0,
		BRK7,
		DORES,
		B_OUT,
		Z_ADL0,
		Z_ADL1,
		Z_ADL2,
		n_DONMI,
		Max,
	};

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

		BaseLogic::FF brk_ff;
		BaseLogic::FF res_ff;
		BaseLogic::FF nmi_ff1;
		BaseLogic::FF nmi_ff2;
		BaseLogic::FF b_ff;

		BaseLogic::DLatch zadl_latch[3];

	public:

		void sim(BaseLogic::TriState inputs[], BaseLogic::TriState outputs[]);

		BaseLogic::TriState getDORES();
		BaseLogic::TriState getB_OUT();
	};
}
