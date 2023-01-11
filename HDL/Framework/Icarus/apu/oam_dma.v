// Test OAM DMA.

// Nothing complicated, just start OAM DMA from a fixed WRAM address and look at the waves.

// The APU dma+dmabuf and the ACLK generator are external modules (oddly enough the DMA is clocked using ACLK; PHI1 is only used to delay core Read Cycle detection)

`timescale 1ns/1ns

module OAM_DMA_Run();

	reg CLK;
	reg RES;
	wire PHI1;
	wire RnW; 		// From "core"
	wire ACLK;
	wire n_ACLK;

	reg W4014;
	reg n_R4015;
	wire SPR_PPU;		// 1: A constant address value is set for writing to the PPU register $2004
	wire RDY;

	wire WR;		// 1: External dbus write enable
	wire RD;		// 0: External dbus read enable

	wire [7:0] DataBus; 		// Internal databus
	wire [15:0] Addr; 		// Address from DMA multiplexer (external addrbus)

	// Tune CLK/ACLK timing according to 2A03
	always #23.28 CLK = ~CLK;

	AclkGenStandalone aclk (.CLK(CLK), .RES(RES), .PHI1(PHI1), .ACLK(ACLK), .n_ACLK(n_ACLK) );

	Sprite_DMA dma (
		.n_ACLK(n_ACLK), .ACLK(ACLK), .PHI1(PHI1),
		.RES(RES), .RnW(RnW), .W4014(W4014), .DB(DataBus), 
		.RUNDMC(1'b0), .n_DMCAB(1'b1), .DMCRDY(1'b1), .DMC_Addr(16'h0), .CPU_Addr(16'h0),
		.Addr(Addr), .RDY_tocore(RDY), .SPR_PPU(SPR_PPU) );

	DMABuffer dmabuf (.PHI2(~PHI1), .SPR_PPU(SPR_PPU), .DB(DataBus), .RnW_fromcore(RnW), .n_R4015(n_R4015), .n_DBGRD(1'b1), .WR_topad(WR), .RD_topad(RD) );

	BogusExternalMem mem (.addrbus(Addr), .databus(DataBus), .write_en(WR), .read_en(RD) );

	RegDriver dma_enabler (.W4014(W4014), .DB(DataBus));

	assign RnW = 1'b1; 		// Virtual CPU always Read Mode

	initial begin

		$dumpfile("oam_dma.vcd");
		$dumpvars(0, dma);
		$dumpvars(1, dmabuf);
		$dumpvars(2, mem);
		$dumpvars(3, aclk);

		CLK <= 1'b0;
		RES <= 1'b0;

		W4014 <= 1'b0;
		n_R4015 <= 1'b1;

		// Start OAM DMA

		W4014 <= 1'b1;
		repeat (1) @ (posedge CLK);
		W4014 <= 1'b0;

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
