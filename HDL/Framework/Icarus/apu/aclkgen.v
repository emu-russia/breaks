// A number of tests require simulation of the ACLK phase pattern.
// To avoid dragging the entire APU - this module contains the minimum number of modules needed to generate ACLK1/#ACLK2 signals.

module AclkGenStandalone (CLK, RES, PHI1, ACLK1, nACLK2);

	input CLK; 
	input RES; 
	output PHI1;			// Sometimes it is required from the outside (triangle channel for example)
	output ACLK1;
	output nACLK2; 

	wire PHI0;
	wire PHI2;

	// The ACLK pattern requires all of these "spares".

	CLK_Divider div (
		.n_CLK_frompad(~CLK),
		.PHI0_tocore(PHI0));

	BogusCorePhi phi (.PHI0(PHI0), .PHI1(PHI1), .PHI2(PHI2));

	ACLKGen clkgen (
		.PHI1(PHI1),
		.PHI2(PHI2),
		.nACLK2(nACLK2),
		.ACLK1(ACLK1),
		.RES(RES));	

endmodule // AclkGenStandalone

module BogusCorePhi (PHI0, PHI1, PHI2);
	
	input PHI0;
	output PHI1;
	output PHI2;

	assign PHI1 = ~PHI0;
	assign PHI2 = PHI0;

endmodule // BogusCorePhi
