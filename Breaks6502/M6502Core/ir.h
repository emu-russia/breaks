#pragma once

namespace M6502Core
{
	class IR
	{
		BaseLogic::DLatch ir_latch[8];

		M6502* core = nullptr;

	public:

		IR(M6502* parent) { core = parent; }

		BaseLogic::TriState IROut[8];

		void sim();

		void get(BaseLogic::TriState IR[8]);
	};
}
