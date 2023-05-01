// APU I/O interface.

// It is moved to a separate module so as not to be confused with the other pads.

module IOPorts(
	nACLK2, ACLK1, W4016, n_R4016, n_R4017, DB, RES, 
	OUT0_Pad, OUT1_Pad, OUT2_Pad, nIN0_Pad, nIN1_Pad);

	input nACLK2;
	input ACLK1;
	input W4016;
	input n_R4016;
	input n_R4017;
	inout [7:0] DB;
	input RES;

	output OUT0_Pad;
	output OUT1_Pad;
	output OUT2_Pad;
	output nIN0_Pad;
	output nIN1_Pad;

	wire [2:0] OUT_topad;
	wire [1:0] IN_topad;

	// The output value for pins /IN0-1 is the internal signals /R4016 and /R4017 from the register selector.

	assign IN_topad[0] = n_R4016;
	assign IN_topad[1] = n_R4017;

	OutPort out_ports [2:0] (
		.DB_bit(DB[2:0]),
		.W4016(W4016),
		.nACLK2(nACLK2),
		.ACLK1(ACLK1),
		.OUT_val(OUT_topad) );

	IOPad out_pads [2:0] (
		.bit_val(OUT_topad[2:0]),
		.res(RES),
		.pad({OUT2_Pad, OUT1_Pad, OUT0_Pad}) );

	IOPad in_pads [1:0] (
		.bit_val(IN_topad[1:0]),
		.res(RES),
		.pad({nIN1_Pad, nIN0_Pad}) );

endmodule // IOPorts

module OutPort(DB_bit, W4016, nACLK2, ACLK1, OUT_val);

	inout DB_bit;
	input W4016;
	input nACLK2;
	input ACLK1;
	output OUT_val;

	wire ff_out;
	wire ACLK5;

	assign ACLK5 = ~nACLK2;		// Other ACLK

	RegisterBit out_ff (
		.d(DB_bit),
		.ena(W4016),
		.ACLK1(ACLK1),
		.q(ff_out) );

	wire n_latch_out;

	dlatch out_latch (
		.d(ff_out),
		.en(ACLK5),
		.nq(n_latch_out) );

	assign OUT_val = ~n_latch_out;

endmodule // OutPort

module IOPad(bit_val, res, pad);

	input bit_val;
	input res;
	output pad;

	wire n1;
	nor (n1, bit_val, res);

	bustris io_tris(
		.a(n1),
		.n_x(pad),
		.n_en(res) );

endmodule // IOPad
