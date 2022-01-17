#pragma once

namespace M6502Core
{
	class IR
	{
		BaseLogic::DLatch ir_latch[8];

	public:

		void sim(BaseLogic::TriState PHI1, BaseLogic::TriState FETCH, BaseLogic::TriState n_in[8]);

		void get(BaseLogic::TriState IR[8]);
	};
}
