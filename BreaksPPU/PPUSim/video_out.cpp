// Video Signal Generator

#include "pch.h"

using namespace BaseLogic;

namespace PPUSim
{
	VideoOut::VideoOut(PPU* parent)
	{
		ppu = parent;

		for (size_t n = 0; n < 6; n++)
		{
			sr[n] = new VideoOutSRBit(ppu);
		}

		if (ppu->rev == Revision::RP2C02G)
		{
			LToV[0] = 0.781f;
			LToV[1] = 1.000f;
			LToV[2] = 1.131f;
			LToV[3] = 1.300f;
			LToV[4] = 1.712f;
			LToV[5] = 1.743f;
			LToV[6] = 1.875f;
			LToV[7] = 2.287f;
			LToV[8] = 2.331f;
			LToV[9] = 2.743f;
			LToV[10] = 2.743f; //?
		}
		else
		{
			// TBD: PAL, others (RGB, clones)

			LToV[0] = 0.0f;
			LToV[1] = 0.0f;
			LToV[2] = 0.0f;
			LToV[3] = 0.0f;
			LToV[4] = 0.0f;
			LToV[5] = 0.0f;
			LToV[6] = 0.0f;
			LToV[7] = 0.0f;
			LToV[8] = 0.0f;
			LToV[9] = 0.0f;
			LToV[10] = 0.0f;
		}
	}

	VideoOut::~VideoOut()
	{
		for (size_t n = 0; n < 6; n++)
		{
			delete sr[n];
		}
	}

	void VideoOut::sim(float* vout)
	{
		TriState PCLK = ppu->wire.PCLK;
		TriState n_PCLK = ppu->wire.n_PCLK;
		TriState BURST = ppu->wire.BURST;
		TriState SYNC = ppu->wire.SYNC;
		TriState PICTURE = ppu->wire.PICTURE;

		TriState P[13], PZ[13];

		// Phase Shifter
		// TBD: PAL

		PZ[6] = NOT(sr[2]->getn_ShiftOut());
		sr[0]->sim(NOT(PZ[6]));
		PZ[3] = NOT(sr[1]->getn_ShiftOut());
		PZ[1] = NOR(sr[0]->getn_ShiftOut(), NOR(NOT(PZ[6]), PZ[3]));
		sr[1]->sim(PZ[1]);
		PZ[3] = NOT(sr[1]->getn_ShiftOut());
		sr[2]->sim(PZ[3]);
		PZ[6] = NOT(sr[2]->getn_ShiftOut());
		sr[3]->sim(PZ[6]);
		PZ[8] = NOT(sr[3]->getn_ShiftOut());
		sr[4]->sim(PZ[8]);
		PZ[10] = NOT(sr[4]->getn_ShiftOut());
		sr[5]->sim(PZ[10]);
		PZ[12] = NOT(sr[5]->getn_ShiftOut());

		PZ[0] = sr[0]->getn_Out();
		PZ[2] = sr[1]->getn_Out();
		PZ[5] = sr[2]->getn_Out();
		PZ[7] = sr[3]->getn_Out();
		PZ[9] = sr[4]->getn_Out();
		PZ[11] = sr[5]->getn_Out();

		TriState n_PR = PZ[0];
		TriState n_PG = PZ[9];
		TriState n_PB = PZ[5];

		// Chrominance Decoder

		cc_burst_latch.set(BURST, n_PCLK);

		for (size_t n = 0; n < 4; n++)
		{
			cc_latch1[n].set(ppu->wire.n_CC[n], PCLK);
			cc_latch2[n].set(cc_latch1[n].nget(), n_PCLK);
		}

		TriState dmxin[4];
		TriState dmxout[16];
		dmxin[0] = cc_latch2[0].nget();
		dmxin[1] = cc_latch2[1].nget();
		dmxin[2] = cc_latch2[2].nget();
		dmxin[3] = NOR(cc_latch2[3].get(), cc_burst_latch.get());
		DMX4(dmxin, dmxout);

		TriState P123 = NOR3(dmxin[1], dmxin[2], dmxin[3]);

		P[0] = dmxout[3];
		P[1] = dmxout[10];
		P[2] = dmxout[5];
		P[3] = dmxout[12];
		P[4] = dmxout[15];
		P[5] = dmxout[7];
		P[6] = dmxout[14];
		P[7] = dmxout[9];
		P[8] = dmxout[4];
		P[9] = dmxout[11];
		P[10] = dmxout[6];
		P[11] = dmxout[13];
		P[12] = dmxout[8];

		TriState pz[13];

		for (size_t n = 0; n < 13; n++)
		{
			if (n != 4)
			{
				pz[n] = AND(P[n], NOT(PZ[n]));
			}
			else
			{
				pz[n] = P[n];
			}
		}

		TriState n_PZ = NOR13(pz);

		dac_latch2.set(NOR(P123, PICTURE), n_PCLK);
		TriState n_POUT = dac_latch2.nget();

		// Luminance Decoder

		TriState n_LU[4];
		n_LU[0] = NOT(NOR3(n_POUT, ppu->wire.n_LL[0], ppu->wire.n_LL[1]));
		n_LU[1] = NOT(NOR3(n_POUT, NOT(ppu->wire.n_LL[0]), ppu->wire.n_LL[1]));
		n_LU[2] = NOT(NOR3(n_POUT, ppu->wire.n_LL[0], NOT(ppu->wire.n_LL[1])));
		n_LU[3] = NOT(NOR3(n_POUT, NOT(ppu->wire.n_LL[0]), NOT(ppu->wire.n_LL[1])));

		// Emphasis

		TriState n[3];
		n[0] = NOR3(n_POUT, n_PB, ppu->wire.n_TB);
		n[1] = NOR3(n_POUT, n_PG, ppu->wire.n_TG);
		n[2] = NOR3(n_POUT, n_PR, ppu->wire.n_TR);
		TriState TINT = NOT(NOR3(n[0], n[1], n[2]));

		// DAC
		// The lower level wins.

		TriState tmp = TriState::Zero;
		size_t L = 15;

		dac_latch1.set(NOT(SYNC), n_PCLK);
		dac_latch3.set(NOT(NOR3(NOR(P123, PICTURE), SYNC, BURST)), n_PCLK);
		dac_latch4.set(BURST, n_PCLK);

		if (dac_latch1.nget() == TriState::One && L > 0)
		{
			L = 0;
		}

		if (dac_latch3.nget() == TriState::One && L > 3)
		{
			L = 3;
		}

		tmp = NOR(dac_latch4.nget(), n_PZ);
		if (tmp == TriState::One && L > 4)
		{
			L = 4;
		}

		tmp = NOR(tmp, dac_latch4.nget());
		if (tmp == TriState::One && L > 1)
		{
			L = 1;
		}

		if (TINT == TriState::One && L > 10)
		{
			L = 10;
		}

		// /LU3

		tmp = NOR(n_LU[3], n_PZ);
		if (tmp == TriState::One && L > 6)
		{
			L = 6;
		}

		tmp = NOR(n_LU[3], tmp);
		if (tmp == TriState::One && L > 2)
		{
			L = 2;
		}

		// /LU0

		tmp = NOR(n_LU[0], n_PZ);
		if (tmp == TriState::One && L > 9)
		{
			L = 9;
		}

		tmp = NOR(n_LU[0], tmp);
		if (tmp == TriState::One && L > 8)
		{
			L = 8;
		}

		// /LU2

		tmp = NOR(n_LU[2], n_PZ);
		if (tmp == TriState::One && L > 7)
		{
			L = 7;
		}

		tmp = NOR(n_LU[2], tmp);
		if (tmp == TriState::One && L > 3)
		{
			L = 3;
		}

		// /LU1

		tmp = NOR(n_LU[1], n_PZ);
		if (tmp == TriState::One && L > 9)
		{
			L = 9;
		}

		tmp = NOR(n_LU[1], tmp);
		if (tmp == TriState::One && L > 5)
		{
			L = 5;
		}

		if (vout != nullptr)
		{
			*vout = LToV[L];
		}
	}

	void VideoOutSRBit::sim(TriState shift_in)
	{
		latch1.set(shift_in, ppu->wire.CLK);
		latch2.set(getn_Out(), ppu->wire.n_CLK);
	}

	TriState VideoOutSRBit::getn_Out()
	{
		return NOR(latch1.get(), ppu->wire.RES);
	}

	TriState VideoOutSRBit::getn_ShiftOut()
	{
		return latch2.get();
	}

}
