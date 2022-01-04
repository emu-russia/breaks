#pragma once

namespace M6502Core
{
	enum class InputPad
	{
		n_NMI = 0,
		n_IRQ,
		n_RES,
		PHI0,
		RDY,
		SO,
		Max,
	};

	enum class OutputPad
	{
		PHI1 = 0,
		PHI2,
		RnW,
		SYNC,
		A0, A1, A2, A3, A4, A5, A6, A7,
		A8, A9, A10, A11, A12, A13, A14, A15,
		Max,
	};

	enum class InOutPad
	{
		D0 = 0, D1, D2, D3, D4, D5, D6, D7,
		Max,
	};

	class Decoder;
	class PreDecode;
	class RegsControl;

	class M6502
	{
		BaseLogic::DLatch prdy_latch1;
		BaseLogic::DLatch prdy_latch2;

	public:
		M6502();
		~M6502();

		Decoder* decoder;
		PreDecode* predecode;
		RegsControl* regs_control;

		void sim(BaseLogic::TriState inputs[], BaseLogic::TriState outputs[], BaseLogic::TriState inOuts[]);
	};

}
