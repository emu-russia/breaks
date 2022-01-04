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

}
