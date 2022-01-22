#include "pch.h"

using namespace BaseLogic;

namespace M6502Core
{
	void AddressBus::sim_ConstGen()
	{
		bool Z_ADL0 = core->cmd.Z_ADL0;
		bool Z_ADL1 = core->cmd.Z_ADL1;
		bool Z_ADL2 = core->cmd.Z_ADL2;
		bool Z_ADH0 = core->cmd.Z_ADH0;
		bool Z_ADH17 = core->cmd.Z_ADH17;

		if (Z_ADL0)
		{
			core->ADL &= ~0b00000001;
		}

		if (Z_ADL1)
		{
			core->ADL &= ~0b00000010;
		}

		if (Z_ADL2)
		{
			core->ADL &= ~0b00000100;
		}

		if (Z_ADH0)
		{
			core->ADH &= ~0b00000001;
		}

		if (Z_ADH17)
		{
			core->ADH &= ~0b11111110;
		}
	}

	void AddressBus::sim_Output(uint16_t* addr_bus)
	{
		TriState PHI1 = core->wire.PHI1;
		TriState PHI2 = core->wire.PHI2;
		bool ADL_ABL = core->cmd.ADL_ABL;
		bool ADH_ABH = core->cmd.ADH_ABH;

		// The address bus is set during PHI1 only

		if (PHI1 == TriState::One && ADL_ABL)
		{
			ABL = core->ADL;
		}

		if (PHI1 == TriState::One && ADH_ABH)
		{
			ABH = core->ADH;
		}

		uint16_t addr = ((uint16_t)ABH << 8) | ABL;
		*addr_bus = addr;
	}

	uint8_t AddressBus::getABL()
	{
		return ABL;
	}

	uint8_t AddressBus::getABH()
	{
		return ABH;
	}
}
