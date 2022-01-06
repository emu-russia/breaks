#include "pch.h"

using namespace BaseLogic;

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
		TriState core_inputs[(size_t)M6502Core::InputPad::Max];
		TriState core_outputs[(size_t)M6502Core::OutputPad::Max];
		TriState core_inOuts[(size_t)M6502Core::InOutPad::Max];

		// DEBUG: Clear the data bus for debugging the logic

		for (size_t n = 0; n < (size_t)M6502Core::InOutPad::Max; n++)
		{
			core_inOuts[n] = TriState::Zero;
		}

		core_inputs[(size_t)M6502Core::InputPad::RDY] = TriState::One;
		core_inputs[(size_t)M6502Core::InputPad::SO] = TriState::Zero;
		core_inputs[(size_t)M6502Core::InputPad::PHI0] = CLK;

		core_inputs[(size_t)M6502Core::InputPad::n_IRQ] = TriState::One;
		core_inputs[(size_t)M6502Core::InputPad::n_NMI] = TriState::One;
		core_inputs[(size_t)M6502Core::InputPad::n_RES] = TriState::One;

		core->sim(core_inputs, core_outputs, core_inOuts);

		CLK = CLK == TriState::Zero ? TriState::One : TriState::Zero;
	}

	void Famicom::reset()
	{
		CLK = TriState::Zero;

		// Simply set /RES = 0 for a few cycles so that the 6502 initiates a BRK reset sequence.

		TriState core_inputs[(size_t)M6502Core::InputPad::Max];
		TriState core_outputs[(size_t)M6502Core::OutputPad::Max];
		TriState core_inOuts[(size_t)M6502Core::InOutPad::Max];

		// DEBUG: Clear the data bus for debugging the logic

		for (size_t n = 0; n < (size_t)M6502Core::InOutPad::Max; n++)
		{
			core_inOuts[n] = TriState::Zero;
		}

		core_inputs[(size_t)M6502Core::InputPad::RDY] = TriState::One;
		core_inputs[(size_t)M6502Core::InputPad::SO] = TriState::Zero;

		core_inputs[(size_t)M6502Core::InputPad::n_IRQ] = TriState::One;
		core_inputs[(size_t)M6502Core::InputPad::n_NMI] = TriState::One;
		core_inputs[(size_t)M6502Core::InputPad::n_RES] = TriState::Zero;

		for (size_t n = 0; n < 32; n++)
		{
			core_inputs[(size_t)M6502Core::InputPad::PHI0] = CLK;

			core->sim(core_inputs, core_outputs, core_inOuts);

			CLK = CLK == TriState::Zero ? TriState::One : TriState::Zero;
		}

		CLK = TriState::Zero;
	}
}
