#include "pch.h"
#include "../Breaks6502/M6502Core/pc.h"

using namespace BaseLogic;
using namespace M6502Core;

static void ResetPcInputs(TriState inputs[])
{
    inputs[(size_t)ProgramCounter_Input::PHI2] = TriState::Zero;

    inputs[(size_t)ProgramCounter_Input::ADL_PCL] = TriState::Zero;
    inputs[(size_t)ProgramCounter_Input::PCL_PCL] = TriState::Zero;
    inputs[(size_t)ProgramCounter_Input::PCL_ADL] = TriState::Zero;
    inputs[(size_t)ProgramCounter_Input::PCL_DB] = TriState::Zero;
    inputs[(size_t)ProgramCounter_Input::ADH_PCH] = TriState::Zero;
    inputs[(size_t)ProgramCounter_Input::PCH_PCH] = TriState::Zero;
    inputs[(size_t)ProgramCounter_Input::PCH_ADH] = TriState::Zero;
    inputs[(size_t)ProgramCounter_Input::PCH_DB] = TriState::Zero;

    inputs[(size_t)ProgramCounter_Input::n_1PC] = TriState::One;
}

void PC_Test(uint16_t initial_pc, uint16_t expected_pc, bool inc)
{
    ProgramCounter pc;

    TriState DB[8];
    TriState ADL[8];
    TriState ADH[8];

    for (size_t n = 0; n < 8; n++)
    {
        DB[n] = TriState::Zero;
        ADL[n] = TriState::Zero;
        ADH[n] = TriState::Zero;
    }

    TriState inputs[(size_t)ProgramCounter_Input::Max];

    // Load

    Unpack((uint8_t)(initial_pc & 0xff), ADL);
    Unpack((uint8_t)(initial_pc >> 8), ADH);

    ResetPcInputs(inputs);
    inputs[(size_t)ProgramCounter_Input::PHI2] = TriState::Zero;
    inputs[(size_t)ProgramCounter_Input::ADL_PCL] = TriState::One;
    pc.sim(inputs, DB, ADL, ADH);

    ResetPcInputs(inputs);
    inputs[(size_t)ProgramCounter_Input::PHI2] = TriState::One;
    pc.sim(inputs, DB, ADL, ADH);

    ResetPcInputs(inputs);
    inputs[(size_t)ProgramCounter_Input::PHI2] = TriState::Zero;
    inputs[(size_t)ProgramCounter_Input::ADH_PCH] = TriState::One;
    pc.sim(inputs, DB, ADL, ADH);

    ResetPcInputs(inputs);
    inputs[(size_t)ProgramCounter_Input::PHI2] = TriState::One;
    pc.sim(inputs, DB, ADL, ADH);

    // Increment?

    if (inc)
    {
        ResetPcInputs(inputs);
        inputs[(size_t)ProgramCounter_Input::PHI2] = TriState::Zero;
        inputs[(size_t)ProgramCounter_Input::PCL_PCL] = TriState::One;
        inputs[(size_t)ProgramCounter_Input::PCH_PCH] = TriState::One;
        inputs[(size_t)ProgramCounter_Input::n_1PC] = TriState::Zero;
        pc.sim(inputs, DB, ADL, ADH);

        ResetPcInputs(inputs);
        inputs[(size_t)ProgramCounter_Input::PHI2] = TriState::One;
        inputs[(size_t)ProgramCounter_Input::n_1PC] = TriState::Zero;
        pc.sim(inputs, DB, ADL, ADH);
    }

    // Store

    printf("Before store PCH: 0x%02X, PCL: 0x%02X\n", pc.getPCH(), pc.getPCL());

    ResetPcInputs(inputs);
    inputs[(size_t)ProgramCounter_Input::PHI2] = TriState::Zero;
    inputs[(size_t)ProgramCounter_Input::PCL_PCL] = TriState::One;
    inputs[(size_t)ProgramCounter_Input::PCH_PCH] = TriState::One;
    pc.sim(inputs, DB, ADL, ADH);

    ResetPcInputs(inputs);
    inputs[(size_t)ProgramCounter_Input::PHI2] = TriState::One;
    inputs[(size_t)ProgramCounter_Input::PCL_ADL] = TriState::One;
    inputs[(size_t)ProgramCounter_Input::PCH_ADH] = TriState::One;
    pc.sim(inputs, DB, ADL, ADH);

    // Check bus value

    uint8_t pcl_from_bus = Pack(ADL);
    uint8_t pch_from_bus = Pack(ADH);
    uint16_t pc_from_bus = ((uint16_t)pch_from_bus << 8) | pcl_from_bus;

    if (pc_from_bus != expected_pc)
    {
        printf("The test failed! PC from bus (0x%04X) != Expected PC (0x%04X)\n", pc_from_bus, expected_pc);
    }

    // Check direct values

    uint8_t PCH = pc.getPCH();
    uint8_t PCL = pc.getPCL();
    uint16_t PC = ((uint16_t)PCH << 8) | PCL;

    if (PC != expected_pc)
    {
        printf("The test failed! PC (0x%04X) != Expected PC (0x%04X)\n", PC, expected_pc);
    }
}

void PC_UnitTest()
{
    // PC = 0x0000

    PC_Test(0x0000, 0x0000, false);

    // PC = 0xA5A5

    PC_Test(0xA5A5, 0xA5A5, false);

    // PC = 0x5A5A

    PC_Test(0x5A5A, 0x5A5A, false);

    // PC = 0xFFFE

    PC_Test(0xFFFE, 0xFFFE, false);

    // PC = 0xFFFF -- Bug?

    PC_Test(0xFFFF, 0xFFFF, false);

    return;

    // PC = 0x0000 -> Increment -> Check PC = 0x0001

    PC_Test(0x0000, 0x0001, true);

    // PC = 0xA5A5 -> Increment -> Check PC = 0xA5A6

    PC_Test(0xA5A5, 0xA5A6, true);

    // PC = 0x5A5A -> Increment -> Check PC = 0x5A5B

    PC_Test(0x5A5A, 0x5A5B, true);

    // PC = 0xFFFE -> Increment -> Check PC = 0xFFFF    -- Bug?

    PC_Test(0xFFFE, 0xFFFF, true);

    // PC = 0xFFFF -> Increment -> Check PC = 0x0000    -- Bug?

    PC_Test(0xFFFF, 0x0000, true);
}
