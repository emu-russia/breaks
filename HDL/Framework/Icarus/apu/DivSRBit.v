`timescale 1ns/1ns

module DivSRBit_Run();

	reg CLK;

	wire q;
	wire nq;
	wire n_val;
	wire sout;

	always #25 CLK = ~CLK;

	assign q = CLK;
	assign nq = ~CLK;

	DivSRBit sr_bit (
		.q(q),
		.nq(nq),
		.rst(1'b0),
		.sin(1'b0),
		.n_val(n_val),
		.sout(sout) );

	initial begin

		CLK <= 1'b0;

		$dumpfile("DivSRBit.vcd");
		$dumpvars(0, sr_bit);

		repeat (20) @ (posedge CLK);
		$finish;
	end

endmodule // DivSRBit_Run
