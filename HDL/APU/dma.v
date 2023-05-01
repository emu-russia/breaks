// Sprite DMA

// This component acts as a small DMA controller, which besides sprite DMA also handles address bus arbitration and processor readiness control (RDY).

module Sprite_DMA(
	ACLK1, nACLK2, PHI1,
	RES, RnW, W4014, DB, 
	RUNDMC, n_DMCAB, DMCRDY, DMC_Addr, CPU_Addr,
	Addr, RDY_tocore, SPR_PPU);

	input ACLK1;
	input nACLK2;
	input PHI1;					// Sprite DMA can only start if the processor goes into a read cycle (PHI1 = 0 and R/W = 1)
								// This is done to delay the start of the DMA because the RDY clearing is ignored on the 6502 write cycles.

	input RES;
	input RnW;
	input W4014;				// Writing to register $4014 clears the lower part of the address and puts the value to be written into the higher part. The DMA process then starts.
	inout [7:0] DB;

	input RUNDMC;				// As long as the RUNDMC signal is 1 the sprite DMA is in standby mode
	input n_DMCAB;				// The address bus is controlled by the DMC circuitry to perform DMC DMA
	input DMCRDY;				// DMC Ready. If the DMC is not ready - the RDY signal is also forced to 0.
	input [15:0] DMC_Addr;
	input [15:0] CPU_Addr;

	output [15:0] Addr;
	output RDY_tocore;
	output SPR_PPU;				// A constant address value is set for writing to the PPU register $2004

	wire SPRDmaEnd;				// End DMA execution ("End")
	wire SPRDmaStep;			// Increment the low-order part of the address ("Step")
	wire [15:0] SPR_Addr;
	wire SPR_CPU;				// Memory address to read during sprite DMA

	SPRDMA_AddrLowCounter dma_addr_low (
		.ACLK1(ACLK1),
		.Clear(RES),
		.Step(SPRDmaStep),
		.Load(W4014),
		.EndCount(SPRDmaEnd),
		.AddrLow(SPR_Addr[7:0]) );

	SPRDMA_AddrHigh dma_addr_high (
		.ACLK1(ACLK1),
		.SetAddr(W4014),
		.DB(DB),
		.AddrHigh(SPR_Addr[15:8]) );

	SPRDMA_Control sprdma_ctl (
		.PHI1(PHI1),
		.RnW(RnW),
		.ACLK1(ACLK1), 
		.nACLK2(nACLK2),
		.RES(RES),
		.W4014(W4014),
		.RUNDMC(RUNDMC),
		.DMCReady(DMCRDY),
		.SPRE(SPRDmaEnd),
		.SPRS(SPRDmaStep),
		.RDY(RDY_tocore),
		.SPR_PPU(SPR_PPU),
		.SPR_CPU(SPR_CPU) );

	Address_MUX addr_mux (
		.SPR_CPU(SPR_CPU),
		.SPR_PPU(SPR_PPU),
		.n_DMCAB(n_DMCAB),
		.DMC_Addr(DMC_Addr),
		.SPR_Addr(SPR_Addr),
		.CPU_Addr(CPU_Addr),
		.AddrOut(Addr) );

endmodule // Sprite_DMA

module SPRDMA_AddrLowCounter(ACLK1, Clear, Step, Load, EndCount, AddrLow);

	input ACLK1;
	input Clear;
	input Step;
	input Load;
	output EndCount;
	output [7:0] AddrLow;

	wire [7:0] cc; 		// Carry chain

	CounterBit cnt [7:0] (
		.ACLK1(ACLK1),
		.clear(Clear),
		.step(Step),
		.load(Load),
		.cin({cc[6:0], 1'b1}),
		.d(8'h00),
		.q(AddrLow),
		.cout(cc) );

	assign EndCount = cc[7];

endmodule // SPRDMA_AddrLowCounter

module SPRDMA_AddrHigh(ACLK1, SetAddr, DB, AddrHigh);

	input ACLK1;
	input SetAddr;
	inout [7:0] DB;
	output [7:0] AddrHigh;

	RegisterBit val_hi [7:0] (
		.d(DB),
		.ena(SetAddr),
		.ACLK1(ACLK1),
		.q(AddrHigh) );

endmodule // SPRDMA_AddrHigh

module SPRDMA_Control(PHI1, RnW, ACLK1, nACLK2, RES, W4014, RUNDMC, DMCReady, SPRE, SPRS, RDY, SPR_PPU, SPR_CPU);

	input PHI1;
	input RnW;
	input ACLK1;
	input nACLK2;
	input RES;
	input W4014;
	
	input RUNDMC;
	input DMCReady;

	input SPRE;
	output SPRS;

	output RDY;
	output SPR_PPU;			// DMA Buffer -> PPU
	output SPR_CPU;			// RAM -> DMA Buffer

	wire ACLK2 = ~ACLK2;
	wire NOSPR;
	wire DOSPR;
	wire spre_out;
	wire dospr_out;
	wire StopDma;
	wire StartDma;
	wire n_StartDma;
	wire toggle;

	nor (SPRS, NOSPR, RUNDMC, ~ACLK2);

	dlatch spre_latch (.d(SPRE), .en(ACLK1), .q(spre_out) );
	dlatch nospr_latch (.d(StopDma), .en(ACLK1), .nq(NOSPR) );
	dlatch dospr_latch (.d(n_StartDma), .en(ACLK2), .q(dospr_out) );

	rsff_2_3 StopDMA (.res1(SPRS & spre_out), .res2(RES), .s(DOSPR), .q(StopDma) );
	rsff_2_3 StartDMA (.res1(~NOSPR), .res2(RES), .s(W4014), .q(StartDma), .nq(n_StartDma) );
	rsff DMADirToggle (.r(ACLK1), .s(ACLK2), .q(toggle) );

	nor(SPR_PPU, NOSPR, RUNDMC, ~toggle);
	nor(SPR_CPU, NOSPR, RUNDMC, toggle);

	// Ready control

	wire sprdma_rdy;
	nor (sprdma_rdy, ~NOSPR, StartDma);
	assign RDY = sprdma_rdy & DMCReady; 		// -> to core

	// 6502 read cycle detect

	wire read_cyc;
	nand (read_cyc, ~PHI1, RnW);
	nor (DOSPR, dospr_out, read_cyc);

endmodule // SPRDMA_Control

module Address_MUX(SPR_CPU, SPR_PPU, n_DMCAB, DMC_Addr, SPR_Addr, CPU_Addr, AddrOut);

	input SPR_CPU;
	input SPR_PPU;
	input n_DMCAB;
	input [15:0] DMC_Addr;
	input [15:0] SPR_Addr;
	input [15:0] CPU_Addr;
	output [15:0] AddrOut;

	wire DMC_AB = ~n_DMCAB;

	wire CPU_AB;
	nor (CPU_AB, SPR_CPU, SPR_PPU, DMC_AB);

	assign AddrOut = SPR_PPU ? 16'h2004 : 
		(SPR_CPU ? SPR_Addr :
			(DMC_AB ? DMC_Addr :
				(CPU_AB ? CPU_Addr : 16'hzzzz) ) );

endmodule // Address_MUX
