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

	void RandomLogic::sim(TriState inputs[], TriState d[], TriState outputs[], TriState DB[])
	{
		TriState PHI1 = inputs[(size_t)RandomLogic_Input::PHI1];
		TriState PHI2 = inputs[(size_t)RandomLogic_Input::PHI2];
		TriState n_ready = inputs[(size_t)RandomLogic_Input::n_ready];
		TriState T0 = inputs[(size_t)RandomLogic_Input::T0];
		TriState T1 = inputs[(size_t)RandomLogic_Input::T1];
		TriState IR0 = inputs[(size_t)RandomLogic_Input::IR0];
		TriState n_IR5 = inputs[(size_t)RandomLogic_Input::n_IR5];
		TriState n_PRDY = inputs[(size_t)RandomLogic_Input::n_PRDY];
		
		TriState BR0 = AND(d[73], NOT(n_PRDY));

		// Register control

		TriState regs_control_in[(size_t)RegsControl_Input::Max];
		TriState regs_control_out[(size_t)RegsControl_Output::Max];

		regs_control_in[(size_t)RegsControl_Input::PHI1] = PHI1;
		regs_control_in[(size_t)RegsControl_Input::PHI2] = PHI2;
		regs_control_in[(size_t)RegsControl_Input::n_ready] = n_ready;
		regs_control_in[(size_t)RegsControl_Input::STOR] = TriState::Zero; // TODO

		regs_control->sim(regs_control_in, d, regs_control_out);

		// ALU control

		TriState alu_control_in[(size_t)ALUControl_Input::Max];
		TriState alu_control_out[(size_t)ALUControl_Output::Max];

		alu_control_in[(size_t)ALUControl_Input::PHI1] = PHI1;
		alu_control_in[(size_t)ALUControl_Input::PHI2] = PHI2;
		alu_control_in[(size_t)ALUControl_Input::BRFW] = branch_logic->getBRFW();
		alu_control_in[(size_t)ALUControl_Input::n_ready] = n_ready;
		alu_control_in[(size_t)ALUControl_Input::BRK6E] = TriState::Zero; // TODO
		alu_control_in[(size_t)ALUControl_Input::STKOP] = regs_control_out[(size_t)RegsControl_Output::STKOP];
		alu_control_in[(size_t)ALUControl_Input::T0] = T0;
		alu_control_in[(size_t)ALUControl_Input::T1] = T1;
		alu_control_in[(size_t)ALUControl_Input::T5] = TriState::Zero; // TODO
		alu_control_in[(size_t)ALUControl_Input::T6] = TriState::Zero; // TODO
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
		bus_in[(size_t)BusControl_Input::STOR] = TriState::Zero; // TODO
		bus_in[(size_t)BusControl_Input::Z_ADL0] = TriState::Zero; // TODO
		bus_in[(size_t)BusControl_Input::ACRL2] = TriState::Zero; // TODO
		bus_in[(size_t)BusControl_Input::DL_PCH] = pc_out[(size_t)PC_Control_Output::DL_PCH];
		bus_in[(size_t)BusControl_Input::n_ready] = n_ready;
		bus_in[(size_t)BusControl_Input::INC_SB] = alu_control_out[(size_t)ALUControl_Output::INC_SB];
		bus_in[(size_t)BusControl_Input::BRK6E] = TriState::Zero; // TODO
		bus_in[(size_t)BusControl_Input::n_PCH_PCH] = pc_out[(size_t)PC_Control_Output::n_PCH_PCH];
		bus_in[(size_t)BusControl_Input::T0] = T0;
		bus_in[(size_t)BusControl_Input::T1] = T1;
		bus_in[(size_t)BusControl_Input::T5] = TriState::Zero; // TODO
		bus_in[(size_t)BusControl_Input::T6] = TriState::Zero; // TODO
		bus_in[(size_t)BusControl_Input::BR0] = BR0;
		bus_in[(size_t)BusControl_Input::IR0] = IR0;

		bus_control->sim(bus_in, d, bus_out);

		// Flags control logic

		TriState flags_ctrl_in[(size_t)FlagsControl_Input::Max];
		TriState flags_ctrl_out[(size_t)FlagsControl_Output::Max];

		flags_ctrl_in[(size_t)FlagsControl_Input::PHI2] = PHI2;
		flags_ctrl_in[(size_t)FlagsControl_Input::T6] = TriState::Zero; // TODO
		flags_ctrl_in[(size_t)FlagsControl_Input::ZTST] = bus_out[(size_t)BusControl_Output::ZTST];
		flags_ctrl_in[(size_t)FlagsControl_Input::SR] = alu_control_out[(size_t)ALUControl_Output::SR];
		flags_ctrl_in[(size_t)FlagsControl_Input::n_ready] = n_ready;

		flags_control->sim(flags_ctrl_in, d, flags_ctrl_out);

		// Flags

		TriState flags_in[(size_t)Flags_Input::Max];

		flags_in[(size_t)Flags_Input::PHI1] = PHI1;
		flags_in[(size_t)Flags_Input::PHI2] = PHI2;
		flags_in[(size_t)Flags_Input::SO] = TriState::Zero; // TODO
		flags_in[(size_t)Flags_Input::B_OUT] = TriState::Zero; // TODO
		flags_in[(size_t)Flags_Input::ACR] = TriState::Zero; // TODO
		flags_in[(size_t)Flags_Input::AVR] = TriState::Zero; // TODO
		flags_in[(size_t)Flags_Input::n_IR5] = n_IR5;
		flags_in[(size_t)Flags_Input::P_DB] = flags_ctrl_out[(size_t)FlagsControl_Output::P_DB];
		flags_in[(size_t)Flags_Input::DB_P] = flags_ctrl_out[(size_t)FlagsControl_Output::DB_P];
		flags_in[(size_t)Flags_Input::DBZ_Z] = flags_ctrl_out[(size_t)FlagsControl_Output::DBZ_Z];
		flags_in[(size_t)Flags_Input::DB_N] = flags_ctrl_out[(size_t)FlagsControl_Output::DB_N];
		flags_in[(size_t)Flags_Input::IR5_C] = flags_ctrl_out[(size_t)FlagsControl_Output::IR5_C];
		flags_in[(size_t)Flags_Input::DB_C] = flags_ctrl_out[(size_t)FlagsControl_Output::DB_C];
		flags_in[(size_t)Flags_Input::ACR_C] = flags_ctrl_out[(size_t)FlagsControl_Output::ACR_C];
		flags_in[(size_t)Flags_Input::IR5_D] = flags_ctrl_out[(size_t)FlagsControl_Output::IR5_D];
		flags_in[(size_t)Flags_Input::IR5_I] = flags_ctrl_out[(size_t)FlagsControl_Output::IR5_I];
		flags_in[(size_t)Flags_Input::DB_V] = flags_ctrl_out[(size_t)FlagsControl_Output::DB_V];
		flags_in[(size_t)Flags_Input::AVR_V] = d[112];
		flags_in[(size_t)Flags_Input::Z_V] = flags_ctrl_out[(size_t)FlagsControl_Output::Z_V];

		flags->sim(flags_in, DB);

		// Conditional branch logic

		TriState branch_logic_in[(size_t)BranchLogic_Input::Max];
		TriState branch_logic_out[(size_t)BranchLogic_Output::Max];

		branch_logic_in[(size_t)BranchLogic_Input::PHI1] = PHI1;
		branch_logic_in[(size_t)BranchLogic_Input::PHI2] = PHI2;
		branch_logic_in[(size_t)BranchLogic_Input::DB7] = DB[7];
		branch_logic_in[(size_t)BranchLogic_Input::n_IR5] = n_IR5;
		branch_logic_in[(size_t)BranchLogic_Input::n_C_OUT] = flags->getn_C_OUT();
		branch_logic_in[(size_t)BranchLogic_Input::n_V_OUT] = flags->getn_V_OUT();
		branch_logic_in[(size_t)BranchLogic_Input::n_N_OUT] = flags->getn_N_OUT();
		branch_logic_in[(size_t)BranchLogic_Input::n_Z_OUT] = flags->getn_Z_OUT();

		branch_logic->sim(branch_logic_in, d, branch_logic_out);

		// Outputs

		outputs[(size_t)RandomLogic_Output::BRFW] = branch_logic_out[(size_t)BranchLogic_Output::BRFW];
		outputs[(size_t)RandomLogic_Output::n_BRTAKEN] = branch_logic_out[(size_t)BranchLogic_Output::n_BRTAKEN];
		outputs[(size_t)RandomLogic_Output::PC_DB] = pc_out[(size_t)PC_Control_Output::PC_DB];
		outputs[(size_t)RandomLogic_Output::n_ADL_PCL] = pc_out[(size_t)PC_Control_Output::n_ADL_PCL];
	}
}
