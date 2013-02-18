// Example emulation run-flow.
#include "6502.h"
#include <stdio.h>
#include <windows.h>

void *FileLoad(char *filename, long *size, char *mode)
{
    FILE*   f;
    char*   buffer;
    long     filesize;

    if(size) *size = 0;

    f = fopen(filename, mode);
    if(f == NULL) return NULL;

    fseek(f, 0, SEEK_END);
    filesize = ftell(f);
    fseek(f, 0, SEEK_SET);

    buffer = (char*)malloc(filesize + 1);
    if(buffer == NULL)
    {
        fclose(f);
        return NULL;
    }
    memset(buffer, 0, filesize + 1);

    fread(buffer, 1, filesize, f);
    fclose(f);
    if(size) *size = filesize;    
    return buffer;
}

int FileSave (char *filename, void *data, long size, char *mode)
{
    FILE *f = fopen(filename, mode);
    if(f == NULL) return 0;

    fwrite(data, size, 1, f);
    fclose(f);
    return 1;
}

// Return instruction name and operands, without operands decoding.

static char *inames[] = {
 "BRK",     "ORA X,ind", "??? ---", "??? ---", "??? ---",   "ORA zpg  ", "ASL zpg  ", "??? ---", "PHP", "ORA #    ", "ASL A  ", "??? ---", "??? ---",   "ORA abs  ", "ASL abs  ", "??? ---",
 "BPL rel", "ORA ind,Y", "??? ---", "??? ---", "??? ---",   "ORA zpg,X", "ASL zpg,X", "??? ---", "CLC", "ORA abs,Y", "??? ---", "??? ---", "??? ---",   "ORA abs,X", "ASL abs,X", "??? ---",
 "JSR abs", "AND X,ind", "??? ---", "??? ---", "BIT zpg",   "AND zpg  ", "ROL zpg  ", "??? ---", "PLP", "AND #    ", "ROL A  ", "??? ---", "BIT abs",   "AND abs  ", "ROL abs  ", "??? ---",
 "BMI rel", "AND ind,Y", "??? ---", "??? ---", "??? ---",   "AND zpg,X", "ROL zpg,X", "??? ---", "SEC", "AND abs,Y", "??? ---", "??? ---", "??? ---",   "AND abs,X", "ROL abs,X", "??? ---",
 "RTI",     "EOR X,ind", "??? ---", "??? ---", "??? ---",   "EOR zpg  ", "LSR zpg  ", "??? ---", "PHA", "EOR #    ", "LSR A  ", "??? ---", "JMP abs",   "EOR abs  ", "LSR abs  ", "??? ---",
 "BVC rel", "EOR ind,Y", "??? ---", "??? ---", "??? ---",   "EOR zpg,X", "LSR zpg,X", "??? ---", "CLI", "EOR abs,Y", "??? ---", "??? ---", "??? ---",   "EOR abs,X", "LSR abs,X", "??? ---",
 "RTS",     "ADC X,ind", "??? ---", "??? ---", "??? ---",   "ADC zpg  ", "ROR zpg  ", "??? ---", "PLA", "ADC #    ", "ROR A  ", "??? ---", "JMP ind",   "ADC abs  ", "ROR abs  ", "??? ---",
 "BVS rel", "ADC ind,Y", "??? ---", "??? ---", "??? ---",   "ADC zpg,X", "ROR zpg,X", "??? ---", "SEI", "ADC abs,Y", "??? ---", "??? ---", "??? ---",   "ADC abs,X", "ROR abs,X", "??? ---",
 "??? ---", "STA X,ind", "??? ---", "??? ---", "STY zpg",   "STA zpg  ", "STX zpg  ", "??? ---", "DEY", "??? ---  ", "TXA    ", "??? ---", "STY abs",   "STA abs  ", "STX abs  ", "??? ---",
 "BCC rel", "STA ind,Y", "??? ---", "??? ---", "STY zpg,X", "STA zpg,X", "STX zpg,Y", "??? ---", "TYA", "STA abs,Y", "TXS    ", "??? ---", "??? ---",   "STA abs,X", "??? ---  ", "??? ---",
 "LDY #",   "LDA X,ind", "LDX #",   "??? ---", "LDY zpg",   "LDA zpg  ", "LDX zpg  ", "??? ---", "TAY", "LDA #    ", "TAX    ", "??? ---", "LDY abs",   "LDA abs  ", "LDX abs  ", "??? ---",
 "BCS rel", "LDA ind,Y", "??? ---", "??? ---", "LDY zpg,X", "LDA zpg,X", "LDX zpg,Y", "??? ---", "CLV", "LDA abs,Y", "TSX    ", "??? ---", "LDY abs,X", "LDA abs,X", "LDX abs,Y", "??? ---",
 "CPY #",   "CMP X,ind", "??? ---", "??? ---", "CPY zpg",   "CMP zpg  ", "DEC zpg  ", "??? ---", "INY", "CMP #    ", "DEX    ", "??? ---", "CPY abs",   "CMP abs  ", "DEC abs  ", "??? ---",
 "BNE rel", "CMP ind,Y", "??? ---", "??? ---", "??? ---",   "CMP zpg,X", "DEC zpg,X", "??? ---", "CLD", "CMP abs,Y", "??? ---", "??? ---", "??? ---",   "CMP abs,X", "DEC abs,X", "??? ---",
 "CPX #",   "SBC X,ind", "??? ---", "??? ---", "CPX zpg",   "SBC zpg  ", "INC zpg  ", "??? ---", "INX", "SBC #    ", "NOP    ", "??? ---", "CPX abs",   "SBC abs  ", "INC abs  ", "??? ---",
 "BEQ rel", "SBC ind,Y", "??? ---", "??? ---", "??? ---",   "SBC zpg,X", "INC zpg,X", "??? ---", "SED", "SBC abs,Y", "??? ---", "??? ---", "??? ---",   "SBC abs,X", "INC abs,X", "??? ---",
};

char * QuickDisa (unsigned char instr)
{
    return inames[instr];
}

static void TracePLA (void)
{
    ContextM6502 cpu;
    int op, i;
    char text[100000], *ptr = text;

    memset (&cpu, 0, sizeof(cpu));

    ptr += sprintf ( ptr, "<html>");
    ptr += sprintf ( ptr, "<style>\nhtml table {\n    font-family:Calibri; \n    font-size: 16px;\n    border-collapse: collapse; }\n");
    ptr += sprintf ( ptr, "html td {\n    border: 1px dotted; \n} \n</style> <table>");
    ptr += sprintf ( ptr, "<tr><td>op</td><td>instr</td><td>T0</td><td>T1</td><td>T2</td><td>T3</td><td>T4</td><td>T5</td><td>TX</td></tr>");
    for (op=0; op<=0xff; op++) {
        ptr += sprintf ( ptr, "<tr>");
        unpackreg (cpu.reg[M6502_REG_IR], (op) & 0xff, 8);

        ptr += sprintf ( ptr, "<td>%02X</td>", op);
        ptr += sprintf ( ptr, "<td><nobr>%s</nobr></td>", QuickDisa(op) );

        cpu.ctrl[M6502_CTRL_nT0] = 0;
        cpu.ctrl[M6502_CTRL_nT1] = 1;
        cpu.ctrl[M6502_CTRL_nT2] = 1;
        cpu.ctrl[M6502_CTRL_nT3] = 1;
        cpu.ctrl[M6502_CTRL_nT4] = 1;
        cpu.ctrl[M6502_CTRL_nT5] = 1;
        M6502Debug (&cpu, "PLA");
        ptr += sprintf ( ptr, "<td>");
        for (i=0; i<129; i++) {
            if (cpu.bus[M6502_BUS_PLA][i]) ptr += sprintf ( ptr, "%s(%i) ", PLAName(i), i);
        }
        ptr += sprintf ( ptr, "</td>");

        cpu.ctrl[M6502_CTRL_nT0] = 1;
        cpu.ctrl[M6502_CTRL_nT1] = 0;
        cpu.ctrl[M6502_CTRL_nT2] = 1;
        cpu.ctrl[M6502_CTRL_nT3] = 1;
        cpu.ctrl[M6502_CTRL_nT4] = 1;
        cpu.ctrl[M6502_CTRL_nT5] = 1;
        M6502Debug (&cpu, "PLA");
        ptr += sprintf ( ptr, "<td>");
        for (i=0; i<129; i++) {
            if (cpu.bus[M6502_BUS_PLA][i]) ptr += sprintf ( ptr, "%s(%i) ", PLAName(i), i);
        }
        ptr += sprintf ( ptr, "</td>");

        cpu.ctrl[M6502_CTRL_nT0] = 1;
        cpu.ctrl[M6502_CTRL_nT1] = 1;
        cpu.ctrl[M6502_CTRL_nT2] = 0;
        cpu.ctrl[M6502_CTRL_nT3] = 1;
        cpu.ctrl[M6502_CTRL_nT4] = 1;
        cpu.ctrl[M6502_CTRL_nT5] = 1;
        M6502Debug (&cpu, "PLA");
        ptr += sprintf ( ptr, "<td>");
        for (i=0; i<129; i++) {
            if (cpu.bus[M6502_BUS_PLA][i]) ptr += sprintf ( ptr, "%s(%i) ", PLAName(i), i);
        }
        ptr += sprintf ( ptr, "</td>");

        cpu.ctrl[M6502_CTRL_nT0] = 1;
        cpu.ctrl[M6502_CTRL_nT1] = 1;
        cpu.ctrl[M6502_CTRL_nT2] = 1;
        cpu.ctrl[M6502_CTRL_nT3] = 0;
        cpu.ctrl[M6502_CTRL_nT4] = 1;
        cpu.ctrl[M6502_CTRL_nT5] = 1;
        M6502Debug (&cpu, "PLA");
        ptr += sprintf ( ptr, "<td>");
        for (i=0; i<129; i++) {
            if (cpu.bus[M6502_BUS_PLA][i]) ptr += sprintf ( ptr, "%s(%i) ", PLAName(i), i);
        }
        ptr += sprintf ( ptr, "</td>");

        cpu.ctrl[M6502_CTRL_nT0] = 1;
        cpu.ctrl[M6502_CTRL_nT1] = 1;
        cpu.ctrl[M6502_CTRL_nT2] = 1;
        cpu.ctrl[M6502_CTRL_nT3] = 1;
        cpu.ctrl[M6502_CTRL_nT4] = 0;
        cpu.ctrl[M6502_CTRL_nT5] = 1;
        M6502Debug (&cpu, "PLA");
        ptr += sprintf ( ptr, "<td>");
        for (i=0; i<129; i++) {
            if (cpu.bus[M6502_BUS_PLA][i]) ptr += sprintf ( ptr, "%s(%i) ", PLAName(i), i);
        }
        ptr += sprintf ( ptr, "</td>");

        cpu.ctrl[M6502_CTRL_nT0] = 1;
        cpu.ctrl[M6502_CTRL_nT1] = 1;
        cpu.ctrl[M6502_CTRL_nT2] = 1;
        cpu.ctrl[M6502_CTRL_nT3] = 1;
        cpu.ctrl[M6502_CTRL_nT4] = 1;
        cpu.ctrl[M6502_CTRL_nT5] = 0;
        M6502Debug (&cpu, "PLA");
        ptr += sprintf ( ptr, "<td>");
        for (i=0; i<129; i++) {
            if (cpu.bus[M6502_BUS_PLA][i]) ptr += sprintf ( ptr, "%s(%i) ", PLAName(i), i);
        }
        ptr += sprintf ( ptr, "</td>");

        cpu.ctrl[M6502_CTRL_nT0] = 1;
        cpu.ctrl[M6502_CTRL_nT1] = 1;
        cpu.ctrl[M6502_CTRL_nT2] = 1;
        cpu.ctrl[M6502_CTRL_nT3] = 1;
        cpu.ctrl[M6502_CTRL_nT4] = 1;
        cpu.ctrl[M6502_CTRL_nT5] = 1;
        M6502Debug (&cpu, "PLA");
        ptr += sprintf ( ptr, "<td>");
        for (i=0; i<129; i++) {
            if (cpu.bus[M6502_BUS_PLA][i]) ptr += sprintf ( ptr, "%s(%i) ", PLAName(i), i);
        }
        ptr += sprintf ( ptr, "</td>");

        ptr += sprintf ( ptr, "</tr>");
    }
    ptr += sprintf ( ptr, "</table></html>");

    FileSave ("PLA.htm", text, strlen(text), "wt");
}

// --------------------------------------------------------------------------
// test program counter (LOW)

void test_pcl (ContextM6502 *cpu)
{
    int i, PCLC = 1, PCHC, carry_in, carry_out, old;

    if ( cpu->bus[M6502_BUS_RANDOM][M6502_IPC] ) PCLC = 0;

    carry_out = cpu->bus[M6502_BUS_RANDOM][M6502_IPC];

    for (i=0; i<8; i++) {
        carry_in = carry_out;
        if ( i & 1 ) {
            carry_out = NAND( cpu->reg[M6502_REG_PCLS][i], carry_in );
            if (cpu->pad[M6502_PAD_PHI2])
                cpu->reg[M6502_REG_PCL][i] = NOR(carry_in, cpu->reg[M6502_REG_PCLS][i]) | NOT(carry_out);
            if (cpu->bus[M6502_BUS_RANDOM][M6502_PCL_PCL])
                cpu->reg[M6502_REG_PCLS][i] = NOT(cpu->reg[M6502_REG_PCL][i]);
        }
        else {
            carry_out = NOR( NOT(cpu->reg[M6502_REG_PCLS][i]), carry_in );
            if (cpu->pad[M6502_PAD_PHI2])
                cpu->reg[M6502_REG_PCL][i] = NAND(carry_in, NOT(cpu->reg[M6502_REG_PCLS][i])) & NOT(carry_out);
            if (cpu->bus[M6502_BUS_RANDOM][M6502_PCL_PCL])
                cpu->reg[M6502_REG_PCLS][i] = cpu->reg[M6502_REG_PCL][i];
        }
        if (cpu->reg[M6502_REG_PCLS][i] == 0) PCLC = 0;
    }

}

// --------------------------------------------------------------------------

void PROGRAM_COUNTER_SETUP (int clk, int T0, int T1, int BRK2)
{
    int     phi1 = NOT(clk);
    int     phi2 = clk;

    static  int ReadyLatch=0, PCLDB=0;

    // input control lines
    int     nready = 0,
            JSR3 = 0, JSR5 = 0,
            BR0 = 0, BR2 = 0, BR3 = 0,
            ABS2 = 0,
            RTS5 = 0,
            JB = 0;

    // output drivers + output latches
    int     ADH_PCH, PCH_PCH, PCH_DB, PCL_DB, PCH_ADH, PCL_PCL, PCL_ADL, ADL_PCL;
    static  int  ADH_PCHLatch=0, PCH_PCHLatch=0, PCH_DBLatch=0, PCL_DBLatch=0, 
                 PCH_ADHLatch=0, PCL_PCLLatch=0, PCL_ADLLatch=0, ADL_PCLLatch=0;

    // ----- SIM

    if (phi1) {
        ReadyLatch = nready;
        PCLDB = NOR(PCH_DBLatch,nready);
    }

    if (phi2) {
        ADH_PCHLatch = NOT(T1 | BR2 | T0 | BR3 | ABS2 | RTS5);
        PCH_PCHLatch = NOT(ADH_PCHLatch);
        PCH_DBLatch = NOR( BRK2, JSR3 );
        PCL_DBLatch = NOT(PCLDB);
        PCL_ADLLatch = NOT (ABS2 | T0 | BR2 | JSR5 | NOR(NOT(T1),NOR(JB,ReadyLatch)) );
        PCH_ADHLatch = NOR(BR2, NOT(PCL_ADLLatch|BR0|NOR(JB,NOT(T1))) );
        ADL_PCLLatch = NOR (T1, NOT(PCL_ADLLatch));
        PCL_PCLLatch = NOT(ADL_PCLLatch);
    }

    ADH_PCH = NOT(ADH_PCHLatch);
    PCH_PCH = NOT(PCH_PCHLatch);
    PCH_DB = NOT(PCH_DBLatch);
    PCL_DB = NOT(PCL_DBLatch);
    PCH_ADH = NOT(PCH_ADHLatch);
    PCL_PCL = NOT(PCL_PCLLatch);
    PCL_ADL = NOT(PCL_ADLLatch);
    ADL_PCL = NOT(ADL_PCLLatch);

    if (phi2) ADH_PCH = PCH_PCH = PCL_PCL = ADL_PCL = 0;           

    if (phi1) printf ("PHI1: ");
    if (phi2) printf ("PHI2: ");
    if (ADH_PCH) printf ("ADH/PCH ");
    if (PCH_PCH) printf ("PCH/PCH ");
    if (PCH_DB) printf ("PCH/DB ");
    if (PCL_DB) printf ("PCL/DB ");
    if (PCH_ADH) printf ("PCH/ADH ");
    if (PCL_PCL) printf ("PCL/PCL ");
    if (PCL_ADL) printf ("PCL/ADL ");
    if (ADL_PCL) printf ("ADL/PCL ");
    printf ("\n");
}

// --------------------------------------------------------------------------

void ALU2 (int clk, int ain, int bin, int carry, int adc);

// --------------------------------------------------------------------------

// Push random data
// TODO: Add infinite cycle test program.
static void DummyMemoryDevice (ContextM6502 *cpu)
{
    if ( cpu->pad[M6502_PAD_PHI2] ) cpu->pad[M6502_PAD_DATA] = rand() & 0xff; 
}

main ()
{
/*
    DWORD old;
    ContextM6502 cpu;
    memset (&cpu, 0, sizeof(cpu));

    // default conditions (no interrupts, no reset, 6502 ready)
    cpu.pad[M6502_PAD_nNMI] = 1;
    cpu.pad[M6502_PAD_nIRQ] = 1;
    cpu.pad[M6502_PAD_nRES] = 1;
    cpu.pad[M6502_PAD_RDY] = 1;

    cpu.debug[M6502_DEBUG_OUT] = 0;

    // prepare pcl test.
    cpu.bus[M6502_BUS_RANDOM][M6502_IPC] = 0;

    // Execute real 1 second.
    srand ( 0xaabb );
    old = GetTickCount ();
    while (1) {
        if ( (GetTickCount () - old) >= 1000 ) break;
        //M6502Step (&cpu);

        cpu.bus[M6502_BUS_RANDOM][M6502_PCL_PCL] = 1;

        M6502Debug (&cpu, "CLK" );
        test_pcl (&cpu);

        if (cpu.pad[M6502_PAD_PHI0] == 0)   // PHI2
        {
            unsigned char pcl = packreg(cpu.reg[M6502_REG_PCLS],8);
            printf ( "PCL = %02X\n", pcl );
        }

        //DummyMemoryDevice (&cpu);
        cpu.pad[M6502_PAD_PHI0] ^= 1;
    }
    printf ("Executed %.4fM/4M cycles\n", (float)cpu.debug[M6502_DEBUG_CLKCOUNT]/1000000.0f );
*/

    TracePLA ();
}
