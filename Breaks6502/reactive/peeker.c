/*++

Copyright (c) Breaks Project

Module Name:

    peeker.c

Abstract:

	Module required for storage of intermediate values of reactive variables
	and output into file as needed.

--*/

#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include "reactive.h"

#define PADDING  "%-10s: "
#define BUS_SPEC "%02X "

typedef struct PeekItem 
{
	char 	ItemName[32];
	int 	*Values;
	unsigned  NumValues;
} PeekItem;

static PeekItem * List;
static unsigned ListCount;

//
// Private methods.
//

static PeekItem * GetItem (char *name)
{
    unsigned n;
    for (n=0; n<ListCount; n++)
    {
        if (!strcmp (List[n].ItemName, name) ) return &List[n];
    }
    return NULL;
}

static void AddItem (char *name)
{
    PeekItem Item;

    List = (PeekItem *) realloc ( List, sizeof(PeekItem) * (ListCount + 1) );

    strncpy (Item.ItemName, name, sizeof(Item.ItemName) - 1 );
    Item.Values = NULL;
    Item.NumValues = 0;

    List[ListCount++] = Item;
}

static void AddItemValue (char *name, int value)
{
    PeekItem * Item = GetItem (name);
    if (Item)
    {
        Item->Values = (int *) realloc ( Item->Values, sizeof(int) * (Item->NumValues + 1) );
        Item->Values[Item->NumValues++] = value;
    }
}

//
// Public API.
//

void PeekerAddItem (char *name)
{
    if ( GetItem(name) == NULL)
    {
        AddItem ( name );
    }
}

void PeekerSnapshot (void)
{
    unsigned n;
    reactive_item * item;

    for (n=0; n<ListCount; n++)
    {
        item = reactive_get_item ( List[n].ItemName );
        AddItemValue ( List[n].ItemName, item->value );
    }
}

void PeekerFlush (char *Filename)
{
    unsigned m, n;
    FILE *f;
    PeekItem * Item;

    f = fopen ( Filename, "wt" );

    for (n=0; n<ListCount; n++)
    {
        Item = GetItem ( List[n].ItemName );

        fprintf ( f, PADDING, List[n].ItemName );
        for (m=0; m<Item->NumValues; m++)
        {
            fprintf ( f, BUS_SPEC, Item->Values[m] );
        }
        fprintf (f, "\n");
    }

    fclose (f);
}