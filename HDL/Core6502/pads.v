// The logic next to the terminal pads.

module PadsLogic(
	PHI1, PHI2,
	n_NMI, n_IRQ, n_RES, n_NMIP, n_IRQP, RESP, 
	RDY, RDY_frompad, n_PRDY, 
	T1_topad, SYNC, SO, SO_frompad,
	WR_topad, RnW);

	input PHI1;
	input PHI2;
	input n_NMI;
	input n_IRQ; 
	input n_RES; 
	output n_NMIP;
	output n_IRQP; 
	output RESP;
	
	input RDY;
	output RDY_frompad;
	output n_PRDY;

	input T1_topad;
	output SYNC;

	input SO;
	output SO_frompad;

	input WR_topad;
	output RnW;

	// Implementation of logic that is located around terminals (pads)

	// Interrupt pads
	// Input inverters can act as transparent latches (since the values of external interrupt signals can be `Z`),
	// but there's probably no point in doing that, they usually put pull-ups on the outside for them anyway. 

	wire nmip_ff_q;
	int_ff nmip_ff (.PHI2(PHI2), .d(~n_NMI), .q(nmip_ff_q));
	assign n_NMIP = ~nmip_ff_q;

	wire irqp_ff_q;
	int_ff irqp_ff (.PHI2(PHI2), .d(~n_IRQ), .q(irqp_ff_q));
	dlatch irqp_latch (.d(irqp_ff_q), .en(PHI1), .nq(n_IRQP));

	wire resp_ff_nq;	// !!!
	int_ff resp_ff (.PHI2(PHI2), .d(~n_RES), .nq(resp_ff_nq));
	dlatch resp_latch (.d(resp_ff_nq), .en(PHI1), .nq(RESP));

	// Others

	assign RDY_frompad = RDY;
	wire prdy_latch1_nq;
	dlatch prdy_latch1 (.d(~RDY), .en(PHI2), .nq(prdy_latch1_nq));
	dlatch prdy_latch2 (.d(prdy_latch1_nq), .en(PHI1), .nq(n_PRDY));

	buf (SYNC, T1_topad);

	wire so_latch1_nq;
	wire so_latch2_nq;
	wire so_latch3_q;
	dlatch so_latch1 (.d(~SO), .en(PHI1), .nq(so_latch1_nq));
	dlatch so_latch2 (.d(so_latch1_nq), .en(PHI2), .nq(so_latch2_nq));
	dlatch so_latch3 (.d(so_latch2_nq), .en(PHI1), .q(so_latch3_q));
	nor (SO_frompad, so_latch3_q, so_latch1_nq);

	dlatch rw_latch (.d(WR_topad), .en(PHI1), .nq(RnW));

endmodule // PadsLogic

// Implementation of flip-flops that are next to interrupt terminals (NMI/IRQ/RES)
module int_ff (PHI2, d, q, nq);

	input PHI2; 		// 1: enable (level-triggered)
	input d;
	output q;
	output nq;

	// Cycle of two AOI-21s
	wire g0_out;
	wire g1_out;
	aoi g0 (.a0(~d), .a1(PHI2), .b(g1_out), .x(g0_out));
	aoi g1 (.a0(d), .a1(PHI2), .b(g0_out), .x(g1_out));

	assign q = g0_out;
	assign nq = g1_out;

endmodule // int_ff
