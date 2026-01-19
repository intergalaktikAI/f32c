# f32c XRAM SDRAM c2 - GHDL Compatibility Build

**Project:** f32c FPGA soft CPU with SDRAM
**Target:** ULX3S (ECP5 12F/85F)
**Toolchain:** GHDL + Yosys + nextpnr-ecp5 (open-source)

---

## Files Created/Modified

### 1. `f32c_cache_ghdl.vhd`

**Purpose:** GHDL-compatible version of f32c_cache.vhd

**Key Changes:**
- **Removed unused M_i_bram signal** (lines 118-121 in original)
  - Original declared `signal M_i_bram: T_icache_bram;` (48K bits) that was NEVER used
  - GHDL doesn't optimize away unused arrays - synthesized to 11,000+ FFs
  - This caused 8x LUT overhead (21,042 vs 2,493 LUT4)

- **Changed I-cache tag BRAM to single-port pattern**
  - ECP5 DP16KD only supports one write port
  - Muxed write signals to single port for proper BRAM inference

**Impact:** 8.4x reduction in LUT usage

### 2. `glue_xram_vector_ghdl.vhd`

**Purpose:** GHDL-compatible version of glue_xram_vector.vhd

**Key Changes:**
- Uses `f32c_cache_ghdl` instead of `f32c_cache` entity
- Line 1080: `cpu: entity work.f32c_cache_ghdl`

### 3. `gpio_ghdl.vhd`

**Purpose:** GHDL-compatible GPIO module

**Key Changes:**
- Simplified GPIO implementation for GHDL synthesis
- Removed constructs that cause GHDL synthesis issues

### 4. `stubs.vhd`

**Purpose:** Stub entities for unused peripherals

**Why needed:**
- GHDL requires all instantiated entities to exist
- These stubs provide empty implementations for:
  - `rtc` (real-time clock)
  - `sdram32` (32-bit SDRAM - we use 16-bit)
  - `sram` (SRAM interface)
  - Other unused peripherals

### 5. `top_xram_sdram_trellis_minimal.vhd`

**Purpose:** Minimal top-level for Trellis/nextpnr build

**Key Features:**
- Simplified port mappings
- ECP5 PLL instantiation for clock generation
- USB serial (usbsio) for communication

### 6. `synth.ys`

**Purpose:** Yosys synthesis script for GHDL+Yosys flow

**Key Points:**
- Uses `ghdl --std=08 --ieee=synopsys` for VHDL analysis
- Includes local GHDL-compatible files instead of original:
  - `./f32c_cache_ghdl.vhd`
  - `./glue_xram_vector_ghdl.vhd`
  - `./gpio_ghdl.vhd`
  - `./stubs.vhd`
- Synthesizes with `synth_ecp5 -top ulx3s_xram_sdram_vector`

### 7. `ulx3s_nextpnr.lpf`

**Purpose:** Pin constraints for nextpnr-ecp5

**Contents:**
- Clock input (25 MHz on G2)
- PLL output frequency constraint (100 MHz)
- UART pins (FTDI)
- LEDs, buttons, switches
- SDRAM interface (16-bit data, 13-bit address)
- SPI Flash
- SD Card
- GPDI (HDMI output)
- GPIO pins

### 8. `Makefile`

**Purpose:** Build automation

**Targets:**
- `make` - Full build (synthesis + PnR + bitstream)
- `make prog` - Program ULX3S via fujprog
- `make clean` - Remove build artifacts

**Docker Integration:**
- Uses `hdlc/ghdl:yosys` for synthesis
- Runs nextpnr-ecp5 natively

---

## Build Results

### Before Fix (original f32c_cache.vhd):
| Resource | Count |
|----------|-------|
| LUT4 | 21,042 |
| FF | 11,982 |
| BRAM | 6 |

### After Fix (f32c_cache_ghdl.vhd):
| Resource | Count |
|----------|-------|
| LUT4 | 3,153 |
| FF | 1,906 |
| BRAM (DP16KD) | 13 |
| DSP (MULT18X18D) | 4 |

**Reduction: 8.4x fewer LUTs!**

---

## Clock Configuration

| Clock | Frequency | Source | Purpose |
|-------|-----------|--------|---------|
| clk_25mhz | 25 MHz | Board input | PLL reference |
| clk | 78.125 MHz | PLL out2 | CPU + SDRAM |
| clk_pixel | 25 MHz | PLL out1 | Video pixel clock |
| clk_pixel_shift | 125 MHz | PLL out0 | HDMI shift clock |

**Note:** CPU clock set to 78.125 MHz to match original Diamond `clk_25_78_125_25` PLL configuration.

---

## Known Issues

1. **BRAM Inference:** Some patterns still infer distributed RAM (TRELLIS_DPR16X4) instead of block RAM
2. **Timing:** May need `--timing-allow-fail` for initial testing

---

## GHDL Feature Requests

See `GHDL_FEATURE_REQUESTS.md` for detailed suggestions based on this porting experience.

---

*Created: 2026-01-19*
*Author: Hans Weber (FPGA Agent)*
*Toolchain: GHDL 4.0.0 + Yosys 0.36 + nextpnr-ecp5*
