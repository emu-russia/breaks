#pragma once

namespace PPUSim
{
	class PPU;
}

#include "bgcol.h"
#include "cram.h"
#include "dataread.h"
#include "fifo.h"
#include "fsm.h"
#include "hv.h"
#include "hv_decoder.h"
#include "mux.h"
#include "oam.h"
#include "pargen.h"
#include "regs.h"
#include "scroll_regs.h"
#include "sprite_eval.h"
#include "video_out.h"
#include "vram_ctrl.h"

namespace PPUSim
{

	/// <summary>
	/// Version of the PPU chip, including all known official and pirate variants.
	/// TODO: The full list of official revisions is not yet very clear, since the area has not been researched on our wiki.
	/// </summary>
	enum class Revision
	{
		Unknown = 0,

		RP2C02G,
		RP2C02H,
		RP2C03,
		RP2C03B,
		RP2C04_0001,
		RP2C04_0002,
		RP2C04_0003,
		RP2C04_0004,
		RP2C05,
		RP2C07_0,

		Max,
	};

	enum class InputPad
	{
		RnW = 0,
		RS0,
		RS1,
		RS2,
		n_DBE,
		CLK,
		n_RES,
		Max,
	};

	enum class OutputPad
	{
		n_INT = 0,
		ALE,
		n_RD,
		n_WR,
		Max,
	};

	class PPU
	{
		friend VideoOutSRBit;
		friend VideoOut;

		/// <summary>
		/// Internal auxiliary and intermediate connections.
		/// </summary>
		struct InternalWires
		{
			BaseLogic::TriState CLK;
			BaseLogic::TriState n_CLK;
			BaseLogic::TriState RES;
			BaseLogic::TriState PCLK;
			BaseLogic::TriState n_PCLK;
			BaseLogic::TriState n_TR;
			BaseLogic::TriState n_TG;
			BaseLogic::TriState n_TB;
			BaseLogic::TriState n_CC[4];
			BaseLogic::TriState n_LL[2];
			BaseLogic::TriState SYNC;
			BaseLogic::TriState PICTURE;
			BaseLogic::TriState BURST;

		} wire;

		Revision rev;

	public:
		PPU(Revision rev);
		~PPU();

		/// <summary>
		/// Simulate one half cycle (state) of the PPU.
		/// </summary>
		/// <param name="inputs">Inputs (see `InputPad`)</param>
		/// <param name="outputs">Outputs (see `OutputPad`)</param>
		/// <param name="ext">Bidirectional EXT color bus</param>
		/// <param name="data_bus">Bidirectional CPU-PPU data bus</param>
		/// <param name="ad_bus">Bidirectional PPU-VRAM data/address bus</param>
		/// <param name="addrHi_bus">This bus carries the rest of the address lines (output)</param>
		/// <param name="vout">The output level of the composite signal (V).</param>
		void sim(BaseLogic::TriState inputs[], BaseLogic::TriState outputs[], uint8_t* ext, uint8_t* data_bus, uint8_t* ad_bus, uint8_t* addrHi_bus, float* vout);
	};

}
