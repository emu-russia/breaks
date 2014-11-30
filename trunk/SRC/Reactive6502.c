// Реактивный 6502.

#include <stdio.h>
#include "reactive.h"

void phi_worker (void)
{
	reactive_item * PHI0 = reactive_get_item ( "PHI0" );
	reactive_item * PHI1 = reactive_get_item ( "PHI1" );
	reactive_item * PHI2 = reactive_get_item ( "PHI2" );

	PHI0->old_value = PHI0->value ^ 1;
	PHI1->old_value = ~PHI0->value & 1;
	PHI2->old_value = PHI2->value & 1;
}

void Clocks (void)
{
	reactive_link ( "PHI1", 0, phi_worker );
	reactive_link ( "PHI2", 0, phi_worker );
}

void Predecode (void)
{

}

main ()
{
	reactive_link ( "PHI0", 0, phi_worker );

	Clocks ();
	Predecode ();

	reactive_assign ( "PHI0", 0 );
}