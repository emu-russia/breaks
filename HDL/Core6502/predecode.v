
module PreDecode (
	PHI2,
	Z_IR,
	Data_bus, n_PD,
	n_IMPLIED, n_TWOCYCLE);

	input PHI2;

	input Z_IR;

	inout [7:0] Data_bus;
	output [7:0] n_PD;

	output n_IMPLIED;
	output n_TWOCYCLE;

	// Implementation

	wire [7:0] PD;
	wire [7:0] transp_latch_nq;
	wire [7:0] PD_latch_q;
	wire implied;
	wire tmp1;
	wire tmp2;
	wire tmp3;

	dlatch transp_latch [7:0] (.d(Data_bus), .en(1'b1), .nq(transp_latch_nq));
	dlatch PD_latch [7:0] (.d(transp_latch_nq), .en(PHI2), .q(PD_latch_q));
	pnor pd_nors [7:0] (.a0(PD_latch_q), .a1(Z_IR), .x(PD));

	assign n_PD = ~PD;

	nor (implied, PD[0], PD[2], n_PD[3]);
	nor (tmp1, PD[1], PD[4], PD[7]);
	nor (tmp2, n_PD[0], PD[2], n_PD[3], PD[4]);
	nor (tmp3, PD[0], PD[2], PD[3], PD[4], n_PD[7]);

	assign n_IMPLIED = ~implied;
	assign n_TWOCYCLE = ~((implied&~tmp1)|tmp2|tmp3);

endmodule // PreDecode
