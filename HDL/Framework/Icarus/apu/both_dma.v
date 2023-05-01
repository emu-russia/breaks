// Mixed OAM DMA + DPCM DMA Test.

//⚠️ To avoid confusion please keep in mind that this test does NOT use a real processor. Therefore all register write signals ("RegOps") and R/W of the processor are manually adjusted.

// 17.01.2023: added a second OAM DMA, which starts on an unaligned PHI relative to ACLK1, so it has one Waste cycle 

`timescale 1ns/1ns

`define CoreCyclesPerCLK 12
`define SampleAddr 16'hf000 		// The starting address of the buffer with DPCM samples in 6502 Plain memory.

module OAM_DMA_With_DPCM_Run ();

	reg CLK;
	reg RES;
	wire PHI1;
	reg RnW; 		// From "core". When a write to the APU registers is simulated the R/W of the processor is also set to Write Mode (R/W = 0)
	wire nACLK2;
	wire ACLK1;

	reg W4010;
	reg W4011;
	reg W4012;
	reg W4013;
	reg W4014;
	reg W4015;	
	reg n_R4015;
	wire SPR_PPU;		// 1: A constant address value is set for writing to the PPU register $2004
	wire RDY;

	wire WR;		// 1: External dbus write enable
	wire RD;		// 1: External dbus read enable

	wire [7:0] DataBus; 		// Internal databus
	wire [15:0] Addr; 		// Address from DMA multiplexer (external addrbus)

	wire n_DMCAB;			// 0: Gain control of the address bus to read the DPCM sample
	wire RUNDMC;			// 1: DMC is minding its own business and hijacks DMA control
	wire DMCRDY;			// 1: DMC Ready. Used to control processor readiness (RDY)
	wire DMCINT;			// 1: DMC interrupt is active

	wire [15:0] DMC_Addr;		// Address for reading the DPCM sample
	wire [6:0] DMC_Out;		// Output value for DAC	

	wire [15:0] CPU_Addr;

	// Tune CLK/ACLK timing according to 2A03
	always #23.28 CLK = ~CLK;

	AclkGenStandalone aclk (.CLK(CLK), .RES(RES), .PHI1(PHI1), .nACLK2(nACLK2), .ACLK1(ACLK1) );

	Sprite_DMA dma (
		.ACLK1(ACLK1), .nACLK2(nACLK2), .PHI1(PHI1),
		.RES(RES), .RnW(RnW), .W4014(W4014), .DB(DataBus), 
		.RUNDMC(RUNDMC), .n_DMCAB(n_DMCAB), .DMCRDY(DMCRDY), .DMC_Addr(DMC_Addr), .CPU_Addr(CPU_Addr),
		.Addr(Addr), .RDY_tocore(RDY), .SPR_PPU(SPR_PPU) );

	DMABuffer dmabuf (.PHI2(~PHI1), .SPR_PPU(SPR_PPU), .DB(DataBus), .RnW_fromcore(RnW), .n_R4015(n_R4015), .n_DBGRD(1'b1), .WR_topad(WR), .RD_topad(RD) );

	BogusExternalMem mem (.addrbus(Addr), .databus(DataBus), .write_en(WR), .read_en(RD) );

	RegDriver dma_enabler (.PHI1(PHI1), .W4010(W4010), .W4012(W4012), .W4013(W4013), .W4014(W4014), .W4015(W4015), .DataBus(DataBus), .CPU_Addr(CPU_Addr) );

	DPCMChan dpcm (
		.PHI1(PHI1), .ACLK1(ACLK1), .nACLK2(nACLK2), 
		.RES(RES), .DB(DataBus), .RnW(RnW), .LOCK(1'b0),
		.W4010(W4010), .W4011(W4011), .W4012(W4012), .W4013(W4013), .W4015(W4015), .n_R4015(n_R4015), 
		.n_DMCAB(n_DMCAB), .RUNDMC(RUNDMC), .DMCRDY(DMCRDY), .DMCINT(DMCINT),
		.DMC_Addr(DMC_Addr), .DMC_Out(DMC_Out) );

	initial begin

		$dumpfile("both_dma.vcd");
		$dumpvars(0, dma);
		$dumpvars(1, dmabuf);
		$dumpvars(2, dpcm);
		$dumpvars(3, mem);
		$dumpvars(4, aclk);
		$dumpvars(5, dpcm.dpcm_ctrl);

		CLK <= 1'b0;
		RES <= 1'b0;
		RnW <= 1'b1;

		W4010 <= 1'b0;
		W4011 <= 1'b0;
		W4012 <= 1'b0;
		W4013 <= 1'b0;
		W4014 <= 1'b0;
		W4015 <= 1'b0;
		n_R4015 <= 1'b1;

		// Start DPCM DMA and run it for a while

		// For the correct simulation of registers by the processor, RegOps must be ON at PHI1=0, and R/W must be 0 whole cycle

		W4010 <= 1'b1;
		RnW <= 1'b0;		
		repeat (`CoreCyclesPerCLK + 1) @ (CLK);
		W4010 <= 1'b0;
		repeat (`CoreCyclesPerCLK) @ (CLK);

		W4012 <= 1'b1;
		RnW <= 1'b0;		
		repeat (`CoreCyclesPerCLK) @ (CLK);
		W4012 <= 1'b0;
		repeat (`CoreCyclesPerCLK) @ (CLK);

		W4013 <= 1'b1;
		RnW <= 1'b0;		
		repeat (`CoreCyclesPerCLK) @ (CLK);
		W4013 <= 1'b0;
		repeat (`CoreCyclesPerCLK) @ (CLK);

		W4015 <= 1'b1;
		RnW <= 1'b0;
		repeat (`CoreCyclesPerCLK) @ (CLK);
		W4015 <= 1'b0;
		repeat (`CoreCyclesPerCLK) @ (CLK);
		
		RnW <= 1'b1;
		repeat (32760) @ (negedge CLK);

		// Then suddenly the "processor" decides to start OAM DMA and further execution takes place in interleave mode

		// ** OAM DMA NO Delay **

		repeat (`CoreCyclesPerCLK) @ (CLK);
		RnW <= 1'b0;
		repeat (`CoreCyclesPerCLK) @ (CLK);
		W4014 <= 1'b1;		
		repeat (`CoreCyclesPerCLK) @ (CLK);
		W4014 <= 1'b0;

		// Free flight for a while..

		RnW <= 1'b1;
		repeat (32766) @ (negedge CLK);

		// ** OAM DMA YES Delay **

		// Add delay here so that the start of the OAM DMA is not aligned to ACLK1 and you get 1 Waste Cycle
		repeat (`CoreCyclesPerCLK) @ (CLK);
		repeat (`CoreCyclesPerCLK) @ (CLK);

		repeat (`CoreCyclesPerCLK) @ (CLK);
		RnW <= 1'b0;
		repeat (`CoreCyclesPerCLK) @ (CLK);
		W4014 <= 1'b1;		
		repeat (`CoreCyclesPerCLK) @ (CLK);
		W4014 <= 1'b0;

		// Free flight for a while..

		RnW <= 1'b1;
		repeat (32768) @ (posedge CLK);

		$finish;
	end

endmodule // OAM_DMA_With_DPCM_Run

// This module executes a "program" sequence of writes to the OAMDMA/DPCM registers
module RegDriver (PHI1, W4010, W4012, W4013, W4014, W4015, DataBus, CPU_Addr);

	input PHI1;
	input W4010;
	input W4012;
	input W4013;
	input W4014;
	input W4015;
	inout [7:0] DataBus;
	output [15:0] CPU_Addr;

	// OAM Dma:
	// $4014 = 0x200

	// DPCM Dma:
	//LDA #$E
	//STA $4010
	//LDA #$C0
	//STA $4012
	//LDA #$FF
	//STA $4013
	//LDA #$F
	//STA $4015
	//LDA #$1F
	//STA $4015

	// All register operations are activated when PHI1 = 0 (6502 "Set Addr and R/W Mode")

	assign DataBus = ~PHI1 ? (W4014 ? 8'h2 : (W4010 ? 8'h0E : (W4012 ? 8'hC0 : (W4013 ? 8'hFF : (W4015 ? 8'h1F : 8'hzz))))) : 8'hzz;

	assign CPU_Addr = W4010 ? 16'h4010 : (W4012 ? 16'h4012 : (W4013 ? 16'h4013 : (W4014 ? 16'h4014 : (W4015 ? 16'h4015 : 16'h0))));

endmodule // RegDriver

// Module for simulating the outside world (WRAM + PPU etc.)
module BogusExternalMem (addrbus, databus, write_en, read_en);

	input [15:0] addrbus; 	// address bus
	inout [7:0] databus; 	// data bus
	input write_en;			// Ignored. As if the data went to the PPU	
	input read_en;			// 1: read mode

	wire wram_cs;
	wire rom_cs;
	assign wram_cs = addrbus < 16'h800;
	assign rom_cs = addrbus[15];

	reg [7:0] mem [0:65535];
	reg [7:0] temp_data;

	initial begin
		$readmemh("dpcm_sample.mem", mem, `SampleAddr);
		temp_data <= 8'h0;
	end

	always @ (posedge rom_cs) begin
		if (read_en && rom_cs)
			temp_data <= mem[addrbus];
	end

	// For DPCM return real samples. For OAM DMA return just 0xAA (bogus)
	assign databus = read_en ? (rom_cs ? temp_data : (wram_cs ? 8'haa : 'hz)) : 'hz;

endmodule // BogusExternalMem
