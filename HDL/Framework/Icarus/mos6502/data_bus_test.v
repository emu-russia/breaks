`timescale 1ns/1ns

module data_bus_test ();

	reg CLK;
	wire PHI1, PHI2;
	always #25 CLK = ~CLK;

	ClkGen clkgen (.PHI0(CLK), .PHI1(PHI1), .PHI2(PHI2) );

	wire ADL, ADH, DB, DB_Ext;

	DataBusBit databus_bit (
		.PHI1(PHI1),
		.PHI2(PHI2),
		.ADL(ADL), 
		.ADH(ADH), 
		.DB(DB), 
		.DB_Ext(DB_Ext),
		.DL_ADL(1'b0), 
		.DL_ADH(1'b0), 
		.DL_DB(1'b0),
		.RD(RD) );

	WRLatch wrlatch (
		.PHI1(PHI1), 
		.PHI2(PHI2), 
		.WR(1'b0),  		// From dispatch
		.RD(RD) );

	wire RD;

	initial begin

		$dumpfile("data_bus_test.vcd");
		$dumpvars(0, data_bus_test);

		CLK <= 1'b0;

		repeat (256) @ (posedge CLK);
		$finish;
	end

endmodule // data_bus_test
