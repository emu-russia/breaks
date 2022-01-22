#pragma once

namespace M6502Core
{
	class PreDecode
	{
		BaseLogic::DLatch pd_latch[8];

		M6502* core = nullptr;

	public:

		PreDecode(M6502* parent) { core = parent; }

		BaseLogic::TriState PD[8] = { BaseLogic::TriState::Zero };
		BaseLogic::TriState n_PD[8];

		void sim(BaseLogic::TriState d[8]);
	};
}
