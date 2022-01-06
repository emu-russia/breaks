#pragma once

namespace M6502Core
{
	enum class ALU_Input
	{
		PHI2 = 0,

		NDB_ADD,
		DB_ADD,
		Z_ADD,
		SB_ADD,
		ADL_ADD,
		ADD_SB06,
		ADD_SB7,
		ADD_ADL,

		ANDS,
		EORS,
		ORS,
		SRS,
		SUMS,

		SB_AC,
		AC_SB,
		AC_DB,
		SB_DB,
		SB_ADH,
		Z_ADH0,
		Z_ADH17,

		n_ACIN,
		n_DAA,
		n_DSA,

		Max,
	};

	class ALU
	{
		BaseLogic::DLatch AI[8];
		BaseLogic::DLatch BI[8];
		BaseLogic::DLatch n_ADD[8];
		BaseLogic::DLatch AC[8];
		BaseLogic::FF AC_FF[8];

		BaseLogic::DLatch BC7_latch;
		BaseLogic::DLatch DC7_latch;

		BaseLogic::DLatch daal_latch;
		BaseLogic::DLatch daah_latch;
		BaseLogic::DLatch dsal_latch;
		BaseLogic::DLatch dsah_latch;

		BaseLogic::DLatch DCLatch;
		BaseLogic::DLatch ACLatch;
		BaseLogic::DLatch AVRLatch;

		bool BCD_Hack = false;		// BCD correction hack for NES/Famicom.

	public:

		void sim(BaseLogic::TriState inputs[], BaseLogic::TriState SB[], BaseLogic::TriState DB[], BaseLogic::TriState ADL[], BaseLogic::TriState ADH[]);

		BaseLogic::TriState getACR();

		BaseLogic::TriState getAVR();
	};
}