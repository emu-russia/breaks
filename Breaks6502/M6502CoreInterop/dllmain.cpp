// dllmain.cpp : Defines the entry point for the DLL application.
#include "pch.h"

M6502Core::M6502 cpu;

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
    uint8_t A[16];
    uint8_t D[8];
};

typedef struct M6502Core::DebugInfo CpuDebugInfoRaw;

#pragma pack(pop)

extern "C"
{
    __declspec(dllexport) void Sim(CpuPadsRaw* pads, CpuDebugInfoRaw* debugInfo)
    {
        TriState inputs[(size_t)M6502Core::InputPad::Max];
        TriState outputs[(size_t)M6502Core::OutputPad::Max];
        TriState inOuts[(size_t)M6502Core::InOutPad::Max];

        inputs[(size_t)M6502Core::InputPad::n_NMI] = pads->n_NMI ? TriState::One : TriState::Zero;
        inputs[(size_t)M6502Core::InputPad::n_IRQ] = pads->n_IRQ ? TriState::One : TriState::Zero;
        inputs[(size_t)M6502Core::InputPad::n_RES] = pads->n_RES ? TriState::One : TriState::Zero;
        inputs[(size_t)M6502Core::InputPad::PHI0] = pads->PHI0 ? TriState::One : TriState::Zero;
        inputs[(size_t)M6502Core::InputPad::RDY] = pads->RDY ? TriState::One : TriState::Zero;
        inputs[(size_t)M6502Core::InputPad::SO] = pads->SO ? TriState::One : TriState::Zero;

        for (size_t n = 0; n < 8; n++)
        {
            TriState Dn = TriState::X;

            switch (pads->D[n])
            {
                case 0:
                    Dn = TriState::Zero;
                    break;
                case 1:
                    Dn = TriState::One;
                    break;
                case 0xff:
                    Dn = TriState::Z;
                    break;
            }

            inOuts[(size_t)M6502Core::InOutPad::D0 + n] = Dn;
        }

        cpu.sim(inputs, outputs, inOuts);

        cpu.getDebug(debugInfo);

        pads->PHI1 = outputs[(size_t)M6502Core::OutputPad::PHI1] == TriState::One ? 1 : 0;
        pads->PHI2 = outputs[(size_t)M6502Core::OutputPad::PHI2] == TriState::One ? 1 : 0;
        pads->RnW = outputs[(size_t)M6502Core::OutputPad::RnW] == TriState::One ? 1 : 0;
        pads->SYNC = outputs[(size_t)M6502Core::OutputPad::SYNC] == TriState::One ? 1 : 0;

        for (size_t n = 0; n < 16; n++)
        {
            pads->A[n] = outputs[(size_t)M6502Core::OutputPad::A0 + n] == TriState::One ? 1 : 0;
        }

        for (size_t n = 0; n < 8; n++)
        {
            uint8_t Dn = 0;

            switch (inOuts[(size_t)M6502Core::InOutPad::D0 + n])
            {
                case TriState::Zero:
                    Dn = 0;
                    break;
                case TriState::One:
                    Dn = 1;
                    break;
                case TriState::Z:
                    Dn = 0xff;
                    break;
            }

            pads->D[n] = Dn;
        }
    }
}
