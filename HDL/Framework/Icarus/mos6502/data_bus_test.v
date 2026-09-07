// Data bus bit + WR latch self-check (BreakingNESWiki/6502/data_bus.md):
//  - Read (RD=1): the external pin value sampled during PHI2 is placed on the
//    internal ADL/ADH/DB lines during the following PHI1 by DL_ADL/DL_ADH/DL_DB.
//  - Write (RD=0, i.e. WR=1 during PHI2): the internal DB value sampled during
//    PHI1 is driven onto the external pin during PHI2 (WRLatch output RD).
// Prints TEST PASS/FAIL.

`timescale 1ns/1ns

module data_bus_test ();

	reg CLK;
	wire PHI1, PHI2;
	always #25 CLK = ~CLK;

	ClkGen clkgen (.PHI0(CLK), .PHI1(PHI1), .PHI2(PHI2) );

	wire ADL, ADH, DB, DB_Ext;
	wire RD;

	reg rd_fixed;			// direct RD for the read test
	reg dl_adl, dl_adh, dl_db;
	reg wr_in;
	wire rd_from_wr;

	reg ext_drv;			// enable external driver
	reg ext_val;
	assign DB_Ext = ext_drv ? ext_val : 1'bz;

	reg db_drv;				// enable internal DB driver
	reg db_val;
	assign DB = db_drv ? db_val : 1'bz;

	DataBusBit databus_bit (
		.PHI1(PHI1),
		.PHI2(PHI2),
		.ADL(ADL),
		.ADH(ADH),
		.DB(DB),
		.DB_Ext(DB_Ext),
		.DL_ADL(dl_adl),
		.DL_ADH(dl_adh),
		.DL_DB(dl_db),
		.RD(rd_fixed) );

	WRLatch wrlatch (
		.PHI1(PHI1),
		.PHI2(PHI2),
		.WR(wr_in),
		.RD(rd_from_wr) );

	integer errors = 0;
	integer cyc = 0;

	task check;
		input [159:0] what;
		input exp;
		input got;
		begin
			cyc = cyc + 1;
			if (got !== exp) begin
				$display("FAIL %0s: got %b, expected %b", what, got, exp);
				errors = errors + 1;
			end
		end
	endtask

	// ---------- read path test ----------
	task read_test;
		input v;
		begin
			// quiet: no internal/external drives
			ext_drv = 0; db_drv = 0;
			dl_adl = 0; dl_adh = 0; dl_db = 0;
			rd_fixed = 1; wr_in = 0;

			@(negedge CLK);					// PHI1 start
			@(posedge CLK);					// PHI2 start
			ext_drv = 1; ext_val = v;		// memory drives the external bus in PHI2
			@(negedge CLK); #2;
			ext_drv = 0;					// external bus released
			// internal lines follow in PHI1
			dl_adl = 1; #3;
			check("read->ADL", v, ADL);
			dl_adl = 0; dl_adh = 1; #1;
			check("read->ADH", v, ADH);
			dl_adh = 0; dl_db = 1; #1;
			check("read->DB", v, DB);
			dl_db = 0;
			@(posedge CLK) #2;				// next PHI2, settle
		end
	endtask

	// ---------- write path test ----------
	task write_test;
		input v;
		begin
			ext_drv = 0; db_drv = 0;
			dl_adl = 0; dl_adh = 0; dl_db = 0;
			rd_fixed = 1; wr_in = 0;

			@(negedge CLK);					// PHI1 start
			// internal data bus driven by the core during PHI1
			db_drv = 1; db_val = v;
			#3;
			check("write PHI1 idle", 1'bz, DB_Ext);	// RD still 1, nothing on pins
			@(posedge CLK);					// PHI2 start
			db_drv = 0;
			wr_in = 1;						// WR=1 -> RD=0 during PHI2
			rd_fixed = 0;					// RD controls the pin driver
			#5;
			check("WR->RD", 1'b0, rd_from_wr);
			check("write->ext", v, DB_Ext);
			@(negedge CLK) #2;
			wr_in = 0;
			rd_fixed = 1;
		end
	endtask

	initial begin
		$dumpfile("data_bus_test.vcd");
		$dumpvars(0, data_bus_test);

		CLK <= 1'b0;
		ext_drv <= 0; db_drv <= 0;
		dl_adl <= 0; dl_adh <= 0; dl_db <= 0;
		rd_fixed <= 1; wr_in <= 0;
		repeat (2) @(posedge CLK);

		read_test(1'b1);
		read_test(1'b0);
		write_test(1'b1);
		write_test(1'b0);

		if (errors == 0)
			$display("data_bus_test: TEST PASS");
		else
			$display("data_bus_test: TEST FAIL (%0d errors)", errors);
		$finish;
	end

endmodule // data_bus_test
