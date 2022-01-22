#include "pch.h"

using namespace BaseLogic;

namespace M6502Core
{
	RandomLogic::RandomLogic(M6502* parent)
	{
		core = parent;
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

		TriState regs_control_in[(size_t)RegsControl_Input::Max];
		TriState regs_control_out[(size_t)RegsControl_Output::Max];

		regs_control_in[(size_t)RegsControl_Input::PHI1] = PHI1;
		regs_control_in[(size_t)RegsControl_Input::PHI2] = PHI2;
		regs_control_in[(size_t)RegsControl_Input::n_ready] = n_ready;
		regs_control_in[(size_t)RegsControl_Input::STOR] = STOR;

		regs_control->sim(regs_control_in, d, regs_control_out);

		// ALU control

		TriState alu_control_in[(size_t)ALUControl_Input::Max];
		TriState alu_control_out[(size_t)ALUControl_Output::Max];

		alu_control_in[(size_t)ALUControl_Input::PHI1] = PHI1;
		alu_control_in[(size_t)ALUControl_Input::PHI2] = PHI2;
		alu_control_in[(size_t)ALUControl_Input::BRFW] = branch_logic->getBRFW();
		alu_control_in[(size_t)ALUControl_Input::n_ready] = n_ready;
		alu_control_in[(size_t)ALUControl_Input::BRK6E] = BRK6E;
		alu_control_in[(size_t)ALUControl_Input::STKOP] = regs_control_out[(size_t)RegsControl_Output::STKOP];
		alu_control_in[(size_t)ALUControl_Input::T0] = T0;
		alu_control_in[(size_t)ALUControl_Input::T1] = T1;
		alu_control_in[(size_t)ALUControl_Input::T5] = T5;
		alu_control_in[(size_t)ALUControl_Input::T6] = T6;
		alu_control_in[(size_t)ALUControl_Input::PGX] = bus_control->getPGX(d, BR0);
		alu_control_in[(size_t)ALUControl_Input::n_D_OUT] = flags->getn_D_OUT();
		alu_control_in[(size_t)ALUControl_Input::n_C_OUT] = flags->getn_C_OUT();

		alu_control->sim(alu_control_in, d, alu_control_out);

		// Program counter (PC) control

		TriState pc_in[(size_t)PC_Control_Input::Max];
		TriState pc_out[(size_t)PC_Control_Output::Max];

		pc_in[(size_t)PC_Control_Input::PHI1] = PHI1;
		pc_in[(size_t)PC_Control_Input::PHI2] = PHI2;
		pc_in[(size_t)PC_Control_Input::n_ready] = n_ready;
		pc_in[(size_t)PC_Control_Input::T0] = T0;
		pc_in[(size_t)PC_Control_Input::T1] = T1;
		pc_in[(size_t)PC_Control_Input::BR0] = BR0;

		pc_control->sim(pc_in, d, pc_out);

		// Bus control

		TriState bus_in[(size_t)BusControl_Input::Max];
		TriState bus_out[(size_t)BusControl_Output::Max];

		bus_in[(size_t)BusControl_Input::PHI1] = PHI1;
		bus_in[(size_t)BusControl_Input::PHI2] = PHI2;
		bus_in[(size_t)BusControl_Input::SBXY] = regs_control_out[(size_t)RegsControl_Output::SBXY];
		bus_in[(size_t)BusControl_Input::STXY] = regs_control_out[(size_t)RegsControl_Output::STXY];
		bus_in[(size_t)BusControl_Input::AND] = alu_control_out[(size_t)ALUControl_Output::AND];
		bus_in[(size_t)BusControl_Input::STOR] = STOR;
		bus_in[(size_t)BusControl_Input::Z_ADL0] = Z_ADL0;
		bus_in[(size_t)BusControl_Input::ACRL2] = ACRL2;
		bus_in[(size_t)BusControl_Input::DL_PCH] = pc_out[(size_t)PC_Control_Output::DL_PCH];
		bus_in[(size_t)BusControl_Input::n_ready] = n_ready;
		bus_in[(size_t)BusControl_Input::INC_SB] = alu_control_out[(size_t)ALUControl_Output::INC_SB];
		bus_in[(size_t)BusControl_Input::BRK6E] = BRK6E;
		bus_in[(size_t)BusControl_Input::n_PCH_PCH] = pc_out[(size_t)PC_Control_Output::n_PCH_PCH];
		bus_in[(size_t)BusControl_Input::T0] = T0;
		bus_in[(size_t)BusControl_Input::T1] = T1;
		bus_in[(size_t)BusControl_Input::T5] = T5;
		bus_in[(size_t)BusControl_Input::T6] = T6;
		bus_in[(size_t)BusControl_Input::BR0] = BR0;
		bus_in[(size_t)BusControl_Input::IR0] = IR0;

		bus_control->sim(bus_in, d, bus_out);

		// Flags control logic

		TriState flags_ctrl_in[(size_t)FlagsControl_Input::Max];
		TriState flags_ctrl_out[(size_t)FlagsControl_Output::Max];

		flags_ctrl_in[(size_t)FlagsControl_Input::PHI2] = PHI2;
		flags_ctrl_in[(size_t)FlagsControl_Input::T6] = T6;
		flags_ctrl_in[(size_t)FlagsControl_Input::ZTST] = bus_out[(size_t)BusControl_Output::ZTST];
		flags_ctrl_in[(size_t)FlagsControl_Input::SR] = alu_control_out[(size_t)ALUControl_Output::SR];
		flags_ctrl_in[(size_t)FlagsControl_Input::n_ready] = n_ready;

		flags_control->sim(flags_ctrl_in, d, flags_ctrl_out);

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

		core->cmd.Y_SB = regs_control_out[(size_t)RegsControl_Output::Y_SB];
		core->cmd.SB_Y = regs_control_out[(size_t)RegsControl_Output::SB_Y];
		core->cmd.X_SB = regs_control_out[(size_t)RegsControl_Output::X_SB];
		core->cmd.SB_X = regs_control_out[(size_t)RegsControl_Output::SB_X];
		core->cmd.S_ADL = regs_control_out[(size_t)RegsControl_Output::S_ADL];
		core->cmd.S_SB = regs_control_out[(size_t)RegsControl_Output::S_SB];
		core->cmd.SB_S = regs_control_out[(size_t)RegsControl_Output::SB_S];
		core->cmd.S_S = regs_control_out[(size_t)RegsControl_Output::S_S];
		core->cmd.NDB_ADD = alu_control_out[(size_t)ALUControl_Output::NDB_ADD];
		core->cmd.DB_ADD = alu_control_out[(size_t)ALUControl_Output::DB_ADD];
		core->cmd.Z_ADD = alu_control_out[(size_t)ALUControl_Output::Z_ADD];
		core->cmd.SB_ADD = alu_control_out[(size_t)ALUControl_Output::SB_ADD];
		core->cmd.ADL_ADD = alu_control_out[(size_t)ALUControl_Output::ADL_ADD];
		core->cmd.n_ACIN = alu_control_out[(size_t)ALUControl_Output::n_ACIN];
		core->cmd.ANDS = alu_control_out[(size_t)ALUControl_Output::ANDS];
		core->cmd.EORS = alu_control_out[(size_t)ALUControl_Output::EORS];
		core->cmd.ORS = alu_control_out[(size_t)ALUControl_Output::ORS];
		core->cmd.SRS = alu_control_out[(size_t)ALUControl_Output::SRS];
		core->cmd.SUMS = alu_control_out[(size_t)ALUControl_Output::SUMS];
		core->cmd.n_DAA = alu_control_out[(size_t)ALUControl_Output::n_DAA];
		core->cmd.n_DSA = alu_control_out[(size_t)ALUControl_Output::n_DSA];
		core->cmd.ADD_SB7 = alu_control_out[(size_t)ALUControl_Output::ADD_SB7];
		core->cmd.ADD_SB06 = alu_control_out[(size_t)ALUControl_Output::ADD_SB06];
		core->cmd.ADD_ADL = alu_control_out[(size_t)ALUControl_Output::ADD_ADL];
		core->cmd.SB_AC = bus_out[(size_t)BusControl_Output::SB_AC];
		core->cmd.AC_SB = bus_out[(size_t)BusControl_Output::AC_SB];
		core->cmd.AC_DB = bus_out[(size_t)BusControl_Output::AC_DB];
		core->cmd.ADH_PCH = pc_out[(size_t)PC_Control_Output::ADH_PCH];
		core->cmd.PCH_PCH = pc_out[(size_t)PC_Control_Output::PCH_PCH];
		core->cmd.PCH_ADH = pc_out[(size_t)PC_Control_Output::PCH_ADH];
		core->cmd.PCH_DB = pc_out[(size_t)PC_Control_Output::PCH_DB];
		core->cmd.ADL_PCL = pc_out[(size_t)PC_Control_Output::ADL_PCL];
		core->cmd.PCL_PCL = pc_out[(size_t)PC_Control_Output::PCL_PCL];
		core->cmd.PCL_ADL = pc_out[(size_t)PC_Control_Output::PCL_ADL];
		core->cmd.PCL_DB = pc_out[(size_t)PC_Control_Output::PCL_DB];
		core->cmd.ADH_ABH = bus_out[(size_t)BusControl_Output::ADH_ABH];
		core->cmd.ADL_ABL = bus_out[(size_t)BusControl_Output::ADL_ABL];
		core->cmd.Z_ADL0 = Z_ADL0;	// pass through
		core->cmd.Z_ADL1 = Z_ADL1;	// pass through
		core->cmd.Z_ADL2 = Z_ADL2;	// pass through
		core->cmd.Z_ADH0 = bus_out[(size_t)BusControl_Output::Z_ADH0];
		core->cmd.Z_ADH17 = bus_out[(size_t)BusControl_Output::Z_ADH17];
		core->cmd.SB_DB = bus_out[(size_t)BusControl_Output::SB_DB];
		core->cmd.SB_ADH = bus_out[(size_t)BusControl_Output::SB_ADH];
		core->cmd.DL_ADL = bus_out[(size_t)BusControl_Output::DL_ADL];
		core->cmd.DL_ADH = bus_out[(size_t)BusControl_Output::DL_ADH];
		core->cmd.DL_DB = bus_out[(size_t)BusControl_Output::DL_DB];

		core->cmd.P_DB = flags_ctrl_out[(size_t)FlagsControl_Output::P_DB];
		core->cmd.DB_P = flags_ctrl_out[(size_t)FlagsControl_Output::DB_P];
		core->cmd.DBZ_Z = flags_ctrl_out[(size_t)FlagsControl_Output::DBZ_Z];
		core->cmd.DB_N = flags_ctrl_out[(size_t)FlagsControl_Output::DB_N];
		core->cmd.IR5_C = flags_ctrl_out[(size_t)FlagsControl_Output::IR5_C];
		core->cmd.DB_C = flags_ctrl_out[(size_t)FlagsControl_Output::DB_C];
		core->cmd.ACR_C = flags_ctrl_out[(size_t)FlagsControl_Output::ACR_C];
		core->cmd.IR5_D = flags_ctrl_out[(size_t)FlagsControl_Output::IR5_D];
		core->cmd.IR5_I = flags_ctrl_out[(size_t)FlagsControl_Output::IR5_I];
		core->cmd.DB_V = flags_ctrl_out[(size_t)FlagsControl_Output::DB_V];
		core->cmd.AVR_V = d[112];
		core->cmd.Z_V = flags_ctrl_out[(size_t)FlagsControl_Output::Z_V];

		core->wire.BRFW = branch_logic_out[(size_t)BranchLogic_Output::BRFW];
		core->wire.n_BRTAKEN = branch_logic_out[(size_t)BranchLogic_Output::n_BRTAKEN];
		core->wire.PC_DB = pc_out[(size_t)PC_Control_Output::PC_DB];
		core->wire.n_ADL_PCL = pc_out[(size_t)PC_Control_Output::n_ADL_PCL];
	}
}
