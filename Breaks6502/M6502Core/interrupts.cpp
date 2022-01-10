#include "pch.h"

using namespace BaseLogic;

namespace M6502Core
{
	void BRKProcessing::sim_BeforeRandom(TriState inputs[], TriState outputs[])
	{
		TriState PHI1 = inputs[(size_t)BRKProcessing_Input::PHI1];
		TriState PHI2 = inputs[(size_t)BRKProcessing_Input::PHI2];
		TriState BRK5 = inputs[(size_t)BRKProcessing_Input::BRK5];
		TriState n_ready = inputs[(size_t)BRKProcessing_Input::n_ready];
		TriState RESP = inputs[(size_t)BRKProcessing_Input::RESP];
		TriState n_NMIP = inputs[(size_t)BRKProcessing_Input::n_NMIP];

		// Interrupt cycle 6-7

		TriState BRK5_RDY = AND(BRK5, NOT(n_ready));
		brk5_latch.set(BRK5_RDY, PHI2);
		brk6_latch1.set(AND(NOT(brk5_latch.get()), NAND(n_ready, brk_ff.get())), PHI1);
		brk_ff.set(brk6_latch1.nget());
		brk6_latch2.set(brk_ff.get(), PHI2);
		TriState BRK6E = NOR(brk6_latch2.nget(), n_ready);
		TriState BRK7 = NOR(brk_ff.get(), BRK5_RDY);

		// Reset FF

		res_latch1.set(RESP, PHI2);
		res_latch2.set(res_ff.get(), PHI1);
		TriState res_out = NOR(res_latch1.get(), res_latch2.get());
		res_ff.set(NOR(res_out, BRK6E));
		TriState DORES = NOT(res_out);

		// NMI Edge Detect

		brk6e_latch.set(BRK6E, PHI1);
		brk7_latch.set(BRK7, PHI2);
		nmip_latch.set(n_NMIP, PHI1);

		donmi_latch.set(NOR3(brk7_latch.nget(), n_NMIP, nmi_ff2.get()), PHI1);

		ff1_latch.set(nmi_ff1.get(), PHI2);
		nmi_ff1.set(NOR(donmi_latch.get(), NOR(ff1_latch.get(), brk6e_latch.get())));
		TriState n_DONMI = nmi_ff1.get();

		delay_latch1.set(nmi_ff1.get(), PHI2);
		delay_latch2.set(delay_latch1.nget(), PHI1);

		ff2_latch.set(nmi_ff2.get(), PHI2);
		nmi_ff2.set(NOR(nmip_latch.get(), NOR(ff2_latch.get(), delay_latch2.get())));

		// Interrupt vector

		zadl_latch[0].set(NOT(BRK5_RDY), PHI2);
		zadl_latch[1].set(NOT(NOR(BRK7, NOT(DORES))), PHI2);
		zadl_latch[2].set(NOR3(BRK7, DORES, n_DONMI), PHI2);

		// Outputs

		outputs[(size_t)BRKProcessing_Output::BRK6E] = BRK6E;
		outputs[(size_t)BRKProcessing_Output::BRK7] = BRK7;
		outputs[(size_t)BRKProcessing_Output::DORES] = DORES;
		outputs[(size_t)BRKProcessing_Output::Z_ADL0] = zadl_latch[0].nget();
		outputs[(size_t)BRKProcessing_Output::Z_ADL1] = zadl_latch[1].nget();
		outputs[(size_t)BRKProcessing_Output::Z_ADL2] = NOT(zadl_latch[2].nget());
		outputs[(size_t)BRKProcessing_Output::n_DONMI] = n_DONMI;
		outputs[(size_t)BRKProcessing_Output::BRK5_RDY] = BRK5_RDY;
	}

	void BRKProcessing::sim_AfterRandom(TriState inputs[], TriState outputs[])
	{
		TriState PHI1 = inputs[(size_t)BRKProcessing_Input::PHI1];
		TriState PHI2 = inputs[(size_t)BRKProcessing_Input::PHI2];
		TriState T0 = inputs[(size_t)BRKProcessing_Input::T0];
		TriState BR2 = inputs[(size_t)BRKProcessing_Input::BR2];
		TriState n_I_OUT = inputs[(size_t)BRKProcessing_Input::n_I_OUT];
		TriState n_IRQP = inputs[(size_t)BRKProcessing_Input::n_IRQP];
		TriState n_DONMI = inputs[(size_t)BRKProcessing_Input::n_DONMI];
		TriState BRK6E = inputs[(size_t)BRKProcessing_Input::BRK6E];
		TriState DORES = inputs[(size_t)BRKProcessing_Input::DORES];

		// B Flag

		TriState int_set = NAND(
			OR(BR2, T0),
			NAND(n_DONMI, OR(n_IRQP, NOT(n_I_OUT)))
		);

		b_latch2.set(b_ff.get(), PHI1);
		b_latch1.set(AND(int_set, NOT(b_latch2.get())), PHI2);
		b_ff.set(NOR(b_latch1.get(), BRK6E));
		TriState B_OUT = NOR(DORES, b_ff.get());

		outputs[(size_t)BRKProcessing_Output::B_OUT] = B_OUT;
	}

	TriState BRKProcessing::getDORES()
	{
		TriState DORES = NOT(NOR(res_latch1.get(), res_latch2.get()));
		return DORES;
	}

	TriState BRKProcessing::getB_OUT()
	{
		TriState DORES = getDORES();
		TriState B_OUT = NOR(DORES, b_ff.get());
		return B_OUT;
	}
}
