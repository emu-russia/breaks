#include "pch.h"

using namespace BaseLogic;

namespace M6502Core
{
	RandomLogic::RandomLogic(M6502* parent)
	{
		core = parent;
		regs_control = new RegsControl(core, MT);
		alu_control = new ALUControl(core, MT);
		pc_control = new PC_Control(core, MT);
		bus_control = new BusControl(core, MT);
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

		if (MT)
			regs_control->mt_run();
		else
			regs_control->sim(regs_control);

		// ALU control

		if (MT)
			alu_control->mt_run();
		else
			alu_control->sim(alu_control);

		// Program counter (PC) control

		if (MT)
			pc_control->mt_run();
		else
			pc_control->sim(pc_control);

		// Bus control

		if (MT)
			bus_control->mt_run();
		else
			bus_control->sim(bus_control);

		// Flags control logic

		flags_control->sim(flags_control);

		// MT Barrier

		if (MT)
		{
			regs_control->mt_wait();
			alu_control->mt_wait();
			pc_control->mt_wait();
			bus_control->mt_wait();
		}

		// The processing of loading flags has moved to the bottom part.

		// Conditional branch logic

		TriState branch_logic_in[(size_t)BranchLogic_Input::Max];
		TriState branch_logic_out[(size_t)BranchLogic_Output::Max];

		branch_logic_in[(size_t)BranchLogic_Input::PHI1] = core->wire.PHI1;
		branch_logic_in[(size_t)BranchLogic_Input::PHI2] = core->wire.PHI2;
		branch_logic_in[(size_t)BranchLogic_Input::DB7] = core->DB[7];
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
