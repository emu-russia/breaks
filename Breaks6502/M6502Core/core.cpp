#include "pch.h"

using namespace BaseLogic;

namespace M6502Core
{
	M6502::M6502()
	{
		decoder = new Decoder;
		predecode = new PreDecode;
		ir = new IR;
		ext = new ExtraCounter;
		brk = new BRKProcessing;
		disp = new Dispatcher;
		random = new RandomLogic;

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
		TriState n_NMI = inputs[(size_t)InputPad::n_NMI];
		TriState n_IRQ = inputs[(size_t)InputPad::n_IRQ];
		TriState n_RES = inputs[(size_t)InputPad::n_RES];
		TriState PHI0 = inputs[(size_t)InputPad::PHI0];
		TriState RDY = inputs[(size_t)InputPad::RDY];
		TriState SO = inputs[(size_t)InputPad::SO];

		// Logic associated with external input terminals

		TriState PHI1 = NOT(PHI0);
		TriState PHI2 = PHI0;

		prdy_latch1.set(NOT(RDY), PHI2);
		prdy_latch2.set(prdy_latch1.nget(), PHI1);
		TriState n_PRDY = prdy_latch2.nget();

		nmip_ff.set(NOR(NOR(nmip_ff.get(), AND(NOT(n_NMI), PHI2)), AND(n_NMI, PHI2)));
		TriState n_NMIP = NOT(nmip_ff.get());

		irqp_ff.set(NOR(NOR(irqp_ff.get(), AND(NOT(n_IRQ), PHI2)), AND(n_IRQ, PHI2)));
		irqp_latch.set(irqp_ff.get(), PHI1);
		TriState n_IRQP = irqp_latch.nget();

		resp_ff.set(NOR(NOR(resp_ff.get(), AND(n_RES, PHI2)), AND(NOT(n_RES), PHI2)));
		resp_latch.set(resp_ff.get(), PHI1);
		TriState RESP = resp_latch.nget();

		// Dispatcher and other auxiliary logic

		TriState disp_early_in[(size_t)Dispatcher_Input::Max];

		disp_early_in[(size_t)Dispatcher_Input::PHI1] = PHI1;
		disp_early_in[(size_t)Dispatcher_Input::PHI2] = PHI2;
		disp_early_in[(size_t)Dispatcher_Input::RDY] = RDY;
		disp_early_in[(size_t)Dispatcher_Input::DORES] = brk->getDORES();
		disp_early_in[(size_t)Dispatcher_Input::ACR] = alu->getACR();

		disp->sim_BeforeDecoder(disp_early_in, disp_early_out, brk);

		TriState n_ready = disp_early_out[(size_t)Dispatcher_Output::n_ready];
		TriState T0 = disp_early_out[(size_t)Dispatcher_Output::T0];
		TriState FETCH = disp_early_out[(size_t)Dispatcher_Output::FETCH];
		TriState Z_IR = disp_early_out[(size_t)Dispatcher_Output::Z_IR];
		TriState ACRL1 = disp_early_out[(size_t)Dispatcher_Output::ACRL1];
		TriState ACRL2 = disp_early_out[(size_t)Dispatcher_Output::ACRL2];

		TriState pd_in[(size_t)PreDecode_Input::Max];
		TriState pd_out[(size_t)PreDecode_Output::Max];
		TriState n_PD[8];

		pd_in[(size_t)PreDecode_Input::PHI2] = PHI2;
		pd_in[(size_t)PreDecode_Input::Z_IR] = Z_IR;

		predecode->sim(pd_in, inOuts, pd_out, n_PD);

		ir->sim(PHI1, FETCH, n_PD);

		TriState ext_in[(size_t)ExtraCounter_Input::Max];

		ext_in[(size_t)ExtraCounter_Input::PHI1] = PHI1;
		ext_in[(size_t)ExtraCounter_Input::PHI2] = PHI2;
		ext_in[(size_t)ExtraCounter_Input::T1] = disp->getT1();
		ext_in[(size_t)ExtraCounter_Input::TRES2] = disp->getTRES2();
		ext_in[(size_t)ExtraCounter_Input::n_ready] = n_ready;

		ext->sim(ext_in, ext_out);

		TriState decoder_in[Decoder::inputs_count];

		TriState IR[8];
		ir->get(IR);

		decoder_in[(size_t)DecoderInput::n_IR0] = NOT(IR[0]);
		decoder_in[(size_t)DecoderInput::n_IR1] = NOT(IR[1]);
		decoder_in[(size_t)DecoderInput::IR01] = NOT(NOR(IR[0], IR[1]));
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

		decoder_in[(size_t)DecoderInput::n_T0] = disp_early_out[(size_t)Dispatcher_Output::n_T0];
		decoder_in[(size_t)DecoderInput::n_T1X] = disp_early_out[(size_t)Dispatcher_Output::n_T1X];
		decoder_in[(size_t)DecoderInput::n_T2] = ext_out[(size_t)ExtraCounter_Output::n_T2];
		decoder_in[(size_t)DecoderInput::n_T3] = ext_out[(size_t)ExtraCounter_Output::n_T3];
		decoder_in[(size_t)DecoderInput::n_T4] = ext_out[(size_t)ExtraCounter_Output::n_T4];
		decoder_in[(size_t)DecoderInput::n_T5] = ext_out[(size_t)ExtraCounter_Output::n_T5];

		decoder->sim(decoder_in, decoder_out);

		// Interrupt handling

		TriState int_in[(size_t)BRKProcessing_Input::Max];

		int_in[(size_t)BRKProcessing_Input::PHI1] = PHI1;
		int_in[(size_t)BRKProcessing_Input::PHI2] = PHI2;
		int_in[(size_t)BRKProcessing_Input::BRK5] = decoder_out[22];
		int_in[(size_t)BRKProcessing_Input::n_ready] = n_ready;
		int_in[(size_t)BRKProcessing_Input::RESP] = RESP;
		int_in[(size_t)BRKProcessing_Input::n_NMIP] = n_NMIP;

		brk->sim_BeforeRandom(int_in, int_out);

		TriState BRK6E = int_out[(size_t)BRKProcessing_Output::BRK6E];

		// Random Logic

		TriState disp_mid_in[(size_t)Dispatcher_Input::Max];

		disp_mid_in[(size_t)Dispatcher_Input::PHI1] = PHI1;
		disp_mid_in[(size_t)Dispatcher_Input::PHI2] = PHI2;
		disp_mid_in[(size_t)Dispatcher_Input::n_ready] = n_ready;

		disp->sim_BeforeRandomLogic(disp_mid_in, decoder_out, disp_mid_out);

		TriState T5 = disp_mid_out[(size_t)Dispatcher_Output::T5];
		TriState T6 = disp_mid_out[(size_t)Dispatcher_Output::T6];

		TriState rand_in[(size_t)RandomLogic_Input::Max];

		rand_in[(size_t)RandomLogic_Input::PHI1] = PHI1;
		rand_in[(size_t)RandomLogic_Input::PHI2] = PHI2;
		rand_in[(size_t)RandomLogic_Input::n_ready] = n_ready;
		rand_in[(size_t)RandomLogic_Input::T0] = T0;
		rand_in[(size_t)RandomLogic_Input::T1] = disp->getT1();
		rand_in[(size_t)RandomLogic_Input::IR0] = IR[0];			// Used for IMPL (D128)
		rand_in[(size_t)RandomLogic_Input::n_IR5] = NOT(IR[5]);
		rand_in[(size_t)RandomLogic_Input::n_PRDY] = n_PRDY;		// Used for BR0
		rand_in[(size_t)RandomLogic_Input::ACR] = alu->getACR();
		rand_in[(size_t)RandomLogic_Input::AVR] = alu->getAVR();
		rand_in[(size_t)RandomLogic_Input::Z_ADL0] = int_out[(size_t)BRKProcessing_Output::Z_ADL0];
		rand_in[(size_t)RandomLogic_Input::Z_ADL1] = int_out[(size_t)BRKProcessing_Output::Z_ADL1];
		rand_in[(size_t)RandomLogic_Input::Z_ADL2] = int_out[(size_t)BRKProcessing_Output::Z_ADL2];
		rand_in[(size_t)RandomLogic_Input::BRK6E] = BRK6E;
		rand_in[(size_t)RandomLogic_Input::SO] = SO;
		rand_in[(size_t)RandomLogic_Input::STOR] = disp->getSTOR(decoder_out);
		rand_in[(size_t)RandomLogic_Input::B_OUT] = brk->getB_OUT(BRK6E);
		rand_in[(size_t)RandomLogic_Input::T5] = T5;
		rand_in[(size_t)RandomLogic_Input::T6] = T6;
		rand_in[(size_t)RandomLogic_Input::ACRL2] = ACRL2;

		random->sim(rand_in, decoder_out, rand_out, DB);

		TriState int_late_in[(size_t)BRKProcessing_Input::Max];
		TriState int_late_out[(size_t)BRKProcessing_Output::Max];

		int_late_in[(size_t)BRKProcessing_Input::PHI1] = PHI1;
		int_late_in[(size_t)BRKProcessing_Input::PHI2] = PHI2;
		int_late_in[(size_t)BRKProcessing_Input::T0] = T0;
		int_late_in[(size_t)BRKProcessing_Input::BR2] = decoder_out[80];
		int_late_in[(size_t)BRKProcessing_Input::n_I_OUT] = random->flags->getn_I_OUT(BRK6E);
		int_late_in[(size_t)BRKProcessing_Input::n_IRQP] = n_IRQP;
		int_late_in[(size_t)BRKProcessing_Input::n_DONMI] = int_out[(size_t)BRKProcessing_Output::n_DONMI];
		int_late_in[(size_t)BRKProcessing_Input::BRK6E] = BRK6E;
		int_late_in[(size_t)BRKProcessing_Input::DORES] = int_out[(size_t)BRKProcessing_Output::DORES];

		brk->sim_AfterRandom(int_late_in, int_late_out);

		TriState disp_late_in[(size_t)Dispatcher_Input::Max];

		disp_late_in[(size_t)Dispatcher_Input::PHI1] = PHI1;
		disp_late_in[(size_t)Dispatcher_Input::PHI2] = PHI2;
		disp_late_in[(size_t)Dispatcher_Input::BRK6E] = BRK6E;
		disp_late_in[(size_t)Dispatcher_Input::RESP] = RESP;
		disp_late_in[(size_t)Dispatcher_Input::ACR] = alu->getACR();
		disp_late_in[(size_t)Dispatcher_Input::BRFW] = rand_out[(size_t)RandomLogic_Output::BRFW];
		disp_late_in[(size_t)Dispatcher_Input::n_BRTAKEN] = rand_out[(size_t)RandomLogic_Output::n_BRTAKEN];
		disp_late_in[(size_t)Dispatcher_Input::n_TWOCYCLE] = pd_out[(size_t)PreDecode_Output::n_TWOCYCLE];
		disp_late_in[(size_t)Dispatcher_Input::n_IMPLIED] = pd_out[(size_t)PreDecode_Output::n_IMPLIED];
		disp_late_in[(size_t)Dispatcher_Input::PC_DB] = rand_out[(size_t)RandomLogic_Output::PC_DB];
		disp_late_in[(size_t)Dispatcher_Input::n_ADL_PCL] = rand_out[(size_t)RandomLogic_Output::n_ADL_PCL];
		disp_late_in[(size_t)Dispatcher_Input::n_ready] = n_ready;
		disp_late_in[(size_t)Dispatcher_Input::T0] = T0;
		disp_late_in[(size_t)Dispatcher_Input::B_OUT] = brk->getB_OUT(BRK6E);
		disp_late_in[(size_t)Dispatcher_Input::T5] = T5;
		disp_late_in[(size_t)Dispatcher_Input::T6] = T6;
		disp_late_in[(size_t)Dispatcher_Input::ACRL1] = ACRL1;
		disp_late_in[(size_t)Dispatcher_Input::ACRL2] = ACRL2;
		disp_late_in[(size_t)Dispatcher_Input::RDY] = RDY;
		disp_late_in[(size_t)Dispatcher_Input::DORES] = brk->getDORES();

		disp->sim_AfterRandomLogic(disp_late_in, decoder_out, disp_late_out);

		TriState WR = disp_late_out[(size_t)Dispatcher_Output::WR];
	}

	void M6502::sim_Bottom(TriState inputs[], TriState outputs[], TriState inOuts[])
	{
		TriState PHI0 = inputs[(size_t)InputPad::PHI0];
		TriState PHI1 = NOT(PHI0);
		TriState PHI2 = PHI0;
		TriState SO = inputs[(size_t)InputPad::SO];
		TriState WR = disp_late_out[(size_t)Dispatcher_Output::WR];
		TriState P_DB = rand_out[(size_t)RandomLogic_Output::P_DB];
		TriState BRK6E = int_out[(size_t)BRKProcessing_Output::BRK6E];

		TriState data_in[(size_t)DataBus_Input::Max];
		TriState regs_in[(size_t)Regs_Input::Max];
		TriState alu_in[(size_t)ALU_Input::Max];
		TriState pc_in[(size_t)ProgramCounter_Input::Max];

		// Bottom Part

		// When you simulate the lower part, you have to turn on the man in you to the fullest and imagine that you are possessed by Chuck Peddle.
		// From the development history of the 6502, we know that one developer did the upper part and another (Chuck) did the lower part. 
		// So to simulate the lower part you have to abstract as much as possible and work only with what you have (registers, buses and set of control commands from the upper part).

		// Bus load from DL: DL_DB (WR = 0), DL_ADL, DL_ADH

		data_in[(size_t)DataBus_Input::PHI1] = PHI1;
		data_in[(size_t)DataBus_Input::PHI2] = PHI2;
		data_in[(size_t)DataBus_Input::WR] = WR;
		data_in[(size_t)DataBus_Input::DL_ADL] = rand_out[(size_t)RandomLogic_Output::DL_ADL];
		data_in[(size_t)DataBus_Input::DL_ADH] = rand_out[(size_t)RandomLogic_Output::DL_ADH];
		data_in[(size_t)DataBus_Input::DL_DB] = rand_out[(size_t)RandomLogic_Output::DL_DB];

		data_bus->sim_GetExternalBus(data_in, DB, ADL, ADH, DB_Dirty, ADL_Dirty, ADH_Dirty, inOuts);

		// Registers to the SB bus: Y_SB, X_SB, S_SB

		regs_in[(size_t)Regs_Input::PHI2] = PHI2;
		regs_in[(size_t)Regs_Input::Y_SB] = rand_out[(size_t)RandomLogic_Output::Y_SB];
		regs_in[(size_t)Regs_Input::X_SB] = rand_out[(size_t)RandomLogic_Output::X_SB];
		regs_in[(size_t)Regs_Input::S_SB] = rand_out[(size_t)RandomLogic_Output::S_SB];

		regs->sim_StoreSB(regs_in, SB, SB_Dirty);

		// Saving flags on DB bus: P_DB

		random->flags->sim_Store(P_DB, BRK6E, brk->getB_OUT(BRK6E), DB, DB_Dirty);

		// Constant generator: Z_ADL0, Z_ADL1, Z_ADL2, Z_ADH0, Z_ADH17

		TriState addr_in_early[(size_t)AddressBus_Input::Max];

		addr_in_early[(size_t)AddressBus_Input::Z_ADL0] = rand_out[(size_t)RandomLogic_Output::Z_ADL0];
		addr_in_early[(size_t)AddressBus_Input::Z_ADL1] = rand_out[(size_t)RandomLogic_Output::Z_ADL1];
		addr_in_early[(size_t)AddressBus_Input::Z_ADL2] = rand_out[(size_t)RandomLogic_Output::Z_ADL2];
		addr_in_early[(size_t)AddressBus_Input::Z_ADH0] = rand_out[(size_t)RandomLogic_Output::Z_ADH0];
		addr_in_early[(size_t)AddressBus_Input::Z_ADH17] = rand_out[(size_t)RandomLogic_Output::Z_ADH17];

		addr_bus->sim_ConstGen(addr_in_early, ADL, ADH, ADL_Dirty, ADH_Dirty);

		// Loading ALU operands: NDB_ADD, DB_ADD, Z_ADD, SB_ADD, ADL_ADD

		alu_in[(size_t)ALU_Input::NDB_ADD] = rand_out[(size_t)RandomLogic_Output::NDB_ADD];
		alu_in[(size_t)ALU_Input::DB_ADD] = rand_out[(size_t)RandomLogic_Output::DB_ADD];
		alu_in[(size_t)ALU_Input::Z_ADD] = rand_out[(size_t)RandomLogic_Output::Z_ADD];
		alu_in[(size_t)ALU_Input::SB_ADD] = rand_out[(size_t)RandomLogic_Output::SB_ADD];
		alu_in[(size_t)ALU_Input::ADL_ADD] = rand_out[(size_t)RandomLogic_Output::ADL_ADD];

		alu->sim_Load(alu_in, SB, DB, ADL, SB_Dirty);

		// ALU operation and ADD saving on SB/ADL: ANDS, EORS, ORS, SRS, SUMS, n_ACIN, n_DAA, n_DSA, ADD_SB7, ADD_SB06, ADD_ADL
		// Bus multiplexing: SB_DB, SB_ADH
		// BCD correction via SB bus: SB_AC

		alu_in[(size_t)ALU_Input::PHI2] = PHI2;
		alu_in[(size_t)ALU_Input::ADD_SB06] = rand_out[(size_t)RandomLogic_Output::ADD_SB06];
		alu_in[(size_t)ALU_Input::ADD_SB7] = rand_out[(size_t)RandomLogic_Output::ADD_SB7];
		alu_in[(size_t)ALU_Input::ADD_ADL] = rand_out[(size_t)RandomLogic_Output::ADD_ADL];
		alu_in[(size_t)ALU_Input::ANDS] = rand_out[(size_t)RandomLogic_Output::ANDS];
		alu_in[(size_t)ALU_Input::EORS] = rand_out[(size_t)RandomLogic_Output::EORS];
		alu_in[(size_t)ALU_Input::ORS] = rand_out[(size_t)RandomLogic_Output::ORS];
		alu_in[(size_t)ALU_Input::SRS] = rand_out[(size_t)RandomLogic_Output::SRS];
		alu_in[(size_t)ALU_Input::SUMS] = rand_out[(size_t)RandomLogic_Output::SUMS];
		alu_in[(size_t)ALU_Input::SB_DB] = rand_out[(size_t)RandomLogic_Output::SB_DB];
		alu_in[(size_t)ALU_Input::SB_ADH] = rand_out[(size_t)RandomLogic_Output::SB_ADH];
		alu_in[(size_t)ALU_Input::n_ACIN] = rand_out[(size_t)RandomLogic_Output::n_ACIN];
		alu_in[(size_t)ALU_Input::n_DAA] = rand_out[(size_t)RandomLogic_Output::n_DAA];
		alu_in[(size_t)ALU_Input::n_DSA] = rand_out[(size_t)RandomLogic_Output::n_DSA];

		alu->sim(alu_in, SB, DB, ADL, ADH, SB_Dirty, DB_Dirty, ADL_Dirty, ADH_Dirty);

		// Saving AC: AC_SB, AC_DB

		alu_in[(size_t)ALU_Input::PHI2] = PHI2;
		alu_in[(size_t)ALU_Input::SB_AC] = rand_out[(size_t)RandomLogic_Output::SB_AC];
		alu_in[(size_t)ALU_Input::AC_SB] = rand_out[(size_t)RandomLogic_Output::AC_SB];
		alu_in[(size_t)ALU_Input::AC_DB] = rand_out[(size_t)RandomLogic_Output::AC_DB];

		alu->sim_Store(alu_in, SB, DB, ADH, SB_Dirty, DB_Dirty, ADH_Dirty);

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
		flags_in[(size_t)Flags_Input::P_DB] = rand_out[(size_t)RandomLogic_Output::P_DB];
		flags_in[(size_t)Flags_Input::DB_P] = rand_out[(size_t)RandomLogic_Output::DB_P];
		flags_in[(size_t)Flags_Input::DBZ_Z] = rand_out[(size_t)RandomLogic_Output::DBZ_Z];
		flags_in[(size_t)Flags_Input::DB_N] = rand_out[(size_t)RandomLogic_Output::DB_N];
		flags_in[(size_t)Flags_Input::IR5_C] = rand_out[(size_t)RandomLogic_Output::IR5_C];
		flags_in[(size_t)Flags_Input::DB_C] = rand_out[(size_t)RandomLogic_Output::DB_C];
		flags_in[(size_t)Flags_Input::ACR_C] = rand_out[(size_t)RandomLogic_Output::ACR_C];
		flags_in[(size_t)Flags_Input::IR5_D] = rand_out[(size_t)RandomLogic_Output::IR5_D];
		flags_in[(size_t)Flags_Input::IR5_I] = rand_out[(size_t)RandomLogic_Output::IR5_I];
		flags_in[(size_t)Flags_Input::DB_V] = rand_out[(size_t)RandomLogic_Output::DB_V];
		flags_in[(size_t)Flags_Input::AVR_V] = rand_out[(size_t)RandomLogic_Output::AVR_V];
		flags_in[(size_t)Flags_Input::Z_V] = rand_out[(size_t)RandomLogic_Output::Z_V];

		random->flags->sim_Load(flags_in, DB);

		// Load registers: SB_X, SB_Y, SB_S / S_S

		regs_in[(size_t)Regs_Input::PHI2] = PHI2;
		regs_in[(size_t)Regs_Input::SB_Y] = rand_out[(size_t)RandomLogic_Output::SB_Y];
		regs_in[(size_t)Regs_Input::SB_X] = rand_out[(size_t)RandomLogic_Output::SB_X];
		regs_in[(size_t)Regs_Input::SB_S] = rand_out[(size_t)RandomLogic_Output::SB_S];
		regs_in[(size_t)Regs_Input::S_S] = rand_out[(size_t)RandomLogic_Output::S_S];

		regs->sim_LoadSB(regs_in, SB);

		// Stack pointer saving on ADL bus: S_ADL

		regs_in[(size_t)Regs_Input::S_ADL] = rand_out[(size_t)RandomLogic_Output::S_ADL];

		regs->sim_StoreADL(regs_in, ADL, ADL_Dirty);

		// PC loading from buses: ADH_PCH, ADL_PCL

		pc_in[(size_t)ProgramCounter_Input::ADL_PCL] = rand_out[(size_t)RandomLogic_Output::ADL_PCL];
		pc_in[(size_t)ProgramCounter_Input::PCL_PCL] = rand_out[(size_t)RandomLogic_Output::PCL_PCL];
		pc_in[(size_t)ProgramCounter_Input::ADH_PCH] = rand_out[(size_t)RandomLogic_Output::ADH_PCH];
		pc_in[(size_t)ProgramCounter_Input::PCH_PCH] = rand_out[(size_t)RandomLogic_Output::PCH_PCH];

		pc->sim_Load(pc_in, ADL, ADH);

		// Increment PC: n_1PC, PCL_PCL, PCH_PCH

		pc_in[(size_t)ProgramCounter_Input::PHI2] = PHI2;
		pc_in[(size_t)ProgramCounter_Input::n_1PC] = disp_late_out[(size_t)Dispatcher_Output::n_1PC];

		pc->sim(pc_in);

		// Saving PC to buses: PCL_ADL, PCH_ADH, PCL_DB, PCH_DB (considering constant generator)

		pc_in[(size_t)ProgramCounter_Input::PCL_ADL] = rand_out[(size_t)RandomLogic_Output::PCL_ADL];
		pc_in[(size_t)ProgramCounter_Input::PCL_DB] = rand_out[(size_t)RandomLogic_Output::PCL_DB];
		pc_in[(size_t)ProgramCounter_Input::PCH_ADH] = rand_out[(size_t)RandomLogic_Output::PCH_ADH];
		pc_in[(size_t)ProgramCounter_Input::PCH_DB] = rand_out[(size_t)RandomLogic_Output::PCH_DB];

		pc->sim_Store(pc_in, DB, ADL, ADH, DB_Dirty, ADL_Dirty, ADH_Dirty);

		// Saving DB to DOR: (WR = 1)

		data_in[(size_t)DataBus_Input::PHI1] = PHI1;
		data_in[(size_t)DataBus_Input::PHI2] = PHI2;
		data_in[(size_t)DataBus_Input::WR] = WR;

		data_bus->sim_SetExternalBus(data_in, DB, inOuts);

		// Set external address bus: ADH_ABH, ADL_ABL

		TriState addr_in_late[(size_t)AddressBus_Input::Max];

		addr_in_late[(size_t)AddressBus_Input::PHI1] = PHI1;
		addr_in_late[(size_t)AddressBus_Input::PHI2] = PHI2;
		addr_in_late[(size_t)AddressBus_Input::ADL_ABL] = rand_out[(size_t)RandomLogic_Output::ADL_ABL];
		addr_in_late[(size_t)AddressBus_Input::ADH_ABH] = rand_out[(size_t)RandomLogic_Output::ADH_ABH];

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
		sim_Top(inputs, outputs, inOuts);
		sim_Bottom(inputs, outputs, inOuts);
	}

	void M6502::getDebug(DebugInfo* info)
	{
		TriState BRK6E = int_out[(size_t)BRKProcessing_Output::BRK6E];

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
		info->ABL = addr_bus->getABL();
		info->ABH = addr_bus->getABH();
		info->DL = data_bus->getDL();
		info->DOR = data_bus->getDOR();

		info->C_OUT = NOT(random->flags->getn_C_OUT()) == TriState::One ? 1 : 0;
		info->Z_OUT = NOT(random->flags->getn_Z_OUT()) == TriState::One ? 1 : 0;
		info->I_OUT = NOT(random->flags->getn_I_OUT(int_out[(size_t)BRKProcessing_Output::BRK6E])) == TriState::One ? 1 : 0;
		info->D_OUT = NOT(random->flags->getn_D_OUT()) == TriState::One ? 1 : 0;
		info->B_OUT = brk->getB_OUT(BRK6E) == TriState::One ? 1 : 0;
		info->V_OUT = NOT(random->flags->getn_V_OUT()) == TriState::One ? 1 : 0;
		info->N_OUT = NOT(random->flags->getn_N_OUT()) == TriState::One ? 1 : 0;

		info->n_PRDY = prdy_latch2.nget() == TriState::One ? 1 : 0;
		info->n_NMIP = NOT(nmip_ff.get()) == TriState::One ? 1 : 0;
		info->n_IRQP = irqp_latch.nget() == TriState::One ? 1 : 0;
		info->RESP = resp_latch.nget() == TriState::One ? 1 : 0;
		info->BRK6E = BRK6E == TriState::One ? 1 : 0;
		info->BRK7 = int_out[(size_t)BRKProcessing_Output::BRK7] == TriState::One ? 1 : 0;
		info->DORES = int_out[(size_t)BRKProcessing_Output::DORES] == TriState::One ? 1 : 0;
		info->n_DONMI = int_out[(size_t)BRKProcessing_Output::n_DONMI] == TriState::One ? 1 : 0;
		info->n_T2 = ext_out[(size_t)ExtraCounter_Output::n_T2] == TriState::One ? 1 : 0;
		info->n_T3 = ext_out[(size_t)ExtraCounter_Output::n_T3] == TriState::One ? 1 : 0;
		info->n_T4 = ext_out[(size_t)ExtraCounter_Output::n_T4] == TriState::One ? 1 : 0;
		info->n_T5 = ext_out[(size_t)ExtraCounter_Output::n_T5] == TriState::One ? 1 : 0;
		info->T0 = disp_early_out[(size_t)Dispatcher_Output::T0] == TriState::One ? 1 : 0;
		info->n_T0 = disp_early_out[(size_t)Dispatcher_Output::n_T0] == TriState::One ? 1 : 0;
		info->n_T1X = disp_early_out[(size_t)Dispatcher_Output::n_T1X] == TriState::One ? 1 : 0;
		info->Z_IR = disp_early_out[(size_t)Dispatcher_Output::Z_IR] == TriState::One ? 1 : 0;
		info->FETCH = disp_early_out[(size_t)Dispatcher_Output::FETCH] == TriState::One ? 1 : 0;
		info->n_ready = disp_early_out[(size_t)Dispatcher_Output::n_ready] == TriState::One ? 1 : 0;
		info->WR = disp_late_out[(size_t)Dispatcher_Output::WR] == TriState::One ? 1 : 0;
		info->TRES2 = disp->getTRES2() == TriState::One ? 1 : 0;
		info->ACRL1 = disp_early_out[(size_t)Dispatcher_Output::ACRL1] == TriState::One ? 1 : 0;
		info->ACRL2 = disp_early_out[(size_t)Dispatcher_Output::ACRL2] == TriState::One ? 1 : 0;
		info->T1 = disp->getT1() == TriState::One ? 1 : 0;
		info->T5 = disp_mid_out[(size_t)Dispatcher_Output::T5] == TriState::One ? 1 : 0;
		info->T6 = disp_mid_out[(size_t)Dispatcher_Output::T6] == TriState::One ? 1 : 0;
		info->ENDS = disp_late_out[(size_t)Dispatcher_Output::ENDS] == TriState::One ? 1 : 0;
		info->ENDX = disp_late_out[(size_t)Dispatcher_Output::ENDX] == TriState::One ? 1 : 0;
		info->TRES1 = disp_late_out[(size_t)Dispatcher_Output::TRES1] == TriState::One ? 1 : 0;
		info->TRESX = disp_late_out[(size_t)Dispatcher_Output::TRESX] == TriState::One ? 1 : 0;

		for (size_t n=0; n<Decoder::outputs_count; n++)
		{
			info->decoder_out[n] = decoder_out[n] == TriState::One ? 1 : 0;
		}

		info->Y_SB = rand_out[(size_t)RandomLogic_Output::Y_SB] == TriState::One ? 1 : 0;
		info->SB_Y = rand_out[(size_t)RandomLogic_Output::SB_Y] == TriState::One ? 1 : 0;
		info->X_SB = rand_out[(size_t)RandomLogic_Output::X_SB] == TriState::One ? 1 : 0;
		info->SB_X = rand_out[(size_t)RandomLogic_Output::SB_X] == TriState::One ? 1 : 0;
		info->S_ADL = rand_out[(size_t)RandomLogic_Output::S_ADL] == TriState::One ? 1 : 0;
		info->S_SB = rand_out[(size_t)RandomLogic_Output::S_SB] == TriState::One ? 1 : 0;
		info->SB_S = rand_out[(size_t)RandomLogic_Output::SB_S] == TriState::One ? 1 : 0;
		info->S_S = rand_out[(size_t)RandomLogic_Output::S_S] == TriState::One ? 1 : 0;
		info->NDB_ADD = rand_out[(size_t)RandomLogic_Output::NDB_ADD] == TriState::One ? 1 : 0;
		info->DB_ADD = rand_out[(size_t)RandomLogic_Output::DB_ADD] == TriState::One ? 1 : 0;
		info->Z_ADD = rand_out[(size_t)RandomLogic_Output::Z_ADD] == TriState::One ? 1 : 0;
		info->SB_ADD = rand_out[(size_t)RandomLogic_Output::SB_ADD] == TriState::One ? 1 : 0;
		info->ADL_ADD = rand_out[(size_t)RandomLogic_Output::ADL_ADD] == TriState::One ? 1 : 0;
		info->n_ACIN = rand_out[(size_t)RandomLogic_Output::n_ACIN] == TriState::One ? 1 : 0;
		info->ANDS = rand_out[(size_t)RandomLogic_Output::ANDS] == TriState::One ? 1 : 0;
		info->EORS = rand_out[(size_t)RandomLogic_Output::EORS] == TriState::One ? 1 : 0;
		info->ORS = rand_out[(size_t)RandomLogic_Output::ORS] == TriState::One ? 1 : 0;
		info->SRS = rand_out[(size_t)RandomLogic_Output::SRS] == TriState::One ? 1 : 0;
		info->SUMS = rand_out[(size_t)RandomLogic_Output::SUMS] == TriState::One ? 1 : 0;
		info->n_DAA = rand_out[(size_t)RandomLogic_Output::n_DAA] == TriState::One ? 1 : 0;
		info->n_DSA = rand_out[(size_t)RandomLogic_Output::n_DSA] == TriState::One ? 1 : 0;
		info->ADD_SB7 = rand_out[(size_t)RandomLogic_Output::ADD_SB7] == TriState::One ? 1 : 0;
		info->ADD_SB06 = rand_out[(size_t)RandomLogic_Output::ADD_SB06] == TriState::One ? 1 : 0;
		info->ADD_ADL = rand_out[(size_t)RandomLogic_Output::ADD_ADL] == TriState::One ? 1 : 0;
		info->SB_AC = rand_out[(size_t)RandomLogic_Output::SB_AC] == TriState::One ? 1 : 0;
		info->AC_SB = rand_out[(size_t)RandomLogic_Output::AC_SB] == TriState::One ? 1 : 0;
		info->AC_DB = rand_out[(size_t)RandomLogic_Output::AC_DB] == TriState::One ? 1 : 0;
		info->n_1PC = disp_late_out[(size_t)Dispatcher_Output::n_1PC] == TriState::One ? 1 : 0;			// From Dispatcher
		info->ADH_PCH = rand_out[(size_t)RandomLogic_Output::ADH_PCH] == TriState::One ? 1 : 0;
		info->PCH_PCH = rand_out[(size_t)RandomLogic_Output::PCH_PCH] == TriState::One ? 1 : 0;
		info->PCH_ADH = rand_out[(size_t)RandomLogic_Output::PCH_ADH] == TriState::One ? 1 : 0;
		info->PCH_DB = rand_out[(size_t)RandomLogic_Output::PCH_DB] == TriState::One ? 1 : 0;
		info->ADL_PCL = rand_out[(size_t)RandomLogic_Output::ADL_PCL] == TriState::One ? 1 : 0;
		info->PCL_PCL = rand_out[(size_t)RandomLogic_Output::PCL_PCL] == TriState::One ? 1 : 0;
		info->PCL_ADL = rand_out[(size_t)RandomLogic_Output::PCL_ADL] == TriState::One ? 1 : 0;
		info->PCL_DB = rand_out[(size_t)RandomLogic_Output::PCL_DB] == TriState::One ? 1 : 0;
		info->ADH_ABH = rand_out[(size_t)RandomLogic_Output::ADH_ABH] == TriState::One ? 1 : 0;
		info->ADL_ABL = rand_out[(size_t)RandomLogic_Output::ADL_ABL] == TriState::One ? 1 : 0;
		info->Z_ADL0 = rand_out[(size_t)RandomLogic_Output::Z_ADL0] == TriState::One ? 1 : 0;
		info->Z_ADL1 = rand_out[(size_t)RandomLogic_Output::Z_ADL1] == TriState::One ? 1 : 0;
		info->Z_ADL2 = rand_out[(size_t)RandomLogic_Output::Z_ADL2] == TriState::One ? 1 : 0;
		info->Z_ADH0 = rand_out[(size_t)RandomLogic_Output::Z_ADH0] == TriState::One ? 1 : 0;
		info->Z_ADH17 = rand_out[(size_t)RandomLogic_Output::Z_ADH17] == TriState::One ? 1 : 0;
		info->SB_DB = rand_out[(size_t)RandomLogic_Output::SB_DB] == TriState::One ? 1 : 0;
		info->SB_ADH = rand_out[(size_t)RandomLogic_Output::SB_ADH] == TriState::One ? 1 : 0;
		info->DL_ADL = rand_out[(size_t)RandomLogic_Output::DL_ADL] == TriState::One ? 1 : 0;
		info->DL_ADH = rand_out[(size_t)RandomLogic_Output::DL_ADH] == TriState::One ? 1 : 0;
		info->DL_DB = rand_out[(size_t)RandomLogic_Output::DL_DB] == TriState::One ? 1 : 0;

		info->P_DB = rand_out[(size_t)RandomLogic_Output::P_DB] == TriState::One ? 1 : 0;
		info->DB_P = rand_out[(size_t)RandomLogic_Output::DB_P] == TriState::One ? 1 : 0;
		info->DBZ_Z = rand_out[(size_t)RandomLogic_Output::DBZ_Z] == TriState::One ? 1 : 0;
		info->DB_N = rand_out[(size_t)RandomLogic_Output::DB_N] == TriState::One ? 1 : 0;
		info->IR5_C = rand_out[(size_t)RandomLogic_Output::IR5_C] == TriState::One ? 1 : 0;
		info->DB_C = rand_out[(size_t)RandomLogic_Output::DB_C] == TriState::One ? 1 : 0;
		info->ACR_C = rand_out[(size_t)RandomLogic_Output::ACR_C] == TriState::One ? 1 : 0;
		info->IR5_D = rand_out[(size_t)RandomLogic_Output::IR5_D] == TriState::One ? 1 : 0;
		info->IR5_I = rand_out[(size_t)RandomLogic_Output::IR5_I] == TriState::One ? 1 : 0;
		info->DB_V = rand_out[(size_t)RandomLogic_Output::DB_V] == TriState::One ? 1 : 0;
		info->AVR_V = rand_out[(size_t)RandomLogic_Output::AVR_V] == TriState::One ? 1 : 0;
		info->Z_V = rand_out[(size_t)RandomLogic_Output::Z_V] == TriState::One ? 1 : 0;
	}
}
