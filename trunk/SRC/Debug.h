#pragma once

typedef struct GraphTrigger
{
    char    *name;
    int     *link;
    int     x, y;
} GraphTrigger;

typedef struct DebugContext
{
    char    *tabname;
    char    *image;
    GraphTrigger    *triggers;
    int     num_triggers;
    void    (*step) ();
} DebugContext;
