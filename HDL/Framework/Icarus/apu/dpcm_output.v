// Test for playing a DPCM sample.

// From the APU only the ACLK generator and the DPCM channel itself are used.
// The DPCM samples are in the `dpcm_sample.mem` file and are loaded into a dummy memory device which is addressed by `DMC_Addr`.

`timescale 1ns/1ns

`define SampleAddr 16'hf000 		// The starting address of the buffer with DPCM samples in 6502 Plain memory.

module DPCMChan_Run();

	reg CLK;
	reg RES;
	wire PHI1;
	wire RnW;
	wire nACLK2;
	wire ACLK1;

	reg W4010;
	reg W4011;
	reg W4012;
	reg W4013;
	reg W4015;
	reg n_R4015;

	wire [7:0] DataBus;

	wire [31:0] AuxOut;

	wire n_DMCAB;			// 0: Gain control of the address bus to read the DPCM sample
	wire RUNDMC;			// 1: DMC is minding its own business and hijacks DMA control
	wire DMCRDY;			// 1: DMC Ready. Used to control processor readiness (RDY)
	wire DMCINT;			// 1: DMC interrupt is active

	wire [15:0] DMC_Addr;		// Address for reading the DPCM sample
	wire [6:0] DMC_Out;		// Output value for DAC

	// Tune CLK/ACLK timing according to 2A03
	always #23.28 CLK = ~CLK;

	AclkGenStandalone aclk (.CLK(CLK), .RES(RES), .PHI1(PHI1), .nACLK2(nACLK2), .ACLK1(ACLK1) );

	assign RnW = 1'b1;

	DPCMRegMaster reg_master (.W4010(W4010), .W4012(W4012), .W4013(W4013), .W4015(W4015), .DataBus(DataBus) );

	DPCMSampleMem mem (.addr(DMC_Addr), .data(DataBus), .ReadMode(~n_DMCAB));

	DPCMChan dpcm (
		.PHI1(PHI1), .ACLK1(ACLK1), .nACLK2(nACLK2), 
		.RES(RES), .DB(DataBus), .RnW(RnW), .LOCK(1'b0),
		.W4010(W4010), .W4011(W4011), .W4012(W4012), .W4013(W4013), .W4015(W4015), .n_R4015(n_R4015), 
		.n_DMCAB(n_DMCAB), .RUNDMC(RUNDMC), .DMCRDY(DMCRDY), .DMCINT(DMCINT),
		.DMC_Addr(DMC_Addr), .DMC_Out(DMC_Out) );

	AUX aux (.AUX_A(8'h00), .AUX_B({DMC_Out,8'h00}), .BOut(AuxOut) );

	initial begin

		$dumpfile("dpcm_output.vcd");
		$dumpvars(0, dpcm);
		$dumpvars(1, aclk);
		$dumpvars(2, AuxOut);

		CLK <= 1'b0;
		RES <= 1'b0;

		W4010 <= 1'b0;
		W4011 <= 1'b0;
		W4012 <= 1'b0;
		W4013 <= 1'b0;
		W4015 <= 1'b0;
		n_R4015 <= 1'b1;

		// Start DPCM Playback

		W4010 <= 1'b1;
		repeat (1) @ (posedge CLK);
		W4010 <= 1'b0;

		W4012 <= 1'b1;
		repeat (1) @ (posedge CLK);
		W4012 <= 1'b0;

		W4013 <= 1'b1;
		repeat (1) @ (posedge CLK);
		W4013 <= 1'b0;

		W4015 <= 1'b1;
		repeat (1) @ (posedge CLK);
		W4015 <= 1'b0;

		repeat (32768) @ (posedge CLK);
		$finish;
	end

endmodule // DPCMChan_Run

// This module executes a "program" sequence of writes to the DPCM registers
module DPCMRegMaster (W4010, W4012, W4013, W4015, DataBus);

	input W4010;
	input W4012;
	input W4013;
	input W4015;
	inout [7:0] DataBus;

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

	assign DataBus = W4010 ? 8'h0E : (W4012 ? 8'hC0 : (W4013 ? 8'hFF : (W4015 ? 8'h1F : 8'hzz)));

endmodule // DPCMRegMaster

module DPCMSampleMem (addr, data, ReadMode);

	input [15:0] addr; 	// address bus
	inout [7:0] data; 	// data bus
	input ReadMode;		// 1: read mode

	reg [7:0] mem [0:65535];
	reg [7:0] temp_data;

	initial begin
		$readmemh("dpcm_sample.mem", mem, `SampleAddr);
	end

	always @ (posedge ReadMode) begin
		if (ReadMode)
			temp_data <= mem[addr];
	end

	assign data = ReadMode ? temp_data : 'hz;

endmodule // DPCMSampleMem
