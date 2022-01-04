#include "pch.h"

using namespace BaseLogic;

namespace M6502Core
{
	M6502::M6502()
	{
		decoder = new Decoder;
		predecode = new PreDecode;
		regs_control = new RegsControl;
	}

	M6502::~M6502()
	{
		delete decoder;
		delete predecode;
		delete regs_control;
	}

	void M6502::sim(TriState inputs[], TriState outputs[], TriState inOuts[])
	{
		TriState decoder_in[Decoder::inputs_count];
		TriState decoder_out[Decoder::outputs_count];

		decoder->sim(decoder_in, decoder_out);

		TriState pd_in[(size_t)PreDecode_Input::Max];
		TriState pd_out[(size_t)PreDecode_Output::Max];
		TriState n_PD[8];

		predecode->sim(pd_in, inOuts, pd_out, n_PD);

		TriState regs_control_in[(size_t)RegsControl_Input::Max];
		TriState regs_control_out[(size_t)RegsControl_Output::Max];

		regs_control->sim(regs_control_in, decoder_out, regs_control_out);


	}

}
