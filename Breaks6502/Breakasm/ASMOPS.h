
#pragma once

void opBRK(char* cmd, char* ops);
void opRTI(char* cmd, char* ops);
void opRTS(char* cmd, char* ops);

void opPHP(char* cmd, char* ops);
void opCLC(char* cmd, char* ops);
void opPLP(char* cmd, char* ops);
void opSEC(char* cmd, char* ops);
void opPHA(char* cmd, char* ops);
void opCLI(char* cmd, char* ops);
void opPLA(char* cmd, char* ops);
void opSEI(char* cmd, char* ops);
void opDEY(char* cmd, char* ops);
void opTYA(char* cmd, char* ops);
void opTAY(char* cmd, char* ops);
void opCLV(char* cmd, char* ops);
void opINY(char* cmd, char* ops);
void opCLD(char* cmd, char* ops);
void opINX(char* cmd, char* ops);
void opSED(char* cmd, char* ops);

void opTXA(char* cmd, char* ops);
void opTXS(char* cmd, char* ops);
void opTAX(char* cmd, char* ops);
void opTSX(char* cmd, char* ops);
void opDEX(char* cmd, char* ops);
void opNOP(char* cmd, char* ops);

void opLDST(char* cmd, char* ops);
void opLDSTX(char* cmd, char* ops);
void opLDSTY(char* cmd, char* ops);
void opBRA(char* cmd, char* ops);
void opJMP(char* cmd, char* ops);
void opALU1(char* cmd, char* ops);
void opSHIFT(char* cmd, char* ops);
void opBIT(char* cmd, char* ops);
void opINCDEC(char* cmd, char* ops);
void opCPXY(char* cmd, char* ops);

void opDEFINE(char* cmd, char* ops);
void opBYTE(char* cmd, char* ops);
void opWORD(char* cmd, char* ops);
void opORG(char* cmd, char* ops);
void opEND(char* cmd, char* ops);
void opDUMMY(char* cmd, char* ops);
