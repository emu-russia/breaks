#!/usr/bin/env python3
"""Assemble the instruction-level core test into HDL/Framework/Icarus/mos6502/instr_test.mem.

Program convention:
  - ORG $0400; entry reached through the $04FF trampoline (see instr_test.v notes).
  - On success store $77 at $0200 and park at $3800; on failure store $EE.
  - Checked memory area $10..$20 is dumped by the harness.
"""
import os

RAM = [0] * 65536
insns = []   # (addr, mnem, oper)

_sz = []
def _rec(mnem, oper):
    size = 1
    if oper is not None:
        if isinstance(oper, str):
            size = 2                      # relative branch
        elif oper[0] == '#':
            size = 2
        elif oper[0] == 'z':
            size = 2
        elif oper[0] == 'a':
            size = 3
        else:
            raise SystemExit(oper)
    _sz.append(size)
    return size

def emit2(mnem, oper=None):
    insns.append((0x0400 + sum(_sz), mnem, oper, _rec(mnem, oper)))

# --- program ---
emit2('LDA', ('#', 0xA5)); emit2('STA', ('z', 0x10))     # $10 = A5
emit2('LDX', ('#', 0x33)); emit2('STX', ('z', 0x11))     # $11 = 33
emit2('LDY', ('#', 0x4C)); emit2('STY', ('z', 0x12))     # $12 = 4C
emit2('LDA', ('#', 0x0F)); emit2('ORA', ('#', 0xF0)); emit2('STA', ('z', 0x13))  # FF
emit2('AND', ('#', 0x0F)); emit2('STA', ('z', 0x14))                              # 0F
emit2('EOR', ('#', 0xFF)); emit2('STA', ('z', 0x15))                              # F0
emit2('ASL');              emit2('STA', ('z', 0x16))                              # E0
emit2('LSR');              emit2('STA', ('z', 0x17))                              # 70
emit2('ROL');              emit2('STA', ('z', 0x18))                              # E0
emit2('ROR');              emit2('STA', ('z', 0x19))                              # 70
emit2('INC', ('z', 0x13))                                                          # 00
emit2('DEC', ('z', 0x14))                                                          # 0E
emit2('INX'); emit2('DEX')                                                         # X=33
emit2('INY'); emit2('DEY')                                                         # Y=4C
emit2('CLC'); emit2('LDA', ('#', 0x64)); emit2('ADC', ('#', 0x01)); emit2('STA', ('z', 0x1A))  # 65
emit2('SBC', ('#', 0x01)); emit2('STA', ('z', 0x1B))                                            # 64
emit2('LDA', ('#', 0xFF)); emit2('ADC', ('#', 0x01)); emit2('STA', ('z', 0x1C))                 # 00 C=1
emit2('LDA', ('#', 0x02)); emit2('CMP', ('#', 0x02)); emit2('BNE', 'fail')
emit2('LDA', ('#', 0x03)); emit2('CMP', ('#', 0x02)); emit2('BEQ', 'fail')
emit2('LDA', ('#', 0x7F)); emit2('CMP', ('#', 0x80)); emit2('BCS', 'fail')
emit2('BCC', 'ok')
labels = {'fail': 0x0400 + sum(_sz)}
emit2('LDA', ('#', 0xEE)); emit2('STA', ('a', 0x0200)); emit2('JMP', ('a', 0x3800))
labels['ok'] = 0x0400 + sum(_sz)
emit2('LDA', ('#', 0x77)); emit2('STA', ('a', 0x0200)); emit2('JMP', ('a', 0x3800))

IMPL = {'ASL':0x0A,'LSR':0x4A,'ROL':0x2A,'ROR':0x6A,'INX':0xE8,'DEX':0xCA,'INY':0xC8,'DEY':0x88,'CLC':0x18}
IMM  = {'LDA':0xA9,'LDX':0xA2,'LDY':0xA0,'ORA':0x09,'AND':0x29,'EOR':0x49,'ADC':0x69,'SBC':0xE9,'CMP':0xC9}
ZP   = {'LDA':0xA5,'STA':0x85,'STX':0x86,'STY':0x84,'ORA':0x05,'AND':0x25,'EOR':0x45,
        'ADC':0x65,'SBC':0xE5,'CMP':0xC5,'INC':0xE6,'DEC':0xC6,'LDX':0xA6,'LDY':0xA4}
ABS  = {'STA':0x8D,'JMP':0x4C}
BRA  = {'BNE':0xD0,'BEQ':0xF0,'BCS':0xB0,'BCC':0x90}

def put(addr, b):
    assert RAM[addr] == 0, f'overlap at {addr:04X}'
    RAM[addr] = b

for addr, mnem, oper, size in insns:
    if oper is None:
        put(addr, IMPL[mnem])
    elif oper[0] == '#':
        put(addr, IMM[mnem]); put(addr+1, oper[1] & 0xFF)
    elif oper[0] == 'z':
        put(addr, ZP[mnem]); put(addr+1, oper[1] & 0xFF)
    elif oper[0] == 'a':
        put(addr, ABS[mnem])
        put(addr+1, oper[1] & 0xFF); put(addr+2, (oper[1] >> 8) & 0xFF)
# branch resolution
for addr, mnem, oper, size in insns:
    if isinstance(oper, str):
        rel = (labels[oper] - (addr + 2)) & 0xFF
        put(addr, BRA[mnem]); put(addr+1, rel)

# trampoline: reset currently lands at $04FF (vector-low load bug) -> JMP $0400
RAM[0x04FF] = 0x4C; RAM[0x0500] = 0x00; RAM[0x0501] = 0x04
# vectors
RAM[0xFFFC] = 0x00; RAM[0xFFFD] = 0x04
RAM[0xFFFE] = 0x00; RAM[0xFFFF] = 0x04
RAM[0xFFFA] = 0x00; RAM[0xFFFB] = 0x04

out = os.path.normpath(os.path.join(os.path.dirname(__file__), '..', 'HDL', 'Framework', 'Icarus', 'mos6502', 'instr_test.mem'))
with open(out, 'w') as f:
    f.write(' '.join(f'{b:02x}' for b in RAM))
print('wrote', out)
for addr, mnem, oper, size in insns:
    print(f'{addr:04X}: {mnem} {oper}')
