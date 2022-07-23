
module ApuPadsLogic(
	CLKPad, n_CLK_frompad,
	n_RESPad, RES_frompad,
	n_IRQPad, Timer_Int, n_IRQ_tocore,
	n_M2_topad, M2Pad,
	DBGPad, DBG_frompad,
	RD, WR, DB, DPads,
	RW_topad, RWPad,
	Addr_topad, APads);

	input CLKPad;
	output n_CLK_frompad;
	
	input n_RESPad;
	output RES_frompad;

	input n_IRQPad;
	input Timer_Int;
	output n_IRQ_tocore;

	input n_M2_topad;
	output M2Pad;

	input DBGPad;
	output DBG_frompad;

	input RD;
	input WR;
	inout [7:0] DB;
	inout [7:0] DPads;

	input RW_topad;
	output RWPad;

	input [15:0] Addr_topad;
	output [15:0] APads;

	not (RES_frompad, n_RESPad);

	wire [15:0] ax;
	for (i=0; i<16; i=i+1) begin
	   nor (ax[i], Addr_topad[i], RES_frompad);
	end
	bustris ax_tris [15:0] (
		.a(ax),
		.x(APads),
		.n_en(RES_frompad) );

	bustris dx_in [7:0] (
		.a(~DPads),
		.x(DB),
		.n_en(WR) );
	wire [7:0] dx;
	for (i =0; i<8; i=i+1) begin
	   nor (dx[i], DB[i], RD);
	end
	bustris dx_out [7:0] (
		.a(dx),
		.x(DPads),
		.n_en(RD) );

	wire rw;
	nor (rw, RW_topad, RES_frompad);
	bustris rw_tris (
		.a(rw),
		.x(RWPad),
		.n_en(RES_frompad) );

	not (n_CLK_frompad, CLKPad);

	assign DBG_frompad = DBGPad;

	wire nDBG;
	not (nDBG, DBG_frompad);

	wire NotDBG_RES;
	nor (NotDBG_RES, ~nDBG, ~RES_frompad);
	wire m2;
	nor (m2, n_M2_topad, NotDBG_RES);
	bustris m2_tris (
		.a(m2),
		.x(M2Pad),
		.n_en(NotDBG_RES) );

	nor (n_IRQ_tocore, ~n_IRQPad, Timer_Int);

endmodule // PadsLogic
