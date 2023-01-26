
module HVCounters (
	n_PCLK, PCLK,
	RES, HC, VC, V_IN,
	H_out, V_out);

	input n_PCLK;
	input PCLK;

	input RES;
	input HC;
	input VC;
	input V_IN;

	output [8:0] H_out;
	output [8:0] V_out;

	// Wires

	wire [8:0] n_h;
	wire [8:0] n_v;
	wire [8:0] hc;
	wire [8:0] vc;

	wire half_hc;
	wire half_vc;

	// Instances

	// The counters use some attempt to speed up the carry propagation, but a questionable one.
	// Without these tweaks carry_in looks the usual way: {carry_chain[7:0], Carry_in}   (9-bit counter)

	HVCounterBit hcnt [8:0] (.PCLK(PCLK), .n_PCLK(n_PCLK), .CLR(HC), .RES(RES),
		.cin({hc[7:5],half_hc,hc[3:0],1'b1}),
		.val(H_out), .n_val(n_h), .cout(hc) );

	assign half_hc = ~(n_h[0] | n_h[1] | n_h[2] | n_h[3] | n_h[4]);

	HVCounterBit vcnt [8:0] (.PCLK(PCLK), .n_PCLK(n_PCLK), .CLR(VC), .RES(RES),
		.cin({vc[7:5],half_vc,vc[3:0],V_IN}),
		.val(V_out), .n_val(n_v), .cout(vc) );

	assign half_vc = ~(~V_IN | n_v[0] | n_v[1] | n_v[2] | n_v[3] | n_v[4]);

endmodule // HVCounters

module HVCounterBit (PCLK, n_PCLK, CLR, RES, cin, val, n_val, cout);

	input PCLK;
	input n_PCLK;
	input CLR;
	input RES;
	input cin;
	output val;
	output n_val;
	output cout;

	wire keep_latch_q;

	dlatch keep_latch (.d(cin ? val : n_val), .en(n_PCLK), .q(keep_latch_q) );
	dlatch out_latch (.d(PCLK ? ~(keep_latch_q | CLR) : val), .en(1'b1), .nq(n_val) );

	assign val = ~(n_val | RES);
	assign cout = ~(n_val | ~cin);

endmodule // HVCounterBit
