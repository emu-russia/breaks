#pragma once

namespace M6502Core
{
	class IR
	{
		uint8_t ir_latch;

		M6502* core = nullptr;

	public:

		IR(M6502* parent) { core = parent; }

		uint8_t IROut;

		void sim();
	};
}
