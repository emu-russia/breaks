// IR (instruction register) self-check:
// while FETCH & PHI1 the register is transparent and stores n_PD
// (IR_out = ~n_PD, i.e. the opcode; n_IR_out = n_PD); otherwise it holds.
// IR01 = IR_out[0] | IR_out[1].
// Prints TEST PASS/FAIL.

`timescale 1ns/1ns

module ir_test ();

	reg CLK;
	reg FETCH;
	reg [7:0] n_pd;
	wire PHI1;
	wire PHI2;

	always #25 CLK = ~CLK;

	ClkGen clk (.PHI0(CLK), .PHI1(PHI1), .PHI2(PHI2));

	wire [7:0] ir_out, n_ir_out;
	wire ir01;

	IR ir (
		.PHI1(PHI1), .PHI2(PHI2),
		.n_PD(n_pd), .FETCH(FETCH),
		.IR01(ir01), .IR_out(ir_out), .n_IR_out(n_ir_out) );

	integer errors = 0;
	integer tests  = 0;

	task check;
		input [159:0] what;
		input [7:0] exp_ir;
		input [7:0] exp_nir;
		begin
			tests = tests + 1;
			if (ir_out !== exp_ir || n_ir_out !== exp_nir) begin
				$display("FAIL %0s: IR_out=%02x n_IR_out=%02x, expected %02x/%02x",
					what, ir_out, n_ir_out, exp_ir, exp_nir);
				errors = errors + 1;
			end
		end
	endtask

	initial begin
		$dumpfile("ir_test.vcd");
		$dumpvars(0, ir_test);

		CLK <= 1'b0;
		FETCH <= 1'b0;
		n_pd <= 8'hA5;

		// initial state (dlatch dout starts 0 -> IR_out = ~0 = FF)
		@(negedge CLK) #10;
		check("initial", 8'hFF, 8'h00);

		// capture n_PD = 0xA5 during PHI1 with FETCH=1
		@(negedge CLK);
		FETCH = 1'b1;
		#10;
		check("fetch A5", ~8'hA5, 8'hA5);
		@(posedge CLK) #10;
		check("hold in PHI2", ~8'hA5, 8'hA5);
		FETCH = 1'b0;

		// change data without FETCH: must hold
		n_pd = 8'h00;
		repeat (2) @(posedge CLK);
		@(negedge CLK) #10;
		check("hold across data change", ~8'hA5, 8'hA5);

		// capture another value (0x3C -> IR_out = 0xC3, IR01 = bit0 = 1)
		@(negedge CLK);
		n_pd = 8'h3C;
		FETCH = 1'b1;
		#10;
		check("fetch 3C", ~8'h3C, 8'h3C);
		FETCH = 1'b0;
		@(negedge CLK) #10;
		check("hold 3C", ~8'h3C, 8'h3C);
		tests = tests + 1;
		if (ir01 !== 1'b1) begin
			$display("FAIL IR01: got %b, expected 1", ir01);
			errors = errors + 1;
		end

		if (errors == 0)
			$display("ir_test: TEST PASS (%0d checks)", tests);
		else
			$display("ir_test: TEST FAIL (%0d of %0d)", errors, tests);
		$finish;
	end

endmodule // ir_test
