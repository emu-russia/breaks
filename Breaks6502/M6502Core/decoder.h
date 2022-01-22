#pragma once

namespace M6502Core
{
	union DecoderInput
	{
		struct
		{
			unsigned n_T1X : 1;		// lsb (bit0)
			unsigned n_T0 : 1;
			unsigned n_IR5 : 1;
			unsigned IR5 : 1;
			unsigned n_IR6 : 1;
			unsigned IR6 : 1;
			unsigned n_IR2 : 1;
			unsigned IR2 : 1;
			unsigned n_IR3 : 1;
			unsigned IR3 : 1;
			unsigned n_IR4 : 1;
			unsigned IR4 : 1;
			unsigned n_IR7 : 1;
			unsigned IR7 : 1;
			unsigned n_IR0 : 1;
			unsigned IR01 : 1;
			unsigned n_IR1 : 1;
			unsigned n_T2 : 1;
			unsigned n_T3 : 1;
			unsigned n_T4 : 1;
			unsigned n_T5 : 1;		// msb
		};
		size_t packed_bits;
	};

	class Decoder
	{
		BaseLogic::PLA* pla = nullptr;

	public:
		static const size_t inputs_count = 21;
		static const size_t outputs_count = 130;

		Decoder();
		~Decoder();

		void sim(size_t input_bits, BaseLogic::TriState** outputs);
	};
}
