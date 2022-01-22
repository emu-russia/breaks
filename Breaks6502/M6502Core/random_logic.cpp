#include "pch.h"

using namespace BaseLogic;

namespace M6502Core
{
	RandomLogic::RandomLogic(M6502* parent)
	{
		core = parent;
		regs_control = new RegsControl(core);
		alu_control = new ALUControl(core);
		pc_control = new PC_Control(core);
		bus_control = new BusControl(core);
		flags_control = new FlagsControl(core);
		flags = new Flags(core);
		branch_logic = new BranchLogic(core);
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

	void RandomLogic::sim()
	{
		// Register control

		regs_control->sim();

		// ALU control

		alu_control->sim();

		// Program counter (PC) control

		pc_control->sim();

		// Bus control

		bus_control->sim();

		// Flags control logic

		flags_control->sim();

		// The processing of loading flags has moved to the bottom part.

		// Conditional branch logic

		branch_logic->sim();
	}
}
