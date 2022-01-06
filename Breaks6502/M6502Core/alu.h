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
	public:

		void sim(BaseLogic::TriState inputs[], BaseLogic::TriState SB[], BaseLogic::TriState DB[], BaseLogic::TriState ADL[], BaseLogic::TriState ADH[]);

		BaseLogic::TriState getACR();

		BaseLogic::TriState getAVR();
	};
}
