#pragma once

namespace M6502Core
{
	enum class RandomLogic_Input
	{
		PHI1 = 0,
		PHI2,
		n_ready,
		T0,
		T1,
		IR0,
		n_IR5,
		n_PRDY,
		Max,
	};

	enum class RandomLogic_Output
	{
		BRFW = 0,
		n_BRTAKEN,
		PC_DB,
		n_ADL_PCL,
		Max,
	};

	class RandomLogic
	{
	public:
		RegsControl* regs_control = nullptr;
		ALUControl* alu_control = nullptr;
		PC_Control* pc_control = nullptr;
		BusControl* bus_control = nullptr;
		FlagsControl* flags_control = nullptr;
		Flags* flags = nullptr;
		BranchLogic* branch_logic = nullptr;

		RandomLogic();
		~RandomLogic();

		void sim(BaseLogic::TriState inputs[], BaseLogic::TriState d[], BaseLogic::TriState outputs[], BaseLogic::TriState DB[]);
	};
}
