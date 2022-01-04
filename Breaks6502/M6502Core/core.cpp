#include "pch.h"

namespace M6502Core
{
	M6502::M6502()
	{
		decoder = new Decoder;
		regs_control = new RegsControl;
	}

	M6502::~M6502()
	{
		delete decoder;
		delete regs_control;
	}

	void M6502::sim(BaseLogic::TriState inputs[], BaseLogic::TriState outputs[], BaseLogic::TriState inOuts[])
	{
		BaseLogic::TriState decoder_in[Decoder::inputs_count];
		BaseLogic::TriState decoder_out[Decoder::outputs_count];

		decoder->sim(decoder_in, decoder_out);

		BaseLogic::TriState regs_control_in[(size_t)RegsControl_Input::Max];
		BaseLogic::TriState regs_control_out[(size_t)RegsControl_Output::Max];

		regs_control->sim(regs_control_in, decoder_out, regs_control_out);
	}

}
