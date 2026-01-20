# GHDL Simulation for f32c ULX3S

## Overview

This document describes how to run GHDL simulation for the f32c FPGA design and documents the simulation results.

## Files

| File | Purpose |
|------|---------|
| `tb_top.vhd` | Testbench for top module |
| `top_xram_sdram_sim.vhd` | Simulation-specific top (uses serial bootloader) |
| `ecp5_sim_prims.vhd` | ECP5 simulation primitives (PLL, DDR, LVDS) |
| `sim.sh` | Simulation script |
| `f32c_core_ghdl.vhd` | GHDL-patched CPU core with signal initializations |
| `f32c_cache_ghdl.vhd` | GHDL-patched cache with signal initializations |
| `rom_ghdl.vhd` | GHDL-patched ROM with R_ack initialization |
| `sio_ghdl.vhd` | GHDL-patched UART with signal initializations |
| `bram_true2p_1clk_ghdl.vhd` | GHDL-patched BRAM with memory initialization |
| `bram_true2p_2clk_ghdl.vhd` | GHDL-patched dual-clock BRAM |
| `sdram_model.vhd` | Behavioral SDRAM model (1MB) |

## How to Run Simulation

### Prerequisites
- Docker with `hdlc/ghdl:yosys` image
- OR native GHDL installation

### Running with Docker (from `rtl` folder)

```bash
cd projects/f32c-valent/rtl

MSYS_NO_PATHCONV=1 docker run --rm \
  -v "C:/Users/Valent/code/agents/goran-fpga/projects/f32c-valent/rtl:/src" \
  -w "/src/proj/lattice/ulx3s/xram_sdram_12f_v2.0_c2_noscripts_trellis" \
  hdlc/ghdl:yosys \
  bash -c "sed -i 's/\r$//' ./sim.sh && chmod +x ./sim.sh && ./sim.sh"
```

### Suppressing Warnings (faster simulation)

To suppress arithmetic warnings from 'U'/'Z' values:
```bash
ghdl -r --std=08 --ieee=synopsys -fexplicit -frelaxed-rules tb_top \
  --wave=sim.ghw --stop-time=1ms --assert-level=error
```

### Output Files
- `sim.ghw` - Waveform file (view with GTKWave)
- `sim.log` - Simulation log

### Viewing Waveforms
```bash
gtkwave sim.ghw
```

---

## Simulation Results (2026-01-20) - SESSION 2

### Test Configuration
- Input Clock: 25 MHz
- PLL Output: 125 MHz (pixel shift), 25 MHz (pixel), 50 MHz (CPU+SDRAM)
- Simulation Duration: 500us
- Bootloader: Serial (C_boot_spi=false)

### Current Status: ⚠️ Infrastructure Working, CPU Not Executing

| Time | LED State | Notes |
|------|-----------|-------|
| 0us | - | Simulation start, PLL initializing |
| 1us | 00000000 | LEDs initialized to 0 ✅ |
| 11us | 00000000 | PLL locked (~4us), design running |
| 111us | 00000000 | SDRAM active (CKE='1', CSN='0') |
| 200us | - | Serial CR (0x0D) sent to bootloader |
| 400us | 00000000 | FTDI_RXD='1' (idle, no serial TX) |
| 500us | 00000000 | No response to serial input |

### Key Finding

**Signal initialization is working** (LEDs show '00000000', not 'UUUUUUUU'), but the **CPU does not appear to be executing bootloader code**. There are persistent 'U' value warnings in arithmetic operations, suggesting some signals are still uninitialized.

---

## Fixes Applied (Session 2)

### New Fixes

| Fix | File | Status |
|-----|------|--------|
| Simulation-specific top with C_boot_spi=false | `top_xram_sdram_sim.vhd` | ✅ Done |
| SDRAM bidirectional data bus handling | `top_xram_sdram_sim.vhd` | ✅ Done |
| BRAM memory initialization to zeros | `bram_true2p_1clk_ghdl.vhd` | ✅ Done |
| Dual-clock BRAM initialization | `bram_true2p_2clk_ghdl.vhd` | ✅ Done |

### Previous Fixes (Session 1)

| Fix | File | Status |
|-----|------|--------|
| PLL simulation model with proper clock generation | `ecp5_sim_prims.vhd` | ✅ Done |
| Initialize sio_break_internal to '0' | `glue_xram_vector_ghdl.vhd` | ✅ Done |
| Initialize R_simple_out (LEDs) to '0' | `glue_xram_vector_ghdl.vhd` | ✅ Done |
| Initialize IF_PC and pipeline registers | `f32c_core_ghdl.vhd` | ✅ Done |
| Add MI32 reset handling | `f32c_core_ghdl.vhd` | ✅ Done |
| Initialize ROM R_ack signal | `rom_ghdl.vhd` | ✅ Done |
| Initialize cache FSM signals | `f32c_cache_ghdl.vhd` | ✅ Done |
| Initialize UART signals | `sio_ghdl.vhd` | ✅ Done |

---

## Current Investigation Status

### Simulation Infrastructure: ✅ WORKING
- PLL simulation model generates correct clocks (125/25/50 MHz)
- Signal initialization working (LEDs show 00000000, not UUUUUUUU)
- SDRAM model included and active (CKE='1', CSN='0')
- SDRAM bidirectional data bus properly connected
- Serial bootloader selected (C_boot_spi=false)
- Serial stimulus sent (CR at 200us, 'h' at ~787us)

### CPU Execution: ⚠️ NOT WORKING
The CPU does not appear to execute the bootloader:
- LEDs remain at 00000000 (no writes to GPIO)
- Serial TX remains idle (no UART output)
- No response to serial input (CR, 'h' commands)
- Persistent 'U' value warnings in arithmetic operations

### Remaining 'U' Value Sources

Despite BRAM initialization, 'U' warnings persist. Potential sources:
1. **D-cache M_d_bram** - Not initialized in f32c_cache_ghdl.vhd
2. **Store buffer M_sb** - Not initialized
3. **Register file** - May need initialization
4. **Other internal arrays** - Need investigation

### Next Steps for Investigation
1. Initialize M_d_bram and M_sb in f32c_cache_ghdl.vhd
2. Check register file initialization
3. Add debug output to trace instruction fetch
4. Verify boot ROM data is being read correctly

---

## Architecture Notes

### Instruction Fetch Path
```
CPU (IF_PC=0x00000000)
    |
    v
f32c_cache_ghdl (I-cache)
    |
    v
glue_xram_vector_ghdl
    |
    +-- S_imem_addr_in_xram='0' (boot ROM address)
    |
    v
rom_ghdl (boot ROM with serial bootloader)
    |
    v
bram_i_to_cpu -> final_to_cpu_i -> f32c_cache -> CPU
```

### Bootloader Selection
```vhdl
-- In top_xram_sdram_sim.vhd:
C_boot_spi: boolean := false;  -- Use serial bootloader (not SPI flash)

-- This selects M_boot_sio_mi32el (index 0) in rom_ghdl.vhd
```

### SDRAM Bidirectional Bus
```vhdl
-- In top_xram_sdram_sim.vhd:
S_sdram_data(31 downto 16) <= (others => 'Z');
sdram_d <= S_sdram_data(15 downto 0);           -- Output: CPU -> SDRAM
S_sdram_data(15 downto 0) <= sdram_d;           -- Input: SDRAM -> CPU
-- std_logic resolution handles multiple drivers
```

---

## Files Modified for GHDL Simulation

```
proj/lattice/ulx3s/xram_sdram_12f_v2.0_c2_noscripts_trellis/
├── top_xram_sdram_sim.vhd     # Simulation top (C_boot_spi=false)
├── f32c_core_ghdl.vhd         # Patched CPU core
├── f32c_cache_ghdl.vhd        # Patched cache
├── rom_ghdl.vhd               # Patched ROM
├── sio_ghdl.vhd               # Patched UART
├── gpio_ghdl.vhd              # Patched GPIO
├── glue_xram_vector_ghdl.vhd  # Patched SoC glue
├── bram_true2p_1clk_ghdl.vhd  # BRAM with init
├── bram_true2p_2clk_ghdl.vhd  # Dual-clock BRAM with init
├── ecp5_sim_prims.vhd         # ECP5 primitives for sim
├── sdram_model.vhd            # Behavioral SDRAM model
├── tb_top.vhd                 # Testbench
├── sim.sh                     # Simulation script
└── patch_f32c_core.py         # Patch generator
```

---

## Comparison: Simulation vs Hardware

| Aspect | Simulation (GHDL) | Hardware (FPGA) |
|--------|-------------------|-----------------|
| Signal init | Explicit (via `:=`) | '0' or vendor-specific |
| BRAM init | Requires explicit | Automatic from bitstream |
| Reset | Requires explicit | Often implicit |
| SDRAM | Behavioral model | Real chip |
| Timing | Behavioral | Real delays |
| Clock | Generated by PLL sim | PLL output |

---

*Created: 2026-01-20*
*Updated: 2026-01-20 (Session 2)*
*Tool: GHDL (via Docker hdlc/ghdl:yosys)*
*Status: ⚠️ Infrastructure working, CPU execution investigation ongoing*
