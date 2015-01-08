// Reactive 6502.

#include <stdio.h>
#include "reactive.h"
#include "peeker.h"

#define RUNOUT 100

//
// Bit manipulating macros.
//

#define BIT(value,n) (((value) >> (n)) & 1)

// HACK: Motherboard
void databus_worker (void)
{
	static unsigned value = 0x00;
	reactive_item * DATA = reactive_get_item ( "DATA" );

	// Bogus.

	//value++;
	DATA->old_value = 0xaa;//value & 0xff;
}

void BoardInit (void)
{
	reactive_link ( "DATA", 0, databus_worker );

	PeekerAddItem ("DATA");
}

// ---

void phi_worker (void)
{
	static unsigned Rundown = RUNOUT;

	reactive_item * PHI0 = reactive_get_item ( "PHI0" );
	reactive_item * PHI1 = reactive_get_item ( "PHI1" );
	reactive_item * PHI2 = reactive_get_item ( "PHI2" );

	if (Rundown) Rundown--;
	else return;

	PHI0->old_value = PHI0->value ^ 1;
	PHI1->old_value = ~PHI0->value & 1;
	PHI2->old_value = PHI0->value & 1;

	PeekerSnapshot ();
}

void predecode_worker (void)
{
	int pdout, temp1, temp2;

	// Inputs
	reactive_item * PHI2 = reactive_get_item ( "PHI2" );
	reactive_item * Z_IR = reactive_get_item ( "Z_IR" );
	reactive_item * DATA = reactive_get_item ( "DATA" );

	// Outputs
	reactive_item * PD = reactive_get_item ( "PD" );
	reactive_item * _IMPLIED = reactive_get_item ( "_IMPLIED" );
	reactive_item * _TWOCYCLE = reactive_get_item ( "_TWOCYCLE" );

	//
	// Logic.
	//

	_IMPLIED->old_value = BIT(pdout,0) | BIT(pdout,2) | ~BIT(pdout,3) & 1;

	pdout = Z_IR->value ? 0 : PD->value;

	temp1 = ~( ~BIT(pdout,0) | BIT(pdout,2) | ~BIT(pdout,3) | BIT(pdout,4) ) & 1;
	temp2 = ~( BIT(pdout,0) | BIT(pdout,2) | BIT(pdout,3) | BIT(pdout,4) | ~BIT(pdout,7) ) & 1;

	_TWOCYCLE->old_value = (~(temp1 | temp2) & ~(~_IMPLIED->old_value & (BIT(pdout,1) | BIT(pdout,4) | BIT(pdout,7)))) & 1;

	if (PHI2->value) PD->old_value = DATA->value;
}

void dispatch_worker (void)
{
	// Dummy.
}

void ClocksInit (void)
{
	reactive_link ( "PHI1", 0, phi_worker );
	reactive_link ( "PHI2", 0, phi_worker );

	PeekerAddItem ("PHI1");
	PeekerAddItem ("PHI2");
}

void PredecodeInit (void)
{
	reactive_link ( "PD", 0, predecode_worker );
	reactive_link ( "_IMPLIED", 0, predecode_worker );
	reactive_link ( "_TWOCYCLE", 0, predecode_worker );

	PeekerAddItem ("PD");
	PeekerAddItem ("_IMPLIED");
	PeekerAddItem ("_TWOCYCLE");
}

void DispatcherInit (void)
{
	reactive_link ( "Z_IR", 0, dispatch_worker );
}

// HACK: Should be actually Mos6502Init.
main ()
{
	BoardInit ();

	reactive_link ( "PHI0", 0, phi_worker );
	PeekerAddItem ("PHI0");

	ClocksInit ();
	PredecodeInit ();
	DispatcherInit ();

	reactive_assign ( "PHI0", 0 );

	PeekerFlush ("state.txt");
}