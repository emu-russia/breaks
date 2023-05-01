// Common elements of APU circuitry

module RegisterBit (ACLK1, ena, d, q, nq);
	input ACLK1;
	input ena;
	input d;
	output q;
	output nq;

	wire tq;
	wire ntq;
	wire latch_in;

	assign latch_in = ena ? d : (ACLK1 ? q : 1'bz);
	dlatch transp (.d(latch_in), .en(1'b1), .nq(ntq));
	assign tq = ~ntq;
	assign q = tq;
	assign nq = ntq;

endmodule // RegisterBit

module RegisterBitRes (ACLK1, ena, d, res, q, nq);

	input ACLK1;
	input ena;
	input d;
	input res;
	output q;
	output nq;

	wire tq;
	wire ntq;
	wire latch_in;

	assign latch_in = ena ? d : (ACLK1 ? q : 1'bz);
	dlatch transp (.d(latch_in & ~res), .en(1'b1), .nq(ntq));
	assign tq = ~ntq;
	assign q = tq;
	assign nq = ntq;

endmodule // RegisterBitRes2

module RegisterBitRes2 (ACLK1, ena, d, res1, res2, q, nq);

	input ACLK1;
	input ena;
	input d;
	input res1;
	input res2;
	output q;
	output nq;

	wire tq;
	wire ntq;
	wire latch_in;

	assign latch_in = ena ? d : (ACLK1 ? q : 1'bz);
	dlatch transp (.d(latch_in & ~(res1 | res2)), .en(1'b1), .nq(ntq));
	assign tq = ~ntq;
	assign q = tq;
	assign nq = ntq;

endmodule // RegisterBitRes2

module CounterBit (ACLK1, d, load, clear, step, cin, q, nq, cout);
	input ACLK1;
	input d;
	input load;
	input clear;
	input step;
	input cin;
	output q;
	output nq;
	output cout;

	wire tq;
	wire ntq;
	wire latch_in;
	wire cgnq;

	assign latch_in = load ? d : (clear ? 1'b0 : (step ? cgnq : (ACLK1 ? tq : 1'bz) ) );
	dlatch transp (.d(latch_in), .en(1'b1), .nq(ntq));
	assign tq = ~ntq;

	dlatch cg (.d(cin ? tq : ntq), .en(ACLK1), .nq(cgnq));

	assign cout = ~(~cin | ntq);
	assign q = tq;
	assign nq = ntq;

endmodule // CounterBit

module DownCounterBit (ACLK1, d, load, clear, step, cin, q, nq, cout);
	input ACLK1;
	input d;
	input load;
	input clear;
	input step;
	input cin;
	output q;
	output nq;
	output cout;

	wire tq;
	wire ntq;
	wire latch_in;
	wire cgnq;

	assign latch_in = load ? d : (clear ? 1'b0 : (step ? cgnq : (ACLK1 ? tq : 1'bz) ) );
	dlatch transp (.d(latch_in), .en(1'b1), .nq(ntq));
	assign tq = ~ntq;

	dlatch cg (.d(cin ? tq : ntq), .en(ACLK1), .nq(cgnq));

	assign cout = ~(~cin | tq);
	assign q = tq;
	assign nq = ntq;

endmodule // DownCounterBit

module RevCounterBit (ACLK1, d, load, clear, step, cin, dec, q, nq, cout);
	input ACLK1;
	input d;
	input load;
	input clear;
	input step;
	input cin;
	input dec;
	output q;
	output nq;
	output cout;

	wire tq;
	wire ntq;
	wire latch_in;
	wire cgnq;

	assign latch_in = load ? d : (clear ? 1'b0 : (step ? cgnq : (ACLK1 ? tq : 1'bz) ) );
	dlatch transp (.d(latch_in), .en(1'b1), .nq(ntq));
	assign tq = ~ntq;

	dlatch cg (.d(cin ? tq : ntq), .en(ACLK1), .nq(cgnq));

	assign cout = ~(~cin | (dec ? tq : ntq));
	assign q = tq;
	assign nq = ntq;

endmodule // RevCounterBit
