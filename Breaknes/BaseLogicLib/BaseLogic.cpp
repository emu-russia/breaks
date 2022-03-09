#include "pch.h"

namespace BaseLogic
{

	TriState NOT (TriState a)
	{
#if _DEBUG
		if (!(a == TriState::Zero || a == TriState::One))
		{
			throw "The third state is not supported for this operation under normal conditions.";
		}
#endif

		return a == TriState::Zero ? TriState::One : TriState::Zero;
	}

	TriState NOR(TriState a, TriState b)
	{
		return (TriState)((~(a | b)) & 1);
	}

	TriState NOR3(TriState a, TriState b, TriState c)
	{
		return (TriState)((~(a | b | c)) & 1);
	}

	TriState NOR4(TriState in[4])
	{
		return (TriState)((~(in[0] | in[1] | in[2] | in[3])) & 1);
	}

	TriState NOR5(TriState in[5])
	{
		return (TriState)((~(in[0] | in[1] | in[2] | in[3] | in[4])) & 1);
	}

	TriState NOR6(TriState in[6])
	{
		return (TriState)((~(in[0] | in[1] | in[2] | in[3] | in[4] | in[5])) & 1);
	}

	TriState NOR7(TriState in[7])
	{
		return (TriState)((~(in[0] | in[1] | in[2] | in[3] | in[4] | in[5] | in[6])) & 1);
	}

	TriState NOR8(TriState in[8])
	{
		return (TriState)((~(in[0] | in[1] | in[2] | in[3] | in[4] | in[5] | in[6] | in[7])) & 1);
	}

	TriState NOR9(TriState in[9])
	{
		return (TriState)((~(in[0] | in[1] | in[2] | in[3] | in[4] | in[5] | in[6] | in[7] | in[8])) & 1);
	}

	TriState NOR13(TriState in[13])
	{
		return (TriState)((~(in[0] | in[1] | in[2] | in[3] | in[4] | in[5] | in[6] | in[7] | in[8] | in[9] | in[10] | in[11] | in[12])) & 1);
	}

	TriState NAND(TriState a, TriState b)
	{
		return (TriState)((~(a & b)) & 1);
	}

	TriState AND(TriState a, TriState b)
	{
		return (TriState)(a & b);
	}

	TriState AND3(TriState a, TriState b, TriState c)
	{
		return (TriState)(((a & b) & c) & 1);
	}

	TriState AND4(TriState in[4])
	{
		return (TriState)(((in[0] & in[1] & in[2] & in[3])) & 1);
	}

	TriState OR(TriState a, TriState b)
	{
		return (TriState)((a | b) & 1);
	}

	TriState OR3(TriState a, TriState b, TriState c)
	{
		return (TriState)((a | b | c) & 1);
	}

	TriState XOR(TriState a, TriState b)
	{
		return (TriState)((a ^ b) & 1);
	}

	void DLatch::set(TriState val, TriState en)
	{
		if (en == TriState::One)
		{
			if (val == TriState::Z)
			{
				// The floating input does not change the state of the latch.
				return;
			}

			g = val;
		}
	}

	TriState DLatch::get()
	{
		return g;
	}

	TriState DLatch::nget()
	{
		return NOT(g);
	}

	void FF::set(TriState val)
	{
		g = val;
	}

	TriState FF::get()
	{
		return g;
	}

	TriState MUX(TriState sel, TriState in0, TriState in1)
	{
		return ((sel & 1) == 0) ? in0 : in1;
	}

	void DMX4(TriState in[4], TriState out[16])
	{
		size_t fireInput = PackNibble(in);

		for (size_t n = 0; n < 16; n++)
		{
			out[n] = n == fireInput ? TriState::One : TriState::Zero;
		}
	}

	PLA::PLA(size_t inputs, size_t outputs)
	{
		romInputs = inputs;
		romOutputs = outputs;
		romSize = inputs * outputs;
		rom = new uint8_t[romSize];
		memset(rom, 0, romSize);
		unomptimized_out = new TriState[romOutputs];
	}

	PLA::~PLA()
	{
		if (rom)
			delete[] rom;

		if (outs)
			delete[] outs;

		if (unomptimized_out)
			delete[] unomptimized_out;
	}

	void PLA::SetMatrix(size_t bitmask[])
	{
		for (size_t out = 0; out < romOutputs; out++)
		{
			size_t val = bitmask[out];

			for (size_t bit = 0; bit < romInputs; bit++)
			{
				rom[out * romInputs + (romInputs - bit - 1)] = val & 1;
				val >>= 1;
			}
		}

		// Optimization for PLA

		if (Optimize)
		{
			if (outs)
			{
				delete[] outs;
				outs = nullptr;
			}

			size_t maxLane = (1ULL << romInputs);

			FILE* f;
			fopen_s(&f, "pla.bin", "rb");
			if (f)
			{
				outs = new TriState[maxLane * romOutputs];
				fread(outs, sizeof(TriState), maxLane * romOutputs, f);
				fclose(f);
				return;
			}

			outs = new TriState[maxLane * romOutputs];
			TriState* outputs;

			for (size_t n = 0; n < maxLane; n++)
			{
				sim_Unomptimized(n, &outputs);

				TriState* lane = &outs[n * romOutputs];
				memcpy(lane, outputs, romOutputs * sizeof(TriState));
			}

			fopen_s(&f, "pla.bin", "wb");
			fwrite(outs, sizeof(TriState), maxLane * romOutputs, f);
			fclose(f);
		}
	}

	void PLA::sim(size_t input_bits, TriState** outputs)
	{
		if (!outs)
		{
			sim_Unomptimized(input_bits, outputs);
			return;
		}

		TriState* lane = &outs[input_bits * romOutputs];
		*outputs = lane;
	}

	void PLA::sim_Unomptimized(size_t input_bits, TriState** outputs)
	{
		for (size_t out = 0; out < romOutputs; out++)
		{
			// Since the decoder lines are multi-input NORs - the default output is `1`.
			unomptimized_out[out] = TriState::One;

			for (size_t bit = 0; bit < romInputs; bit++)
			{
				// If there is a transistor at the crossing point and the corresponding input is `1` - then ground the output and abort the term.
				if (rom[out * romInputs + bit] && (input_bits & (1ULL << bit)))
				{
					unomptimized_out[out] = TriState::Zero;
					break;
				}
			}
		}
		*outputs = unomptimized_out;
	}

	uint8_t Pack(TriState in[8])
	{
		uint8_t val = 0;
		for (size_t i = 0; i < 8; i++)
		{
			val <<= 1;
			val |= (in[7 - i] == TriState::One) ? 1 : 0;
		}
		return val;
	}

	uint8_t PackNibble(TriState in[4])
	{
		uint8_t val = 0;
		for (size_t i = 0; i < 4; i++)
		{
			val <<= 1;
			val |= (in[4 - i] == TriState::One) ? 1 : 0;
		}
		return val;
	}

	void Unpack(uint8_t val, TriState out[8])
	{
		for (size_t i = 0; i < 8; i++)
		{
			out[i] = (val & 1) ? TriState::One : TriState::Zero;
			val >>= 1;
		}
	}

	void Dump(TriState in[8], const char* name)
	{
		printf("%s: ", name);
		for (size_t i = 0; i < 8; i++)
		{
			switch (in[7 - i])
			{
				case TriState::Zero:
					printf("0 ");
					break;
				case TriState::One:
					printf("1 ");
					break;
				case TriState::Z:
					printf("z ");
					break;
				case TriState::X:
					printf("x ");
					break;
			}
		}
		printf("\n");
	}

	void BusConnect(TriState& a, TriState& b)
	{
		if (a != b)
		{
			if (a == TriState::Zero)
			{
				b = TriState::Zero;
			}
			if (b == TriState::Zero)
			{
				a = TriState::Zero;
			}
		}
	}

}
