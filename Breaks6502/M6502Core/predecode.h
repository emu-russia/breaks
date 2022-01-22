#pragma once

namespace M6502Core
{
	class PreDecode
	{
		uint8_t pd_latch;

		M6502* core = nullptr;

		BaseLogic::TriState precalc_n_TWOCYCLE[0x100];
		BaseLogic::TriState precalc_n_IMPLIED[0x100];

	public:

		PreDecode(M6502* parent);

		uint8_t PD;
		uint8_t n_PD;

		void sim(uint8_t *data_bus);
	};
}
