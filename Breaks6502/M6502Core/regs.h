#pragma once

namespace M6502Core
{
	class Regs
	{
		BaseLogic::FF Y[8];
		BaseLogic::FF X[8];
		BaseLogic::DLatch S_in[8];
		BaseLogic::DLatch S_out[8];

		M6502* core = nullptr;

	public:

		Regs(M6502* parent) { core = parent; }

		void sim_LoadSB();

		void sim_StoreSB();

		void sim_StoreOldS();

		uint8_t getY();
		uint8_t getX();
		uint8_t getS();
	};
}
