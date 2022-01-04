#pragma once

namespace M6502Core
{
	typedef enum
	{
		n_NMI,
		n_IRQ,
		n_RES,
		PHI0,
		RDY,
		SO,
	} InputPad;

	typedef enum
	{
		PHI1,
		PHI2,
		RW,
		SYNC,
		A0, A1, A2, A3, A4, A5, A6, A7,
		A8, A9, A10, A11, A12, A13, A14, A15,
	} OutputPad;

	typedef enum
	{
		D0, D1, D2, D3, D4, D5, D6, D7,
	} InOutPad;

	class M6502
	{
	public:
		M6502();
		~M6502();

		void sim(BaseLogic::TriState inputs[], BaseLogic::TriState outputs[], BaseLogic::TriState inOuts[]);
	};

}
