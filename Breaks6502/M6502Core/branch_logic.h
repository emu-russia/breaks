#pragma once

namespace M6502Core
{
	enum class BranchLogic_Input
	{
		PHI1 = 0,
		PHI2,
		BR2,
		DB7,
		n_IR5,
		D121,
		D126,
		n_C_OUT,
		n_V_OUT,
		n_N_OUT,
		n_Z_OUT,
		Max,
	};

	enum class BranchLogic_Output
	{
		n_BRTAKEN = 0,
		BRFW,
		Max,
	};

	class BranchLogic
	{
		BaseLogic::DLatch br2_latch;
		BaseLogic::DLatch brfw_latch1;
		BaseLogic::DLatch brfw_latch2;
		BaseLogic::FF brfw_ff;

	public:

		void sim(BaseLogic::TriState inputs[], BaseLogic::TriState outputs[]);

		BaseLogic::TriState getBRFW();
	};
}
