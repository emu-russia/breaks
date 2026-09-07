// Clock generator self-check:
// According to BreakingNESWiki/6502 whatwhen.md:
//   PHI1 is high when PHI0 is low, PHI2 tracks PHI0.
// Check the phase relationship (including the "topad" outputs) on both
// edges over many cycles. Prints TEST PASS/FAIL.

`timescale 1ns/1ns

module clock_test ();

	reg CLK;
	always #25 CLK = ~CLK;

	wire PHI1, PHI2, PHI1_topad, PHI2_topad;

	ClkGen clkgen (.PHI0(CLK), .PHI1(PHI1), .PHI2(PHI2), .PHI1_topad(PHI1_topad), .PHI2_topad(PHI2_topad) );

	integer errors = 0;
	integer cyc = 0;

	// Sample mid-PHI2 and mid-PHI1 (away from the edges).
	task check;
		input [159:0] where;
		input exp_phi1;
		input exp_phi2;
		begin
			cyc = cyc + 1;
			if (PHI1 !== exp_phi1) begin
				$display("FAIL %0s: PHI1=%b, expected %b (cyc=%0d)", where, PHI1, exp_phi1, cyc);
				errors = errors + 1;
			end
			if (PHI2 !== exp_phi2) begin
				$display("FAIL %0s: PHI2=%b, expected %b (cyc=%0d)", where, PHI2, exp_phi2, cyc);
				errors = errors + 1;
			end
			if (PHI1_topad !== exp_phi1 || PHI2_topad !== exp_phi2) begin
				$display("FAIL %0s: pad PHI1/PHI2 = %b/%b, expected %b/%b", where, PHI1_topad, PHI2_topad, exp_phi1, exp_phi2);
				errors = errors + 1;
			end
		end
	endtask

	initial begin
		$dumpfile("clock_test.vcd");
		$dumpvars(0, clock_test);

		CLK <= 1'b0;
		repeat (2) @(posedge CLK);		// let it settle

		// PHI2 half: PHI0=1 -> PHI1=0, PHI2=1
		repeat (64) begin
			@(posedge CLK); #5;
			check("P2", 1'b0, 1'b1);
			@(negedge CLK); #5;
			check("P1", 1'b1, 1'b0);
		end

		if (errors == 0)
			$display("clock_test: TEST PASS");
		else
			$display("clock_test: TEST FAIL (%0d errors)", errors);
		$finish;
	end

endmodule // clock_test
