module div_umc (  port_x, port_y, port_nCLK, port_b, port_a, port_c, port_tmp2);

	inout wire port_x;
	output wire port_y;
	input wire port_nCLK;
	input wire port_b;
	input wire port_a;
	input wire port_c;
	inout wire port_tmp2;

	// Wires

	wire w1;
	wire w2;
	wire w3;
	wire w4;
	wire w5;
	wire w6;
	wire w7;
	wire w8;
	wire w9;
	wire w10;
	wire w11;
	wire w12;
	wire ck;
	wire cck;
	wire w15;
	wire w16;
	wire w17;
	wire w18;
	wire w19;
	wire w20;
	wire w21;
	wire w22;
	wire w23;
	wire w24;
	wire w25;
	wire w26;
	wire w27;
	wire w28;
	wire w29;
	wire w30;
	wire w31;
	wire w32;
	wire w33;
	wire w34;
	wire w35;
	wire w36;
	wire w37;
	wire w38;
	wire w39;
	wire w40;
	wire w41;
	wire w42;
	wire w43;
	wire w44;
	wire tmp1;
	wire w46;
	wire w47;
	wire w48;
	wire fb;
	wire w_tmp2;
	wire w51;
	wire w52;

	assign port_x = w39;
	assign port_y = w34;
	assign w38 = port_nCLK;
	assign w46 = port_b;
	assign w47 = port_a;
	assign w48 = port_c;
	assign port_tmp2 = w_tmp2;

	// Instances

	div_umc_notsuper g1 (.a(w40), .x(w39) );
	div_umc_nor g2 (.a(w_tmp2), .b(w46), .x(w34) );
	div_umc_nor g3 (.a(w31), .b(w29), .x(w30) );
	div_umc_nor g4 (.a(w48), .b(w30), .x(w29) );
	div_umc_nor g5 (.a(w28), .b(w27), .x(w35) );
	div_umc_nor g6 (.a(w36), .b(w35), .x(w1) );
	div_umc_nor g7 (.b(w16), .a(cck), .x(ck) );
	div_umc_nor g8 (.a(w15), .b(ck), .x(cck) );
	div_umc_nor g9 (.b(w_tmp2), .a(w12), .x(tmp1) );
	div_umc_nor g10 (.b(fb), .a(w9), .x(w8) );
	div_umc_nor g11 (.a(w6), .b(fb), .x(w5) );
	div_umc_nor g12 (.a(w44), .b(w1), .x(w3) );
	div_umc_nor g13 (.a(w43), .b(tmp1), .x(w17) );
	div_umc_nor g14 (.b(w42), .a(tmp1), .x(w18) );
	div_umc_nor g15 (.b(w41), .a(tmp1), .x(w20) );
	div_umc_dlatch g16 (.d(w26), .en(ck), .nq(w40) );
	div_umc_dlatch g17 (.d(w52), .en(cck), .nq(w26) );
	div_umc_dlatch g18 (.d(w_tmp2), .en(ck), .nq(w52) );
	div_umc_dlatch g19 (.d(w25), .en(cck), .nq(fb) );
	div_umc_dlatch g20 (.d(w24), .en(ck), .nq(w25) );
	div_umc_dlatch g21 (.d(w23), .en(cck), .nq(w24) );
	div_umc_dlatch g22 (.d(w22), .en(ck), .nq(w23) );
	div_umc_dlatch g23 (.d(w21), .en(cck), .nq(w22) );
	div_umc_dlatch g24 (.d(w20), .en(ck), .nq(w21) );
	div_umc_dlatch g25 (.d(w19), .en(cck), .q(w41) );
	div_umc_dlatch g26 (.d(w18), .en(ck), .nq(w19) );
	div_umc_dlatch g27 (.d(w51), .en(cck), .q(w42) );
	div_umc_dlatch g28 (.d(w17), .en(ck), .nq(w51) );
	div_umc_dlatch g29 (.d(w2), .en(cck), .q(w43) );
	div_umc_dlatch g30 (.d(w3), .en(ck), .nq(w2) );
	div_umc_dlatch g31 (.d(w4), .en(cck), .q(w44) );
	div_umc_dlatch g32 (.d(w5), .en(ck), .nq(w4) );
	div_umc_dlatch g33 (.d(w7), .en(cck), .q(w6) );
	div_umc_dlatch g34 (.d(w8), .en(ck), .nq(w7) );
	div_umc_dlatch g35 (.d(w10), .en(cck), .q(w9) );
	div_umc_dlatch g36 (.d(w11), .en(ck), .nq(w10) );
	div_umc_not g37 (.a(fb), .x(w12) );
	div_umc_not g38 (.a(fb), .x(w11) );
	div_umc_not g39 (.a(w39), .x(w33) );
	div_umc_not g40 (.a(w29), .x(w28) );
	div_umc_not g41 (.a(fb), .x(w36) );
	div_umc_not g42 (.a(w37), .x(w_tmp2) );
	div_umc_not g43 (.a(w38), .x(w15) );
	div_umc_not g44 (.a(w15), .x(w16) );
	div_umc_mux g45 (.sel(w_tmp2), .a0(w3), .a1(w8), .x(w37) );
	div_umc_not g46 (.a(w_tmp2), .x(w27) );
	div_umc_dlatch g47 (.d(w32), .en(w33), .nq(w31) );
	div_umc_dlatch g48 (.d(w47), .en(w39), .nq(w32) );
endmodule // div_umc

// Module Definitions [It is possible to wrap here on your primitives]

module div_umc_notsuper (  a, x);

	input wire a;
	output wire x;

	not (x, a);

endmodule // div_umc_notsuper

module div_umc_nor (  a, b, x);

	input wire a;
	input wire b;
	output wire x;

	nor (x, a, b);

endmodule // div_umc_nor

module div_umc_dlatch (  d, en, nq, q);

	input wire d;
	input wire en;
	output wire nq;
	output wire q;

	reg dout; 
	always @(d or en) begin
		if (en == 1'b1 && (d == 1'b0 || d == 1'b1))
			dout <= d;   // Use non-blocking
	end

	assign q = dout;
	assign nq = ~dout;

	initial dout <= 1'b0;

endmodule // div_umc_dlatch

module div_umc_not (  a, x);

	input wire a;
	output wire x;

	not (x, a);

endmodule // div_umc_not

module div_umc_mux (  sel, a0, a1, x);

	input wire sel;
	input wire a0;
	input wire a1;
	output wire x;

	assign x = sel ? a1 : a0;

endmodule // div_umc_mux
