#include "pch.h"

namespace Breaknes
{
	Famicom::Famicom()
	{
		core = new M6502Core::M6502;
	}

	Famicom::~Famicom()
	{
		delete core;
	}

	void Famicom::sim()
	{
		BaseLogic::TriState core_inputs[M6502Core::InputPad::InputPad_Max];
		BaseLogic::TriState core_outputs[M6502Core::OutputPad::OutputPad_Max];
		BaseLogic::TriState core_inOuts[M6502Core::InOutPad::InOutPad_Max];

		core->sim(core_inputs, core_outputs, core_inOuts);

		CLK = CLK == BaseLogic::TriState::Zero ? BaseLogic::TriState::One : BaseLogic::TriState::Zero;
	}
}
