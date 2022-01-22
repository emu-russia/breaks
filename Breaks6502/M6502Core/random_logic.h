#pragma once

namespace M6502Core
{
	enum class RandomLogic_Output
	{
		Y_SB = 0,
		SB_Y,
		X_SB,
		SB_X,
		S_ADL,
		S_SB,
		SB_S,
		S_S,
		NDB_ADD,
		DB_ADD,
		Z_ADD,
		SB_ADD,
		ADL_ADD,
		n_ACIN,
		ANDS,
		EORS,
		ORS,
		SRS,
		SUMS,
		n_DAA,
		n_DSA,
		ADD_SB7,
		ADD_SB06,
		ADD_ADL,
		SB_AC,
		AC_SB,
		AC_DB,
		ADH_PCH,
		PCH_PCH,
		PCH_ADH,
		PCH_DB,
		ADL_PCL,
		PCL_PCL,
		PCL_ADL,
		PCL_DB,
		ADH_ABH,
		ADL_ABL,
		Z_ADL0,
		Z_ADL1,
		Z_ADL2,
		Z_ADH0,
		Z_ADH17,
		SB_DB,
		SB_ADH,
		DL_ADL,
		DL_ADH,
		DL_DB,

		P_DB,
		DB_P,
		DBZ_Z,
		DB_N,
		IR5_C,
		DB_C,
		ACR_C,
		IR5_D,
		IR5_I,
		DB_V,
		AVR_V,
		Z_V,

		Max,
	};

	class RandomLogic
	{
		M6502* core = nullptr;

	public:
		RegsControl* regs_control = nullptr;
		ALUControl* alu_control = nullptr;
		PC_Control* pc_control = nullptr;
		BusControl* bus_control = nullptr;
		FlagsControl* flags_control = nullptr;
		Flags* flags = nullptr;
		BranchLogic* branch_logic = nullptr;

		RandomLogic(M6502* parent);
		~RandomLogic();

		void sim(BaseLogic::TriState outputs[]);
	};
}
