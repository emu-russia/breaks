// Video Signal Generator

#pragma once

namespace PPUSim
{
	/// <summary>
	/// Implementation of a single bit of the shift register.
	/// TODO: Switch to generalized implementation.
	/// </summary>
	class VideoOutSRBit
	{
		PPU* ppu = nullptr;

		BaseLogic::DLatch latch1;
		BaseLogic::DLatch latch2;

	public:

		VideoOutSRBit(PPU* parent) { ppu = parent; }

		void sim(BaseLogic::TriState shift_in);

		BaseLogic::TriState getn_Out();
		BaseLogic::TriState getn_ShiftOut();
	};

	class VideoOut
	{
		float LToV[16];

		BaseLogic::DLatch cc_latch1[4];
		BaseLogic::DLatch cc_latch2[4];
		BaseLogic::DLatch cc_burst_latch;
		BaseLogic::DLatch dac_latch1;
		BaseLogic::DLatch dac_latch2;
		BaseLogic::DLatch dac_latch3;
		BaseLogic::DLatch dac_latch4;

		VideoOutSRBit *sr[6];		// Individual bits of the shift register for the phase shifter.

		PPU* ppu = nullptr;

	public:

		VideoOut(PPU* parent);
		~VideoOut();

		// TBD: Once everything is working, add output support for RGB-like PPUs.
		
		void sim(float *vout);
	};
}
