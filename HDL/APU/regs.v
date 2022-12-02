
module ApuRegsDecoder (
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

	// Check that the CPU address falls in the APU registers mapped to the address space.

	wire [15:0] CpuA;
	assign CpuA = Addr_fromcore;

	wire REGWR;
	wire nREGWR;
	nor (REGWR, CpuA[5], CpuA[6], CpuA[7], CpuA[8], CpuA[9], CpuA[10], CpuA[11], CpuA[12], CpuA[13], ~CpuA[14], CpuA[15], RnW_fromcore);
	assign nREGWR = ~REGWR;

	wire REGRD;
	wire nREGRD;
	nor (REGRD, CpuA[5], CpuA[6], CpuA[7], CpuA[8], CpuA[9], CpuA[10], CpuA[11], CpuA[12], CpuA[13], ~CpuA[14], CpuA[15], ~RnW_fromcore);
	assign nREGRD = ~REGRD;

	nand (n_DBGRD, DBG_frompad, ~nREGRD);

	// PLA

	wire [28:0] pla;

	ApuRegs_PLA regs_pla (
		.nREGRD(nREGRD),
		.nREGWR(nREGWR),
		.A(Addr_frommux[4:0]),
		.nA(~Addr_frommux[4:0]),
		.pla(pla) );

	// Select a register index.
	// Note that during PHI1 all write operations are disabled.

	nand(n_R4018, DBG_frompad, pla[0]);
	nand(n_R401A, DBG_frompad, pla[2]);
	not(n_R4015, pla[4]);
	nor(W4002, PHI1, ~pla[6]);
	nor(W4001, PHI1, ~pla[8]);
	nor(W4005, PHI1, ~pla[10]);
	nor(W4006, PHI1, ~pla[12]);
	nor(W4008, PHI1, ~pla[14]);
	nor(W400A, PHI1, ~pla[16]);
	nor(W400B, PHI1, ~pla[18]);
	nor(W400E, PHI1, ~pla[20]);
	nor(W4013, PHI1, ~pla[22]);
	nor(W4012, PHI1, ~pla[24]);
	nor(W4010, PHI1, ~pla[26]);
	nor(W4014, PHI1, ~pla[28]);

	nand(n_R4019, DBG_frompad, pla[1]);
	wire w401a_temp;
	nand (w401a_temp, DBG_frompad, pla[3]);
	nor(W401A, PHI1, w401a_temp);
	nor(W4003, PHI1, ~pla[5]);
	nor(W4007, PHI1, ~pla[7]);
	nor(W4004, PHI1, ~pla[9]);
	nor(W400C, PHI1, ~pla[11]);
	nor(W4000, PHI1, ~pla[13]);
	nor(W4015, PHI1, ~pla[15]);
	nor(W4011, PHI1, ~pla[17]);
	nor(W400F, PHI1, ~pla[19]);
	not(n_R4017, pla[21]);
	not(n_R4016, pla[23]);
	nor(W4016, PHI1, ~pla[25]);
	nor(W4017, PHI1, ~pla[27]);

endmodule // ApuRegsDecoder

module ApuRegs_PLA(nREGRD, nREGWR, A, nA, pla);

	input nREGRD;
	input nREGWR;
	input [4:0] A;
	input [4:0] nA;
	output [28:0] pla;

	nor (pla[0], nREGRD, A[0], A[1], A[2], nA[3], nA[4]);
	nor (pla[1], nREGRD, nA[0], A[1], A[2], nA[3], nA[4]);
	nor (pla[2], nREGRD, A[0], nA[1], A[2], nA[3], nA[4]);
	nor (pla[3], nREGWR, A[0], nA[1], A[2], nA[3], nA[4]);

	nor (pla[4], nREGRD, nA[0], A[1], nA[2], A[3], nA[4]);
	nor (pla[5], nREGWR, nA[0], nA[1], A[2], A[3], A[4]);
	nor (pla[6], nREGWR, A[0], nA[1], A[2], A[3], A[4]);
	nor (pla[7], nREGWR, nA[0], nA[1], nA[2], A[3], A[4]);
	nor (pla[8], nREGWR, nA[0], A[1], A[2], A[3], A[4]);

	nor (pla[9],  nREGWR, A[0], A[1], nA[2], A[3], A[4]);
	nor (pla[10], nREGWR, nA[0], A[1], nA[2], A[3], A[4]);
	nor (pla[11], nREGWR, A[0], A[1], nA[2], nA[3], A[4]);
	nor (pla[12], nREGWR, A[0], nA[1], nA[2], A[3], A[4]);
	nor (pla[13], nREGWR, A[0], A[1], A[2], A[3], A[4]);

	nor (pla[14], nREGWR, A[0], A[1], A[2], nA[3], A[4]);
	nor (pla[15], nREGWR, nA[0], A[1], nA[2], A[3], nA[4]);
	nor (pla[16], nREGWR, A[0], nA[1], A[2], nA[3], A[4]);
	nor (pla[17], nREGWR, nA[0], A[1], A[2], A[3], nA[4]);
	nor (pla[18], nREGWR, nA[0], nA[1], A[2], nA[3], A[4]);

	nor (pla[19], nREGWR, nA[0], nA[1], nA[2], nA[3], A[4]);
	nor (pla[20], nREGWR, A[0], nA[1], nA[2], nA[3], A[4]);
	nor (pla[21], nREGRD, nA[0], nA[1], nA[2], A[3], nA[4]);
	nor (pla[22], nREGWR, nA[0], nA[1], A[2], A[3], nA[4]);
	nor (pla[23], nREGRD, A[0], nA[1], nA[2], A[3], nA[4]);

	nor (pla[24], nREGWR, A[0], nA[1], A[2], A[3], nA[4]);
	nor (pla[25], nREGWR, A[0], nA[1], nA[2], A[3], nA[4]);
	nor (pla[26], nREGWR, A[0], A[1], A[2], A[3], nA[4]);
	nor (pla[27], nREGWR, nA[0], nA[1], nA[2], A[3], nA[4]);
	nor (pla[28], nREGWR, A[0], A[1], nA[2], A[3], nA[4]);

endmodule // ApuRegs_PLA
