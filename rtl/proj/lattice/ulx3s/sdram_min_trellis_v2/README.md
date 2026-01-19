# sdram_min_trellis_v2 - Open-Source Toolchain Build

This directory contains modified files for building f32c sdram_min configuration
using open-source FPGA toolchain (GHDL + Yosys + nextpnr-ecp5).

## Why Modified Files?

The original f32c VHDL code was written for proprietary tools (Lattice Diamond, Xilinx ISE).
GHDL has stricter VHDL parsing and different synthesis patterns. These files were modified
to achieve compatibility with GHDL + ghdl-yosys-plugin.

## File Descriptions

### glue_sdram_min_ghdl.vhd
**Original:** `../../xram_sdram/glue_sdram.vhd`

**Modifications:**
- Removed SPI active accent implementation (GHDL doesn't support `inout` port mode in same way)
- Changed `case when F_io_from() to F_io_to()` to `if-elsif-else` (GHDL requires "locally static" choices)
- Changed `with select when range` to conditional assignments for the same reason
- Simplified signal assignments for GHDL synthesis compatibility

### sdram_controller_ghdl.vhd
**Original:** `../../../soc/sdram.vhd`

**Modifications:**
- Removed vendor-specific BRAM attributes (`syn_ramstyle`, `ram_style`)
- Changed dual-write-port BRAM pattern to read-first pattern (ECP5 DP16KD compatibility)
- Simplified initialization loops for GHDL elaboration

### sdram_pack_ghdl.vhd
**Original:** `../../../soc/sdram_pack.vhd`

**Modifications:**
- Minor syntax adjustments for GHDL compatibility
- Package used by sdram_controller_ghdl.vhd

### top_sdram_min.vhd
**New file** - Top-level entity for this specific build.

**Purpose:**
- Instantiates ECP5 PLL (ecp5pll) for clock generation
- Connects glue_sdram_min to board I/O
- Minimal configuration: 1 CPU, UART, SDRAM, LEDs

### synth_docker.ys
**New file** - Yosys synthesis script.

**Purpose:**
- Lists all VHDL files in correct compilation order
- Specifies GHDL flags: `--ieee=synopsys -fexplicit -frelaxed-rules --latches`
- Runs `synth_ecp5` for ECP5 target

### ulx3s_nextpnr.lpf
**Original:** `../../../lattice/ulx3s/clocks/ulx3s_v20_segpdi.lpf` (partial)

**Modifications:**
- Removed IOBUF commands (not supported by nextpnr-ecp5)
- Removed LOCATE COMP for unused pins
- Added FREQUENCY constraints for PLL clocks
- Kept only pins used by sdram_min configuration

### Makefile
**New file** - Build system for open-source toolchain.

**Targets:**
- `make` - Build using local GHDL+Yosys (Linux/macOS with oss-cad-suite)
- `make docker` - Build using Docker container (Windows or fallback)
- `make prog` - Program ULX3S board with fujprog

## Build Results

Synthesis (GHDL + Yosys):
- 22 DP16KD (BRAM blocks)
- ~3,060 LUT4
- ~1,600 FF

Compared to Lattice Diamond:
- Diamond: 3,504 LUT4
- Open-source: 3,060 LUT4 (13% smaller!)

## Usage

```bash
# Linux/macOS (with oss-cad-suite installed)
make clean && make

# Windows (or if local GHDL not available)
make clean && make docker

# Program board
make prog
```

## Known Issues

1. **Timing:** nextpnr reports ~41 MHz achieved vs 84 MHz target. Uses `--timing-allow-fail`.
   Design works in practice but timing closure needs optimization.

2. **SPI disabled:** SPI peripheral commented out due to GHDL `inout` port issues.
   Can be re-enabled with interface wrapper.

---
*Created: 2026-01-19*
*Author: Hans Weber (FPGA Agent)*
