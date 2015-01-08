#include <stdio.h>
#include "reactive.h"

// a <= 5
// b <= 2
// a [ a=b ] b
// b <= 7

void a_handler (void)
{
	reactive_item * a = reactive_get_item ( "a" );
	reactive_item * b = reactive_get_item ( "b" );

	a->old_value = b->value;
}

void b_handler (void)
{
	reactive_item * a = reactive_get_item ( "a" );
	reactive_item * b = reactive_get_item ( "b" );

	//b->old_value = a->value;
}

main ()
{
	reactive_link ( "a", 5, a_handler );
	reactive_link ( "b", 2, b_handler );

	//reactive_dump ();

	reactive_assign ( "b", 7 );

	reactive_dump ();
}