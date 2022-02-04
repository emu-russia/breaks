#pragma once

namespace M6502Core
{
	class ALU
	{
		uint8_t AI;
		uint8_t BI;
		uint8_t n_ADD;
		uint8_t AC;

		BaseLogic::DLatch BC7_latch;
		BaseLogic::DLatch DC7_latch;

		BaseLogic::DLatch daal_latch;
		BaseLogic::DLatch daah_latch;
		BaseLogic::DLatch dsal_latch;
		BaseLogic::DLatch dsah_latch;

		BaseLogic::DLatch DCLatch;
		BaseLogic::DLatch ACLatch;
		BaseLogic::DLatch AVRLatch;

		bool BCD_Hack = false;		// BCD correction hack for NES/Famicom.

		M6502* core = nullptr;

	public:

		ALU(M6502* parent) { core = parent; }

		void sim_Load();

		void sim();

		void sim_HLE();

		void sim_StoreADD();

		void sim_StoreAC();

		void sim_BusMux();

		BaseLogic::TriState getACR();

		BaseLogic::TriState getAVR();

		uint8_t getAI();
		uint8_t getBI();
		uint8_t getADD();
		uint8_t getAC();

		void SetBCDHack(bool enable) { BCD_Hack = enable; }
	};
}
