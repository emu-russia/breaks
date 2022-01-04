#pragma once

/// <summary>
/// Basic logic primitives used in N-MOS chips.
/// Combinational primitives are implemented using ordinary methods.
/// Sequential primitives are implemented using classes.
/// </summary>
namespace BaseLogic
{
	enum TriState
	{
		Zero = 0,
		One = 1,
		Z = -1,
		X = -2,
	};

	/// <summary>
	/// The simplest element, implemented with a single N-MOS FET.
	/// </summary>
	/// <param name="a"></param>
	/// <returns></returns>
	TriState NOT(TriState a);

	/// <summary>
	/// 2-nor
	/// </summary>
	/// <param name="a"></param>
	/// <param name="b"></param>
	/// <returns></returns>
	TriState NOR(TriState a, TriState b);

	/// <summary>
	/// 3-nor
	/// </summary>
	/// <param name="a"></param>
	/// <param name="b"></param>
	/// <param name="c"></param>
	/// <returns></returns>
	TriState NOR3(TriState a, TriState b, TriState c);

	/// <summary>
	/// 2-nand
	/// </summary>
	/// <param name="a"></param>
	/// <param name="b"></param>
	/// <returns></returns>
	TriState NAND(TriState a, TriState b);

	/// <summary>
	/// 2-and
	/// </summary>
	/// <param name="a"></param>
	/// <param name="b"></param>
	/// <returns></returns>
	TriState AND(TriState a, TriState b);

	/// <summary>
	/// The real latch works as a pair of N-MOS transistors.
	/// The first transistor is the tri-state (`d`). It opens the input to the gate of the second transistor, where the value is stored.
	/// After closing the tri-state the value is stored as a `floating` value on the gate of the second transistor.
	/// The output from the second transistor is the DLatch output.
	/// Since the second transistor is essentially an inverter, the output will also be in inverse logic (`/out`)
	/// </summary>
	class DLatch
	{
		TriState g = TriState::Zero;

	public:

		void set(TriState val, TriState en);
		TriState get();
		TriState nget();
	};

	/// <summary>
	/// 2-mux
	/// </summary>
	/// <param name="sel"></param>
	/// <param name="in0"></param>
	/// <param name="in1"></param>
	/// <returns></returns>
	TriState MUX(TriState sel, TriState in0, TriState in1);

}
