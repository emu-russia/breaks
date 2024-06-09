// Testing the extra counter (T2-T5), which is actually a shift register (weird one)

`timescale 1ns/1ns

module ExtraCounter_Run();

	reg CLK;
	wire PHI1;
	wire PHI2;

	reg TRES2;
	reg n_ready;
	reg T1;

	always #1 CLK = ~CLK;

	ClkGen clk (.PHI0(CLK), .PHI1(PHI1), .PHI2(PHI2));

	ExtraCounter extra_cnt (
		.PHI1(PHI1), .PHI2(PHI2), .TRES2(TRES2), .n_ready(n_ready), .T1(T1));

	initial begin

		$dumpfile("excnt_test.vcd");
		$dumpvars(0, ExtraCounter_Run);

		CLK <= 1'b0;
		TRES2 <= 1'b0;
		n_ready <= 1'b0;
		T1 <= 1'b0;

		// Just work

		repeat (4) @ (posedge CLK);

		// Load T1 and check how it is pushed out through outputs T2-T5

		T1 <= 1'b1;
		repeat (1) @ (posedge CLK);
		T1 <= 1'b0;
		repeat (8) @ (posedge CLK);

		// Load T1, then suddenly do NotReady; then ready

		T1 <= 1'b1;
		repeat (1) @ (posedge CLK);
		T1 <= 1'b0;
		repeat (2) @ (posedge CLK);
		n_ready <= 1'b1;
		repeat (4) @ (posedge CLK);
		n_ready <= 1'b0;
		repeat (4) @ (posedge CLK);

		// Load T1, then suddenly do TRES2; then just work

		T1 <= 1'b1;
		repeat (1) @ (posedge CLK);
		T1 <= 1'b0;
		repeat (2) @ (posedge CLK);
		TRES2 <= 1'b1;
		repeat (4) @ (posedge CLK);
		TRES2 <= 1'b0;
		repeat (4) @ (posedge CLK);

		$finish;
	end

endmodule // ExtraCounter_Run
