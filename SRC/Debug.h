#pragma once

typedef struct GraphTrigger
{
    char    *name;
    int     *link;
    int     x, y;
} GraphTrigger;

typedef struct GraphLocator
{
    char    *name;
    int     coord_x, coord_y;
} GraphLocator;

typedef struct GraphCollector
{
    int     coord_x, coord_y;
    int     width, height;
    char    *font;
    int     fontSize;
    unsigned long (*getter)();
    void    (*setter) (unsigned long);
    char    *format;
} GraphCollector;

typedef struct DebugContext
{
    char    *tabname;
    char    *image;
    GraphTrigger    *triggers;
    int     num_triggers;
    GraphLocator    *locators;
    int     num_locators;
    GraphCollector  *collectors;
    int     num_collectors;
    void    (*step) ();
} DebugContext;
