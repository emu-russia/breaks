
module Core(
	core_PHI0, core_PHI1, core_PHI2,
	core_nNMI, core_nIRQ, core_nRES, core_RDY, 
	core_SO, core_RnW, core_SYNC, core_DPads, core_APads);

	input core_PHI0;
	output core_PHI1;
	output core_PHI2;

	input core_nNMI;
	input core_nIRQ;
	input core_nRES;
	input core_RDY;

	input core_SO;
	output core_RnW;
	output core_SYNC;
	inout [7:0] core_DPads;
	output [15:0] core_APads;

	Core6502 embedded_6502 (
		.n_NMI(core_nNMI),
		.n_IRQ(core_nIRQ),
		.n_RES(core_nRES),
		.PHI0(core_PHI0),
		.PHI1(core_PHI1),
		.PHI2(core_PHI2),
		.RDY(core_RDY),
		.SO(core_SO),
		.RnW(core_RnW),
		.SYNC(core_SYNC),
		.A(core_APads),
		.D(core_DPads) );

endmodule // Core
