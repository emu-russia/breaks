// Reactive core.

typedef struct reactive_item
{
	char *name;
	int value;		// выходное значение
	int old_value;	// входное значение
	void (*handler)(void);
} reactive_item;

reactive_item * reactive_get_item ( char * name );

// Добавление реактивной переменной в очередь.
void reactive_link ( char *name, int value, void (*handler)(void) );

// Реактивное присваивание значения переменной.
// a <= value
void reactive_assign ( char *a, int value );

// DEBUG
void reactive_dump (void);