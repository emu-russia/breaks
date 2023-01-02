`timescale 1ns/1ns

// Run all Noise decoder values 

module NoiseDecoder_Run();

	reg [4:0] val;
	wire [3:0] NF;
	wire [10:0] NNF;

	always #1 val = val + 1;

	assign NF = val[4:0];
	NOISE_Decoder dec (.NF(NF), .NNF(NNF));

	initial begin

		$dumpfile("noise_decoder.vcd");
		$dumpvars(0, dec);

		val <= 0;

		repeat (17) @ (val);
		$finish;
	end

	always @ (val)
		$display ("out:%x", NNF);

endmodule // NoiseDecoder_Run
