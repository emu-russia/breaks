
// Random logic output "drivers", to control bottom part of 6502

// Address bus
#define DRIVE_ADH_ABH       0
#define DRIVE_ADL_ABL       1
#define DRIVE_0_ADL0        4
#define DRIVE_0_ADL1        5
#define DRIVE_0_ADL2        6

// Registers
#define DRIVE_Y_SB          2
#define DRIVE_X_SB          3
#define DRIVE_SB_Y          7
#define DRIVE_SB_X          8
#define DRIVE_S_SB          9
#define DRIVE_S_ADL         10
#define DRIVE_SB_S          11
#define DRIVE_S_S           12

// ALU drivers
#define DRIVE_NOTDB_ADD     13
#define DRIVE_DB_ADD        14
#define DRIVE_0_ADD         15
#define DRIVE_SB_ADD        16
#define DRIVE_ADL_ADD       17
#define DRIVE_ANDS          18
#define DRIVE_EORS          19
#define DRIVE_ORS           20
#define DRIVE_I_ADDC        21
#define DRIVE_SRS           22
#define DRIVE_SUMS          23
#define DRIVE_DAA           24
#define DRIVE_ADD_SB7       25
#define DRIVE_ADD_SB06      26
#define DRIVE_ADD_ADL       27
#define DRIVE_DSA           28
#define DRIVE_0_ADH0        29
#define DRIVE_SB_DB         30
#define DRIVE_SB_AC         31
#define DRIVE_SB_ADH        32
#define DRIVE_0_ADH17       33
#define DRIVE_AC_SB         34
#define DRIVE_AC_DB         35
                            
// Program Counter
#define DRIVE_ADH_PCH       36
#define DRIVE_PCH_PCH       37
#define DRIVE_PCH_DB        38
#define DRIVE_PCL_DB        39
#define DRIVE_PCH_ADH       40
#define DRIVE_PCL_PCL       41
#define DRIVE_PCL_ADL       42
#define DRIVE_ADL_PCL       43
#define DRIVE_IPC           44

// Data latch
#define DRIVE_DL_ADL        45
#define DRIVE_DL_ADH        46
#define DRIVE_DL_DB         47

void RandomLogicEarly (Context6502 * cpu);
void RandomLogic (Context6502 * cpu);