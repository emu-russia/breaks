#pragma once

namespace M6502Core
{
	union CarryBCD_TempWire
	{
		struct
		{
			unsigned n_ADL_ADD : 1;
			unsigned n_ADL_ADD_Derived : 1;
			unsigned INC_SB : 1;
			unsigned BRX : 1;
			unsigned CSET : 1;
		};
		uint8_t bits;
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
		BaseLogic::DLatch sr_latch1;
		BaseLogic::DLatch sr_latch2;

		M6502* core = nullptr;

		BaseLogic::TriState STKOP = BaseLogic::TriState::Zero;
		BaseLogic::TriState n_ADL_ADD = BaseLogic::TriState::Zero;
		BaseLogic::TriState INC_SB = BaseLogic::TriState::Zero;
		BaseLogic::TriState BRX = BaseLogic::TriState::Zero;
		BaseLogic::TriState n_ADD_SB7 = BaseLogic::TriState::Zero;

		CarryBCD_TempWire temp_tab1[1 << 19];
		CarryBCD_TempWire prev_temp1;

		CarryBCD_TempWire PreCalc1(uint8_t ir, bool n_T0, bool n_T1X, bool n_T2, bool n_T3, bool n_T4, bool n_T5, 
			bool n_ready, bool T0, bool T5, bool BRFW, bool n_C_OUT);

	public:

		ALUControl(M6502* parent);

		void sim_CarryBCD();
		void sim_ALUInput();
		void sim_ALUOps();
		void sim_ADDOut();

		void sim();
	};
}
