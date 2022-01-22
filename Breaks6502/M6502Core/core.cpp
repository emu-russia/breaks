#include "pch.h"

using namespace BaseLogic;

namespace M6502Core
{
	M6502::M6502(bool HLE)
	{
		HLE_Mode = HLE;

		decoder = new Decoder;
		predecode = new PreDecode(this);
		ir = new IR(this);
		ext = new ExtraCounter(this);
		brk = new BRKProcessing(this);
		disp = new Dispatcher(this);
		random = new RandomLogic(this);

		addr_bus = new AddressBus;
		regs = new Regs;
		alu = new ALU;
		pc = new ProgramCounter;
		data_bus = new DataBus;
	}

	M6502::~M6502()
	{
		delete decoder;
		delete predecode;
		delete ir;
		delete ext;
		delete brk;
		delete disp;
		delete random;

		delete addr_bus;
		delete regs;
		delete alu;
		delete pc;
		delete data_bus;
	}

	void M6502::sim_Top(TriState inputs[], TriState outputs[], TriState inOuts[])
	{
		wire.n_NMI = inputs[(size_t)InputPad::n_NMI];
		wire.n_IRQ = inputs[(size_t)InputPad::n_IRQ];
		wire.n_RES = inputs[(size_t)InputPad::n_RES];
		wire.PHI0 = inputs[(size_t)InputPad::PHI0];
		wire.RDY = inputs[(size_t)InputPad::RDY];
		wire.SO = inputs[(size_t)InputPad::SO];

		// Logic associated with external input terminals

		wire.PHI1 = NOT(wire.PHI0);
		wire.PHI2 = wire.PHI0;

		prdy_latch1.set(NOT(wire.RDY), wire.PHI2);
		prdy_latch2.set(prdy_latch1.nget(), wire.PHI1);
		wire.n_PRDY = prdy_latch2.nget();

		if (wire.PHI2 == TriState::One && nNMI_Cache != wire.n_NMI)
		{
			nmip_ff.set(NOR(NOR(nmip_ff.get(), AND(NOT(wire.n_NMI), wire.PHI2)), AND(wire.n_NMI, wire.PHI2)));
			nNMI_Cache = wire.n_NMI;
		}
		wire.n_NMIP = NOT(nmip_ff.get());

		if (wire.PHI2 == TriState::One && nIRQ_Cache != wire.n_IRQ)
		{
			irqp_ff.set(NOR(NOR(irqp_ff.get(), AND(NOT(wire.n_IRQ), wire.PHI2)), AND(wire.n_IRQ, wire.PHI2)));
			nIRQ_Cache = wire.n_IRQ;
		}
		irqp_latch.set(irqp_ff.get(), wire.PHI1);
		wire.n_IRQP = irqp_latch.nget();

		if (wire.PHI2 == TriState::One && nRES_Cache != wire.n_RES)
		{
			resp_ff.set(NOR(NOR(resp_ff.get(), AND(wire.n_RES, wire.PHI2)), AND(NOT(wire.n_RES), wire.PHI2)));
			nRES_Cache = wire.n_RES;
		}
		resp_latch.set(resp_ff.get(), wire.PHI1);
		wire.RESP = resp_latch.nget();

		// Dispatcher and other auxiliary logic

		disp->sim_BeforeDecoder();

		predecode->sim(inOuts);

		ir->sim();

		ext->sim();

		TriState decoder_in[Decoder::inputs_count];
		TriState* IR = ir->IROut;

		decoder_in[(size_t)DecoderInput::n_IR0] = NOT(IR[0]);
		decoder_in[(size_t)DecoderInput::n_IR1] = NOT(IR[1]);
		decoder_in[(size_t)DecoderInput::IR01] = OR(IR[0], IR[1]);
		decoder_in[(size_t)DecoderInput::n_IR2] = NOT(IR[2]);
		decoder_in[(size_t)DecoderInput::IR2] = IR[2];
		decoder_in[(size_t)DecoderInput::n_IR3] = NOT(IR[3]);
		decoder_in[(size_t)DecoderInput::IR3] = IR[3];
		decoder_in[(size_t)DecoderInput::n_IR4] = NOT(IR[4]);
		decoder_in[(size_t)DecoderInput::IR4] = IR[4];
		decoder_in[(size_t)DecoderInput::n_IR5] = NOT(IR[5]);
		decoder_in[(size_t)DecoderInput::IR5] = IR[5];
		decoder_in[(size_t)DecoderInput::n_IR6] = NOT(IR[6]);
		decoder_in[(size_t)DecoderInput::IR6] = IR[6];
		decoder_in[(size_t)DecoderInput::n_IR7] = NOT(IR[7]);
		decoder_in[(size_t)DecoderInput::IR7] = IR[7];

		decoder_in[(size_t)DecoderInput::n_T0] = wire.n_T0;
		decoder_in[(size_t)DecoderInput::n_T1X] = wire.n_T1X;
		decoder_in[(size_t)DecoderInput::n_T2] = wire.n_T2;
		decoder_in[(size_t)DecoderInput::n_T3] = wire.n_T3;
		decoder_in[(size_t)DecoderInput::n_T4] = wire.n_T4;
		decoder_in[(size_t)DecoderInput::n_T5] = wire.n_T5;

		decoder->sim(decoder_in, &decoder_out);

		// Interrupt handling

		brk->sim_BeforeRandom();

		// Random Logic

		disp->sim_BeforeRandomLogic();

		random->sim();

		brk->sim_AfterRandom();

		disp->sim_AfterRandomLogic();
	}

	void M6502::sim_Bottom(TriState inputs[], TriState outputs[], TriState inOuts[])
	{
		TriState PHI0 = wire.PHI0;
		TriState PHI1 = wire.PHI1;
		TriState PHI2 = wire.PHI2;
		TriState SO = wire.SO;
		TriState WR = wire.WR;
		TriState P_DB = cmd.P_DB;
		TriState BRK6E = wire.BRK6E;

		TriState data_in[(size_t)DataBus_Input::Max];
		TriState regs_in[(size_t)Regs_Input::Max];
		TriState alu_in[(size_t)ALU_Input::Max];
		TriState pc_in[(size_t)ProgramCounter_Input::Max];

		// Bottom Part

		// When you simulate the lower part, you have to turn on the man in you to the fullest and imagine that you are possessed by Chuck Peddle.
		// From the development history of the 6502, we know that one developer did the upper part and another (Chuck) did the lower part. 
		// So to simulate the lower part you have to abstract as much as possible and work only with what you have (registers, buses and set of control commands from the upper part).

		// Bus load from DL: DL_DB, DL_ADL, DL_ADH

		data_in[(size_t)DataBus_Input::PHI1] = PHI1;
		data_in[(size_t)DataBus_Input::PHI2] = PHI2;
		data_in[(size_t)DataBus_Input::WR] = WR;
		data_in[(size_t)DataBus_Input::DL_ADL] = cmd.DL_ADL;
		data_in[(size_t)DataBus_Input::DL_ADH] = cmd.DL_ADH;
		data_in[(size_t)DataBus_Input::DL_DB] = cmd.DL_DB;

		data_bus->sim_GetExternalBus(data_in, DB, ADL, ADH, DB_Dirty, ADL_Dirty, ADH_Dirty, inOuts);

		// Registers to the SB bus: Y_SB, X_SB, S_SB

		regs_in[(size_t)Regs_Input::PHI2] = PHI2;
		regs_in[(size_t)Regs_Input::Y_SB] = cmd.Y_SB;
		regs_in[(size_t)Regs_Input::X_SB] = cmd.X_SB;
		regs_in[(size_t)Regs_Input::S_SB] = cmd.S_SB;

		regs->sim_StoreSB(regs_in, SB, SB_Dirty);

		// ADD saving on SB/ADL: ADD_SB7, ADD_SB06, ADD_ADL

		alu_in[(size_t)ALU_Input::ADD_SB06] = cmd.ADD_SB06;
		alu_in[(size_t)ALU_Input::ADD_SB7] = cmd.ADD_SB7;
		alu_in[(size_t)ALU_Input::ADD_ADL] = cmd.ADD_ADL;

		alu->sim_StoreADD(alu_in, SB, ADL, SB_Dirty, ADL_Dirty);

		// Saving AC: AC_SB, AC_DB

		alu_in[(size_t)ALU_Input::AC_SB] = cmd.AC_SB;
		alu_in[(size_t)ALU_Input::AC_DB] = cmd.AC_DB;

		alu->sim_StoreAC(alu_in, SB, DB, SB_Dirty, DB_Dirty);

		// Saving flags on DB bus: P_DB

		random->flags->sim_Store(P_DB, BRK6E, brk->getB_OUT(BRK6E), DB, DB_Dirty);

		// Stack pointer saving on ADL bus: S_ADL

		regs_in[(size_t)Regs_Input::S_ADL] = cmd.S_ADL;

		regs->sim_StoreOldS(regs_in, ADL, ADL_Dirty);

		// Increment PC: n_1PC

		pc_in[(size_t)ProgramCounter_Input::PHI2] = PHI2;
		pc_in[(size_t)ProgramCounter_Input::n_1PC] = wire.n_1PC;

		if (HLE_Mode)
		{
			pc->sim_HLE(pc_in);
		}
		else
		{
			pc->sim(pc_in);
		}

		// Saving PC to buses: PCL_ADL, PCH_ADH, PCL_DB, PCH_DB

		pc_in[(size_t)ProgramCounter_Input::PCL_ADL] = cmd.PCL_ADL;
		pc_in[(size_t)ProgramCounter_Input::PCL_DB] = cmd.PCL_DB;
		pc_in[(size_t)ProgramCounter_Input::PCH_ADH] = cmd.PCH_ADH;
		pc_in[(size_t)ProgramCounter_Input::PCH_DB] = cmd.PCH_DB;

		pc->sim_Store(pc_in, DB, ADL, ADH, DB_Dirty, ADL_Dirty, ADH_Dirty);

		// Bus multiplexing: SB_DB, SB_ADH

		alu_in[(size_t)ALU_Input::SB_DB] = cmd.SB_DB;
		alu_in[(size_t)ALU_Input::SB_ADH] = cmd.SB_ADH;

		alu->sim_BusMux(alu_in, SB, DB, ADH, SB_Dirty, DB_Dirty, ADH_Dirty);

		// Constant generator: Z_ADL0, Z_ADL1, Z_ADL2, Z_ADH0, Z_ADH17

		TriState addr_in_early[(size_t)AddressBus_Input::Max];

		addr_in_early[(size_t)AddressBus_Input::Z_ADL0] = cmd.Z_ADL0;
		addr_in_early[(size_t)AddressBus_Input::Z_ADL1] = cmd.Z_ADL1;
		addr_in_early[(size_t)AddressBus_Input::Z_ADL2] = cmd.Z_ADL2;
		addr_in_early[(size_t)AddressBus_Input::Z_ADH0] = cmd.Z_ADH0;
		addr_in_early[(size_t)AddressBus_Input::Z_ADH17] = cmd.Z_ADH17;

		addr_bus->sim_ConstGen(addr_in_early, ADL, ADH, ADL_Dirty, ADH_Dirty);

		// Loading ALU operands: NDB_ADD, DB_ADD, Z_ADD, SB_ADD, ADL_ADD

		alu_in[(size_t)ALU_Input::NDB_ADD] = cmd.NDB_ADD;
		alu_in[(size_t)ALU_Input::DB_ADD] = cmd.DB_ADD;
		alu_in[(size_t)ALU_Input::Z_ADD] = cmd.Z_ADD;
		alu_in[(size_t)ALU_Input::SB_ADD] = cmd.SB_ADD;
		alu_in[(size_t)ALU_Input::ADL_ADD] = cmd.ADL_ADD;

		alu->sim_Load(alu_in, SB, DB, ADL, SB_Dirty);

		// ALU operation: ANDS, EORS, ORS, SRS, SUMS, n_ACIN, n_DAA, n_DSA
		// BCD correction via SB bus: SB_AC

		alu_in[(size_t)ALU_Input::PHI2] = PHI2;
		alu_in[(size_t)ALU_Input::ANDS] = cmd.ANDS;
		alu_in[(size_t)ALU_Input::EORS] = cmd.EORS;
		alu_in[(size_t)ALU_Input::ORS] = cmd.ORS;
		alu_in[(size_t)ALU_Input::SRS] = cmd.SRS;
		alu_in[(size_t)ALU_Input::SUMS] = cmd.SUMS;
		alu_in[(size_t)ALU_Input::SB_AC] = cmd.SB_AC;
		alu_in[(size_t)ALU_Input::n_ACIN] = cmd.n_ACIN;
		alu_in[(size_t)ALU_Input::n_DAA] = cmd.n_DAA;
		alu_in[(size_t)ALU_Input::n_DSA] = cmd.n_DSA;

		alu->sim(alu_in, SB, DB, ADL, ADH, SB_Dirty, DB_Dirty, ADL_Dirty, ADH_Dirty);

		// Load flags: DB_P, DBZ_Z, DB_N, IR5_C, DB_C, IR5_D, IR5_I, DB_V, Z_V, ACR_C, AVR_V

		TriState flags_in[(size_t)Flags_Input::Max];

		TriState IR[8];
		ir->get(IR);

		flags_in[(size_t)Flags_Input::PHI1] = PHI1;
		flags_in[(size_t)Flags_Input::PHI2] = PHI2;
		flags_in[(size_t)Flags_Input::SO] = SO;
		flags_in[(size_t)Flags_Input::B_OUT] = brk->getB_OUT(BRK6E);
		flags_in[(size_t)Flags_Input::ACR] = alu->getACR();
		flags_in[(size_t)Flags_Input::AVR] = alu->getAVR();
		flags_in[(size_t)Flags_Input::n_IR5] = NOT(IR[5]);
		flags_in[(size_t)Flags_Input::BRK6E] = BRK6E;
		flags_in[(size_t)Flags_Input::P_DB] = cmd.P_DB;
		flags_in[(size_t)Flags_Input::DB_P] = cmd.DB_P;
		flags_in[(size_t)Flags_Input::DBZ_Z] = cmd.DBZ_Z;
		flags_in[(size_t)Flags_Input::DB_N] = cmd.DB_N;
		flags_in[(size_t)Flags_Input::IR5_C] = cmd.IR5_C;
		flags_in[(size_t)Flags_Input::DB_C] = cmd.DB_C;
		flags_in[(size_t)Flags_Input::ACR_C] = cmd.ACR_C;
		flags_in[(size_t)Flags_Input::IR5_D] = cmd.IR5_D;
		flags_in[(size_t)Flags_Input::IR5_I] = cmd.IR5_I;
		flags_in[(size_t)Flags_Input::DB_V] = cmd.DB_V;
		flags_in[(size_t)Flags_Input::AVR_V] = cmd.AVR_V;
		flags_in[(size_t)Flags_Input::Z_V] = cmd.Z_V;

		random->flags->sim_Load(flags_in, DB);

		// Load registers: SB_X, SB_Y, SB_S / S_S

		regs_in[(size_t)Regs_Input::PHI2] = PHI2;
		regs_in[(size_t)Regs_Input::SB_Y] = cmd.SB_Y;
		regs_in[(size_t)Regs_Input::SB_X] = cmd.SB_X;
		regs_in[(size_t)Regs_Input::SB_S] = cmd.SB_S;
		regs_in[(size_t)Regs_Input::S_S] = cmd.S_S;

		regs->sim_LoadSB(regs_in, SB);

		// PC loading from buses / keep: ADH_PCH/PCH_PCH, ADL_PCL/PCL_PCL

		pc_in[(size_t)ProgramCounter_Input::ADL_PCL] = cmd.ADL_PCL;
		pc_in[(size_t)ProgramCounter_Input::PCL_PCL] = cmd.PCL_PCL;
		pc_in[(size_t)ProgramCounter_Input::ADH_PCH] = cmd.ADH_PCH;
		pc_in[(size_t)ProgramCounter_Input::PCH_PCH] = cmd.PCH_PCH;

		pc->sim_Load(pc_in, ADL, ADH);

		// Saving DB to DOR

		data_in[(size_t)DataBus_Input::PHI1] = PHI1;
		data_in[(size_t)DataBus_Input::PHI2] = PHI2;
		data_in[(size_t)DataBus_Input::WR] = WR;

		data_bus->sim_SetExternalBus(data_in, DB, inOuts);

		// Set external address bus: ADH_ABH, ADL_ABL

		TriState addr_in_late[(size_t)AddressBus_Input::Max];

		addr_in_late[(size_t)AddressBus_Input::PHI1] = PHI1;
		addr_in_late[(size_t)AddressBus_Input::PHI2] = PHI2;
		addr_in_late[(size_t)AddressBus_Input::ADL_ABL] = cmd.ADL_ABL;
		addr_in_late[(size_t)AddressBus_Input::ADH_ABH] = cmd.ADH_ABH;

		addr_bus->sim_Output(addr_in_late, ADL, ADH, outputs);

		// Outputs

		rw_latch.set(WR, PHI1);

		outputs[(size_t)OutputPad::PHI1] = PHI1;
		outputs[(size_t)OutputPad::PHI2] = PHI2;
		outputs[(size_t)OutputPad::RnW] = rw_latch.nget();
		outputs[(size_t)OutputPad::SYNC] = disp->getT1();
	}

	void M6502::sim(TriState inputs[], TriState outputs[], TriState inOuts[])
	{
		TriState PHI0 = inputs[(size_t)InputPad::PHI0];
		TriState PHI2 = PHI0;

		// Precharge internal buses.
		// This operation is critical because it is used to form the interrupt address and the stack pointer.

		if (PHI2 == TriState::One)
		{
			Unpack(0xff, SB);
			Unpack(0xff, DB);
			Unpack(0xff, ADL);
			Unpack(0xff, ADH);
		}

		// These variables are used to mark the "dirty" bits of the internal buses. This is used to resolve conflicts, according to the "Ground wins" rule.

		for (size_t n = 0; n < 8; n++)
		{
			SB_Dirty[n] = false;
			DB_Dirty[n] = false;
			ADL_Dirty[n] = false;
			ADH_Dirty[n] = false;
		}

		// To stabilize latches, the top part is simulated twice.

		sim_Top(inputs, outputs, inOuts);
		sim_Bottom(inputs, outputs, inOuts);
		sim_Top(inputs, outputs, inOuts);
	}

	void M6502::getDebug(DebugInfo* info)
	{
		TriState BRK6E = wire.BRK6E;

		info->SB = Pack(SB);
		info->DB = Pack(DB);
		info->ADL = Pack(ADL);
		info->ADH = Pack(ADH);

		TriState IR[8];
		ir->get(IR);
		info->IR = Pack(IR);
		info->PD = Pack(predecode->PD);
		info->Y = regs->getY();
		info->X = regs->getX();
		info->S = regs->getS();
		info->AI = alu->getAI();
		info->BI = alu->getBI();
		info->ADD = alu->getADD();
		info->AC = alu->getAC();
		info->PCL = pc->getPCL();
		info->PCH = pc->getPCH();
		info->PCLS = pc->getPCLS();
		info->PCHS = pc->getPCHS();
		info->ABL = addr_bus->getABL();
		info->ABH = addr_bus->getABH();
		info->DL = data_bus->getDL();
		info->DOR = data_bus->getDOR();

		info->C_OUT = NOT(random->flags->getn_C_OUT()) == TriState::One ? 1 : 0;
		info->Z_OUT = NOT(random->flags->getn_Z_OUT()) == TriState::One ? 1 : 0;
		info->I_OUT = NOT(random->flags->getn_I_OUT(BRK6E)) == TriState::One ? 1 : 0;
		info->D_OUT = NOT(random->flags->getn_D_OUT()) == TriState::One ? 1 : 0;
		info->B_OUT = brk->getB_OUT(BRK6E) == TriState::One ? 1 : 0;
		info->V_OUT = NOT(random->flags->getn_V_OUT()) == TriState::One ? 1 : 0;
		info->N_OUT = NOT(random->flags->getn_N_OUT()) == TriState::One ? 1 : 0;

		info->n_PRDY = prdy_latch2.nget() == TriState::One ? 1 : 0;
		info->n_NMIP = NOT(nmip_ff.get()) == TriState::One ? 1 : 0;
		info->n_IRQP = irqp_latch.nget() == TriState::One ? 1 : 0;
		info->RESP = resp_latch.nget() == TriState::One ? 1 : 0;
		info->BRK6E = BRK6E == TriState::One ? 1 : 0;
		info->BRK7 = wire.BRK7 == TriState::One ? 1 : 0;
		info->DORES = wire.DORES == TriState::One ? 1 : 0;
		info->n_DONMI = wire.n_DONMI == TriState::One ? 1 : 0;
		info->n_T2 = wire.n_T2 == TriState::One ? 1 : 0;
		info->n_T3 = wire.n_T3 == TriState::One ? 1 : 0;
		info->n_T4 = wire.n_T4 == TriState::One ? 1 : 0;
		info->n_T5 = wire.n_T5 == TriState::One ? 1 : 0;
		info->T0 = wire.T0 == TriState::One ? 1 : 0;
		info->n_T0 = wire.n_T0 == TriState::One ? 1 : 0;
		info->n_T1X = wire.n_T1X == TriState::One ? 1 : 0;
		info->Z_IR = wire.Z_IR == TriState::One ? 1 : 0;
		info->FETCH = wire.FETCH == TriState::One ? 1 : 0;
		info->n_ready = wire.n_ready == TriState::One ? 1 : 0;
		info->WR = wire.WR == TriState::One ? 1 : 0;
		info->TRES2 = disp->getTRES2() == TriState::One ? 1 : 0;
		info->ACRL1 = wire.ACRL1 == TriState::One ? 1 : 0;
		info->ACRL2 = wire.ACRL2 == TriState::One ? 1 : 0;
		info->T1 = disp->getT1() == TriState::One ? 1 : 0;
		info->T5 = wire.T5 == TriState::One ? 1 : 0;
		info->T6 = wire.T6 == TriState::One ? 1 : 0;
		info->ENDS = wire.ENDS == TriState::One ? 1 : 0;
		info->ENDX = wire.ENDX == TriState::One ? 1 : 0;
		info->TRES1 = wire.TRES1 == TriState::One ? 1 : 0;
		info->TRESX = wire.TRESX == TriState::One ? 1 : 0;
		info->BRFW = wire.BRFW == TriState::One ? 1 : 0;
		info->n_BRTAKEN = wire.n_BRTAKEN == TriState::One ? 1 : 0;
		info->ACR = alu->getACR() == TriState::One ? 1 : 0;
		info->AVR = alu->getAVR() == TriState::One ? 1 : 0;

		for (size_t n=0; n<Decoder::outputs_count; n++)
		{
			info->decoder_out[n] = decoder_out[n] == TriState::One ? 1 : 0;
		}

		info->Y_SB = cmd.Y_SB == TriState::One ? 1 : 0;
		info->SB_Y = cmd.SB_Y == TriState::One ? 1 : 0;
		info->X_SB = cmd.X_SB == TriState::One ? 1 : 0;
		info->SB_X = cmd.SB_X == TriState::One ? 1 : 0;
		info->S_ADL = cmd.S_ADL == TriState::One ? 1 : 0;
		info->S_SB = cmd.S_SB == TriState::One ? 1 : 0;
		info->SB_S = cmd.SB_S == TriState::One ? 1 : 0;
		info->S_S = cmd.S_S == TriState::One ? 1 : 0;
		info->NDB_ADD = cmd.NDB_ADD == TriState::One ? 1 : 0;
		info->DB_ADD = cmd.DB_ADD == TriState::One ? 1 : 0;
		info->Z_ADD = cmd.Z_ADD == TriState::One ? 1 : 0;
		info->SB_ADD = cmd.SB_ADD == TriState::One ? 1 : 0;
		info->ADL_ADD = cmd.ADL_ADD == TriState::One ? 1 : 0;
		info->n_ACIN = cmd.n_ACIN == TriState::One ? 1 : 0;
		info->ANDS = cmd.ANDS == TriState::One ? 1 : 0;
		info->EORS = cmd.EORS == TriState::One ? 1 : 0;
		info->ORS = cmd.ORS == TriState::One ? 1 : 0;
		info->SRS = cmd.SRS == TriState::One ? 1 : 0;
		info->SUMS = cmd.SUMS == TriState::One ? 1 : 0;
		info->n_DAA = cmd.n_DAA == TriState::One ? 1 : 0;
		info->n_DSA = cmd.n_DSA == TriState::One ? 1 : 0;
		info->ADD_SB7 = cmd.ADD_SB7 == TriState::One ? 1 : 0;
		info->ADD_SB06 = cmd.ADD_SB06 == TriState::One ? 1 : 0;
		info->ADD_ADL = cmd.ADD_ADL == TriState::One ? 1 : 0;
		info->SB_AC = cmd.SB_AC == TriState::One ? 1 : 0;
		info->AC_SB = cmd.AC_SB == TriState::One ? 1 : 0;
		info->AC_DB = cmd.AC_DB == TriState::One ? 1 : 0;
		info->n_1PC = wire.n_1PC == TriState::One ? 1 : 0;			// From Dispatcher
		info->ADH_PCH = cmd.ADH_PCH == TriState::One ? 1 : 0;
		info->PCH_PCH = cmd.PCH_PCH == TriState::One ? 1 : 0;
		info->PCH_ADH = cmd.PCH_ADH == TriState::One ? 1 : 0;
		info->PCH_DB = cmd.PCH_DB == TriState::One ? 1 : 0;
		info->ADL_PCL = cmd.ADL_PCL == TriState::One ? 1 : 0;
		info->PCL_PCL = cmd.PCL_PCL == TriState::One ? 1 : 0;
		info->PCL_ADL = cmd.PCL_ADL == TriState::One ? 1 : 0;
		info->PCL_DB = cmd.PCL_DB == TriState::One ? 1 : 0;
		info->ADH_ABH = cmd.ADH_ABH == TriState::One ? 1 : 0;
		info->ADL_ABL = cmd.ADL_ABL == TriState::One ? 1 : 0;
		info->Z_ADL0 = cmd.Z_ADL0 == TriState::One ? 1 : 0;
		info->Z_ADL1 = cmd.Z_ADL1 == TriState::One ? 1 : 0;
		info->Z_ADL2 = cmd.Z_ADL2 == TriState::One ? 1 : 0;
		info->Z_ADH0 = cmd.Z_ADH0 == TriState::One ? 1 : 0;
		info->Z_ADH17 = cmd.Z_ADH17 == TriState::One ? 1 : 0;
		info->SB_DB = cmd.SB_DB == TriState::One ? 1 : 0;
		info->SB_ADH = cmd.SB_ADH == TriState::One ? 1 : 0;
		info->DL_ADL = cmd.DL_ADL == TriState::One ? 1 : 0;
		info->DL_ADH = cmd.DL_ADH == TriState::One ? 1 : 0;
		info->DL_DB = cmd.DL_DB == TriState::One ? 1 : 0;

		info->P_DB = cmd.P_DB == TriState::One ? 1 : 0;
		info->DB_P = cmd.DB_P == TriState::One ? 1 : 0;
		info->DBZ_Z = cmd.DBZ_Z == TriState::One ? 1 : 0;
		info->DB_N = cmd.DB_N == TriState::One ? 1 : 0;
		info->IR5_C = cmd.IR5_C == TriState::One ? 1 : 0;
		info->DB_C = cmd.DB_C == TriState::One ? 1 : 0;
		info->ACR_C = cmd.ACR_C == TriState::One ? 1 : 0;
		info->IR5_D = cmd.IR5_D == TriState::One ? 1 : 0;
		info->IR5_I = cmd.IR5_I == TriState::One ? 1 : 0;
		info->DB_V = cmd.DB_V == TriState::One ? 1 : 0;
		info->AVR_V = cmd.AVR_V == TriState::One ? 1 : 0;
		info->Z_V = cmd.Z_V == TriState::One ? 1 : 0;
	}

	void M6502::getUserRegs(UserRegs* userRegs)
	{
		userRegs->Y = regs->getY();
		userRegs->X = regs->getX();
		userRegs->S = regs->getS();
		userRegs->A = alu->getAC();
		userRegs->PCL = pc->getPCL();
		userRegs->PCH = pc->getPCH();

		userRegs->C_OUT = NOT(random->flags->getn_C_OUT()) == TriState::One ? 1 : 0;
		userRegs->Z_OUT = NOT(random->flags->getn_Z_OUT()) == TriState::One ? 1 : 0;
		userRegs->I_OUT = NOT(random->flags->getn_I_OUT(wire.BRK6E)) == TriState::One ? 1 : 0;
		userRegs->D_OUT = NOT(random->flags->getn_D_OUT()) == TriState::One ? 1 : 0;
		userRegs->V_OUT = NOT(random->flags->getn_V_OUT()) == TriState::One ? 1 : 0;
		userRegs->N_OUT = NOT(random->flags->getn_N_OUT()) == TriState::One ? 1 : 0;
	}
}
