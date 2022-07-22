// The logic next to the terminal pads.

module PadsLogic(
	n_NMI, n_IRQ, n_RES, n_NMIP, n_IRQP, RESP, 
	RDY, RDY_frompad, n_PRDY, 
	T1_topad, SYNC, SO, SO_frompad,
	WR_topad, RnW);

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

endmodule // PadsLogic
