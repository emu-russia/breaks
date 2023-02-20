// APU Player on Verilog.

`timescale 1ns/1ns

module APUPlayer ();

	reg CLK;
	reg n_RES;
	wire M2;
	wire RnW;
	
	wire [7:0] AUX_A;
	wire [14:0] AUX_B;
	wire [31:0] AOut;
	wire [31:0] BOut;
	reg [23:0] AuxA_Addr;
	reg [23:0] AuxB_Addr;

	wire [15:0] AB;
	wire [7:0] DB;

	// Tune CLK/ACLK timing according to 2A03
	always #23.28 CLK = ~CLK;	

	APU apu (
		.AUX_A(AUX_A),
		.AUX_B(AUX_B),
		.n_RES(n_RES),
		.A(AB),
		.D(DB),
		.CLK(CLK),
		.DBG(1'b0),
		.M2(M2),
		.n_IRQ(1'b1),
		.n_NMI(1'b1),
		.RnW(RnW) );

	NES_WRAM wram (.M2(M2), .RnW(RnW), .n_RES(n_RES), .Addr(AB), .Data(DB));

	AUX aux (.AUX_A(AUX_A), .AUX_B(AUX_B), .AOut(AOut), .BOut(BOut) );

	// To avoid messing with float numbers, let's make a "stereo" dump

	AUX_Dumper auxa_dump (.addr(AuxA_Addr), .val(AOut));
	AUX_Dumper auxb_dump (.addr(AuxB_Addr), .val(BOut));

	always @(apu.PHI0) begin
		AuxA_Addr <= AuxA_Addr + 1;
		AuxB_Addr <= AuxB_Addr + 1;
	end

	initial begin

		$dumpfile("apu_player.vcd");
		$dumpvars(0, apu);
		$dumpvars(1, wram);
		$dumpvars(2, aux);
		$dumpvars(3, auxa_dump);
		$dumpvars(4, auxb_dump);

		CLK <= 1'b0;
		AuxA_Addr <= 0;
		AuxB_Addr <= 0;
		
		// Global reset

		n_RES <= 1'b0;
		repeat (2) @ (negedge CLK);
		n_RES <= 1'b1;

		// Continue

		repeat (32768) @ (posedge CLK);
		$finish;
	end

endmodule // APUPlayer

module NES_WRAM (M2, RnW, n_RES, Addr, Data);

	input M2;
	input RnW;
	input n_RES;
	input [15:0] Addr;
	inout [7:0] Data;

	wire wram_sel;

	assign wram_sel = ~| Addr[15:11];
	assign Data = (wram_sel & RnW) ? 8'b0 : 8'bz;

endmodule // NES_WRAM
