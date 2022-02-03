#pragma once

namespace Breaknes
{
	class Famicom
	{
		M6502Core::M6502* core = nullptr;
		BaseLogic::TriState CLK = BaseLogic::TriState::Zero;

		uint16_t addr_bus;
		uint8_t data_bus;

	public:
		Famicom();
		~Famicom();

		void sim();
		void reset();
	};
}
