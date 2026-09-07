// Pads logic self-check:
//  - SYNC is a plain buffer of T1_topad.
//  - RnW = ~WR latched during PHI1 (visible during PHI2).
//  - /NMI, /IRQ, /RES are sampled during PHI2 into their flip-flops;
//    n_NMIP/n_IRQP are active low while the pin is asserted, RESP is high
//    while /RES is low (after settling).
//  - RDY_frompad follows RDY; with SO held high SO_frompad stays low.
// Prints TEST PASS/FAIL.

`timescale 1ns/1ns

module pads_test ();

	reg CLK;
	wire PHI1, PHI2;
	always #25 CLK = ~CLK;

	ClkGen clkgen (.PHI0(CLK), .PHI1(PHI1), .PHI2(PHI2) );

	reg n_nmi, n_irq, n_res, rdy, t1_topad, so, wr_topad;
	wire n_nmip, n_irqp, resp, rdy_frompad, n_prdy, sync, so_frompad, rnw;

	PadsLogic pads (
		.PHI1(PHI1),
		.PHI2(PHI2),
		.n_NMI(n_nmi),
		.n_IRQ(n_irq),
		.n_RES(n_res),
		.n_NMIP(n_nmip),
		.n_IRQP(n_irqp),
		.RESP(resp),
		.RDY(rdy),
		.RDY_frompad(rdy_frompad),
		.n_PRDY(n_prdy),
		.T1_topad(t1_topad),
		.SYNC(sync),
		.SO(so),
		.SO_frompad(so_frompad),
		.WR_topad(wr_topad),
		.RnW(rnw) );

	integer errors = 0;
	integer tests  = 0;

	task check;
		input [159:0] what;
		input exp;
		input got;
		begin
			tests = tests + 1;
			if (got !== exp) begin
				$display("FAIL %0s: got %b, expected %b", what, got, exp);
				errors = errors + 1;
			end
		end
	endtask

	initial begin
		$dumpfile("pads_test.vcd");
		$dumpvars(0, pads_test);

		CLK <= 1'b0;
		n_nmi <= 1; n_irq <= 1; n_res <= 1;
		rdy <= 1; t1_topad <= 0; so <= 1; wr_topad <= 0;
		repeat (4) @(posedge CLK);

		// SYNC buffer
		@(negedge CLK); #3;
		t1_topad = 1;
		#3;
		check("SYNC buf 1", 1'b1, sync);
		t1_topad = 0;
		#3;
		check("SYNC buf 0", 1'b0, sync);

		// RDY passthrough + RnW latch
		rdy = 0; wr_topad = 1;
		@(posedge CLK) #10;			// PHI2
		check("RDY_frompad", 1'b0, rdy_frompad);
		check("RnW=~WR", 1'b0, rnw);		// write
		@(negedge CLK);
		wr_topad = 0; rdy = 1;
		@(posedge CLK) #10;
		check("RnW read", 1'b1, rnw);

		// reset / interrupt sampling
		@(negedge CLK); #2;
		n_res = 0; n_nmi = 0; n_irq = 0;
		repeat (3) @(posedge CLK);
		@(posedge CLK) #10;
		check("RESP high", 1'b1, resp);
		check("n_NMIP low", 1'b0, n_nmip);
		check("n_IRQP low", 1'b0, n_irqp);

		n_res = 1; n_nmi = 1; n_irq = 1;
		repeat (3) @(posedge CLK);
		@(posedge CLK) #10;
		check("RESP low", 1'b0, resp);
		check("n_NMIP high", 1'b1, n_nmip);
		check("n_IRQP high", 1'b1, n_irqp);

		// SO held high -> no overflow pulse
		check("SO_frompad idle", 1'b0, so_frompad);

		if (errors == 0)
			$display("pads_test: TEST PASS (%0d checks)", tests);
		else
			$display("pads_test: TEST FAIL (%0d of %0d)", errors, tests);
		$finish;
	end

endmodule // pads_test
