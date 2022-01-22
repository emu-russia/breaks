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

	void RandomLogic::sim()
	{
		TriState* d = core->decoder_out;
		TriState PHI1 = core->wire.PHI1;
		TriState PHI2 = core->wire.PHI2;
		TriState n_ready = core->wire.n_ready;
		TriState T0 = core->wire.T0;
		TriState T1 = core->disp->getT1();
		TriState IR0 = core->ir->IROut[0];
		TriState n_IR5 = NOT(core->ir->IROut[5]);
		TriState n_PRDY = core->wire.n_PRDY;
		TriState ACR = core->alu->getACR();
		TriState AVR = core->alu->getAVR();
		TriState Z_ADL0 = core->cmd.Z_ADL0;
		TriState Z_ADL1 = core->cmd.Z_ADL1;
		TriState Z_ADL2 = core->cmd.Z_ADL2;
		TriState BRK6E = core->wire.BRK6E;
		TriState SO = core->wire.SO;
		TriState STOR = core->disp->getSTOR(d);
		TriState B_OUT = core->brk->getB_OUT(core->wire.BRK6E);
		TriState T5 = core->wire.T5;
		TriState T6 = core->wire.T6;
		TriState ACRL2 = core->wire.ACRL2;

		TriState BR0 = AND(d[73], NOT(n_PRDY));

		// Register control

		regs_control->sim(regs_control);

		// ALU control

		alu_control->sim(alu_control);

		// Program counter (PC) control

		pc_control->sim(pc_control);

		// Bus control

		bus_control->sim(bus_control);

		// Flags control logic

		flags_control->sim(flags_control);

		// The processing of loading flags has moved to the bottom part.

		// Conditional branch logic

		TriState branch_logic_in[(size_t)BranchLogic_Input::Max];
		TriState branch_logic_out[(size_t)BranchLogic_Output::Max];

		branch_logic_in[(size_t)BranchLogic_Input::PHI1] = PHI1;
		branch_logic_in[(size_t)BranchLogic_Input::PHI2] = PHI2;
		branch_logic_in[(size_t)BranchLogic_Input::DB7] = core->DB[7];
		branch_logic_in[(size_t)BranchLogic_Input::n_IR5] = n_IR5;
		branch_logic_in[(size_t)BranchLogic_Input::n_C_OUT] = flags->getn_C_OUT();
		branch_logic_in[(size_t)BranchLogic_Input::n_V_OUT] = flags->getn_V_OUT();
		branch_logic_in[(size_t)BranchLogic_Input::n_N_OUT] = flags->getn_N_OUT();
		branch_logic_in[(size_t)BranchLogic_Input::n_Z_OUT] = flags->getn_Z_OUT();

		branch_logic->sim(branch_logic_in, d, branch_logic_out);

		// Outputs

		core->wire.BRFW = branch_logic_out[(size_t)BranchLogic_Output::BRFW];
		core->wire.n_BRTAKEN = branch_logic_out[(size_t)BranchLogic_Output::n_BRTAKEN];
	}
}
