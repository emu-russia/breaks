#pragma once

namespace M6502Core
{
	enum class FlagsControl_Input
	{
		PHI2 = 0,
		T6,
		ZTST,
		SR,
		n_ready,
		Max,
	};

	enum class FlagsControl_Output
	{
		P_DB = 0,
		IR5_I,
		IR5_C,
		IR5_D,
		Z_V,
		ACR_C,
		DBZ_Z,
		DB_N,
		DB_P,
		DB_C,
		DB_V,
		Max,
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

	public:

		void sim(BaseLogic::TriState inputs[], BaseLogic::TriState d[], BaseLogic::TriState outputs[]);
	};
}
