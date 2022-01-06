#pragma once

namespace M6502Core
{
	enum class ALUControl_Input
	{
		PHI1 = 0,
		PHI2,
		BRFW,
		n_ready,
		BRK6E,
		STKOP,
		T0,
		T1,
		T5,
		T6,
		PGX,
		n_D_OUT,
		n_C_OUT,
		Max,
	};

	enum class ALUControl_Output
	{
		NDB_ADD = 0,
		DB_ADD,
		Z_ADD,
		SB_ADD,
		ADL_ADD,
		ADD_SB7,
		ADD_SB06,
		ADD_ADL,

		ANDS,
		EORS,
		ORS,
		SRS,
		SUMS,

		n_ACIN,
		n_DAA,
		n_DSA,

		AND,
		SR,
		INC_SB,
		Max,
	};

	class ALUControl
	{
		BaseLogic::DLatch acin_latch1;
		BaseLogic::DLatch acin_latch2;
		BaseLogic::DLatch acin_latch3;
		BaseLogic::DLatch acin_latch4;
		BaseLogic::DLatch acin_latch5;

		BaseLogic::DLatch ndbadd_latch;
		BaseLogic::DLatch dbadd_latch;
		BaseLogic::DLatch zadd_latch;
		BaseLogic::DLatch sbadd_latch;
		BaseLogic::DLatch adladd_latch;
		
		BaseLogic::DLatch ands_latch1;
		BaseLogic::DLatch ands_latch2;
		BaseLogic::DLatch eors_latch1;
		BaseLogic::DLatch eors_latch2;
		BaseLogic::DLatch ors_latch1;
		BaseLogic::DLatch ors_latch2;
		BaseLogic::DLatch srs_latch1;
		BaseLogic::DLatch srs_latch2;
		BaseLogic::DLatch sums_latch1;
		BaseLogic::DLatch sums_latch2;

		BaseLogic::DLatch addsb7_latch;
		BaseLogic::DLatch addsb06_latch;
		BaseLogic::DLatch addadl_latch;

		BaseLogic::DLatch daa_latch1;
		BaseLogic::DLatch daa_latch2;
		BaseLogic::DLatch dsa_latch1;
		BaseLogic::DLatch dsa_latch2;

		// ADD/SB7 latches

		BaseLogic::DLatch cout_latch;
		BaseLogic::DLatch nready_latch;
		BaseLogic::DLatch mux_latch1;
		BaseLogic::DLatch ff_latch1;
		BaseLogic::DLatch ff_latch2;
		BaseLogic::FF sb7_ff;
		BaseLogic::DLatch sr_latch1;
		BaseLogic::DLatch sr_latch2;

	public:

		void sim(BaseLogic::TriState inputs[], BaseLogic::TriState d[], BaseLogic::TriState outputs[]);
	};
}