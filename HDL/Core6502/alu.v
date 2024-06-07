
module ALU(
	PHI2,
	NDB_ADD, DB_ADD, Z_ADD, SB_ADD, ADL_ADD, ADD_SB06, ADD_SB7, ADD_ADL,
	ANDS, EORS, ORS, SRS, SUMS, 
	SB_AC, AC_SB, AC_DB, SB_DB, SB_ADH, Z_ADH0, Z_ADH17,
	n_ACIN, n_DAA, n_DSA,
	SB, DB, ADL, ADH,
	ACR, AVR);

	input PHI2;
	
	input NDB_ADD;
	input DB_ADD;
	input Z_ADD;
	input SB_ADD;
	input ADL_ADD;
	input ADD_SB06;
	input ADD_SB7;
	input ADD_ADL;

	input ANDS;
	input EORS;
	input ORS;
	input SRS;
	input SUMS;

	input SB_AC;
	input AC_SB;
	input AC_DB;
	input SB_DB;
	input SB_ADH;
	input Z_ADH0;
	input Z_ADH17;

	input n_ACIN;
	input n_DAA;
	input n_DSA;

	inout [7:0] SB;
	inout [7:0] DB;
	inout [7:0] ADL;
	inout [7:0] ADH;

	output ACR;
	output AVR;

	// ALU Ops intermediate results

	wire [7:0] nands;
	wire [7:0] ands; 		// odd bits
	wire [7:0] nors;
	wire [7:0] ors; 		// even bits
	wire [7:0] xors; 		// odd bits
	wire [7:0] xnors; 		// even bits
	wire [7:0] nsums;
	wire [7:0] nres;

	wire [7:0] carry; 		// inverted carry chain (even: inverted polarity, odd: regular polarity)
	assign carry[0] = n_ACIN;

	// AI/BI Latches

	wire [7:0] ai_d;
	assign ai_d = Z_ADD ? 8'b00000000 : (SB_ADD ? SB : 8'bzzzzzzzz);
	wire [7:0] bi_d;
	assign bi_d = ADL_ADD ? ADL : (DB_ADD ? DB : ( NDB_ADD ? ~DB : 8'bzzzzzzzz) );
	dlatch ai_latch [7:0] (.d(ai_d), .en(8'b11111111), .q(ai) );
	wire [7:0] ai;
	dlatch bi_latch [7:0] (.d(bi_d), .en(8'b11111111), .q(bi) );
	wire [7:0] bi;

	// ALU Ops

	nand na [7:0] (nands, ai, bi);
	nor no [7:0] (nors, ai, bi);

	not (ands[1], nands[1]);
	not (ands[3], nands[3]);
	not (ands[5], nands[5]);
	not (ands[7], nands[7]);

	nor (ors[0], nors[0]);
	nor (ors[2], nors[2]);
	nor (ors[4], nors[4]);
	nor (ors[6], nors[6]);

	nand (xnors[0], ors[0], nands[0]);
	nand (xnors[2], ors[2], nands[2]);
	nand (xnors[4], ors[4], nands[4]);
	nand (xnors[6], ors[6], nands[6]);

	nor (xors[1], nors[1], ands[1]);
	nor (xors[3], nors[3], ands[3]);
	nor (xors[5], nors[5], ands[5]);
	nor (xors[7], nors[7], ands[7]);

	assign nsums[0] = ~((xnors[0]&~carry[0]) | ~(xnors[0]|~carry[0]));
	assign nsums[1] = ~(( xors[1]&~carry[1]) | ~( xors[1]|~carry[1]));
	assign nsums[2] = ~((xnors[2]&~carry[2]) | ~(xnors[2]|~carry[2]));
	assign nsums[3] = ~(( xors[3]&~carry[3]) | ~( xors[3]|~carry[3]));
	assign nsums[4] = ~((xnors[4]&~carry[4]) | ~(xnors[4]|~carry[4]));
	assign nsums[5] = ~(( xors[5]&~carry[5]) | ~( xors[5]|~carry[5]));
	assign nsums[6] = ~((xnors[6]&~carry[6]) | ~(xnors[6]|~carry[6]));
	assign nsums[7] = ~(( xors[7]&~carry[7]) | ~( xors[7]|~carry[7]));

	assign nres = SRS ? ({1'b1,nands[7:1]}) : (
		ANDS ? nands : (
		ORS ? nors : (
		EORS ? xnors : (
		SUMS ? nsums : 8'bzzzzzzzz ))));

	// Carry Chain

	wire cout;

	aoi c0 (.a0(carry[0]), .a1(nands[0]), .b(nors[0]), .x(carry[1]) );
	aoi c1 (.a0(carry[1]), .a1(ors[1]),   .b(ands[1]), .x(carry[2]) );
	aoi c2 (.a0(carry[2]), .a1(nands[2]), .b(nors[2]), .x(carry[3]) );
	aoi c3 (.a0(carry[3]), .a1(ors[3]),   .b(ands[3]), .x(carry[4]) );
	aoi c4 (.a0(carry[4]), .a1(nands[4]), .b(nors[4]), .x(carry[5]) );
	aoi c5 (.a0(carry[5]), .a1(ors[5]),   .b(ands[5]), .x(carry[6]) );
	aoi c6 (.a0(carry[6]), .a1(nands[6]), .b(nors[6]), .x(carry[7]) );
	aoi c7 (.a0(carry[7]), .a1(ors[7]),   .b(ands[7]), .x(cout) );

	// Fast BCD Carry

	// Adder Hold

	wire nADD1, nADD2, nADD5, nADD6;

	wire [7:0] add_out;
	dlatch add [7:0] (.d(nres), .en(PHI2), .nq(add_out) );
	assign ADL = ADD_ADL ? add_out : 8'bzzzzzzzz;
	assign SB[6:0] = ADD_SB06 ? add_out[6:0] : 7'bzzzzzzz;
	assign SB[7] = ADD_SB7 ? add_out[7] : 1'bz;

	not (nADD1, add_out[1]);
	not (nADD2, add_out[2]);
	not (nADD5, add_out[5]);
	not (nADD6, add_out[6]);

	// BCD Correction

	// Accumulator + Bus Mpx

endmodule // ALU
