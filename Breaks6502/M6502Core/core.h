#pragma once

namespace M6502Core
{
	class M6502;
}

// An external class that has access to all core internals. Use for unit testing.

namespace M6502CoreUnitTest
{
	class UnitTest;
}

#include "decoder.h"
#include "ir.h"
#include "predecode.h"
#include "extra_counter.h"
#include "interrupts.h"
#include "flags.h"

#include "regs_control.h"
#include "alu_control.h"
#include "bus_control.h"
#include "pc_control.h"
#include "dispatch.h"
#include "flags_control.h"
#include "branch_logic.h"
#include "random_logic.h"

#include "address_bus.h"
#include "regs.h"
#include "alu.h"
#include "pc.h"
#include "data_bus.h"

namespace M6502Core
{
	enum class InputPad
	{
		n_NMI = 0,
		n_IRQ,
		n_RES,
		PHI0,
		RDY,
		SO,
		Max,
	};

	enum class OutputPad
	{
		PHI1 = 0,
		PHI2,
		RnW,
		SYNC,
		Max,
	};

#pragma pack(push, 1)
	struct DebugInfo
	{
		// Regs & Buses

		uint8_t SB;
		uint8_t DB;
		uint8_t ADL;
		uint8_t ADH;

		uint8_t IR;
		uint8_t PD;
		uint8_t Y; 
		uint8_t X;
		uint8_t S;
		uint8_t AI;
		uint8_t BI;
		uint8_t ADD;
		uint8_t AC;
		uint8_t PCL;
		uint8_t PCH;
		uint8_t PCLS;
		uint8_t PCHS;
		uint8_t ABL;
		uint8_t ABH;
		uint8_t DL;
		uint8_t DOR;

		uint8_t C_OUT;
		uint8_t Z_OUT;
		uint8_t I_OUT;
		uint8_t D_OUT;
		uint8_t B_OUT;
		uint8_t V_OUT;
		uint8_t N_OUT;

		// Internals

		uint8_t n_PRDY;
		uint8_t n_NMIP;
		uint8_t n_IRQP;
		uint8_t RESP;
		uint8_t BRK6E;
		uint8_t BRK7;
		uint8_t DORES;
		uint8_t n_DONMI;
		uint8_t n_T2;
		uint8_t n_T3;
		uint8_t n_T4;
		uint8_t n_T5;
		uint8_t T0;
		uint8_t n_T0;
		uint8_t n_T1X;
		uint8_t Z_IR;
		uint8_t FETCH;
		uint8_t n_ready;
		uint8_t WR;
		uint8_t TRES2;
		uint8_t ACRL1;
		uint8_t ACRL2;
		uint8_t T1;
		uint8_t T5;
		uint8_t T6;
		uint8_t ENDS;
		uint8_t ENDX;
		uint8_t TRES1;
		uint8_t TRESX;
		uint8_t BRFW;
		uint8_t n_BRTAKEN;
		uint8_t ACR;
		uint8_t AVR;

		// Decoder

		uint8_t decoder_out[Decoder::outputs_count];

		// Control commands

		uint8_t Y_SB;
		uint8_t SB_Y;
		uint8_t X_SB;
		uint8_t SB_X;
		uint8_t S_ADL;
		uint8_t S_SB;
		uint8_t SB_S;
		uint8_t S_S;
		uint8_t NDB_ADD;
		uint8_t DB_ADD;
		uint8_t Z_ADD;
		uint8_t SB_ADD;
		uint8_t ADL_ADD;
		uint8_t ANDS;
		uint8_t EORS;
		uint8_t ORS;
		uint8_t SRS;
		uint8_t SUMS;
		uint8_t ADD_SB7;
		uint8_t ADD_SB06;
		uint8_t ADD_ADL;
		uint8_t SB_AC;
		uint8_t AC_SB;
		uint8_t AC_DB;
		uint8_t ADH_PCH;
		uint8_t PCH_PCH;
		uint8_t PCH_ADH;
		uint8_t PCH_DB;
		uint8_t ADL_PCL;
		uint8_t PCL_PCL;
		uint8_t PCL_ADL;
		uint8_t PCL_DB;
		uint8_t ADH_ABH;
		uint8_t ADL_ABL;
		uint8_t Z_ADL0;
		uint8_t Z_ADL1;
		uint8_t Z_ADL2;
		uint8_t Z_ADH0;
		uint8_t Z_ADH17;
		uint8_t SB_DB;
		uint8_t SB_ADH;
		uint8_t DL_ADL;
		uint8_t DL_ADH;
		uint8_t DL_DB;

		uint8_t P_DB;
		uint8_t DB_P;
		uint8_t DBZ_Z;
		uint8_t DB_N;
		uint8_t IR5_C;
		uint8_t DB_C;
		uint8_t ACR_C;
		uint8_t IR5_D;
		uint8_t IR5_I;
		uint8_t DB_V;
		uint8_t AVR_V;
		uint8_t Z_V;

		uint8_t n_ACIN;
		uint8_t n_DAA;
		uint8_t n_DSA;
		uint8_t n_1PC;			// From Dispatcher
	};
#pragma pack(pop)

	struct UserRegs
	{
		uint8_t A;
		uint8_t X;
		uint8_t Y;
		uint8_t S;
		uint8_t C_OUT;
		uint8_t Z_OUT;
		uint8_t I_OUT;
		uint8_t D_OUT;
		uint8_t V_OUT;
		uint8_t N_OUT;
		uint8_t PCH;
		uint8_t PCL;
	};

	class M6502
	{
		friend M6502CoreUnitTest::UnitTest;
		friend IR;
		friend PreDecode;
		friend ExtraCounter;
		friend BRKProcessing;
		friend Dispatcher;
		friend RandomLogic;
		friend RegsControl;
		friend ALUControl;
		friend BusControl;
		friend PC_Control;
		friend FlagsControl;
		friend BranchLogic;
		friend AddressBus;
		friend Regs;
		friend Flags;
		friend ALU;
		friend ProgramCounter;
		friend DataBus;

		BaseLogic::FF nmip_ff;
		BaseLogic::FF irqp_ff;
		BaseLogic::FF resp_ff;
		BaseLogic::DLatch irqp_latch;
		BaseLogic::DLatch resp_latch;

		BaseLogic::DLatch prdy_latch1;
		BaseLogic::DLatch prdy_latch2;

		BaseLogic::DLatch rw_latch;

		uint8_t SB;
		uint8_t DB;
		uint8_t ADL;
		uint8_t ADH;

		bool SB_Dirty;
		bool DB_Dirty;
		bool ADL_Dirty;
		bool ADH_Dirty;

		Decoder* decoder = nullptr;
		PreDecode* predecode = nullptr;
		IR* ir = nullptr;
		ExtraCounter* ext = nullptr;
		BRKProcessing* brk = nullptr;
		Dispatcher* disp = nullptr;
		RandomLogic* random = nullptr;

		AddressBus* addr_bus = nullptr;
		Regs* regs = nullptr;
		ALU* alu = nullptr;
		ProgramCounter* pc = nullptr;
		DataBus* data_bus = nullptr;

		BaseLogic::TriState* decoder_out;
		size_t TxBits;		// Used to optimize table indexing

		void sim_Top(BaseLogic::TriState inputs[], uint8_t* data_bus);

		void sim_Bottom(BaseLogic::TriState inputs[], BaseLogic::TriState outputs[], uint16_t* addr_bus, uint8_t* data_bus);

		BaseLogic::TriState nNMI_Cache = BaseLogic::TriState::Z;
		BaseLogic::TriState nIRQ_Cache = BaseLogic::TriState::Z;
		BaseLogic::TriState nRES_Cache = BaseLogic::TriState::Z;

		bool HLE_Mode = false;		// Acceleration mode for fast applications. In this case we are cheating a little bit.

		/// <summary>
		/// Internal auxiliary and intermediate connections.
		/// </summary>
		struct InternalWires
		{
			BaseLogic::TriState n_NMI;
			BaseLogic::TriState n_IRQ;
			BaseLogic::TriState n_RES;
			BaseLogic::TriState PHI0;
			BaseLogic::TriState RDY;
			BaseLogic::TriState SO;
			BaseLogic::TriState PHI1;
			BaseLogic::TriState PHI2;
			BaseLogic::TriState n_PRDY;
			BaseLogic::TriState n_NMIP;
			BaseLogic::TriState n_IRQP;
			BaseLogic::TriState RESP;
			BaseLogic::TriState n_ready;
			BaseLogic::TriState T0;
			BaseLogic::TriState FETCH;
			BaseLogic::TriState Z_IR;
			BaseLogic::TriState ACRL1;
			BaseLogic::TriState ACRL2;
			BaseLogic::TriState n_T0;
			BaseLogic::TriState n_T1X;
			BaseLogic::TriState WR;
			BaseLogic::TriState T5;
			BaseLogic::TriState T6;
			BaseLogic::TriState n_1PC;
			BaseLogic::TriState ENDS;
			BaseLogic::TriState ENDX;
			BaseLogic::TriState TRES1;
			BaseLogic::TriState TRESX;
			BaseLogic::TriState n_T2;
			BaseLogic::TriState n_T3;
			BaseLogic::TriState n_T4;
			BaseLogic::TriState n_T5;
			BaseLogic::TriState n_IMPLIED;
			BaseLogic::TriState n_TWOCYCLE;
			BaseLogic::TriState BRK6E;
			BaseLogic::TriState BRK7;
			BaseLogic::TriState DORES;
			BaseLogic::TriState n_DONMI;
			BaseLogic::TriState BRK5_RDY;
			BaseLogic::TriState B_OUT;
			BaseLogic::TriState BRFW;
			BaseLogic::TriState n_BRTAKEN;
			BaseLogic::TriState PC_DB;
			BaseLogic::TriState n_ADL_PCL;
			BaseLogic::TriState n_IR5;
		} wire;

		/// <summary>
		/// Commands for bottom and flags.
		/// </summary>
		union RandomLogic_Output
		{
			struct {
				unsigned Y_SB : 1;
				unsigned SB_Y : 1;
				unsigned X_SB : 1;
				unsigned SB_X : 1;
				unsigned S_ADL : 1;
				unsigned S_SB : 1;
				unsigned SB_S : 1;
				unsigned S_S : 1;
				unsigned NDB_ADD : 1;
				unsigned DB_ADD : 1;
				unsigned Z_ADD : 1;
				unsigned SB_ADD : 1;
				unsigned ADL_ADD : 1;
				unsigned n_ACIN : 1;
				unsigned ANDS : 1;
				unsigned EORS : 1;
				unsigned ORS : 1;
				unsigned SRS : 1;
				unsigned SUMS : 1;
				unsigned n_DAA : 1;
				unsigned n_DSA : 1;
				unsigned ADD_SB7 : 1;
				unsigned ADD_SB06 : 1;
				unsigned ADD_ADL : 1;
				unsigned SB_AC : 1;
				unsigned AC_SB : 1;
				unsigned AC_DB : 1;
				unsigned ADH_PCH : 1;
				unsigned PCH_PCH : 1;
				unsigned PCH_ADH : 1;
				unsigned PCH_DB : 1;
				unsigned ADL_PCL : 1;
				unsigned PCL_PCL : 1;
				unsigned PCL_ADL : 1;
				unsigned PCL_DB : 1;
				unsigned ADH_ABH : 1;
				unsigned ADL_ABL : 1;
				unsigned Z_ADL0 : 1;
				unsigned Z_ADL1 : 1;
				unsigned Z_ADL2 : 1;
				unsigned Z_ADH0 : 1;
				unsigned Z_ADH17 : 1;
				unsigned SB_DB : 1;
				unsigned SB_ADH : 1;
				unsigned DL_ADL : 1;
				unsigned DL_ADH : 1;
				unsigned DL_DB : 1;

				unsigned P_DB : 1;
				unsigned DB_P : 1;
				unsigned DBZ_Z : 1;
				unsigned DB_N : 1;
				unsigned IR5_C : 1;
				unsigned DB_C : 1;
				unsigned ACR_C : 1;
				unsigned IR5_D : 1;
				unsigned IR5_I : 1;
				unsigned DB_V : 1;
				unsigned AVR_V : 1;
				unsigned Z_V : 1;
			};
			uint64_t raw;
		} cmd;

	public:
		M6502(bool HLE, bool BCD_Hack);
		~M6502();

		void sim(BaseLogic::TriState inputs[], BaseLogic::TriState outputs[], uint16_t *addr_bus, uint8_t* data_bus);

		void getDebug(DebugInfo* info);

		void getUserRegs(UserRegs* userRegs);
	};
}
