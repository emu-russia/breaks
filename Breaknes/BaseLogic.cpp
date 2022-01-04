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

		return (TriState)(~a & 1);
	}

	TriState NOR(TriState a, TriState b)
	{
		return (TriState)((~(a | b)) & 1);
	}

	TriState NOR3(TriState a, TriState b, TriState c)
	{
		return (TriState)((~(a | b | c)) & 1);
	}

	TriState NAND(TriState a, TriState b)
	{
		return (TriState)((~(a & b)) & 1);
	}

	TriState AND(TriState a, TriState b)
	{
		return NOT(NAND(a, b));
	}

	void DLatch::set(TriState val, TriState en)
	{
		if (en == TriState::One)
		{
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

	TriState MUX(TriState sel, TriState in0, TriState in1)
	{
		return ((sel & 1) == 0) ? in0 : in1;
	}

	PLA::PLA(size_t inputs, size_t outputs)
	{
		romInputs = inputs;
		romOutputs = outputs;
		romSize = inputs * outputs;
		rom = new uint8_t[romSize];
		memset(rom, 0, romSize);
	}

	PLA::~PLA()
	{
		if (rom)
			delete[] rom;
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
	}

	void PLA::sim(TriState inputs[], TriState outputs[])
	{
		for (size_t out = 0; out < romOutputs; out++)
		{
			// Since the decoder lines are multi-input NORs - the default output is `1`.
			outputs[out] = TriState::One;

			for (size_t bit = 0; bit < romInputs; bit++)
			{
				// If there is a transistor at the crossing point and the corresponding input is `1` - then ground the output and abort the term.
				if (rom[out * romInputs + bit] && (inputs[bit] == TriState::One))
				{
					outputs[out] = TriState::Zero;
					break;
				}
			}
		}
	}

}
