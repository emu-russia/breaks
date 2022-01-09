#pragma once

namespace M6502Core
{
	enum class ProgramCounter_Input
	{
		PHI2 = 0,
		ADL_PCL,
		PCL_PCL,
		PCL_ADL,
		PCL_DB,
		ADH_PCH,
		PCH_PCH,
		PCH_ADH,
		PCH_DB,
		n_1PC,
		Max,
	};

	class ProgramCounter
	{
		BaseLogic::DLatch PCL[8];
		BaseLogic::DLatch PCLS[8];
		BaseLogic::DLatch PCH[8];
		BaseLogic::DLatch PCHS[8];

		void sim_EvenBit(
			BaseLogic::TriState PHI2, BaseLogic::TriState ADx_PCx, BaseLogic::TriState PCx_PCx, BaseLogic::TriState PCx_ADx, BaseLogic::TriState PCx_DB, BaseLogic::TriState DB[], BaseLogic::TriState ADx[],
			BaseLogic::TriState cin, BaseLogic::TriState& cout, BaseLogic::TriState& sout, size_t n,
			BaseLogic::DLatch PCx[], BaseLogic::DLatch PCxS[]);

		void sim_OddBit(
			BaseLogic::TriState PHI2, BaseLogic::TriState ADx_PCx, BaseLogic::TriState PCx_PCx, BaseLogic::TriState PCx_ADx, BaseLogic::TriState PCx_DB, BaseLogic::TriState DB[], BaseLogic::TriState ADx[],
			BaseLogic::TriState cin, BaseLogic::TriState& cout, BaseLogic::TriState& sout, size_t n,
			BaseLogic::DLatch PCx[], BaseLogic::DLatch PCxS[]);

	public:

		void sim(BaseLogic::TriState inputs[], BaseLogic::TriState DB[], BaseLogic::TriState ADL[], BaseLogic::TriState ADH[]);

		uint8_t getPCL();
		uint8_t getPCH();
	};
}
