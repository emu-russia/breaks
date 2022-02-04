// dllmain.cpp : Defines the entry point for the DLL application.
#include "pch.h"

M6502Core::M6502 cpu(false, false);

using namespace BaseLogic;

BOOL APIENTRY DllMain( HMODULE hModule,
                       DWORD  ul_reason_for_call,
                       LPVOID lpReserved
                     )
{
    switch (ul_reason_for_call)
    {
        case DLL_PROCESS_ATTACH:
            break;
        case DLL_THREAD_ATTACH:
            break;
        case DLL_THREAD_DETACH:
            break;
        case DLL_PROCESS_DETACH:
            break;
    }
    return TRUE;
}

#pragma pack(push, 1)
struct CpuPadsRaw
{
    uint8_t n_NMI;
    uint8_t n_IRQ;
    uint8_t n_RES;
    uint8_t PHI0;
    uint8_t RDY;
    uint8_t SO;
    uint8_t PHI1;
    uint8_t PHI2;
    uint8_t RnW;
    uint8_t SYNC;
    uint16_t A;
    uint8_t D;
};

typedef struct M6502Core::DebugInfo CpuDebugInfoRaw;

#pragma pack(pop)

extern "C"
{
    __declspec(dllexport) void Sim(CpuPadsRaw* pads, CpuDebugInfoRaw* debugInfo)
    {
        TriState inputs[(size_t)M6502Core::InputPad::Max];
        TriState outputs[(size_t)M6502Core::OutputPad::Max];

        inputs[(size_t)M6502Core::InputPad::n_NMI] = pads->n_NMI ? TriState::One : TriState::Zero;
        inputs[(size_t)M6502Core::InputPad::n_IRQ] = pads->n_IRQ ? TriState::One : TriState::Zero;
        inputs[(size_t)M6502Core::InputPad::n_RES] = pads->n_RES ? TriState::One : TriState::Zero;
        inputs[(size_t)M6502Core::InputPad::PHI0] = pads->PHI0 ? TriState::One : TriState::Zero;
        inputs[(size_t)M6502Core::InputPad::RDY] = pads->RDY ? TriState::One : TriState::Zero;
        inputs[(size_t)M6502Core::InputPad::SO] = pads->SO ? TriState::One : TriState::Zero;

        cpu.sim(inputs, outputs, &pads->A, &pads->D);

        cpu.getDebug(debugInfo);

        pads->PHI1 = outputs[(size_t)M6502Core::OutputPad::PHI1] == TriState::One ? 1 : 0;
        pads->PHI2 = outputs[(size_t)M6502Core::OutputPad::PHI2] == TriState::One ? 1 : 0;
        pads->RnW = outputs[(size_t)M6502Core::OutputPad::RnW] == TriState::One ? 1 : 0;
        pads->SYNC = outputs[(size_t)M6502Core::OutputPad::SYNC] == TriState::One ? 1 : 0;
    }
}
