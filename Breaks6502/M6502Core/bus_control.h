#pragma once

namespace M6502Core
{
	enum class BusControl_Input
	{
		PHI1 = 0,
		PHI2,
		SBXY,
		STXY,
		AND,
		STOR,
		Z_ADL0,
		ACRL2,
		DL_PCH,
		n_ready,
		INC_SB,
		BRK6E,
		n_PCH_PCH,
		T0,
		T1,
		T5,
		T6,
		BR0,
		IR0,
		Max,
	};

	enum class BusControl_Output
	{
		ADL_ABL = 0,
		ADH_ABH,
		AC_DB,
		SB_AC,
		AC_SB,
		SB_DB,
		SB_ADH,
		Z_ADH0,
		Z_ADH17,
		DL_ADL,
		DL_ADH,
		DL_DB,

		ZTST,
		PGX,
		Max,
	};

	class BusControl
	{
		BaseLogic::DLatch z_adh0_latch;
		BaseLogic::DLatch z_adh17_latch;
		BaseLogic::DLatch sb_ac_latch;
		BaseLogic::DLatch adl_abl_latch;
		BaseLogic::DLatch ac_sb_latch;
		BaseLogic::DLatch sb_db_latch;
		BaseLogic::DLatch ac_db_latch;
		BaseLogic::DLatch sb_adh_latch;
		BaseLogic::DLatch adh_abh_latch;
		BaseLogic::DLatch dl_adh_latch;
		BaseLogic::DLatch dl_adl_latch;
		BaseLogic::DLatch dl_db_latch;
		BaseLogic::DLatch nready_latch;

	public:

		void sim(BaseLogic::TriState inputs[], BaseLogic::TriState d[], BaseLogic::TriState outputs[]);

		/// <summary>
		/// Get the PGX control signal from the decoder outputs and BR0.
		/// </summary>
		/// <param name="d"></param>
		/// <returns></returns>
		BaseLogic::TriState getPGX(BaseLogic::TriState d[], BaseLogic::TriState BR0);
	};
}
