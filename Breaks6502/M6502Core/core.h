#pragma once

namespace M6502Core
{
	enum InputPad
	{
		n_NMI = 0,
		n_IRQ,
		n_RES,
		PHI0,
		RDY,
		SO,
		InputPad_Max,
	};

	enum OutputPad
	{
		PHI1 = 0,
		PHI2,
		RnW,
		SYNC,
		A0, A1, A2, A3, A4, A5, A6, A7,
		A8, A9, A10, A11, A12, A13, A14, A15,
		OutputPad_Max,
	};

	enum InOutPad
	{
		D0 = 0, D1, D2, D3, D4, D5, D6, D7,
		InOutPad_Max,
	};

	class Decoder;

	class M6502
	{
	public:
		M6502();
		~M6502();

		Decoder* decoder;

		void sim(BaseLogic::TriState inputs[], BaseLogic::TriState outputs[], BaseLogic::TriState inOuts[]);
	};

}
