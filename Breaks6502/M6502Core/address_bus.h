#pragma once

namespace M6502Core
{
	class AddressBus
	{
		BaseLogic::FF ABL[8];
		BaseLogic::FF ABH[8];

		M6502* core = nullptr;

	public:

		AddressBus(M6502* parent) { core = parent; }

		void sim_ConstGen();

		void sim_Output(BaseLogic::TriState cpu_out[]);

		uint8_t getABL();
		uint8_t getABH();
	};
}
