// Reactive.

#include <stdlib.h>
#include <string.h>
#include "reactive.h"

static reactive_item *queue;
static int queue_num = 0;

reactive_item * reactive_get_item ( char * name )
{
	int i;
	for (i=0; i<queue_num; i++)
	{
		if (!strcmp ( name, queue[i].name )) return &queue[i];
	}
	return NULL;
}

// Раскрутить реактивные связи.
static void reactive_dispatch (void)
{
	int i, stable = 0, iteration = 0;
	while (!stable)
	{
		printf ( "Iteration %i. Current values\n", iteration);
		reactive_dump ();

		// Обработчики изменяют свои текущие значения
		for (i=0; i<queue_num; i++)
		{
			if(queue[i].handler)
				queue[i].handler ();
		}

		printf ( "Iteration %i. New values\n", iteration);
		reactive_dump ();

		// Если все новые значения равны старым, то выходим
		stable = 1;
		for (i=0; i<queue_num; i++)
		{
			if ( queue[i].old_value != queue[i].value )
				stable = 0;
		}

		printf ( "Iteration %i. Stable=%i\n", iteration, stable);

		if (stable) break;

		// Переносим текущие значения на выход
		for (i=0; i<queue_num; i++)
			queue[i].value = queue[i].old_value;

		printf ( "Iteration %i. Output\n", iteration);

		iteration++;
	}
}

// Добавление реактивной переменной в очередь.
void reactive_link ( char *name, int value, void (*handler)(void) )
{
	reactive_item item;

	// Если уже есть, то не добавляем.
	if ( reactive_get_item (name) ) return;

	item.name = name;
	item.value = item.old_value = value;
	item.handler = handler;

	queue = (reactive_item *)realloc ( queue, queue_num + 1 );
	memcpy ( &queue[queue_num], &item, sizeof(reactive_item) );	
	queue_num ++;
}

// Реактивное присваивание значения переменной.
// a <= value
void reactive_assign ( char *a, int value)
{
	reactive_item * item;

	item = reactive_get_item ( a );
	if ( item ) {
		item->old_value = value;
		reactive_dispatch ();
	}
}

// DEBUG
void reactive_dump (void)
{
	reactive_item * item;
	int i;
	for (i=0; i<queue_num; i++)
	{
		item = &queue[i];
		printf ( "Variable: %s, value=%i, old_value=%i\n",
				item->name, item->value, item->old_value );
	}
}