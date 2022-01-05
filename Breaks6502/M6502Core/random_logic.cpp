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

	void RandomLogic::sim(TriState inputs[], TriState d[], TriState outputs[])
	{
		TriState PHI1 = inputs[(size_t)RandomLogic_Input::PHI1];
		TriState PHI2 = inputs[(size_t)RandomLogic_Input::PHI2];

		TriState regs_control_in[(size_t)RegsControl_Input::Max];
		TriState regs_control_out[(size_t)RegsControl_Output::Max];

		regs_control_in[(size_t)RegsControl_Input::PHI1] = PHI1;
		regs_control_in[(size_t)RegsControl_Input::PHI2] = PHI2;

		regs_control->sim(regs_control_in, d, regs_control_out);

		alu_control->sim();
		pc_control->sim();
		bus_control->sim();
		flags_control->sim();
		flags->sim();

		TriState branch_logic_in[(size_t)BranchLogic_Input::Max] = { TriState::Zero };	// DEBUG
		TriState branch_logic_out[(size_t)BranchLogic_Output::Max] = { TriState::Zero };	// DEBUG

		branch_logic_in[(size_t)BranchLogic_Input::PHI1] = PHI1;
		branch_logic_in[(size_t)BranchLogic_Input::PHI2] = PHI2;

		branch_logic->sim(branch_logic_in, branch_logic_out);

		outputs[(size_t)RandomLogic_Output::BRFW] = branch_logic_out[(size_t)BranchLogic_Output::BRFW];
		outputs[(size_t)RandomLogic_Output::n_BRTAKEN] = branch_logic_out[(size_t)BranchLogic_Output::n_BRTAKEN];
	}
}
