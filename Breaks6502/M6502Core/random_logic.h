#pragma once

namespace M6502Core
{
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

		void sim(BaseLogic::TriState d[]);
	};
}
