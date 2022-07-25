
module LengthCounters(
	n_ACLK,
	RES, DB, n_R4015, W4015, nLFO2, 
	W4003, W4007, W400B, W400F,
	SQA_LC, SQB_LC, TRI_LC, RND_LC,
	NOSQA, NOSQB, NOTRI, NORND);

	input n_ACLK;

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

	LengthCounter length_cnt [3:0] (
		.n_ACLK(n_ACLK),
		.RES(RES),
		.W400x_load({W400F, W400B, W4007, W4003}),
		.n_R4015(n_R4015),
		.W4015(W4015),
		.DB(DB),
		.dbit_ena({DB[3], DB[2], DB[1], DB[0]}),
		.nLFO2(nLFO2),
		.NotCount({NORND, NOTRI, NOSQB, NOSQA}),
		.Carry_in({RND_LC, TRI_LC, SQB_LC, SQA_LC}) );

endmodule // LengthCounters

module LengthCounter(
	n_ACLK,
	RES, W400x_load, n_R4015, W4015, DB, dbit_ena, nLFO2,
	NotCount, Carry_in);

	input n_ACLK;

	input RES;
	input W400x_load;
	input n_R4015;
	input W4015;
	inout [7:0] DB;
	inout dbit_ena;
	input nLFO2;

	output NotCount;
	input Carry_in;

	wire [7:0] LC;
	wire STEP;
	wire Carry_out;

	LengthCounter_PLA pla (
		.DB(DB),
		.LC_Out(LC) );

	LC_DownCounter cnt (
		.Clk(n_ACLK),
		.Clear(RES),
		.Step(STEP),
		.Val_in(LC),
		.Carry_in(Carry_in),
		.Carry_out(Carry_out) );

	LC_Control ctl(
		.n_ACLK(n_ACLK),
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
	n_ACLK,
	RES, W400x_load, n_R4015, W4015, dbit_ena, nLFO2, cout,
	NotCount, Step);

	input n_ACLK;

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

	sdffre ena_ff (.d(dbit_ena), .en(W4015), .res(RES), .phi_keep(n_ACLK), .nq(LCDIS));
	dlatch ena_latch (.d(LCDIS), .en(n_ACLK), .q(ena_latch_out));
	dlatch cout_latch (.d(cout), .en(n_ACLK), .q(cout_latch_out));
	rsff_2_4 stat_ff (
		.res1(ena_latch_out & n_ACLK),
		.res2(cout_latch_out & Step),
		.res3(RES),
		.s(W400x_load),
		.q(StatOut),
		.nq(n_StatOut) );
	dlatch step_latch (.d(n_StatOut), .en(n_ACLK), .q(step_latch_out));

	assign NotCount = ~StatOut;
	bustris stat_tris (.a(n_StatOut), .n_x(dbit_ena), .n_en(n_R4015));

	nor (Step, step_latch_out, nLFO2);

endmodule // LC_Control

module LC_DownCounter(Clk, Clear, Step, Val_in, Carry_in, Carry_out);

	input Clk;
	input Clear;
	input Step;
	input [7:0] Val_in;
	input Carry_in;
	output Carry_out;

	wire [7:0] carry_chain;

	apu_downcnt_bit lc_cnt [7:0] (
		.Clk(Clk),
		.Clear(Clear),
		.Step(Step),
		.Val_in(Val_in),
		.Carry_in({carry_chain[6:0], Carry_in}),
		.Carry_out(carry_chain) );

	assign Carry_out = carry_chain[7];

endmodule // LC_DownCounter

module LengthCounter_PLA(DB, LC_Out);

	inout [7:0] DB;
	output [7:0] LC_Out;

endmodule // LengthCounter_PLA

module apu_downcnt_bit(Clk, Clear, Step, Val_in, Carry_in, Carry_out);

	input Clk;
	input Clear;
	input Step;
	input Val_in;
	input Carry_in;
	output Carry_out;

endmodule // apu_downcnt
