// It looks a little sloppy, but if you'd seen the silicon, you'd understand why.

module ApuPadsLogic(
	CLKPad, n_CLK_frompad,
	n_RESPad, RES_frompad,
	n_IRQPad, Timer_Int, n_IRQ_tocore,
	n_M2_topad, M2Pad,
	DBGPad, DBG_frompad,
	RD, WR, DB, DPads,
	RW_topad, RWPad,
	Addr_topad, APads);

	input CLKPad;				// CLK Input Pad
	output n_CLK_frompad; 		// Output intermediate signal /CLK for divider
	input n_RESPad;				// Input Pad /RES
	output RES_frompad;			// Value from /RES pad (inverted for convenience)
	input n_IRQPad; 			// Input Pad /RES
	input Timer_Int; 			// Timer interrupt (combined with DMC interrupt)
	output n_IRQ_tocore; 		// Signal /IRQ for 6502 core
	input n_M2_topad;			// Output signal #M2 from the divider for pad M2
	output M2Pad;				// Input Pad /RES
	input DBGPad; 				// DBG Input Pad (2A03 Test Mode)
	output DBG_frompad; 		// Value from the DBG pad to the APU internals
	input RD; 					// Internal signal for data bus mode (read/write)
	input WR; 					// Internal signal for data bus mode (read/write)
	inout [7:0] DB;				// Internal data bus
	inout [7:0] DPads; 			// External data bus pads
	input RW_topad; 			// The value for the R/W pad (obtained in the ...mm...sprite DMA buffer)
	output RWPad; 				// Output Pad R/W
	input [15:0] Addr_topad; 	// Value for address bus pads
	output [15:0] APads;		// External address bus pads

	// Connect all

	not (RES_frompad, n_RESPad);

	wire [15:0] ax;
	pnor addr_out [15:0] (
		.a0(Addr_topad),
		.a1({16{RES_frompad}}),
		.x(ax) );
	bustris addr_tris [15:0] (
		.a(ax),
		.n_x(APads),
		.n_en(RES_frompad) );

	bustris data_tris_in [7:0] (
		.a(~DPads),
		.n_x(DB),
		.n_en(WR) );
	wire [7:0] dx;
	pnor data_out [7:0] (
		.a0(DB),
		.a1({8{RD}}),
		.x(dx) );    
	bustris data_tris_out [7:0] (
		.a(dx),
		.n_x(DPads),
		.n_en(RD) );

	wire rw;
	nor (rw, RW_topad, RES_frompad);
	bustris rw_tris (
		.a(rw),
		.n_x(RWPad),
		.n_en(RES_frompad) );

	not (n_CLK_frompad, CLKPad);

	assign DBG_frompad = DBGPad;

	wire nDBG;
	not (nDBG, DBG_frompad);

	wire NotDBG_RES;
	nor (NotDBG_RES, ~nDBG, ~RES_frompad);
	wire m2;
	nor (m2, n_M2_topad, NotDBG_RES);
	bufif0 (M2Pad, m2, NotDBG_RES);		// data_out, data_in, ctrl

	nor (n_IRQ_tocore, ~n_IRQPad, Timer_Int);

endmodule // PadsLogic
