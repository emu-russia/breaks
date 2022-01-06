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

	void M6502::sim(TriState inputs[], TriState outputs[], TriState inOuts[])
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
		TriState disp_early_out[(size_t)Dispatcher_Output::Max];

		disp_early_in[(size_t)Dispatcher_Input::PHI1] = PHI1;
		disp_early_in[(size_t)Dispatcher_Input::PHI2] = PHI2;
		disp_early_in[(size_t)Dispatcher_Input::RDY] = RDY;
		disp_early_in[(size_t)Dispatcher_Input::DORES] = brk->getDORES();
		disp_early_in[(size_t)Dispatcher_Input::B_OUT] = brk->getB_OUT();

		disp->sim_BeforeDecoder(disp_early_in, disp_early_out);

		TriState n_ready = disp_early_out[(size_t)Dispatcher_Output::n_ready];
		TriState T0 = disp_early_out[(size_t)Dispatcher_Output::T0];
		TriState WR = disp_early_out[(size_t)Dispatcher_Output::WR];

		TriState FETCH = disp_early_out[(size_t)Dispatcher_Output::FETCH];
		TriState Z_IR = disp_early_out[(size_t)Dispatcher_Output::Z_IR];

		TriState pd_in[(size_t)PreDecode_Input::Max];
		TriState pd_out[(size_t)PreDecode_Output::Max];
		TriState n_PD[8];

		pd_in[(size_t)PreDecode_Input::PHI2] = PHI2;
		pd_in[(size_t)PreDecode_Input::Z_IR] = Z_IR;

		predecode->sim(pd_in, inOuts, pd_out, n_PD);

		ir->sim(PHI1, FETCH, n_PD);

		TriState ext_in[(size_t)ExtraCounter_Input::Max];
		TriState ext_out[(size_t)ExtraCounter_Output::Max];

		ext_in[(size_t)ExtraCounter_Input::PHI1] = PHI1;
		ext_in[(size_t)ExtraCounter_Input::PHI2] = PHI2;
		ext_in[(size_t)ExtraCounter_Input::T1] = disp->getT1();
		ext_in[(size_t)ExtraCounter_Input::TRES2] = disp->getTRES2();
		ext_in[(size_t)ExtraCounter_Input::n_ready] = n_ready;

		ext->sim(ext_in, ext_out);

		TriState decoder_in[Decoder::inputs_count];
		TriState decoder_out[Decoder::outputs_count];

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
		TriState int_out[(size_t)BRKProcessing_Output::Max];

		int_in[(size_t)BRKProcessing_Input::PHI1] = PHI1;
		int_in[(size_t)BRKProcessing_Input::PHI2] = PHI2;
		int_in[(size_t)BRKProcessing_Input::BRK5] = decoder_out[22];
		int_in[(size_t)BRKProcessing_Input::n_ready] = n_ready;
		int_in[(size_t)BRKProcessing_Input::RESP] = RESP;
		int_in[(size_t)BRKProcessing_Input::n_NMIP] = n_NMIP;
		int_in[(size_t)BRKProcessing_Input::n_IRQP] = n_IRQP;
		int_in[(size_t)BRKProcessing_Input::T0] = T0;
		int_in[(size_t)BRKProcessing_Input::BR2] = decoder_out[80];
		int_in[(size_t)BRKProcessing_Input::n_I_OUT] = random->flags->getn_I_OUT();

		brk->sim(int_in, int_out);

		// Random Logic

		TriState disp_mid_in[(size_t)Dispatcher_Input::Max];
		TriState disp_mid_out[(size_t)Dispatcher_Output::Max];

		disp_mid_in[(size_t)Dispatcher_Input::PHI1] = PHI1;
		disp_mid_in[(size_t)Dispatcher_Input::PHI2] = PHI2;
		disp_mid_in[(size_t)Dispatcher_Input::ACR] = alu->getACR();
		disp_mid_in[(size_t)Dispatcher_Input::n_ready] = n_ready;

		disp->sim_BeforeRandomLogic(disp_mid_in, decoder_out, disp_mid_out);

		TriState T5 = disp_mid_out[(size_t)Dispatcher_Output::T5];
		TriState T6 = disp_mid_out[(size_t)Dispatcher_Output::T6];
		TriState ACRL1 = disp_mid_out[(size_t)Dispatcher_Output::ACRL1];
		TriState ACRL2 = disp_mid_out[(size_t)Dispatcher_Output::ACRL2];

		TriState rand_in[(size_t)RandomLogic_Input::Max];
		TriState rand_out[(size_t)RandomLogic_Output::Max];

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
		rand_in[(size_t)RandomLogic_Input::BRK6E] = int_out[(size_t)BRKProcessing_Output::BRK6E];
		rand_in[(size_t)RandomLogic_Input::SO] = SO;
		rand_in[(size_t)RandomLogic_Input::STOR] = disp->getSTOR(decoder_out);
		rand_in[(size_t)RandomLogic_Input::B_OUT] = int_out[(size_t)BRKProcessing_Output::B_OUT];
		rand_in[(size_t)RandomLogic_Input::T5] = T5;
		rand_in[(size_t)RandomLogic_Input::T6] = T6;
		rand_in[(size_t)RandomLogic_Input::ACRL2] = ACRL2;

		random->sim(rand_in, decoder_out, rand_out, DB);

		TriState disp_late_in[(size_t)Dispatcher_Input::Max];
		TriState disp_late_out[(size_t)Dispatcher_Output::Max];

		disp_late_in[(size_t)Dispatcher_Input::PHI1] = PHI1;
		disp_late_in[(size_t)Dispatcher_Input::PHI2] = PHI2;
		disp_late_in[(size_t)Dispatcher_Input::BRK6E] = int_out[(size_t)BRKProcessing_Output::BRK6E];
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
		disp_late_in[(size_t)Dispatcher_Input::B_OUT] = brk->getB_OUT();
		disp_late_in[(size_t)Dispatcher_Input::T5] = T5;
		disp_late_in[(size_t)Dispatcher_Input::T6] = T6;
		disp_late_in[(size_t)Dispatcher_Input::ACRL1] = ACRL1;
		disp_late_in[(size_t)Dispatcher_Input::ACRL2] = ACRL2;

		disp->sim_AfterRandomLogic(disp_late_in, decoder_out, disp_late_out);

		// Bottom Part

		addr_bus->sim();

		regs->sim();

		TriState alu_in[(size_t)ALU_Input::Max];

		alu_in[(size_t)ALU_Input::PHI2] = PHI2;
		alu_in[(size_t)ALU_Input::NDB_ADD] = rand_out[(size_t)RandomLogic_Output::NDB_ADD];
		alu_in[(size_t)ALU_Input::DB_ADD] = rand_out[(size_t)RandomLogic_Output::DB_ADD];
		alu_in[(size_t)ALU_Input::Z_ADD] = rand_out[(size_t)RandomLogic_Output::Z_ADD];
		alu_in[(size_t)ALU_Input::SB_ADD] = rand_out[(size_t)RandomLogic_Output::SB_ADD];
		alu_in[(size_t)ALU_Input::ADL_ADD] = rand_out[(size_t)RandomLogic_Output::ADL_ADD];
		alu_in[(size_t)ALU_Input::ADD_SB06] = rand_out[(size_t)RandomLogic_Output::ADD_SB06];
		alu_in[(size_t)ALU_Input::ADD_SB7] = rand_out[(size_t)RandomLogic_Output::ADD_SB7];
		alu_in[(size_t)ALU_Input::ADD_ADL] = rand_out[(size_t)RandomLogic_Output::ADD_ADL];
		alu_in[(size_t)ALU_Input::ANDS] = rand_out[(size_t)RandomLogic_Output::ANDS];
		alu_in[(size_t)ALU_Input::EORS] = rand_out[(size_t)RandomLogic_Output::EORS];
		alu_in[(size_t)ALU_Input::ORS] = rand_out[(size_t)RandomLogic_Output::ORS];
		alu_in[(size_t)ALU_Input::SRS] = rand_out[(size_t)RandomLogic_Output::SRS];
		alu_in[(size_t)ALU_Input::SUMS] = rand_out[(size_t)RandomLogic_Output::SUMS];
		alu_in[(size_t)ALU_Input::SB_AC] = rand_out[(size_t)RandomLogic_Output::SB_AC];
		alu_in[(size_t)ALU_Input::AC_SB] = rand_out[(size_t)RandomLogic_Output::AC_SB];
		alu_in[(size_t)ALU_Input::AC_DB] = rand_out[(size_t)RandomLogic_Output::AC_DB];
		alu_in[(size_t)ALU_Input::SB_DB] = rand_out[(size_t)RandomLogic_Output::SB_DB];
		alu_in[(size_t)ALU_Input::SB_ADH] = rand_out[(size_t)RandomLogic_Output::SB_ADH];
		alu_in[(size_t)ALU_Input::Z_ADH0] = rand_out[(size_t)RandomLogic_Output::Z_ADH0];
		alu_in[(size_t)ALU_Input::Z_ADH17] = rand_out[(size_t)RandomLogic_Output::Z_ADH17];
		alu_in[(size_t)ALU_Input::n_ACIN] = rand_out[(size_t)RandomLogic_Output::n_ACIN];
		alu_in[(size_t)ALU_Input::n_DAA] = rand_out[(size_t)RandomLogic_Output::n_DAA];
		alu_in[(size_t)ALU_Input::n_DSA] = rand_out[(size_t)RandomLogic_Output::n_DSA];

		alu->sim(alu_in, SB, DB, ADL, ADH);

		pc->sim();

		data_bus->sim();

		// Outputs

		rw_latch.set(WR, PHI1);

		outputs[(size_t)OutputPad::PHI1] = PHI1;
		outputs[(size_t)OutputPad::PHI2] = PHI2;
		outputs[(size_t)OutputPad::RnW] = rw_latch.nget();
		outputs[(size_t)OutputPad::SYNC] = disp->getT1();
	}

}
