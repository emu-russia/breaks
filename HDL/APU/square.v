
// In the real circuit there is no `AdderCarryMode` signal. For Square0 the input n_carry is connected directly to VDD and for Square1 it is connected to INC.
// But we cheat a little bit here for convenience by making the connection using multiplexer.

module SquareChan (
	nACLK2, ACLK1, 
	RES, DB, WR0, WR1, WR2, WR3, nLFO1, nLFO2, SQ_LC, NOSQ, LOCK, AdderCarryMode,
	SQ_Out);

	input nACLK2;
	input ACLK1;

	input RES;
	inout [7:0] DB;
	input WR0;
	input WR1;
	input WR2;
	input WR3;
	input nLFO1;
	input nLFO2;
	output SQ_LC;
	input NOSQ;
	input LOCK;
	input AdderCarryMode;			// 0: input n_carry connected to INC, 1: input n_carry connected to Vdd

	output [3:0] SQ_Out;

	// Internal wires

	wire [10:0] Fx;
	wire [10:0] nFx;
	wire [10:0] n_sum;
	wire [10:0] S;
	wire [2:0] SR;
	wire [11:0] BS;
	wire DEC;
	wire INC;
	wire n_COUT;
	wire SW_UVF;
	wire FCO;
	wire FLOAD;
	wire DO_SWEEP;
	wire SW_OVF;
	wire DUTY;
	wire [3:0] Vol;

	// Instantiate

	RegisterBit dir_reg (.ACLK1(ACLK1), .ena(WR1), .d(DB[3]), .q(DEC) );

	assign INC = ~DEC;
	assign BS = {DEC, DEC ? nFx : Fx};

	SQUARE_FreqReg freq_reg (.nACLK2(nACLK2), .ACLK1(ACLK1), .WR2(WR2), .WR3(WR3), .DB(DB), .DO_SWEEP(DO_SWEEP), .n_sum(n_sum), .nFx(nFx), .Fx(Fx) );

	SQUARE_ShiftReg shift_reg (.ACLK1(ACLK1), .WR1(WR1), .DB(DB), .SR(SR) );

	SQUARE_BarrelShifter barrel (.BS(BS), .SR(SR), .S(S) );

	SQUARE_Adder adder (.CarryMode(AdderCarryMode), .INC(INC), .nFx(nFx), .Fx(Fx), .S(S), .n_sum(n_sum), .n_COUT(n_COUT), .SW_UVF(SW_UVF) );

	SQUARE_FreqCounter freq_cnt (.nACLK2(nACLK2), .ACLK1(ACLK1), .RES(RES), .Fx(Fx), .FCO(FCO), .FLOAD(FLOAD) );

	Envelope_Unit env_unit (.ACLK1(ACLK1), .RES(RES), .WR_Reg(WR0), .WR_LC(WR3), .n_LFO1(nLFO1), .DB(DB), .V(Vol), .LC(SQ_LC) );

	SQUARE_Sweep sweep_unit (.ACLK1(ACLK1), .RES(RES), .WR1(WR1), .SR(SR), .DEC(DEC), .n_COUT(n_COUT), .SW_UVF(SW_UVF), .NOSQ(NOSQ), .n_LFO2(nLFO2), 
		.DB(DB), .DO_SWEEP(DO_SWEEP), .SW_OVF(SW_OVF) );

	SQUARE_Duty duty_unit (.ACLK1(ACLK1), .RES(RES), .FLOAD(FLOAD), .FCO(FCO), .WR0(WR0), .WR3(WR3), .DB(DB), .DUTY(DUTY) );

	SQUARE_Output sqo (.ACLK1(ACLK1), .DUTY(DUTY), .LOCK(LOCK), .SW_UVF(SW_UVF), .NOSQ(NOSQ), .SW_OVF(SW_OVF), .V(Vol), .SQ_Out(SQ_Out) );

endmodule // SquareChan

module SQUARE_FreqReg (nACLK2, ACLK1, WR2, WR3, DB, DO_SWEEP, n_sum, nFx, Fx);

	input nACLK2;
	input ACLK1; 
	input WR2; 
	input WR3; 
	inout [7:0] DB;
	input DO_SWEEP; 
	input [10:0] n_sum; 
	output [10:0] nFx; 
	output [10:0] Fx;

	wire ACLK3;
	assign ACLK3 = ~nACLK2;

	SQUARE_FreqRegBit freq_reg [10:0] (.ACLK3(ACLK3), .ACLK1(ACLK1), 
		.WR({ {3{WR3}}, {8{WR2}} }), .DB_in({ DB[2:0], DB[7:0] }), .DO_SWEEP(DO_SWEEP), .n_sum(n_sum), .nFx(nFx), .Fx(Fx) );

endmodule // SQUARE_FreqReg

module SQUARE_FreqRegBit (ACLK3, ACLK1, WR, DB_in, DO_SWEEP, n_sum, nFx, Fx);

	input ACLK3;
	input ACLK1;
	input WR;
	inout DB_in;
	input DO_SWEEP;
	input n_sum;
	output nFx;
	output Fx;

	wire d;
	wire transp_latch_q;
	wire sum_latch_q;
	wire sum_latch_nq;

	assign d = WR ? DB_in : (ACLK3 ? Fx : 1'bz);
	dlatch transp_latch (.d(d), .en(1'b1), .q(transp_latch_q) );
	dlatch sum_latch (.d(n_sum), .en(ACLK1), .q(sum_latch_q), .nq(sum_latch_nq) );
	nor (nFx, (sum_latch_nq & DO_SWEEP), transp_latch_q);
	nor (Fx, nFx, (sum_latch_q & DO_SWEEP));

endmodule // SQUARE_FreqRegBit

module SQUARE_ShiftReg (ACLK1, WR1, DB, SR);

	input ACLK1;
	input WR1;
	input [7:0] DB;
	output [2:0] SR;

	RegisterBit sr_reg [2:0] (.ACLK1(ACLK1), .ena(WR1), .d(DB[2:0]), .q(SR) );

endmodule // SQUARE_ShiftReg

module SQUARE_BarrelShifter (BS, SR, S);

	input [11:0] BS;
	input [2:0] SR;
	output [10:0] S;

	wire [10:0] q1;
	wire [10:0] q2;

	assign q1[0] = SR[0] ? BS[1] : BS[0];
	assign q1[1] = SR[0] ? BS[2] : BS[1];
	assign q1[2] = SR[0] ? BS[3] : BS[2];
	assign q1[3] = SR[0] ? BS[4] : BS[3];
	assign q1[4] = SR[0] ? BS[5] : BS[4];
	assign q1[5] = SR[0] ? BS[6] : BS[5];
	assign q1[6] = SR[0] ? BS[7] : BS[6];
	assign q1[7] = SR[0] ? BS[8] : BS[7];
	assign q1[8] = SR[0] ? BS[9] : BS[8];
	assign q1[9] = SR[0] ? BS[10] : BS[9];
	assign q1[10] = SR[0] ? BS[11] : BS[10];

	assign q2[0] = SR[1] ? q1[2] : q1[0];
	assign q2[1] = SR[1] ? q1[3] : q1[1];
	assign q2[2] = SR[1] ? q1[4] : q1[2];
	assign q2[3] = SR[1] ? q1[5] : q1[3];
	assign q2[4] = SR[1] ? q1[6] : q1[4];
	assign q2[5] = SR[1] ? q1[7] : q1[5];
	assign q2[6] = SR[1] ? q1[8] : q1[6];
	assign q2[7] = SR[1] ? q1[9] : q1[7];
	assign q2[8] = SR[1] ? q1[10] : q1[8];
	assign q2[9] = SR[1] ? BS[11] : q1[9];
	assign q2[10] = SR[1] ? BS[11] : q1[10];

	assign S[0] = SR[2] ? q2[4] : q2[0];
	assign S[1] = SR[2] ? q2[5] : q2[1];
	assign S[2] = SR[2] ? q2[6] : q2[2];
	assign S[3] = SR[2] ? q2[7] : q2[3];
	assign S[4] = SR[2] ? q2[8] : q2[4];
	assign S[5] = SR[2] ? q2[9] : q2[5];
	assign S[6] = SR[2] ? q2[10] : q2[6];
	assign S[7] = SR[2] ? BS[11] : q2[7];
	assign S[8] = SR[2] ? BS[11] : q2[8];
	assign S[9] = SR[2] ? BS[11] : q2[9];
	assign S[10] = SR[2] ? BS[11] : q2[10];

endmodule // SQUARE_BarrelShifter

module SQUARE_Adder (CarryMode, INC, nFx, Fx, S, n_sum, n_COUT, SW_UVF);

	input CarryMode;
	input INC;
	input [10:0] nFx;
	input [10:0] Fx;
	input [10:0] S;
	output [10:0] n_sum;
	output n_COUT;
	output SW_UVF;

	wire n_cin;
	assign n_cin = CarryMode ? 1'b1 : INC;
	wire [10:0] n_cout;
	wire [10:0] cout;

	SQUARE_AdderBit adder [10:0] (.F(Fx), .nF(nFx), .S(S), .nS(~S), 
		.C({cout[9:0],~n_cin}), .nC({n_cout[9:0],n_cin}), .n_cout(n_cout), .cout(cout), .n_sum(n_sum) );
	assign n_COUT = n_cout[10];
	nor (SW_UVF, Fx[2], Fx[3], Fx[4], Fx[5], Fx[6], Fx[7], Fx[8], Fx[9], Fx[10]);

endmodule // SQUARE_Adder

module SQUARE_AdderBit (F, nF, S, nS, C, nC, n_cout, cout, n_sum);

	input F;
	input nF;
	input S;
	input nS;
	input C;
	input nC;
	output n_cout;
	output cout;
	output n_sum;

	nor (n_cout, (F & S), (F & nS & C), (nF & S & C));
	nor (n_sum, (F & nS & nC), (nF & S & nC), (nF & nS & C), (F & S & C) );
	assign cout = ~n_cout;

endmodule // SQUARE_AdderBit

module SQUARE_FreqCounter (nACLK2, ACLK1, RES, Fx, FCO, FLOAD);

	input nACLK2;
	input ACLK1;
	input RES;
	input [10:0] Fx;
	output FCO;
	output FLOAD;

	wire FSTEP;
	wire fco_latch_nq;
	wire [10:0] cout;

	dlatch fco_latch (.d(FCO), .en(ACLK1), .nq(fco_latch_nq) );
	DownCounterBit freq_cnt [10:0] (.ACLK1(ACLK1), .d(Fx), .load(FLOAD), .clear(RES), .step(FSTEP), .cin({cout[9:0],1'b1}), .cout(cout) );
	assign FCO = cout[10];

	nor (FLOAD, nACLK2, fco_latch_nq);
	nor (FSTEP, nACLK2, ~fco_latch_nq);

endmodule // SQUARE_FreqCounter

module SQUARE_Sweep (ACLK1, RES, WR1, SR, DEC, n_COUT, SW_UVF, NOSQ, n_LFO2, DB, DO_SWEEP, SW_OVF);

	input ACLK1;
	input RES;
	input WR1;
	input [2:0] SR;
	input DEC;
	input n_COUT;
	input SW_UVF;
	input NOSQ;
	input n_LFO2;
	inout [7:0] DB;
	output DO_SWEEP;
	output SW_OVF;

	wire SRZ;
	wire SWDIS;
	wire SWRELOAD;
	wire SSTEP;
	wire SLOAD;
	wire SCO;
	wire n_SCO;
	wire reload_latch_q;
	wire sco_latch_q;
	wire reload_ff_q;
	wire [2:0] sweep_reg_q;
	wire [2:0] cnt_q; 	// debug
	wire [2:0] cout;
	wire temp_reload;

	dlatch reload_latch (.d(reload_ff_q), .en(ACLK1), .q(reload_latch_q), .nq(SWRELOAD) );
	dlatch sco_latch (.d(SCO), .en(ACLK1), .q(sco_latch_q), .nq(n_SCO) );

	rsff reload_ff (.r(WR1), .s(~(n_LFO2 | reload_latch_q)), .q(reload_ff_q) );

	RegisterBit swdis_reg (.ACLK1(ACLK1), .ena(WR1), .d(DB[7]), .nq(SWDIS) );

	RegisterBit sweep_reg [2:0] (.ACLK1(ACLK1), .ena(WR1), .d(DB[6:4]), .q(sweep_reg_q) );
	DownCounterBit sweep_cnt [2:0] (.ACLK1(ACLK1), .d(sweep_reg_q), .load(SLOAD), .clear(RES), .step(SSTEP), .cin({cout[1:0],1'b1}), .cout(cout), .q(cnt_q) );
	assign SCO = cout[2];

	nor (temp_reload, SWRELOAD, sco_latch_q);
	nor (SSTEP, n_LFO2, ~temp_reload);
	nor (SLOAD, n_LFO2, temp_reload);
	nor (SW_OVF, DEC, n_COUT);
	nor (SRZ, SR[0], SR[1], SR[2]);
	nor (DO_SWEEP, SRZ, SWDIS, NOSQ, SW_OVF, n_SCO, n_LFO2, SW_UVF);

endmodule // SQUARE_Sweep

module SQUARE_Duty (ACLK1, RES, FLOAD, FCO, WR0, WR3, DB, DUTY);

	input ACLK1;
	input RES;
	input FLOAD;
	input FCO;
	input WR0;
	input WR3;
	inout [7:0] DB;
	output DUTY;

	wire [2:0] cout;
	wire [2:0] DC;
	wire [1:0] DT;
	wire [3:0] in;

	RegisterBit duty_reg [1:0] (.ACLK1(ACLK1), .ena(WR0), .d(DB[7:6]), .q(DT) );
	DownCounterBit duty_cnt [2:0] (.ACLK1(ACLK1), .d(3'b000), .load(WR3), .clear(RES), .step(FLOAD), .cin({cout[1:0],1'b1}), .q(DC), .cout(cout) );

	nand (in[3], DC[1], DC[2]);
	nor (in[0], ~DC[0], in[3]);
	assign in[1] = ~in[3];
	assign in[2] = DC[2];

	assign DUTY = DT[1] ? (DT[0] ? in[3] : in[2]) : (DT[0] ? in[1] : in[0]); 	// mux 4-to-1

endmodule // SQUARE_Duty

module SQUARE_Output (ACLK1, DUTY, LOCK, SW_UVF, NOSQ, SW_OVF, V, SQ_Out);

	input ACLK1;
	input DUTY;
	input LOCK;
	input SW_UVF;
	input NOSQ;
	input SW_OVF;
	input [3:0] V;
	output [3:0] SQ_Out;

	wire d;
	wire sqo_latch_q;
	wire sqv;

	nor (d, ~DUTY, SW_UVF, NOSQ, SW_OVF);
	dlatch sqo_latch (.d(d), .en(ACLK1), .q(sqo_latch_q) );
	nor (sqv, sqo_latch_q, LOCK);

	pnor vout [3:0] (.a0({4{sqv}}), .a1(~V), .x(SQ_Out) );

endmodule // SQUARE_Output
