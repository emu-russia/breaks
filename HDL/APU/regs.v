
module ApuRegsBlock(
	PHI1, 
	Addr_fromcore, Addr_frommux, RnW_fromcore, DBG_frompad, 
	n_R4018, n_R401A, n_R4015, W4002, W4001, W4005, W4006, W4008, W400A, W400B, W400E, W4013, W4012, W4010, W4014,
	n_R4019, W401A, W4003, W4007, W4004, W400C, W4000, W4015, W4011, W400F, n_R4017, n_R4016, W4016, W4017,
	n_DBGRD);

	input PHI1;

	// ⚠️ The APU registers address space is selected by the value of the CPU address bus (CPU_Ax). But the choice of register is made by the value of the address, which is formed at the address multiplexer of DMA-controller (signals A0-A4).

	input [15:0] Addr_fromcore;
	input [15:0] Addr_frommux;
	input RnW_fromcore;
	input DBG_frompad;

	output n_R4018;
	output n_R401A;
	output n_R4015;
	output W4002;
	output W4001;
	output W4005;
	output W4006;
	output W4008;
	output W400A;
	output W400B;
	output W400E;
	output W4013;
	output W4012;
	output W4010;
	output W4014;

	output n_R4019;
	output W401A;
	output W4003;
	output W4007;
	output W4004;
	output W400C;
	output W4000;
	output W4015;
	output W4011;
	output W400F;
	output n_R4017;
	output n_R4016;
	output W4016;
	output W4017;

	output n_DBGRD;

	wire [15:0] CpuA;
	assign CpuA = Addr_fromcore;

	wire nREGWR;
	nor (nREGWR, CpuA[5], CpuA[6], CpuA[7], CpuA[8], CpuA[9], CpuA[10], CpuA[11], CpuA[12], CpuA[13], ~CpuA[14], CpuA[15], RnW_fromcore);

	wire nREGRD;
	nor (nREGRD, CpuA[5], CpuA[6], CpuA[7], CpuA[8], CpuA[9], CpuA[10], CpuA[11], CpuA[12], CpuA[13], ~CpuA[14], CpuA[15], ~RnW_fromcore);

endmodule // RegsBlock
