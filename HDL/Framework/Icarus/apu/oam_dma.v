// Test OAM DMA.

// Nothing complicated, just start OAM DMA from a fixed WRAM address and look at the waves.

// The APU dma+dmabuf and the ACLK generator are external modules (oddly enough the DMA is clocked using ACLK; PHI1 is only used to delay core Read Cycle detection)

//⚠️ To avoid confusion please keep in mind that this test does NOT use a real processor. Therefore all register write signals ("RegOps") and R/W of the processor are manually adjusted.

// 17.01.2023: added a second OAM DMA, which starts on an unaligned PHI relative to ACLK1, so it has one Waste cycle 

`timescale 1ns/1ns

`define CoreCyclesPerCLK 12

module OAM_DMA_Run();

	reg CLK;
	reg RES;
	wire PHI1;
	reg RnW; 		// From "core". When a write to the APU registers is simulated the R/W of the processor is also set to Write Mode (R/W = 0)
	wire ACLK1;
	wire nACLK2;

	reg W4014;
	reg n_R4015;
	wire SPR_PPU;		// 1: A constant address value is set for writing to the PPU register $2004
	wire RDY;

	wire WR;		// 1: External dbus write enable
	wire RD;		// 1: External dbus read enable

	wire [7:0] DataBus; 		// Internal databus
	wire [15:0] Addr; 		// Address from DMA multiplexer (external addrbus)

	// Tune CLK/ACLK timing according to 2A03
	always #23.28 CLK = ~CLK;

	AclkGenStandalone aclk (.CLK(CLK), .RES(RES), .PHI1(PHI1), .nACLK2(nACLK2), .ACLK1(ACLK1) );

	Sprite_DMA dma (
		.ACLK1(ACLK1), .nACLK2(nACLK2), .PHI1(PHI1),
		.RES(RES), .RnW(RnW), .W4014(W4014), .DB(DataBus), 
		.RUNDMC(1'b0), .n_DMCAB(1'b1), .DMCRDY(1'b1), .DMC_Addr(16'h0), .CPU_Addr(16'h0),
		.Addr(Addr), .RDY_tocore(RDY), .SPR_PPU(SPR_PPU) );

	DMABuffer dmabuf (.PHI2(~PHI1), .SPR_PPU(SPR_PPU), .DB(DataBus), .RnW_fromcore(RnW), .n_R4015(n_R4015), .n_DBGRD(1'b1), .WR_topad(WR), .RD_topad(RD) );

	BogusExternalMem mem (.addrbus(Addr), .databus(DataBus), .write_en(WR), .read_en(RD) );

	RegDriver dma_enabler (.W4014(W4014), .DB(DataBus));

	initial begin

		$dumpfile("oam_dma.vcd");
		$dumpvars(0, dma);
		$dumpvars(1, dmabuf);
		$dumpvars(2, mem);
		$dumpvars(3, aclk);

		CLK <= 1'b0;
		RES <= 1'b0;
		RnW <= 1'b1;

		W4014 <= 1'b0;
		n_R4015 <= 1'b1;

		// Some idle time

		repeat (16 * `CoreCyclesPerCLK) @ (CLK);

		// Start OAM DMA

		// ** OAM DMA NO Delay **

		repeat (`CoreCyclesPerCLK) @ (CLK);
		RnW <= 1'b0;
		repeat (`CoreCyclesPerCLK) @ (CLK);
		W4014 <= 1'b1;		
		repeat (`CoreCyclesPerCLK) @ (CLK);
		W4014 <= 1'b0;

		// Free flight for a while..

		RnW <= 1'b1;
		repeat (32743) @ (negedge CLK);

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

endmodule // OAM_DMA_Run

// Module for simulating the outside world (WRAM + PPU etc.)
module BogusExternalMem (addrbus, databus, write_en, read_en);

	input [15:0] addrbus;
	inout [7:0] databus;
	input write_en;			// Ignored. As if the data went to the PPU
	input read_en;

	reg [7:0] temp_data;

	initial begin
		temp_data <= 8'haa;
	end

	always @ (posedge read_en) begin
		if (read_en)
			temp_data <= ~temp_data; 		// Just complementary to change the value to be seen. Nothing to do with the sprite format.
	end

	assign databus = read_en ? temp_data : 'hz;

endmodule // BogusExternalMem

// We need someone to set the starting address of the DMA (DB)
module RegDriver (W4014, DB);

	input W4014;
	inout [7:0] DB;

	assign DB = W4014 ? 8'h2 : 8'hz; 	// oam dma address = 0x200

endmodule // RegDriver
