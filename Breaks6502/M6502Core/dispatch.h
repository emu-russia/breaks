#pragma once

namespace M6502Core
{
	enum class Dispatcher_Input
	{
		PHI1 = 0,
		PHI2,
		RDY,
		BRK6E,
		RESP,
		DORES,
		B_OUT,

		ACR,
		BRFW,
		n_BRTAKEN,
		n_TWOCYCLE,
		n_IMPLIED,
		PC_DB,
		n_ADL_PCL,
		Max,
	};

	enum class Dispatcher_Output
	{
		T0 = 0,
		n_T0,
		n_T1X,
		Z_IR,
		FETCH,
		n_ready,
		TRES2,

		ACRL2,
		T1,
		T5,
		T6,
		WR,
		n_1PC,
		Max,
	};

	class Dispatcher
	{
		BaseLogic::DLatch acr_latch1;
		BaseLogic::DLatch acr_latch2;
		BaseLogic::FF acrl_ff;

		BaseLogic::DLatch t56_latch;
		BaseLogic::DLatch t5_latch1;
		BaseLogic::DLatch t5_latch2;
		BaseLogic::DLatch t6_latch1;
		BaseLogic::DLatch t6_latch2;
		BaseLogic::FF t5_ff;
		
		BaseLogic::DLatch tres2_latch;
		BaseLogic::DLatch tresx_latch1;
		BaseLogic::DLatch tresx_latch2;

		BaseLogic::DLatch fetch_latch;
		BaseLogic::DLatch wr_latch;
		BaseLogic::DLatch ready_latch1;
		BaseLogic::DLatch ready_latch2;
		BaseLogic::FF rdy_ff;

		BaseLogic::DLatch ends_latch1;
		BaseLogic::DLatch ends_latch2;

		BaseLogic::DLatch nready_latch;
		BaseLogic::DLatch step_latch1;
		BaseLogic::DLatch step_latch2;
		BaseLogic::FF step_ff;
		BaseLogic::DLatch t1_latch;

		BaseLogic::DLatch comp_latch1;
		BaseLogic::DLatch comp_latch2;
		BaseLogic::DLatch comp_latch3;

		BaseLogic::DLatch t0_latch;
		BaseLogic::DLatch t1x_latch;
		BaseLogic::FF t0_ff;

		BaseLogic::DLatch br_latch1;
		BaseLogic::DLatch br_latch2;
		BaseLogic::DLatch ipc_latch1;
		BaseLogic::DLatch ipc_latch2;
		BaseLogic::DLatch ipc_latch3;

	public:
		
		void sim_BeforeDecoder(BaseLogic::TriState inputs[], BaseLogic::TriState outputs[]);

		void sim_AfterRandomLogic(BaseLogic::TriState inputs[], BaseLogic::TriState outputs[]);

		BaseLogic::TriState getTRES2();
	};
}
