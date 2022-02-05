#include "pch.h"

using namespace BaseLogic;

namespace M6502Core
{
	M6502::M6502(bool HLE, bool BCD_Hack)
	{
		HLE_Mode = HLE;

		decoder = new Decoder;
		predecode = new PreDecode(this);
		ir = new IR(this);
		ext = new ExtraCounter(this);
		brk = new BRKProcessing(this);
		disp = new Dispatcher(this);
		random = new RandomLogic(this);

		addr_bus = new AddressBus(this);
		regs = new Regs(this);
		alu = new ALU(this);
		alu->SetBCDHack(BCD_Hack);
		pc = new ProgramCounter(this, HLE_Mode);
		data_bus = new DataBus(this);
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

	void M6502::sim_Top(TriState inputs[], uint8_t* data_bus)
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

		predecode->sim(data_bus);

		ir->sim();

		if (HLE_Mode)
		{
			ext->sim_HLE();
		}
		else
		{
			ext->sim();
		}

		DecoderInput decoder_in;
		decoder_in.packed_bits = 0;

		uint8_t IR = ir->IROut;

		TriState IR0 = IR & 0b00000001 ? TriState::One : TriState::Zero;
		TriState IR1 = IR & 0b00000010 ? TriState::One : TriState::Zero;
		TriState IR2 = IR & 0b00000100 ? TriState::One : TriState::Zero;
		TriState IR3 = IR & 0b00001000 ? TriState::One : TriState::Zero;
		TriState IR4 = IR & 0b00010000 ? TriState::One : TriState::Zero;
		TriState IR5 = IR & 0b00100000 ? TriState::One : TriState::Zero;
		TriState IR6 = IR & 0b01000000 ? TriState::One : TriState::Zero;
		TriState IR7 = IR & 0b10000000 ? TriState::One : TriState::Zero;

		wire.n_IR5 = NOT(IR5);

		decoder_in.n_IR0 = NOT(IR0);
		decoder_in.n_IR1 = NOT(IR1);
		decoder_in.IR01 = OR(IR0, IR1);
		decoder_in.n_IR2 = NOT(IR2);
		decoder_in.IR2 = IR2;
		decoder_in.n_IR3 = NOT(IR3);
		decoder_in.IR3 = IR3;
		decoder_in.n_IR4 = NOT(IR4);
		decoder_in.IR4 = IR4;
		decoder_in.n_IR5 = wire.n_IR5;
		decoder_in.IR5 = IR5;
		decoder_in.n_IR6 = NOT(IR6);
		decoder_in.IR6 = IR6;
		decoder_in.n_IR7 = NOT(IR7);
		decoder_in.IR7 = IR7;

		decoder_in.n_T0 = wire.n_T0;
		decoder_in.n_T1X = wire.n_T1X;
		decoder_in.n_T2 = wire.n_T2;
		decoder_in.n_T3 = wire.n_T3;
		decoder_in.n_T4 = wire.n_T4;
		decoder_in.n_T5 = wire.n_T5;

		TxBits = 0;
		TxBits |= ((size_t)wire.n_T0 << 0);
		TxBits |= ((size_t)wire.n_T1X << 1);
		TxBits |= ((size_t)wire.n_T2 << 2);
		TxBits |= ((size_t)wire.n_T3 << 3);
		TxBits |= ((size_t)wire.n_T4 << 4);
		TxBits |= ((size_t)wire.n_T5 << 5);

		decoder->sim(decoder_in.packed_bits, &decoder_out);

		// Interrupt handling

		brk->sim_BeforeRandom();

		// Random Logic

		disp->sim_BeforeRandomLogic();

		random->sim();

		brk->sim_AfterRandom();

		disp->sim_AfterRandomLogic();
	}

	void M6502::sim_Bottom(TriState inputs[], TriState outputs[], uint16_t* ext_addr_bus, uint8_t* ext_data_bus)
	{
		// Bottom Part

		// When you simulate the lower part, you have to turn on the man in you to the fullest and imagine that you are possessed by Chuck Peddle.
		// From the development history of the 6502, we know that one developer did the upper part and another (Chuck) did the lower part. 
		// So to simulate the lower part you have to abstract as much as possible and work only with what you have (registers, buses and set of control commands from the upper part).

		// Bus load from DL: DL_DB, DL_ADL, DL_ADH

		data_bus->sim_GetExternalBus(ext_data_bus);

		// Registers to the SB bus: Y_SB, X_SB, S_SB

		regs->sim_StoreSB();

		// ADD saving on SB/ADL: ADD_SB7, ADD_SB06, ADD_ADL

		alu->sim_StoreADD();

		// Saving AC: AC_SB, AC_DB

		alu->sim_StoreAC();

		// Saving flags on DB bus: P_DB

		random->flags->sim_Store();

		// Stack pointer saving on ADL bus: S_ADL

		regs->sim_StoreOldS();

		// Increment PC: n_1PC

		pc->sim();

		// Saving PC to buses: PCL_ADL, PCH_ADH, PCL_DB, PCH_DB

		pc->sim_Store();

		// Bus multiplexing: SB_DB, SB_ADH

		alu->sim_BusMux();

		// Constant generator: Z_ADL0, Z_ADL1, Z_ADL2, Z_ADH0, Z_ADH17

		addr_bus->sim_ConstGen();

		// Loading ALU operands: NDB_ADD, DB_ADD, Z_ADD, SB_ADD, ADL_ADD

		alu->sim_Load();

		// ALU operation: ANDS, EORS, ORS, SRS, SUMS, n_ACIN, n_DAA, n_DSA
		// BCD correction via SB bus: SB_AC

		if (HLE_Mode)
		{
			alu->sim_HLE();
		}
		else
		{
			alu->sim();
		}

		// Load flags: DB_P, DBZ_Z, DB_N, IR5_C, DB_C, IR5_D, IR5_I, DB_V, Z_V, ACR_C, AVR_V

		random->flags->sim_Load();

		// Load registers: SB_X, SB_Y, SB_S / S_S

		regs->sim_LoadSB();

		// PC loading from buses / keep: ADH_PCH/PCH_PCH, ADL_PCL/PCL_PCL

		pc->sim_Load();

		// Saving DB to DOR

		data_bus->sim_SetExternalBus(ext_data_bus);

		// Set external address bus: ADH_ABH, ADL_ABL

		addr_bus->sim_Output(ext_addr_bus);

		// Outputs

		rw_latch.set(wire.WR, wire.PHI1);

		outputs[(size_t)OutputPad::PHI1] = wire.PHI1;
		outputs[(size_t)OutputPad::PHI2] = wire.PHI2;
		outputs[(size_t)OutputPad::RnW] = rw_latch.nget();
		outputs[(size_t)OutputPad::SYNC] = disp->getT1();
	}

	void M6502::sim(TriState inputs[], TriState outputs[], uint16_t* addr_bus, uint8_t* data_bus)
	{
		TriState PHI0 = inputs[(size_t)InputPad::PHI0];
		TriState PHI2 = PHI0;

		// Precharge internal buses.
		// This operation is critical because it is used to form the interrupt address and the stack pointer (and many other cases).

		if (PHI2 == TriState::One)
		{
			SB = 0xff;
			DB = 0xff;
			ADL = 0xff;
			ADH = 0xff;
		}

		// These variables are used to mark the "dirty" bits of the internal buses. This is used to resolve conflicts, according to the "Ground wins" rule.

		for (size_t n = 0; n < 8; n++)
		{
			SB_Dirty = false;
			DB_Dirty = false;
			ADL_Dirty = false;
			ADH_Dirty = false;
		}

		// To stabilize latches, both parts are simulated twice.

		sim_Top(inputs, data_bus);
		sim_Bottom(inputs, outputs, addr_bus, data_bus);
		sim_Top(inputs, data_bus);
		sim_Bottom(inputs, outputs, addr_bus, data_bus);
	}

	void M6502::getDebug(DebugInfo* info)
	{
		TriState BRK6E = wire.BRK6E;

		info->SB = SB;
		info->DB = DB;
		info->ADL = ADL;
		info->ADH = ADH;

		info->IR = ir->IROut;
		info->PD = predecode->PD;
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

		info->Y_SB = cmd.Y_SB;
		info->SB_Y = cmd.SB_Y;
		info->X_SB = cmd.X_SB;
		info->SB_X = cmd.SB_X;
		info->S_ADL = cmd.S_ADL;
		info->S_SB = cmd.S_SB;
		info->SB_S = cmd.SB_S;
		info->S_S = cmd.S_S;
		info->NDB_ADD = cmd.NDB_ADD;
		info->DB_ADD = cmd.DB_ADD;
		info->Z_ADD = cmd.Z_ADD;
		info->SB_ADD = cmd.SB_ADD;
		info->ADL_ADD = cmd.ADL_ADD;
		info->n_ACIN = cmd.n_ACIN;
		info->ANDS = cmd.ANDS;
		info->EORS = cmd.EORS;
		info->ORS = cmd.ORS;
		info->SRS = cmd.SRS;
		info->SUMS = cmd.SUMS;
		info->n_DAA = cmd.n_DAA;
		info->n_DSA = cmd.n_DSA;
		info->ADD_SB7 = cmd.ADD_SB7;
		info->ADD_SB06 = cmd.ADD_SB06;
		info->ADD_ADL = cmd.ADD_ADL;
		info->SB_AC = cmd.SB_AC;
		info->AC_SB = cmd.AC_SB;
		info->AC_DB = cmd.AC_DB;
		info->n_1PC = wire.n_1PC == TriState::One ? 1 : 0;			// From Dispatcher
		info->ADH_PCH = cmd.ADH_PCH;
		info->PCH_PCH = cmd.PCH_PCH;
		info->PCH_ADH = cmd.PCH_ADH;
		info->PCH_DB = cmd.PCH_DB;
		info->ADL_PCL = cmd.ADL_PCL;
		info->PCL_PCL = cmd.PCL_PCL;
		info->PCL_ADL = cmd.PCL_ADL;
		info->PCL_DB = cmd.PCL_DB;
		info->ADH_ABH = cmd.ADH_ABH;
		info->ADL_ABL = cmd.ADL_ABL;
		info->Z_ADL0 = cmd.Z_ADL0;
		info->Z_ADL1 = cmd.Z_ADL1;
		info->Z_ADL2 = cmd.Z_ADL2;
		info->Z_ADH0 = cmd.Z_ADH0;
		info->Z_ADH17 = cmd.Z_ADH17;
		info->SB_DB = cmd.SB_DB;
		info->SB_ADH = cmd.SB_ADH;
		info->DL_ADL = cmd.DL_ADL;
		info->DL_ADH = cmd.DL_ADH;
		info->DL_DB = cmd.DL_DB;

		info->P_DB = cmd.P_DB;
		info->DB_P = cmd.DB_P;
		info->DBZ_Z = cmd.DBZ_Z;
		info->DB_N = cmd.DB_N;
		info->IR5_C = cmd.IR5_C;
		info->DB_C = cmd.DB_C;
		info->ACR_C = cmd.ACR_C;
		info->IR5_D = cmd.IR5_D;
		info->IR5_I = cmd.IR5_I;
		info->DB_V = cmd.DB_V;
		info->AVR_V = cmd.AVR_V;
		info->Z_V = cmd.Z_V;
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
