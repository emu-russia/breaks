#pragma once

namespace M6502Core
{
	class Regs
	{
		uint8_t Y;
		uint8_t X;
		uint8_t S_in;
		uint8_t S_out;

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
