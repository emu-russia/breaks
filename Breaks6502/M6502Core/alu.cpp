#include "pch.h"

using namespace BaseLogic;

namespace M6502Core
{
	void ALU::sim(TriState inputs[], TriState SB[], TriState DB[], TriState ADL[], TriState ADH[])
	{
		TriState PHI2 = inputs[(size_t)ALU_Input::PHI2];
		TriState NDB_ADD = inputs[(size_t)ALU_Input::NDB_ADD];
		TriState DB_ADD = inputs[(size_t)ALU_Input::DB_ADD];
		TriState Z_ADD = inputs[(size_t)ALU_Input::Z_ADD];
		TriState SB_ADD = inputs[(size_t)ALU_Input::SB_ADD];
		TriState ADL_ADD = inputs[(size_t)ALU_Input::ADL_ADD];
		TriState ADD_SB06 = inputs[(size_t)ALU_Input::ADD_SB06];
		TriState ADD_SB7 = inputs[(size_t)ALU_Input::ADD_SB7];
		TriState ADD_ADL = inputs[(size_t)ALU_Input::ADD_ADL];
		TriState ANDS = inputs[(size_t)ALU_Input::ANDS];
		TriState EORS = inputs[(size_t)ALU_Input::EORS];
		TriState ORS = inputs[(size_t)ALU_Input::ORS];
		TriState SRS = inputs[(size_t)ALU_Input::SRS];
		TriState SUMS = inputs[(size_t)ALU_Input::SUMS];
		TriState SB_AC = inputs[(size_t)ALU_Input::SB_AC];
		TriState AC_SB = inputs[(size_t)ALU_Input::AC_SB];
		TriState AC_DB = inputs[(size_t)ALU_Input::AC_DB];
		TriState SB_DB = inputs[(size_t)ALU_Input::SB_DB];
		TriState SB_ADH = inputs[(size_t)ALU_Input::SB_ADH];
		TriState Z_ADH0 = inputs[(size_t)ALU_Input::Z_ADH0];
		TriState Z_ADH17 = inputs[(size_t)ALU_Input::Z_ADH17];
		TriState n_ACIN = inputs[(size_t)ALU_Input::n_ACIN];
		TriState n_DAA = inputs[(size_t)ALU_Input::n_DAA];
		TriState n_DSA = inputs[(size_t)ALU_Input::n_DSA];


	}

	TriState ALU::getACR()
	{
		return TriState::Zero;	// TODO
	}

	TriState ALU::getAVR()
	{
		return TriState::Zero;	// TODO
	}

}
