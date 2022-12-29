// Common elements of APU circuitry

module RegisterBit (n_ACLK, ena, d, q, nq);
	input n_ACLK;
	input ena;
	input d;
	output q;
	output nq;

	wire tq;
	wire ntq;
	wire latch_in;

	assign latch_in = ena ? d : (n_ACLK ? q : 1'bz);
	dlatch transp (.d(latch_in), .en(1'b1), .nq(ntq));
	assign tq = ~ntq;
	assign q = tq;
	assign nq = ntq;

endmodule // RegisterBit

module RegisterBitRes (n_ACLK, ena, d, res, q, nq);

	input n_ACLK;
	input ena;
	input d;
	input res;
	output q;
	output nq;

	wire tq;
	wire ntq;
	wire latch_in;

	assign latch_in = ena ? d : (n_ACLK ? q : 1'bz);
	dlatch transp (.d(latch_in & ~res), .en(1'b1), .nq(ntq));
	assign tq = ~ntq;
	assign q = tq;
	assign nq = ntq;

endmodule // RegisterBitRes2

module RegisterBitRes2 (n_ACLK, ena, d, res1, res2, q, nq);

	input n_ACLK;
	input ena;
	input d;
	input res1;
	input res2;
	output q;
	output nq;

	wire tq;
	wire ntq;
	wire latch_in;

	assign latch_in = ena ? d : (n_ACLK ? q : 1'bz);
	dlatch transp (.d(latch_in & ~(res1 | res2)), .en(1'b1), .nq(ntq));
	assign tq = ~ntq;
	assign q = tq;
	assign nq = ntq;

endmodule // RegisterBitRes2

module CounterBit (n_ACLK, d, load, clear, step, cin, q, nq, cout);
	input n_ACLK;
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

	assign latch_in = load ? d : (clear ? 1'b0 : (step ? cgnq : (n_ACLK ? tq : 1'bz) ) );
	dlatch transp (.d(latch_in), .en(1'b1), .nq(ntq));
	assign tq = ~ntq;

	dlatch cg (.d(cin ? tq : ntq), .en(n_ACLK), .nq(cgnq));

	assign cout = ~(~cin | ntq);
	assign q = tq;
	assign nq = ntq;

endmodule // CounterBit

module DownCounterBit (n_ACLK, d, load, clear, step, cin, q, nq, cout);
	input n_ACLK;
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

	assign latch_in = load ? d : (clear ? 1'b0 : (step ? cgnq : (n_ACLK ? tq : 1'bz) ) );
	dlatch transp (.d(latch_in), .en(1'b1), .nq(ntq));
	assign tq = ~ntq;

	dlatch cg (.d(cin ? tq : ntq), .en(n_ACLK), .nq(cgnq));

	assign cout = ~(~cin | tq);
	assign q = tq;
	assign nq = ntq;

endmodule // DownCounterBit

module RevCounterBit (n_ACLK, d, load, clear, step, cin, dec, q, nq, cout);
	input n_ACLK;
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

	assign latch_in = load ? d : (clear ? 1'b0 : (step ? cgnq : (n_ACLK ? tq : 1'bz) ) );
	dlatch transp (.d(latch_in), .en(1'b1), .nq(ntq));
	assign tq = ~ntq;

	dlatch cg (.d(cin ? tq : ntq), .en(n_ACLK), .nq(cgnq));

	assign cout = ~(~cin | (dec ? tq : ntq));
	assign q = tq;
	assign nq = ntq;

endmodule // RevCounterBit
