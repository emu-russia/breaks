
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

	// To debug: ai(AI), bi(BI), add_out(ADD), ACIN(CarryIn), ACR(CarryOut), AVR(OverflowOut), AC_q(A)

	// ALU Ops intermediate results

	wire [7:0] nands;
	wire [7:0] ands; 		// odd bits only
	wire [7:0] nors;
	wire [7:0] ors; 		// even bits only
	wire [7:0] xors; 		// odd bits only
	wire [7:0] xnors; 		// even bits only
	wire [7:0] nsums;
	wire [7:0] nres;

	wire [7:0] cout; 		// inverted carry chain (even bits out: regular polarity, odd bits out: inverted polarity)

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

	wire ACIN;
	not (ACIN, n_ACIN);
	assign nsums[0] = ~((xnors[0]&ACIN) | ~(xnors[0]|ACIN));
	assign nsums[1] = ~(( xors[1]&~cout[0]) | ~( xors[1]|~cout[0]));
	assign nsums[2] = ~((xnors[2]&~cout[1]) | ~(xnors[2]|~cout[1]));
	assign nsums[3] = ~(( xors[3]&~cout[2]) | ~( xors[3]|~cout[2]));
	assign nsums[4] = ~((xnors[4]&~cout[3]) | ~(xnors[4]|~cout[3]));
	assign nsums[5] = ~(( xors[5]&~cout[4]) | ~( xors[5]|~cout[4]));
	assign nsums[6] = ~((xnors[6]&~cout[5]) | ~(xnors[6]|~cout[5]));
	assign nsums[7] = ~(( xors[7]&~cout[6]) | ~( xors[7]|~cout[6]));

	assign nres = SRS ? ({1'b1,nands[7:1]}) : (
		ANDS ? nands : (
		ORS ? nors : (
		EORS ? xnors : (
		SUMS ? nsums : 8'bzzzzzzzz ))));

	// Carry Chain

	aoi cc0 (.a0(n_ACIN),  .a1(nands[0]), .b(nors[0]), .x(cout[0]) );
	aoi cc1 (.a0(cout[0]), .a1(ors[1]),   .b(ands[1]), .x(cout[1]) );
	aoi cc2 (.a0(cout[1]), .a1(nands[2]), .b(nors[2]), .x(cout[2]) );
	aoi211 cc3 (.a0(cout[2]), .a1(ors[3]), .b(ands[3]), .c(DC3), .x(cout[3]) );
	aoi cc4 (.a0(cout[3]), .a1(nands[4]), .b(nors[4]), .x(cout[4]) );
	aoi cc5 (.a0(cout[4]), .a1(ors[5]),   .b(ands[5]), .x(cout[5]) );
	aoi cc6 (.a0(cout[5]), .a1(nands[6]), .b(nors[6]), .x(cout[6]) );
	aoi cc7 (.a0(cout[6]), .a1(ors[7]),   .b(ands[7]), .x(cout[7]) );

	// Fast BCD Carry  (https://patents.google.com/patent/US3991307A)

	wire nncarry4 = ~(~cout[4]);

	wire a0, b0, c0;
	wire temp1;
	assign temp1 = ~((n_ACIN&nands[0]) | nors[0]);
	assign a0 = ~(nors[2] | ~(ands[1] & temp1));
	wire nnands2;
	assign nnands2 = ~nands[2];
	assign b0 = ~(nnands2 | xors[3]);
	assign c0 = ~(temp1 | ~(nnands2|nors[2]) | ands[1] | xors[1]);
	assign DC3 = (a0 | ~(b0|c0)) & ~n_DAA;

	wire a1, b1, c1;
	assign a1 = ~(xnors[6] | ~(ands[5]&nncarry4));
	assign b1 = ~(xors[7] | ~nands[6]);
	assign c1 = ~(nncarry4 | ands[5] | xors[5] | ~xnors[6]);
	assign DC7 = (a1 | ~(b1|c1)) & ~n_DAA;

	// ACR, AVR

	dlatch DCLatch (.d(DC7), .en(PHI2), .q(DCLatch_q) );
	wire DCLatch_q;
	wire AC7;
	not (AC7, cout[7]);
	dlatch ACLatch (.d(AC7), .en(PHI2), .q(ACLatch_q) );
	wire ACLatch_q;
	wire AVRLatch_d;
	assign AVRLatch_d = ~(~(cout[6]|nands[7]) | (cout[6]&nors[7]));
	dlatch AVRLatch (.d(AVRLatch_d), .en(PHI2), .nq(AVR) );

	wire nACR;
	nor (nACR, DCLatch_q, ACLatch_q);
	not (ACR, nACR);

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

	wire DAAL, DAAH, DSAL, DSAH;

	wire daal_latch_d;
	nand (daal_latch_d, ~n_DAA, ~cout[3]);
	dlatch daal_latch (.d(daal_latch_d), .en(PHI2), .nq(DAAL) );
	dlatch daah_latch (.d(~n_DAA), .en(PHI2), .nq(daah_latch_nq) );
	wire daah_latch_nq;
	nor (DAAH, nACR, daah_latch_nq);
	wire dsal_latch_d;
	nor (dsal_latch_d, ~cout[3], n_DSA);
	dlatch dsal_latch (.d(dsal_latch_d), .en(PHI2), .q(DSAL) );
	dlatch dsah_latch (.d(~n_DSA), .en(PHI2), .nq(dsah_latch_nq) );
	wire dsah_latch_nq;
	nor (DSAH, ACR, dsah_latch_nq);

	bcd_nibble bcd_lo (.daa(DAAL), .dsa(DSAL), .sb(SB[3:0]), .bcd(acin[3:0]), .b1(nADD1), .b2(nADD2) );
	bcd_nibble bcd_hi (.daa(DAAH), .dsa(DSAH), .sb(SB[7:4]), .bcd(acin[7:4]), .b1(nADD5), .b2(nADD6) );

	// Accumulator + Bus Mpx

	wire [7:0] acin;

	wire [7:0] ac_d;
	assign ac_d = PHI2 ? AC_q : (SB_AC ? acin : 8'bzzzzzzzz);
	dlatch AC [7:0] (.d(ac_d), .en(8'b11111111), .nq(AC_nq) );
	wire [7:0] AC_nq;
	wire [7:0] AC_q;
	assign AC_q = ~AC_nq;

	assign SB = AC_SB ? AC_q : 8'bzzzzzzzz;
	assign DB = AC_DB ? AC_q : 8'bzzzzzzzz;

	tranif1 sb_db [7:0] (SB, DB, {8{SB_DB}});
	tranif1 sb_adh [7:0] (SB, ADH, {8{SB_ADH}});

	// ADH const gen
	assign ADH[0] = Z_ADH0 ? 1'b0 : 1'bz;
	assign ADH[7:1] = Z_ADH17 ? 7'b0000000 : 7'bzzzzzzz;

endmodule // ALU

// The BCD correction circuitry is symmetrical for each 4-bit nibble
module bcd_nibble (daa, dsa, sb, bcd, b1, b2);

	input daa;
	input dsa;
	input [3:0] sb;
	output [3:0] bcd;
	input b1;
	input b2;

	assign bcd[0] = sb[0];
	xor (bcd[1], ~(daa|dsa), ~sb[1]);
	xor (bcd[2], ((~(b1&daa)) & (~(~b1&dsa))), ~sb[2]);
	wire t1, t2;
	nand (t1, b1, b2);
	nor (t2, b1, b2);
	xor (bcd[3], ((~(t1&daa)) & (~(~t2&dsa))), ~sb[3]);

endmodule // bcd_nibble
