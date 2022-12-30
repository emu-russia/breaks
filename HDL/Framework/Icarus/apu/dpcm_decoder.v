`timescale 1ns/1ns

// Run all DPCM decoder values 

module DPCMDecoder_Run();

	reg [3:0] val;
	wire [3:0] Dec_in;
	wire [8:0] Dec_out;

	always #1 val = val + 1;

	assign Dec_in = val;
	DPCM_Decoder dec (.Fx(Dec_in), .FR(Dec_out));

	initial begin

		$dumpfile("dpcm_decoder.vcd");
		$dumpvars(0, dec);

		val <= 0;

		repeat (17) @ (val);
		$finish;
	end

	always @ (val)
		$display ("out:%x", Dec_out);

endmodule // DPCMDecoder_Run
