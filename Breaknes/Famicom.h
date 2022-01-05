#pragma once

namespace Breaknes
{
	class Famicom
	{
		M6502Core::M6502* core = nullptr;
		BaseLogic::TriState CLK = BaseLogic::TriState::Zero;

	public:
		Famicom();
		~Famicom();

		void sim();
		void reset();
	};
}
