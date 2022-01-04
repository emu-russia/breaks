#include "pch.h"

using namespace BaseLogic;

namespace M6502Core
{
	RandomLogic::RandomLogic()
	{
		regs_control = new RegsControl;
		alu_control = new ALUControl;
		pc_control = new PC_Control;
		bus_control = new BusControl;
		flags_control = new FlagsControl;
		flags = new Flags;
		branch_logic = new BranchLogic;
	}

	RandomLogic::~RandomLogic()
	{
		delete regs_control;
		delete alu_control;
		delete pc_control;
		delete bus_control;
		delete flags_control;
		delete flags;
		delete branch_logic;
	}

	void RandomLogic::sim(TriState d[])
	{
		TriState regs_control_in[(size_t)RegsControl_Input::Max];
		TriState regs_control_out[(size_t)RegsControl_Output::Max];

		regs_control->sim(regs_control_in, d, regs_control_out);

		alu_control->sim();
		pc_control->sim();
		bus_control->sim();
		flags_control->sim();
		flags->sim();
		branch_logic->sim();
	}
}
