
module LengthCounters(
	nACLK2, ACLK1,
	RES, DB, n_R4015, W4015, nLFO2, 
	W4003, W4007, W400B, W400F,
	SQA_LC, SQB_LC, TRI_LC, RND_LC,
	NOSQA, NOSQB, NOTRI, NORND);

	input nACLK2;
	input ACLK1;

	input RES;
	inout [7:0] DB;
	input n_R4015;
	input W4015;
	input nLFO2;

	input W4003;
	input W4007;
	input W400B;
	input W400F;

	input SQA_LC;
	input SQB_LC;
	input TRI_LC;
	input RND_LC;

	output NOSQA;
	output NOSQB;
	output NOTRI;
	output NORND;

	wire [7:0] LC;

	LengthCounter_PLA pla (
		.DB(DB),
		.LC_Out(LC) );

	LengthCounter length_cnt [3:0] (
		.nACLK2(nACLK2),
		.ACLK1(ACLK1),
		.RES(RES),
		.W400x_load({W400F, W400B, W4007, W4003}),
		.n_R4015(n_R4015),
		.W4015(W4015),
		.LC(LC),
		.dbit_ena({DB[3], DB[2], DB[1], DB[0]}),
		.nLFO2(nLFO2),
		.Carry_in({RND_LC, TRI_LC, SQB_LC, SQA_LC}),
		.NotCount({NORND, NOTRI, NOSQB, NOSQA}) );

endmodule // LengthCounters

module LengthCounter(
	nACLK2, ACLK1,
	RES, W400x_load, n_R4015, W4015, LC, dbit_ena, nLFO2,
	Carry_in, NotCount);

	input nACLK2;
	input ACLK1;

	input RES;
	input W400x_load;
	input n_R4015;
	input W4015;
	input [7:0] LC;
	inout dbit_ena;
	input nLFO2;

	input Carry_in;
	output NotCount;

	wire STEP;
	wire Carry_out;

	LC_DownCounter cnt (
		.Clk(ACLK1),
		.Clear(RES),
		.Step(STEP),
		.Load(W400x_load),
		.Val_in(LC),
		.Carry_in(Carry_in),
		.Carry_out(Carry_out) );

	LC_Control ctl (
		.nACLK2(nACLK2),
		.ACLK1(ACLK1),
		.RES(RES),
		.W400x_load(W400x_load),
		.n_R4015(n_R4015),
		.W4015(W4015),
		.dbit_ena(dbit_ena),
		.nLFO2(nLFO2),
		.cout(Carry_out),
		.NotCount(NotCount),
		.Step(STEP) );

endmodule // LengthCounter

module LC_Control(
	nACLK2, ACLK1,
	RES, W400x_load, n_R4015, W4015, dbit_ena, nLFO2, cout,
	NotCount, Step);

	input nACLK2;
	input ACLK1;

	input RES;
	input W400x_load;
	input n_R4015;
	input W4015;
	inout dbit_ena;
	input nLFO2;
	input cout;

	output NotCount;
	output Step;

	wire LCDIS;
	wire ena_latch_out;
	wire cout_latch_out;
	wire StatOut;
	wire n_StatOut;
	wire step_latch_out;
	wire ACLK4;		// Other ACLK

	assign ACLK4 = ~nACLK2;
	sdffre ena_ff (.d(dbit_ena), .en(W4015), .res(RES), .phi_keep(ACLK1), .nq(LCDIS));
	dlatch ena_latch (.d(LCDIS), .en(ACLK1), .q(ena_latch_out));
	dlatch cout_latch (.d(cout), .en(ACLK1), .q(cout_latch_out));
	rsff_2_4 stat_ff (
		.res1(ena_latch_out & ACLK4),
		.res2(cout_latch_out & Step),
		.res3(RES),
		.s(W400x_load),
		.q(StatOut),
		.nq(n_StatOut) );
	dlatch step_latch (.d(n_StatOut), .en(ACLK1), .q(step_latch_out));

	assign NotCount = ~StatOut;
	bustris stat_tris (.a(n_StatOut), .n_x(dbit_ena), .n_en(n_R4015));

	nor (Step, step_latch_out, nLFO2);

endmodule // LC_Control

module LC_DownCounter(Clk, Clear, Step, Load, Val_in, Carry_in, Carry_out);

	input Clk;
	input Clear;
	input Step;
	input Load;
	input [7:0] Val_in;
	input Carry_in;
	output Carry_out;

	wire [7:0] carry_chain;
	wire [7:0] cnt_value; 	// debug

	DownCounterBit lc_cnt [7:0] (
		.ACLK1(Clk),
		.load(Load),
		.clear(Clear),
		.step(Step),
		.d(Val_in),
		.q(cnt_value),
		.cin({carry_chain[6:0], Carry_in}),
		.cout(carry_chain) );

	assign Carry_out = carry_chain[7];

endmodule // LC_DownCounter

module LengthCounter_PLA(DB, LC_Out);

	inout [7:0] DB;
	output [7:0] LC_Out;

	wire [4:0] Dec1_in;
	wire [31:0] Dec1_out;

	dlatch din [4:0] (.d(DB[7:3]), .en(1'b1), .q(Dec1_in));
	LengthDecoder1 dec1 (.Dec1_in(Dec1_in), .Dec1_out(Dec1_out));
	LengthDecoder2 dec2 (.Dec2_in(Dec1_out), .Dec2_out(LC_Out));

endmodule // LengthCounter_PLA

module LengthDecoder1 (Dec1_in, Dec1_out);

	input [4:0] Dec1_in;
	output [31:0] Dec1_out;

	wire [4:0] d;
	wire [4:0] nd;

	assign d = Dec1_in;
	assign nd = ~Dec1_in;

	nor (Dec1_out[0], d[0], d[1], d[2], d[3], d[4]);
	nor (Dec1_out[1], d[0], nd[1], d[2], d[3], d[4]);
	nor (Dec1_out[2], d[0], d[1], nd[2], d[3], d[4]);
	nor (Dec1_out[3], d[0], nd[1], nd[2], d[3], d[4]);
	nor (Dec1_out[4], d[0], d[1], d[2], nd[3], d[4]);
	nor (Dec1_out[5], d[0], nd[1], d[2], nd[3], d[4]);
	nor (Dec1_out[6], d[0], d[1], nd[2], nd[3], d[4]);
	nor (Dec1_out[7], d[0], nd[1], nd[2], nd[3], d[4]);

	nor (Dec1_out[8], d[0], d[1], d[2], d[3], nd[4]);
	nor (Dec1_out[9], d[0], nd[1], d[2], d[3], nd[4]);
	nor (Dec1_out[10], d[0], d[1], nd[2], d[3], nd[4]);
	nor (Dec1_out[11], d[0], nd[1], nd[2], d[3], nd[4]);
	nor (Dec1_out[12], d[0], d[1], d[2], nd[3], nd[4]);
	nor (Dec1_out[13], d[0], nd[1], d[2], nd[3], nd[4]);
	nor (Dec1_out[14], d[0], d[1], nd[2], nd[3], nd[4]);
	nor (Dec1_out[15], d[0], nd[1], nd[2], nd[3], nd[4]);

	nor (Dec1_out[16], nd[0], d[1], d[2], d[3], d[4]);
	nor (Dec1_out[17], nd[0], nd[1], d[2], d[3], d[4]);
	nor (Dec1_out[18], nd[0], d[1], nd[2], d[3], d[4]);
	nor (Dec1_out[19], nd[0], nd[1], nd[2], d[3], d[4]);
	nor (Dec1_out[20], nd[0], d[1], d[2], nd[3], d[4]);
	nor (Dec1_out[21], nd[0], nd[1], d[2], nd[3], d[4]);
	nor (Dec1_out[22], nd[0], d[1], nd[2], nd[3], d[4]);
	nor (Dec1_out[23], nd[0], nd[1], nd[2], nd[3], d[4]);

	nor (Dec1_out[24], nd[0], d[1], d[2], d[3], nd[4]);
	nor (Dec1_out[25], nd[0], nd[1], d[2], d[3], nd[4]);
	nor (Dec1_out[26], nd[0], d[1], nd[2], d[3], nd[4]);
	nor (Dec1_out[27], nd[0], nd[1], nd[2], d[3], nd[4]);
	nor (Dec1_out[28], nd[0], d[1], d[2], nd[3], nd[4]);
	nor (Dec1_out[29], nd[0], nd[1], d[2], nd[3], nd[4]);
	nor (Dec1_out[30], nd[0], d[1], nd[2], nd[3], nd[4]);
	nor (Dec1_out[31], nd[0], nd[1], nd[2], nd[3], nd[4]);

endmodule // LengthDecoder1

module LengthDecoder2 (Dec2_in, Dec2_out);

	input [31:0] Dec2_in;
	output [7:0] Dec2_out;

	wire [31:0] d;
	assign d = Dec2_in;

	nor (Dec2_out[7], 
		d[0], d[1], d[2], d[3], d[5], d[6], d[7],
		d[8], d[9], d[10], d[11], d[13], d[14], d[15],
		d[17], d[18], d[19], d[20], d[21], d[22], d[23],
		d[24], d[25], d[26], d[27], d[28], d[29], d[30], d[31] );
	nor (Dec2_out[6], 
		d[0], d[1], d[2], d[4], d[5], d[6], d[7], 
		d[8], d[9], d[10], d[12], d[14], d[15], 
		d[17], d[18], d[19], d[20], d[21], d[22], d[23], 
		d[24], d[25], d[26], d[27], d[28], d[29], d[30], d[31] );
	nor (Dec2_out[5], 
		d[0], d[1], d[3], d[4], d[6], d[7], 
		d[8], d[9], d[11], d[13], d[14], d[15], 
		d[17], d[18], d[19], d[20], d[21], d[22], d[23], 
		d[24], d[25], d[26], d[27], d[28], d[29], d[30], d[31] );
	nor (Dec2_out[4], 
		d[0], d[2], d[3], d[6], 
		d[8], d[10], d[13], d[14], 
		d[17], d[18], d[19], d[20], d[21], d[22], d[23],
		d[24] );
	nor (Dec2_out[3], 
		d[1], d[2], 
		d[9], d[13], 
		d[17], d[18], d[19], d[20], 
		d[25], d[26], d[27], d[28] );
	nor (Dec2_out[2], 
		d[0], d[1], d[5], d[7], 
		d[8], 
		d[17], d[18], d[21], d[22], 
		d[25], d[26], d[29], d[30] );
	nor (Dec2_out[1], 
		d[0], d[6], d[7], 
		//...
		d[16], d[17], d[19], d[21], d[23], 
		d[25], d[27], d[29], d[31] );
	assign Dec2_out[0] = 1'b1;

endmodule //  LengthDecoder2
