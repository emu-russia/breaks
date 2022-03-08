#include "pch.h"

using namespace BaseLogic;

namespace PPUSim
{

	PPU::PPU(Revision _rev)
	{
		rev = _rev;
	}

	PPU::~PPU()
	{

	}

	void PPU::sim(TriState inputs[], TriState outputs[], uint8_t* ext, uint8_t* data_bus, uint8_t* ad_bus, uint8_t* addrHi_bus, float* vout)
	{

	}

}
