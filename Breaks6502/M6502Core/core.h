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
	class IR;
	class ExtraCounter;
	class BRKProcessing;
	class Dispatcher;
	class RandomLogic;

	class AddressBus;
	class Regs;
	class ALU;
	class ProgramCounter;
	class DataBus;

	class M6502
	{
		BaseLogic::FF nmip_ff;
		BaseLogic::FF irqp_ff;
		BaseLogic::FF resp_ff;
		BaseLogic::DLatch irqp_latch;
		BaseLogic::DLatch resp_latch;

		BaseLogic::DLatch prdy_latch1;
		BaseLogic::DLatch prdy_latch2;

		BaseLogic::DLatch rw_latch;

		BaseLogic::TriState SB[8];
		BaseLogic::TriState DB[8];
		BaseLogic::TriState ADL[8];
		BaseLogic::TriState ADH[8];

	public:
		M6502();
		~M6502();

		Decoder* decoder = nullptr;
		PreDecode* predecode = nullptr;
		IR* ir = nullptr;
		ExtraCounter* ext = nullptr;
		BRKProcessing* brk = nullptr;
		Dispatcher* disp = nullptr;
		RandomLogic* random = nullptr;

		AddressBus* addr_bus = nullptr;
		Regs* regs = nullptr;
		ALU* alu = nullptr;
		ProgramCounter* pc = nullptr;
		DataBus* data_bus = nullptr;

		void sim(BaseLogic::TriState inputs[], BaseLogic::TriState outputs[], BaseLogic::TriState inOuts[]);
	};
}
