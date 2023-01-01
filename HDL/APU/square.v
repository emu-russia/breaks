
module SquareChan (
	ACLK, n_ACLK, 
	RES, DB, WR0, WR1, WR2, WR3, nLFO1, nLFO2, SQ_LC, NOSQ, LOCK, AdderCarryMode,
	SQ_Out);

	input ACLK;
	input n_ACLK;

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
	input AdderCarryMode;			// 0: input carry connected to INC, 1: input carry connected to Vdd

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
	wire SWEEP;
	wire FCO;
	wire FLOAD;
	wire ADDOUT;
	wire SWCTRL;
	wire DUTY;
	wire [3:0] Vol;

	// Instantiate

	assign INC = ~DEC;
	assign BS = {DEC, DEC ? nFx : Fx};

	SQUARE_FreqReg freq_reg (.ACLK(ACLK), .n_ACLK(n_ACLK), .WR2(WR2), .WR3(WR3), .DB(DB), .ADDOUT(ADDOUT), .n_sum(n_sum), .nFx(nFx), .Fx(Fx) );

	SQUARE_ShiftReg shift_reg (.n_ACLK(n_ACLK), .WR1(WR1), .DB(DB), .SR(SR) );

	SQUARE_BarrelShifter barrel (.BS(BS), .SR(SR), .S(S) );

	SQUARE_Adder adder (.CarryMode(AdderCarryMode), .INC(INC), .nFx(nFx), .Fx(Fx), .S(S), .n_sum(n_sum), .n_COUT(n_COUT), .SWEEP(SWEEP) );

	SQUARE_FreqCounter freq_cnt (.ACLK(ACLK), .n_ACLK(n_ACLK), .RES(RES), .Fx(Fx), .FCO(FCO), .FLOAD(FLOAD) );

	Envelope_Unit env_unit (.n_ACLK(n_ACLK), .RES(RES), .WR_Reg(WR_Reg), .WR_LC(WR_LC), .n_LFO1(n_LFO1), .DB(DB), .V(Vol), .LC(LC) );

	SQUARE_Sweep sweep_unit (.n_ACLK(n_ACLK), .RES(RES), .WR1(WR1), .SR(SR), .DEC(DEC), .n_COUT(n_COUT), .SWEEP(SWEEP), .NOSQ(NOSQ), .n_LFO2(nLFO2), 
		.DB(DB), .ADDOUT(ADDOUT), .SWCTRL(SWCTRL) );

	SQUARE_Duty duty_unit (.n_ACLK(n_ACLK), .RES(RES), .FLOAD(FLOAD), .FCO(FCO), .WR0(WR0), .WR3(WR3), .DB(DB), .DUTY(DUTY) );

	SQUARE_Output sqo (.n_ACLK(n_ACLK), .DUTY(DUTY), .LOCK(LOCK), .SWEEP(SWEEP), .NOSQ(NOSQ), .SWCTRL(SWCTRL), .V(Vol), .SQ_Out(SQ_Out) );

endmodule // SquareChan

module SQUARE_FreqReg (ACLK, n_ACLK, WR2, WR3, DB, ADDOUT, n_sum, nFx, Fx);

	input ACLK;
	input n_ACLK; 
	input WR2; 
	input WR3; 
	inout [7:0] DB;
	input ADDOUT; 
	input [10:0] n_sum; 
	output [10:0] nFx; 
	output [10:0] Fx;

endmodule // SQUARE_FreqReg

module SQUARE_FreqRegBit ();
endmodule // SQUARE_FreqRegBit

module SQUARE_ShiftReg (n_ACLK, WR1, DB, SR);

	input n_ACLK;
	input WR1;
	input [7:0] DB;
	output [2:0] SR;

endmodule // SQUARE_ShiftReg

module SQUARE_BarrelShifter (BS, SR, S);

	input [11:0] BS;
	input [2:0] SR;
	output [10:0] S;

endmodule // SQUARE_BarrelShifter

module SQUARE_Adder (CarryMode, INC, nFx, Fx, S, n_sum, n_COUT, SWEEP);

	input CarryMode;
	input INC;
	input [10:0] nFx;
	input [10:0] Fx;
	input [10:0] S;
	output [10:0] n_sum;
	output n_COUT;
	output SWEEP;

endmodule // SQUARE_Adder

module SQUARE_AdderBit ();
endmodule // SQUARE_AdderBit

module SQUARE_FreqCounter (ACLK, n_ACLK, RES, Fx, FCO, FLOAD);

	input ACLK;
	input n_ACLK;
	input RES;
	input [10:0] Fx;
	output FCO;
	output FLOAD;

endmodule // SQUARE_FreqCounter

module SQUARE_Sweep (n_ACLK, RES, WR1, SR, DEC, n_COUT, SWEEP, NOSQ, n_LFO2, DB, ADDOUT, SWCTRL);

	input n_ACLK;
	input RES;
	input WR1;
	input [2:0] SR;
	input DEC;
	input n_COUT;
	input SWEEP;
	input NOSQ;
	input n_LFO2;
	inout [7:0] DB;
	output ADDOUT;
	output SWCTRL;

endmodule // SQUARE_Sweep

module SQUARE_Duty (n_ACLK, RES, FLOAD, FCO, WR0, WR3, DB, DUTY);

	input n_ACLK;
	input RES;
	input FLOAD;
	input FCO;
	input WR0;
	input WR3;
	inout [7:0] DB;
	output DUTY;

endmodule // SQUARE_Duty

module SQUARE_Output (n_ACLK, DUTY, LOCK, SWEEP, NOSQ, SWCTRL, V, SQ_Out);

	input n_ACLK;
	input DUTY;
	input LOCK;
	input SWEEP;
	input NOSQ;
	input SWCTRL;
	input [3:0] V;
	output [3:0] SQ_Out;

endmodule // SQUARE_Output
