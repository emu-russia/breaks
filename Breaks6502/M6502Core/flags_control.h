#pragma once

namespace M6502Core
{
	class FlagsControl
	{
		BaseLogic::DLatch pdb_latch;
		BaseLogic::DLatch iri_latch;
		BaseLogic::DLatch irc_latch;
		BaseLogic::DLatch ird_latch;
		BaseLogic::DLatch zv_latch;
		BaseLogic::DLatch acrc_latch;
		BaseLogic::DLatch dbz_latch;
		BaseLogic::DLatch dbn_latch;
		BaseLogic::DLatch dbc_latch;
		BaseLogic::DLatch pin_latch;
		BaseLogic::DLatch bit_latch;

		M6502* core = nullptr;

	public:

		FlagsControl(M6502* parent) { core = parent; }

		void sim();
	};
}
