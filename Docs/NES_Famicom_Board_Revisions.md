# NES / Famicom Motherboard Revisions

A collection of the known motherboard (mainboard) revisions of the Nintendo
Entertainment System (NES-001 / NES-101) and the Family Computer (Famicom,
HVC-001 / HVC-101), with the main ICs found on each board: CPU, PPU, work RAM,
glue logic, CIC lockout chip and RF/video circuitry.

> **Note on sources:** this document is compiled from community hardware
> documentation (NESdev wiki and forums, ConsoleMods wiki, FamicomWorld,
> collector blogs and this repository's own notes). Where the community itself
> is unsure ("unclear if this was even shipped", "changes vs previous not
> documented"), this is kept and marked as unconfirmed. Board revision numbers
> are printed on the PCB; in repaired or serviced consoles the board may not be
> the one the console left the factory with (Nintendo swapped boards during
> servicing, e.g. pre-Rev-05 Famicom boards were replaced with Rev-05).

---

## 1. Famicom (HVC-001)

### 1.1 Overview

The Japanese Family Computer was released on 15 July 1983. Its mainboards were
numbered sequentially **HVC-CPU-01 … HVC-CPU-08**, followed by the
cost-reduced **HVC-CPU-GPM-01** and **HVC-CPU-GPM-02** (sub-revisions a…k)
series that were produced until the original design was replaced by the AV
Famicom in 1993. The console was externally reworked several times:

| Era | Controllers / case | Board revisions | Notes |
|---|---|---|---|
| Launch | Square-button controllers, smooth glossy red bottom shell | HVC-CPU-01 … -05 | Recall over a buggy CPU (1984); boards below -05 were swapped for -05 by Nintendo free of charge when serviced |
| Mid | Round-button controllers, smooth then rough (matte) bottom shell | HVC-CPU-06 … -08 | Round buttons introduced ~1984 together with the "fixed" 2A03E CPU |
| Late | Round-button controllers, "VCI"/"GMP" logos on the bottom | HVC-CPU-GPM-01, GPM-02a…k | VCCI-compliant redesign with integrated RF and extra shielding |

Serial numbers: early units use the `H`-prefix serial (e.g. H2747892), the
early GPM-era units use `HV` (e.g. HV1058701), later GPM-02 units use `HC`
(e.g. HC1238361) and AV Famicoms use `HN`. Rough production counts reported by
collectors: ~16M HVC-001 units before the VCCI redesign, ~13.5M of them
Rev-07, and ~5–6M VCCI (GPM) units. Serial alone cannot reliably identify the
board revision because Nintendo swapped boards during servicing (pre-Rev-05
boards were replaced with Rev-05, and later with Rev-07).

Sources:
- https://famicomworld.com/forum/index.php?topic=5242.0 (HVC *GPM* thread)
- http://jpx72web.blogspot.com/2016/11/famicom-av-mod-new.html
- http://nerdlypleasures.blogspot.com/2017/06/official-variations-of-nintendo-8-bit.html
- https://consolemods.org/wiki/index.php?title=NES:NES_Model_Differences

### 1.2 Revision table

| Board | Era | CPU | PPU | Notes |
|---|---|---|---|---|
| HVC-CPU-01 | 1983 | RP2A03 (no letter) | RP2C02A | Earliest confirmed board (serial H1018239); some boards have no revision number printed; "Nintendo 1983 HVC-CPU" silk-screen; unusually many hand-added jumper components on the solder side |
| HVC-CPU-02 | 1983 | not documented | not documented | No confirmed board photo so far; possibly never shipped in volume |
| HVC-CPU-03 | 1983 | RP2A03 (no letter) | RP2C02A | Oldest widely-confirmed square-button board (serials H1121204, H1167930); 74HC368 controller buffer; hand-added resistors+diode+cap on solder side |
| HVC-CPU-04 | 1983 | not documented | not documented | Square buttons; called the "real first release" by collectors |
| HVC-CPU-05 | 1984 | RP2A03E (plain RP2A03 seen on a repaired unit) | RP2C02D (RC2C02C ceramic on a Nintendo-repaired unit) | Last square-button / first round-button era; standard replacement board for recalled units; two different PCBs carry the same "-05" number; SRAM: Toshiba TMM2115AP-15 + NEC D4016CX-20; C21 fitted with 30 pF or 27 pF per lot |
| HVC-CPU-06 | 1984 | RP2A03 (no letter) or RP2A03E | not documented (2C02E era) | Last board to use the original CPU; first with surface-mount RAM; very rare |
| HVC-CPU-07 | 1984–1988 | RP2A03E, later RP2A03G | RP2C02E, later RP2C02G | By far the most common pre-GPM board (~13.5M of the ~16M pre-VCCI Famicoms); produced for years |
| HVC-CPU-08 | 1984/early 1985 | RP2A03E | RP2C02D | Very rare variant of the -07 board with surface-mount RAM instead of through-hole; serial H3460607 example |
| HVC-CPU-GPM-01 | 1988 | RP2A03G (one collector reports "chipset rev. H") | RP2C02G (one collector reports "chipset rev. H") | First major internal redesign (see 1.3); serials HV…; short run |
| HVC-CPU-GPM-02a…k | 1989–1993 | RP2A03G (one collector reports "chipset rev. H") | RP2C02G-0 (one collector reports "chipset rev. H") | The most plentiful Famicom board; produced until 1993; SRAM: Fujitsu MB8416A-15-SK; sub-revisions a…k printed in the board corner (e.g. "02A", "02C", "02G", "02H") |

Sources:
- https://famicomworld.com/forum/index.php?topic=5242.0
- http://famicomblog.blogspot.com/2011/10/in-search-of-square-button-famicom.html
- http://jpx72web.blogspot.com/2015/09/two-different-rev05-famicom-revisions.html
- http://jpx72web.blogspot.com/2016/11/famicom-av-mod-new.html
- https://consolemods.org/wiki/index.php?title=NES:NES_Model_Differences
- http://offgao.blog112.fc2.com/blog-entry-24.html (HVC-CPU-01), blog-entry-33.html (HVC-CPU-03), blog-entry-22.html (HVC-CPU-08), blog-entry-27.html (GPM-01), blog-entry-38.html (HVCN-CPU-01/02), blog-entry-28.html (RC2C02C), blog-entry-20/21.html (HVC-CPU-07/-05)
- http://ahoministrator.sakura.ne.jp/retrospective/archives/249 (HVC-CPU-05), /305 (HVC-CPU-GPM-02)

### 1.3 What changed between revisions

- **HVC-CPU-01…-05 → -06/-07**: the launch boards used the original (letterless)
  RP2A03 CPU, which was recalled due to stability issues. It also lacks the
  APU's "looped noise" mode (some games, e.g. Mega Man 2, sound slightly
  different) and has timing differences that make it incompatible with some
  flash carts (e.g. the original EverDrive N8). The "fixed" RP2A03E CPU
  debuted together with the round-button controllers. HVC-CPU-06 was the last
  board with the original CPU and is the first with surface-mount RAM.
- **HVC-CPU-07**: the most common early board; most use 2A03E/2C02E, later
  ones use the G revisions (matching the RP2A03G/RP2C02G-0 production start in
  1987).
- **HVC-CPU-08**: a rare variant of -07 with surface-mount RAM chips.
- **GPM series (1988)**: the first major internal revision. To meet Japanese
  VCCI (Voluntary Control Council for Interference) standards, the RF/power
  board was soldered directly onto the motherboard (previously connected by a
  thin ribbon cable), and more extensive shielding was added: a metal shroud
  over the cartridge connector and an additional grounded copper plane on the
  bottom of the board (the GPM designation is said to stand for "Ground Plane
  Method"). The "FF" Famicom Family logo was added to the front nameplate from
  this revision onward. Note: sources disagree on whether the GPM-01 already
  had the cartridge-connector shielding (ConsoleMods says yes; a FamicomWorld
  post describes GPM-01 as "unshielded" and GPM-02 as "shielded", and some
  HV-serial GPM-02 boards lack the shielding on the 60-pin cart port).
- **GPM-01 (1988)**: compared with the -07 board it has more components, a
  fuse, and louder expansion (cartridge) audio, and the AV-mod is easier. Some
  units have metal shielding around the cart slot, some do not. Serial numbers
  of this era are usually `HV…`.
- **GPM-02 (1989)**: mostly the same as GPM-01, with added ceramic capacitors —
  ConsoleMods documents a capacitor C36 near the PPU and another between the
  two controller buffer chips; a FamicomWorld post (80sFREAK) documents "C37
  560 pF added and FC2 shifted". Produced until 1993. Board numbers have letter
  suffixes (02a…02k); the exact changes per letter are not documented. Serial
  prefixes are `HC…` (and some `HV…`).
- **JIO**: some late boards (and the AV Famicom, see 1.5) replace the discrete
  glue logic (139 decoder + 368 buffers + pull-up resistor pack) with a single
  custom 32-pin "JIO" chip (markings: `BU3270S`, `BU3266S`).

Sources:
- https://consolemods.org/wiki/index.php?title=NES:NES_Model_Differences
- https://famicomworld.com/forum/index.php?topic=5242.0
- https://forums.nesdev.org/viewtopic.php?t=16764 (JIO)

### 1.4 Famicom board components (typical, non-JIO boards)

- **CPU**: Ricoh RP2A03 (revision letter depends on era, see Section 3).
- **PPU**: Ricoh RP2C02 (revision letter depends on era, see Section 4).
- **Work RAM**: one 2K×8 SRAM. Documented parts: Toshiba TMM2115AP-15, NEC
  D4016CX-20 (HVC-CPU-05), Fujitsu MB8416A-15-SK (GPM-02), LH5116D-12,
  HM6116 (see Section 5).
- **Glue logic**:
  - 2× **40H368 / 74HC368** (inverting tristate buffers) serve the I/O
    subsystem; one tristate is used as an inverting amplifier for the main
    audio channel and another to invert PA13. Marked 74HC368 on an HVC-CPU-03
    board.
  - **74LS139** (dual 2-to-4 decoder with inverted outputs) maps CPU memory
    areas (PPU registers, cartridge PRG, internal RAM).
  - **74LS373** (8-bit transparent latch) latches the lower 8 bits of the PPU
    address (the PPU address/data bus is multiplexed).
  - Pull-up resistor pack (RM1) on IRQ/NMI lines.
- **RF/video**: separate RF box in early revisions (connected via ribbon
  cable), integrated into the mainboard from the GPM revision; transistor Q1
  (2SA937) in the video circuit.
- Later boards replace the discrete logic with the **JIO** chip.

Sources:
- https://github.com/emu-russia/breaks/blob/master/Docs/Famicom/Chipset/Readme.md
- https://github.com/emu-russia/breaks/blob/master/BreakingNESWiki/MB/Famicom.md

### 1.5 AV Famicom (HVC-101, "New Famicom", 1993–2003)

- Boards: **HVCN-CPU-01** (1993–1995) and **HVCN-CPU-02** (1995–2003).
- CPU/PPU: **2A03H / 2C02H** (confirmed on units with ~1994 and ~2001 date
  codes; the last known unit, serial HN11032909, has 2003 date codes).
- HVCN-CPU-01 looks similar to the NESN-CPU-01, but the 74LS139 demultiplexer
  and the controller buffer chips are combined into a single I/O chip, the
  **JIO** (`BU3266`/`BU3270`, marked "JIO"); C14 sits near the 7805 heat sink.
- HVCN-CPU-02 is a very minor revision: capacitor C14 was relocated from under
  the 7805 heatsink to a position near the work RAM, and a diode was added to
  the power circuit as reverse-polarity protection; the board colour differs.
- Composite video via the SNES-style Multi-Out connector; no RF modulator
  (sold separately), no lockout chip, no microphone support. Produced until
  2003.

Sources:
- https://consolemods.org/wiki/index.php?title=NES:NES_Model_Differences
- http://offgao.blog112.fc2.com/blog-entry-38.html (HVCN-CPU-01/02 photos and date codes)
- https://github.com/emu-russia/breaks/blob/master/Docs/JIO/Readme.md
- http://nerdlypleasures.blogspot.com/2017/06/official-variations-of-nintendo-8-bit.html

---

## 2. NES (NES-001)

### 2.1 Overview

The NES front-loader was released in New York City on 18 October 1985 as a
test market, and received a full North American release in the fall of 1986.
Mainboard revisions run **NES-CPU-01 … -11**. Unlike the Famicom, the NES
contains a **CIC lockout chip** on the motherboard that must authenticate the
cartridge; Nintendo used different CIC variants per region (see Section 5.1).
Revisions below -05 have noticeably poorer video output (a 2.2 kΩ collector
resistor on the video amplifier transistor makes colors look washed out), and
revisions -09…-11 progressively add circuitry to defeat "CIC STUN" and -5V
lockout-defeat attacks used by unlicensed cartridges.

### 2.2 Revision table (NTSC)

The detailed table below is condensed from the NESdev forums (lidnariq's NES
motherboard revision summary) and this repository's notes.

| Board | CPU / PPU | PCB copyright | VRAM/WRAM package | CIC | Notable differences |
|---|---|---|---|---|---|
| NES-CPU-01 | 2A03E / 2C02E(-0) | 1985 | NDIP only | 3193 (non-A) | Earliest revision; test-market only |
| NES-CPU-02 | 2A03E / 2C02E-0 | 1985 | NDIP only | 3193 (non-A) | First revision actually released in the USA (first ~10,000 test-release consoles before the wide release) |
| NES-CPU-03 | 2A03E / 2C02E-0 | 1985 | NDIP only | 3193 (non-A) | Unclear if it was ever shipped separately from -02 |
| NES-CPU-04 | 2A03E / 2C02E-0 (later G) | 1986 | NDIP only | 3193 (non-A) or 3193A | Some boards have 74HC139 at U3 instead of 74LS139; first board revision also used for PAL consoles |
| NES-CPU-05 | 2A03G / 2C02G-0 | 1986 | NDIP only | 3193A | CPU/PPU switched to G revision; video/stability issues resolved |
| NES-CPU-06 | 2A03G / 2C02G-0 | 1987 | NDIP or DIP | 3193A | Slight layout changes; first boards with conventional DIP RAM |
| NES-CPU-07 | 2A03G / 2C02G-0 | 1987 | NDIP or DIP | 3193A | Minor layout changes vs -06 |
| NES-CPU-08 | 2A03G / 2C02G-0 | 1989 | NDIP or DIP | 3193A | Minor layout changes vs -07. Note: this is the only board with a **1989** PCB copyright — later boards revert to 1987; Lord Nightmare hypothesizes this relates to a Japanese copyright-restoration (WIPO/Berne/URAA) matter |
| NES-CPU-09 | 2A03G/2C02G-0 or 2A07/2C07-0 | 1987 | NDIP or DIP | (CIC present; variant not documented per revision) | One resistor between CIC (data?) pin and cart connector to thwart some CIC STUN attacks; PAL-capable CPU/PPU option |
| NES-CPU-10 | 2A03G / 2C02G | 1987 | NDIP or DIP | (CIC present; variant not documented per revision) | Two resistors between CIC pins (clock and data?) and cart connector; some later PCBs have a hand-added-at-factory diode (or diodes) to nearby GND vias to prevent the -5V attack |
| NES-CPU-11 | 2A03G/2C02G or 2A07A/2C07A | 1987 | NDIP or DIP | (CIC present; variant not documented per revision) | Two resistors and two diodes between CIC pins, cart connector and GND to prevent both CIC STUN and -5V attacks; final front-loader board (1990–1993). Note: it is possible (unconfirmed) that very late CPU-11 boards carry the "H" revision 2A03/2C02 (Lord Nightmare) |

Notes from ConsoleMods wiki:

- **NES-CPU-01…-03** are generally only found in the 1985 NYC and early 1986
  test-market consoles. All of them have the "E" revisions of the CPU and PPU,
  and a 2.2 kΩ resistor on the collector of the video amplifier transistor Q1
  (510 Ω on most later revisions), which causes washed-out colors.
- **NES-CPU-04** (1986) changed the Q1 collector resistor to 150 Ω and was the
  first board revision used for PAL consoles; most NTSC CPU-04s use the E
  revisions, later boards use G.
- **NES-CPU-05…-10** (1986–1990): starting with -05, all boards use the G
  revisions of the CPU and PPU and the 510 Ω resistor; -06 has slight layout
  changes and can accommodate either narrow-DIP or conventional-DIP work RAM
  and PPU RAM; -07 and -08 are mostly the same with only minor layout changes;
  -09 and -10 add an extra 2.2 kΩ resistor to the CIC lockout chip's clock
  circuit.
- **NES-CPU-11** (1990–1993): final front-loader revision; mostly similar to
  -10 but with two 1 kΩ series resistors and two clamp diodes added to the CIC
  chip's data lines, preventing the "stun" circuits found in Camerica and
  Color Dreams / Wisdom Tree cartridges. North American consoles with the red
  "1-800" service hotline sticker (1992–1993) always contain a CPU-11 board.

Typical NES-001 board population (U-designators, from the Console5 wiki; the
parts vary across revisions as noted in the table):

- U1, U4: 2K×8 SRAM (WRAM / VRAM): LH5216AD-10L, MN4216-20 or CXK5816SPS-15L
- U2: 74LS373 (PPU address/data latch)
- U3: 74LS139 (address demux; 74HC139 on some CPU-04 boards)
- U5: PPU RP2C02 (revision per table)
- U6: CPU RP2A03 (revision per table)
- U7, U8: 74HC368N or PC74HC368P (controller / expansion-port buffers)
- U9: 74HCU04 (oscillator inverter)
- U10: CIC 3193A (absent on NES-101 boards)
- +5 V regulator: AN7805

RF/power modules documented by Console5 (Alps and Mitsumi variants; not mapped
to specific NES-CPU-xx revisions): Alps modules with a BA20 (or similar) diode
bridge (green PCB with "floating cap" — early; and brown PCB), Alps modules
with a discrete-diode bridge ("FR853" and "SH-SH5 / FS074" PCB variants), the
Alps "R22" module (France RGB NES power module), and Mitsumi modules
("TDK-T12V", "MTM-8V-0 / VIX", "TDK-T31V"). The 2200 µF filter capacitor on
the AV/power module is failure-prone across all board revisions.

Sources:
- https://forums.nesdev.org/viewtopic.php?p=196688#p196688
- https://consolemods.org/wiki/index.php?title=NES:NES_Model_Differences
- https://wiki.console5.com/tw/index.php?title=Nintendo_NES-001
- https://github.com/emu-russia/breaks/blob/master/BreakingNESWiki/MB/NES.md

### 2.3 NES-101 top-loader ("New-Style NES", 1993–1995)

The NES-101 removed the RF/AV output jacks, the lockout chip and the expansion
port. Its cartridge connector is more reliable than the front-loader's, but the
common board's video output is marred by "jailbars" (the 72-pin connector
populates only 68 pins: 1–17, 20–53 and 56–72). Four mainboards are
documented:

| Board | Era | U1 WRAM | U2 | U3 | U4 VRAM | U5 PPU | U6 CPU | U7,U8 | U9 |
|---|---|---|---|---|---|---|---|---|---|
| NESN-CPU-01 | 1993–1994 | LH5216AD-10L | HD74LS373P | HD74LS139P | — | RP2C02G-0 | RP2A03G | 2× SN74HC368N | 7805 |
| NESN-CPU-JIO-01 | 1994–1995 | LH5216AD-10L | SN74LS373N | **BU3266S (JIO)** | LH5216AD-10L | RP2C02H-0 | RP2A03H | — | 7805 |
| NESN-CPU-AV-01 | 1994 | BR6216B-10LL | MB74LS373 | **BU3270S (JIO)** | BR6216B-10LL | RP2C02H-0 | RP2A03H | — | 7805 |
| NESN-CPU-JIO-02 (PAL) | 1994–1995 | as JIO-01 | | | | 2C07 | 2A07 | | |

Notes:

- **NESN-CPU-01** (the common board) has the jailbar video problem, caused
  mostly by poor PCB routing: the composite video trace is very thin and runs
  alongside digital traces.
- **NESN-CPU-JIO-01** (rare) improves the video circuitry and largely
  eliminates the jailbars. The CPU and PPU were repositioned (PPU to the left,
  CPU to the right), the two discrete controller buffer ICs and the 74LS139
  were combined into the "JIO" chip, and the bridge rectifier was replaced
  with two diode arrays. Top-loaders with this board were only available as
  replacement consoles from Nintendo, for people who complained about the
  NES-101's video quality.
- **NESN-CPU-JIO-02** is almost identical and is found only in PAL top-loaders
  (released only in Australia and New Zealand); like all previous PAL NES
  consoles they use the 2A07 CPU and 2C07 PPU.
- **NESN-CPU-AV-01** (1994) is the "ultimate" NES-101 revision: the RF port
  was replaced with composite AV out using the same Multi-Out connector as the
  SNES/AV Famicom. Extremely rare; layout mostly similar to the JIO-01.

Sources:
- https://github.com/emu-russia/breaks/blob/master/BreakingNESWiki/MB/NES.md
- https://wiki.console5.com/tw/index.php?title=Nintendo_NES-101
- https://consolemods.org/wiki/index.php?title=NES:NES_Model_Differences
- https://www.game-tech.us/nes2-intro/
- http://nerdlypleasures.blogspot.com/2017/06/official-variations-of-nintendo-8-bit.html

### 2.4 Regional NES variants (non-NTSC)

| Console | Model | TV system | CIC | Notes |
|---|---|---|---|---|
| European NES | NESE-001 | PAL | 3195A (PAL-B) | Distributed in Netherlands, Belgium, Germany, Austria, Switzerland, Denmark, Iceland, Norway, Sweden, Finland |
| Spanish NES | NESE-001 | PAL | 3195A (PAL-B) | Same hardware as the European version |
| French NES | NESE-001 (FRA) | PAL RGB | 3195A (PAL-B) | No RF modulator / AV jacks; proprietary rear connector carrying RGB (actually composite decoded into RGB for French TVs); uses the 2C07 PPU |
| Mattel NES (UK/AUS/NZ/ITA) | NESE-001 | PAL | 3197A (PAL-A) | Sold by Mattel before Nintendo took over distribution |
| Post-Mattel UK / AUS / ITA | NESE-001 | PAL | 3197A (PAL-A) | Nintendo took over distribution |
| Hong Kong / Asian / Indian NES | NESA-001 | PAL | 3196A | Grey plastic around controller ports; Indian version branded "Samurai Electronic TV Game" |
| Korean NES ("Comboy") | NES-001 (KOR) | NTSC | 3195A | Distributed by Hyundai; NTSC console with a PAL-B lockout chip |
| Brazilian NES | NES-001 (BRA) | PAL-M | 6113B1 | Released late by Playtronic; color-conversion circuitry because the 2C02 PPU outputs NTSC color |

Source:
- http://nerdlypleasures.blogspot.com/2017/06/official-variations-of-nintendo-8-bit.html

---

## 3. CPU revisions (Ricoh RP2A03 / RP2A07)

CPU chips in official consoles are marked e.g. `RP2A03`, `RP2A03E`, `RP2A03G`,
`RP2A03H` (NTSC) and `RP2A07`, `RP2A07A` (PAL). The letter is the chip
revision. Production-date ranges below are from the NESdev wiki "CPU variants"
page (date codes printed on chip packages). The 2A03 is a 6502 with the
decimal mode removed — on the 2A03G die the decimal-mode logic is surgically
removed.

| Marking | First seen | Last seen | Notes |
|---|---|---|---|
| RP2A03 (letterless) | 1983-06 | 1984-09 | M2 duty cycle 17/24 instead of 15/24; **lacks tonal (looped) noise mode**; lowest noise period 2046 instead of 4068; APU frame counter not restarted on reset; broken/disabled programmable interval timer on-die; pin 30 not connected. A ceramic version exists (1983-06). Used in launch Famicoms (HVC-CPU-01…-06) and Vs. System boards (which additionally do not support looped noise) |
| RP2A03E | 1984-10 | 1986-06 | Pin 30 is /RDY (combined with internal signals before feeding the internal 6502); the "fixed" CPU that debuted with round-button Famicoms |
| RP2A03G | 1987-04 | 1993-11 | Reference model; pin 30 enables CPU test mode; later production runs introduced a DMC DMA bug |
| RP2A03H | 1993-12 | 1999-05 | No known differences from late RP2A03G (a technical report — RustyNES ADR-0033 — describes an extra-read difference vs G during DMC+OAM overlap; unverified) |
| RP2A03H (laser-marked) | 2001-03 | 2002-11 | Last production |
| RP2A04 | 1986-03 | — | Not a CPU at all: a jumper in a 40-pin PDIP, used in place of CPUs in Vs. System boards |
| RP2A07 (PAL) | 1987-03 | 1990-04 | ÷16 clock divider, different DMC/noise/frame-timer tables; M2 duty 19/32; fixed DPCM RDY address-bus glitches; pin 30 = 6502 /RDY |
| RP2A07A (PAL) | 1991-06 | 1992-10 | No known differences from RP2A07 |

Additional notes from the community:

- kevtris (NESdev): Vs. System boards use the letterless RP2A03, which does
  not support looped noise; an RP2A03E from a FamicomBox works fine with
  looped noise; no CPU revision earlier than E or an "F" revision has been
  seen; later revisions are suspected to be die shrinks.
- The reset screen tint differs between revisions: the 2A03E/2C02E pair shows
  purple or brown at reset, later revisions show grey.
- Clones found in official consoles: none — UA6527/UA6527P (UMC clones of
  RP2A03G) appear only in clones/famiclones (see the NESdev "CPU variants"
  page for the full clone list).

Sources:
- https://www.nesdev.org/w/index.php?title=CPU_variants
- https://forums.nesdev.org/viewtopic.php?p=85071
- https://forums.nesdev.org/viewtopic.php?t=4279

---

## 4. PPU revisions (Ricoh RP2C02 / RP2C07)

| Marking | First seen | Last seen | Notes |
|---|---|---|---|
| RP2C02 (letterless) | 1983-06 | 1983-08 | Extremely rare; likely only a few thousand made |
| RP2C02A | 1983-08 | 1983-10 | Erroneous sprite pixels can appear at X=255; PPUMASK/PPUCTRL seemingly asynchronous |
| RP2C02B | 1983-12 | 1984-05 | Same X=255 sprite bug as A; production was paused for 2C02C then resumed |
| RP2C02C | 1983-12 | 1984-02 | Production stopped in favour of resuming 2C02B |
| RC2C02C | 1984-01 | — | Ceramic package; currently only found inside serviced Famicoms |
| RP2C02D | 1984-07 | 1984-12 | — |
| RP2C02D-0 | 1984-10 | 1984-12 | — |
| RP2C02E | 1984-12 | 1985-10 | — |
| RP2C02E-0 | 1985-03 | 1987-03 | In this and all previous revisions OAMDATA and palette RAM are **not readable**; various OAM evaluation bugs |
| RP2C02G-0 | 1987-05 | 1993-10 | Writes to OAMADDR cause OAM corruption; susceptible to reflections (fixed by series resistors between CPU and cartridge ROM) |
| RP2C02H-0 | 1993-12 | 1999-05 | Thought to fix some glitches of the 2C02G-0 |
| RP2C02H-0 (laser) | 2000-10 | 2003-01 | Last production |
| RP2C07 (PAL-B) | 1985-12 | — | 71-scanline vblank; OAM evaluation can never be fully disabled; red/green color emphasis swapped |
| RP2C07-0 (PAL) | 1987-10 | 1992-01 | — |
| RP2C07A-0 (PAL) | 1992-06 | — | Believed identical to 2C07 except subtle differences |

RGB/arcade variants used in official hardware (briefly): RC2C03 (Sharp C1 TV),
RP2C03B/C, RC2C03B/C, RP2C04-0001…0004 (Vs. System, scrambled palettes),
RC2C05-01…04 (Vs. System), RC2C05-99 (Famicom Titler).

UMC clone UA6528 (a 2C02E-era clone) and other clones are found only in
famiclones, not in official NES/Famicom consoles.

Sources:
- https://www.nesdev.org/w/index.php?title=PPU_variants

---

## 5. Support chips

### 5.1 CIC (lockout) chips

The CIC ("Check IC" / "10NES") performs the copy-protection handshake between
the console and the cartridge: the console CIC acts as a "lock" and the
cartridge CIC as a "key"; if authentication fails the console resets in a loop.
The CIC is a Sharp 4-bit one-chip microcomputer (SM590 family): both lock and
key run the same program in lockstep and exchange data over two wires. Tested
lock/key compatibility (kevtris): 3193-lock + 3193-key works, 3193-lock +
6113-key works, 6113-lock + 6113-key works, but **6113-lock + 3193-key does
not work** — which is why even the last front-loaders kept 3193-family locks.
Drop-in substitutes for the console CIC: 3193 → 3193A, 6113, 6113A, 6113B1.
The 3195A (PAL-B) has a different (768-byte) ROM layout vs. the 512-byte 6113.

The Famicom and the NES-101 top-loader have no lockout chip. The NTSC NES-001
uses the 3193/3193A/6113 family (the 6113 family is primarily documented as
the cartridge key; which exact NTSC board revisions shipped a 6113-family
*lock* is not precisely documented); PAL regions used two incompatible types,
"PAL-A" and "PAL-B":

| Marking | Used in | Notes |
|---|---|---|
| 3193 (non-A) | NES-CPU-02/-04 (early NTSC) | Earliest NTSC CIC |
| 3193A | NES-CPU-04/-05… (NTSC) | Common NTSC CIC |
| 6113, 6113A, 6113B1 | Cartridge keys on most carts; listed as NTSC NES-001 lock options; Brazilian NES uses 6113B1 | 6113B ties fewer pins to GND than 6113 |
| 3195A | NESE-001 (PAL-B: Europe, Spain, France); NES-001 (KOR) "Comboy" | PAL-B; 768-byte ROM |
| 3197A | NESE-001 (PAL-A: Mattel UK/AUS/NZ/ITA) | PAL-A |
| 3196A | NESA-001 (HK/Asian/Indian) | — |
| 3198 / 3199 | FamicomBox | FamicomBox cartridges use a unique 3198 key; 3199 is the coin-timer variant |

The anti-lockout-defeat circuitry of NES-CPU-09/-10/-11 (series resistors and
clamp diodes on the CIC lines) is described in Section 2.2. Sources:
https://en.wikipedia.org/wiki/CIC_(Nintendo), https://hackmii.com/2010/01/the-weird-and-wonderful-cic/,
https://forums.nesdev.org/viewtopic.php?t=1219, https://forums.nesdev.org/viewtopic.php?t=319,
https://forums.nesdev.org/viewtopic.php?t=17502.

### 5.2 Glue logic and the JIO chip

- **74LS139 / 74HC139**: dual 2-to-4 line decoder with inverted outputs; used
  to map CPU memory areas (PPU registers, cartridge PRG ROM, internal RAM).
  Some NES-CPU-04 boards use the 74HC139 at U3.
- **74LS373 / HD74LS373P / MB74LS373 / SN74LS373N**: 8-bit transparent latch;
  latches the lower 8 address bits of the multiplexed PPU address/data bus.
- **40H368 / SN74HC368N**: hex inverting tristate buffers; two of them serve
  the NES/Famicom I/O subsystem. On the Famicom one tristate is used as an
  inverting audio amplifier and another to invert PA13.
- **JIO chip** (`BU3266`/`BU3266S`, `BU3270`/`BU3270S`, marked "JIO" /
  "Nintendo"): a custom 32-pin IC that integrates the 139 decoder, the
  368-style controller buffers and the pull-up resistors. Documented placement:
  BU3266 in HVCN-CPU-01 AV Famicoms, the PAL top-loader (NESN-CPU-JIO-02) and
  the rare RF-only revised NES top-loader (NESN-CPU-JI0-01); BU3270 in
  HVCN-CPU-02 AV Famicoms and NESN-CPU-AV-01. Whether any HVC-CPU-GPM-02
  sub-revision carried a JIO is **unconfirmed**. Its two inverters are used for
  the audio channel and PA13. The JIO-based audio amplifier mixes the
  expansion (cartridge) audio quieter than on pre-GPM boards — the reason
  games designed for early Famicoms sound different on GPM/AV Famicoms.
  Pinout documentation:
  https://github.com/emu-russia/breaks/blob/master/Docs/JIO/Readme.md

### 5.3 Work RAM (SRAM)

- 2K×8 static RAM (16 Kbit). NES-001 boards: LH5216AD-10L, MN4216-20,
  CXK5816SPS-15L. NES-101 boards: LH5216AD-10L, BR6216B-10LL. Famicom boards:
  TMM2115AP-15, D4016CX-20, MB8416A-15-SK, HM6116 (Hitachi; datasheet in this
  repo), LH5116D-12 (Sharp, in the GPM-01 donor board), KM6116 (Samsung
  drop-in)… (HM6116/KM6116 are documented on Famicom/famiclone boards, not on
  official NES-001 boards). Any 2 KB×8, 8-bit, ≤200 ns part is a drop-in.
- The NES uses two of them (WRAM + VRAM); the Famicom uses one (WRAM — the PPU
  nametable VRAM lives on the cartridge in the Famicom's original design).
- Early Famicom boards use through-hole RAM; HVC-CPU-06 and -08 use
  surface-mount RAM.

### 5.4 RF modulator and video circuits

- Famicom: early boards use a separate RF box connected by a ribbon cable; the
  GPM boards integrate the RF/power circuit on the mainboard (VCCI
  compliance). Transistor Q1 (2SA937) is part of the Famicom's video circuit.
- NES front-loader: internal RF modulator with a channel select switch
  (channels 3/4), plus side-mounted composite video/audio jacks. The video
  amplifier transistor's collector resistor differs across revisions (2.2 kΩ
  on CPU-01…-03, 150 Ω on CPU-04, 510 Ω from CPU-05 on), affecting color
  saturation. The French NES has no RF modulator (RGB/SCART cable).
- NES-101: no AV output on the common board (RF only); the rare AV-01 board
  replaces the RF port with a Multi-Out connector. The jailbar issue of the
  common board is caused by poor PCB routing of the composite video trace; the
  JIO-01 board repositions the CPU/PPU and improves the video circuitry.

---

## 6. Revision change summary (timeline)

| Year | Event |
|---|---|
| 1983-07 | Famicom launch; HVC-CPU-01…-05 (square buttons); letterless RP2A03/RP2C02 |
| 1983-12 | Famicom board recall (Rev-01…-04); Rev-05 becomes the replacement board |
| 1984 | Round-button controllers and "fixed" RP2A03E CPU introduced; HVC-CPU-06/-07/-08; RP2C02E |
| 1985-10 | NES NYC test release (first ~10,000 units, NES-CPU-01…-03, 3193 CIC) |
| 1986 | NES wide release (NES-CPU-04/-05); 3193A CIC; RP2A03G/RP2C02G-0 appear; first PAL NES boards; Sharp Twin Famicom (AN-500, AV output) |
| 1987 | NES-CPU-06/-07; DIP RAM appears; PAL NES (RP2A07/RP2C07) |
| 1987–1990 | NES-CPU-08/-09/-10/-11; CIC STUN / -5V countermeasures added |
| 1988–1989 | Famicom GPM series (GPM-01 1988, GPM-02 1989, sub-revisions a…k); integrated RF; produced until 1993; Sharp Famicom Titler (1989, RGB PPU RC2C05-99) |
| 1990–1993 | NES-CPU-11 (final front-loader board) |
| 1993 | NES-101 top-loader (NESN-CPU-01, jailbars); AV Famicom (HVC-101, HVCN-CPU-01); RP2A03H/RP2C02H-0 |
| 1993–1994 | NESN-CPU-JIO-01 and NESN-CPU-AV-01 (JIO-based, jailbar-free); PAL top-loader NESN-CPU-JIO-02 |
| 1994 | Brazilian NES-001 (Playtronic, PAL-M, 6113B1 CIC) — late in the NES lifespan |
| 1995–2003 | AV Famicom HVCN-CPU-02 (minor revision) produced until 2003 |

---

## 7. Sources

- NESdev wiki, "CPU variants": https://www.nesdev.org/w/index.php?title=CPU_variants
- NESdev wiki, "PPU variants": https://www.nesdev.org/w/index.php?title=PPU_variants
- NESdev forums, NES motherboard revisions summary (Lord Nightmare): https://forums.nesdev.org/viewtopic.php?p=196688#p196688 (mirror: https://nesdev.nes.science/f9/t15985.xhtml)
- NESdev forums, "NES CPU/PPU revisions" (kevtris et al.): https://forums.nesdev.org/viewtopic.php?p=85071
- NESdev forums, "Early NES Motherboard and CPU info 1985": https://forums.nesdev.org/viewtopic.php?p=150067
- NESdev forums, 2A03E thread: https://forums.nesdev.org/viewtopic.php?t=4279
- NESdev forums, JIO chip: https://forums.nesdev.org/viewtopic.php?t=16764
- NESdev forums, "Reverse Engineering the CIC": https://forums.nesdev.org/viewtopic.php?t=1219
- NESdev forums, "CIC Lockout chip pinout?" (6113 vs 6113B): https://forums.nesdev.org/viewtopic.php?t=319
- NESdev forums, "NES and Famicom Substitute ICs": https://forums.nesdev.org/viewtopic.php?t=17502
- Wikipedia, "CIC (Nintendo)": https://en.wikipedia.org/wiki/CIC_(Nintendo)
- Segher, "The weird and wonderful CIC" (HackMii): https://hackmii.com/2010/01/the-weird-and-wonderful-cic/
- ConsoleMods wiki, "NES Model Differences": https://consolemods.org/wiki/index.php?title=NES:NES_Model_Differences
- FamicomWorld, "HVC *GPM* (Oops)? What is the meaning? + FC CPU Board Revision Numbers": https://famicomworld.com/forum/index.php?topic=5242.0
- FamicomWorld, "Do newer revision CPU/PPU work on older revision motherboards?": https://famicomworld.com/forum/index.php?topic=15674.msg191989
- Famicomblog (senseiman), "In Search of the Square Button Famicom Revisions": http://famicomblog.blogspot.com/2011/10/in-search-of-square-button-famicom.html
- OffGao (FC2 blog), Famicom board revision photo entries: http://offgao.blog112.fc2.com/blog-entry-24.html (HVC-CPU-01), blog-entry-33.html (HVC-CPU-03), blog-entry-22.html (HVC-CPU-08), blog-entry-27.html (GPM-01), blog-entry-38.html (HVCN-CPU-01/02), blog-entry-28.html (RC2C02C), blog-entry-20/21.html (HVC-CPU-07/-05)
- ahoministrator, Famicom board teardowns: http://ahoministrator.sakura.ne.jp/retrospective/archives/249 (HVC-CPU-05), /305 (HVC-CPU-GPM-02)
- NESdev wiki, "Famicom": https://www.nesdev.org/wiki/Famicom
- jpx72 web blog, "Famicom AV mod - NEW!" (revision list): http://jpx72web.blogspot.com/2016/11/famicom-av-mod-new.html
- jpx72 web blog, "Two different Rev05 Famicom revisions": http://jpx72web.blogspot.com/2015/09/two-different-rev05-famicom-revisions.html
- Nerdly Pleasures, "Official Variations of the Nintendo 8-bit NES/Famicom Console Hardware": http://nerdlypleasures.blogspot.com/2017/06/official-variations-of-nintendo-8-bit.html
- game-tech.us, "NES2 intro" (NES-101 JIO-01 teardown): https://www.game-tech.us/nes2-intro/
- Console5 wiki, "Nintendo NES-101": https://wiki.console5.com/tw/index.php?title=Nintendo_NES-101
- Console5 wiki, "Nintendo NES-001": https://wiki.console5.com/tw/index.php?title=Nintendo_NES-001
- qmtpro, NES chip die images (RP2A03G / RP2C02G): https://www.qmtpro.com/~nes/chipimages/
- Retrocomputing StackExchange, "Differences between the NES-001 (NTSC) motherboard revisions": https://retrocomputing.stackexchange.com/questions/2980/does-anyone-know-the-specific-differences-between-the-nes-001-ntsc-motherboard
- This repository:
  - BreakingNESWiki/MB/NES.md and BreakingNESWiki/MB/Famicom.md
  - Docs/Famicom/Chipset/Readme.md (decapped chipset photos, donor HVC-CPU-GPM-01)
  - Docs/JIO/Readme.md (JIO pinout, by Jacques Gagnon)
  - Docs/Famicom/ (HVC-CPU-05/06 schematics, famicom_pcb_HVC-CPU-06 photo)
  - Docs/NES/ (NES-CPU-01/02 and NES-CPU-11 schematics)
