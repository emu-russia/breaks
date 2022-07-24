
module ClkGen(PHI0, PHI1, PHI2, PHI1_topad, PHI2_topad);

	input PHI0;
	output PHI1;
	output PHI2;
	output PHI1_topad;
	output PHI2_topad;

	Phi1Gen phi1_tocore (.PHI0(PHI0), .PHI1(PHI1) );
	Phi2Gen phi2_tocore (.PHI0(PHI0), .PHI1(PHI1), .PHI2(PHI2) );

	Phi1Gen phi1_topad (.PHI0(PHI0), .PHI1(PHI1_topad) );
	Phi2Gen phi2_topad (.PHI0(PHI0), .PHI1(PHI1_topad), .PHI2(PHI2_topad) );

endmodule 	// ClkGen

module Phi1Gen(PHI0, PHI1);

	input PHI0;
	output PHI1;

	assign PHI1 = ~(~(~PHI0));

endmodule // Phi1Gen

module Phi2Gen(PHI0, PHI1, PHI2);

	input PHI0;
	input PHI1;
	output PHI2;

	wire tmp1;
	wire tmp2;
	assign tmp1 = ~PHI0 | PHI1;
	assign tmp2 = ~PHI0 & tmp1;
	assign PHI2 = ~(tmp2 ? tmp2 : tmp1);	

endmodule // Phi2Gen
