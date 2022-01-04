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
		BaseLogic::TriState core_inputs[(size_t)M6502Core::InputPad::Max];
		BaseLogic::TriState core_outputs[(size_t)M6502Core::OutputPad::Max];
		BaseLogic::TriState core_inOuts[(size_t)M6502Core::InOutPad::Max];

		core->sim(core_inputs, core_outputs, core_inOuts);

		CLK = CLK == BaseLogic::TriState::Zero ? BaseLogic::TriState::One : BaseLogic::TriState::Zero;
	}
}
