#pragma once

namespace M6502Core
{
	enum DecoderInput
	{
		n_T1X = 0,
		n_T0,
		n_IR5,
		IR5,
		n_IR6,
		IR6,
		n_IR2,
		IR2,
		n_IR3,
		IR3,
		n_IR4,
		IR4,
		n_IR7,
		IR7,
		n_IR0,
		IR01,
		n_IR1,
		n_T2,
		n_T3,
		n_T4,
		n_T5,
	};

	class Decoder
	{
	public:
		BaseLogic::PLA *pla = nullptr;

		Decoder();
		~Decoder();

		void sim(BaseLogic::TriState inputs[], BaseLogic::TriState outputs[]);
	};
}
