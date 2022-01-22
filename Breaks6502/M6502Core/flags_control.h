#pragma once

namespace M6502Core
{
	union FlagsControl_TempWire
	{
		struct
		{
			unsigned n_POUT : 1;
			unsigned n_ARIT : 1;
			unsigned n_PIN : 1;
			unsigned ZTST : 1;
			unsigned SR : 1;
		};
		uint8_t bits;
	};

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

		FlagsControl_TempWire temp_tab[0x10000];
		RegsControl_TempWire prev_temp;

		FlagsControl_TempWire PreCalc(uint8_t ir, bool n_T0, bool n_T1X, bool n_T2, bool n_T3, bool n_T4, bool n_T5, bool T5, bool T6);

	public:

		FlagsControl(M6502* parent);

		void sim();
	};
}
