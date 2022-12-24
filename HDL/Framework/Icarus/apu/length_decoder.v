`timescale 1ns/1ns

// Run all Length decoder values 

module LengthDecoder_Run();

	reg [4:0] val;
	wire [7:0] Dec_in;
	wire [7:0] LC_Out;

	always #1 val = val + 1;

	assign Dec_in = {val[4:0],3'b0};
	LengthCounter_PLA pla (.DB(Dec_in), .LC_Out(LC_Out));

	initial begin

		$dumpfile("length_decoder.vcd");
		$dumpvars(0, pla);

		val <= 0;

		repeat (33) @ (val);
		$finish;
	end

	always @ (val)
		$display ("out:%x", LC_Out);

endmodule // LengthDecoder_Run
