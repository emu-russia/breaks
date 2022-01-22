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

		flags_control->sim(flags_control);

		// The processing of loading flags has moved to the bottom part.

		// Conditional branch logic

		TriState branch_logic_in[(size_t)BranchLogic_Input::Max];
		TriState branch_logic_out[(size_t)BranchLogic_Output::Max];

		branch_logic_in[(size_t)BranchLogic_Input::PHI1] = core->wire.PHI1;
		branch_logic_in[(size_t)BranchLogic_Input::PHI2] = core->wire.PHI2;
		branch_logic_in[(size_t)BranchLogic_Input::DB7] = core->DB & 0x80 ? TriState::One : TriState::Zero;
		branch_logic_in[(size_t)BranchLogic_Input::n_IR5] = NOT(core->ir->IROut[5]);
		branch_logic_in[(size_t)BranchLogic_Input::n_C_OUT] = flags->getn_C_OUT();
		branch_logic_in[(size_t)BranchLogic_Input::n_V_OUT] = flags->getn_V_OUT();
		branch_logic_in[(size_t)BranchLogic_Input::n_N_OUT] = flags->getn_N_OUT();
		branch_logic_in[(size_t)BranchLogic_Input::n_Z_OUT] = flags->getn_Z_OUT();

		branch_logic->sim(branch_logic_in, core->decoder_out, branch_logic_out);

		// Outputs

		core->wire.BRFW = branch_logic_out[(size_t)BranchLogic_Output::BRFW];
		core->wire.n_BRTAKEN = branch_logic_out[(size_t)BranchLogic_Output::n_BRTAKEN];
	}
}
