# f32c Open-Source Build Instructions

Build f32c XRAM SDRAM for ULX3S using the open-source FPGA toolchain.

## Prerequisites

1. **Docker Desktop** - installed and running
2. **Git** - to clone the repository

## Quick Start

```bash
# 1. Clone repository
git clone https://github.com/anthropics/goran-fpga.git
cd goran-fpga

# 2. Build the patched GHDL Docker image (one-time)
cd docker
docker build -f Dockerfile.ghdl-yosys-patched -t ghdl-yosys-patched .
cd ..

# 3. Run full build
cd projects/f32c-valent
./build-f32c.sh all
```

## Step-by-Step Build

### Step 1: Build GHDL Patched Image (One-time)

```bash
cd docker
docker build -f Dockerfile.ghdl-yosys-patched -t ghdl-yosys-patched .
```

This creates a Docker image with GHDL patched for f32c compatibility (relaxed locally static checking).

### Step 2: Synthesis (GHDL + Yosys)

```bash
cd projects/f32c-valent
./build-f32c.sh synth
```

Or manually:
```bash
docker run --rm -m 16g \
  -v "$(pwd)/rtl:/src" \
  -w "/src/proj/lattice/ulx3s/xram_sdram_12f_v2.0_c2_noscripts_trellis" \
  ghdl-yosys-patched \
  yosys -m ghdl synth.ys
```

**Output:** `f32c_xram.json` (~44MB)
**Time:** ~5-10 minutes

### Step 3: Place & Route (nextpnr-ecp5)

```bash
./build-f32c.sh pnr
```

Or manually:
```bash
docker run --rm -m 8g \
  -v "$(pwd)/rtl:/src" \
  -w "/src/proj/lattice/ulx3s/xram_sdram_12f_v2.0_c2_noscripts_trellis" \
  hdlc/nextpnr:ecp5 \
  nextpnr-ecp5 --85k --package CABGA381 \
    --json f32c_xram.json \
    --lpf /src/proj/lattice/constraints/ulx3s_v20.lpf \
    --textcfg f32c_xram_85k.config \
    --placer sa
```

**Output:** `f32c_xram_85k.config`
**Time:** ~30-60 minutes (SA placer is slow but reliable)

### Step 4: Generate Bitstream (ecppack)

```bash
./build-f32c.sh bit
```

Or manually:
```bash
docker run --rm \
  -v "$(pwd)/rtl:/src" \
  -w "/src/proj/lattice/ulx3s/xram_sdram_12f_v2.0_c2_noscripts_trellis" \
  hdlc/nextpnr:ecp5 \
  ecppack f32c_xram_85k.config f32c_xram_85k.bit
```

**Output:** `f32c_xram_85k.bit`
**Time:** ~1 minute

### Step 5: Program FPGA

```bash
fujprog f32c_xram_85k.bit
```

## Monitoring Progress

### Check Synthesis Progress
```bash
# Watch Yosys output
docker logs -f <container_id>
```

### Check PnR Progress
```bash
# Follow nextpnr output - look for:
# - "initial placement placed X/48410 cells" - placement progress
# - "at iteration #X: wirelen = Y" - SA optimization (wirelen should decrease)
# - "Info: Router" - routing phase starts
# - "Remaining X/147215" - routing progress

# To monitor in real-time:
docker logs -f <container_id>
```

### Device Size Selection

| Device | LUTs | Result |
|--------|------|--------|
| LFE5U-12F | 12K | Too small (106% utilization) |
| LFE5U-45F | 45K | Works (59% utilization) |
| LFE5U-85F | 85K | Recommended (~30% utilization) |

To change device, edit `build-f32c.sh`:
```bash
DEVICE="85k"  # Change to 45k or 12k
```

## Troubleshooting

### "Unable to find legal placement"
Use SA placer instead of heap placer:
```bash
nextpnr-ecp5 ... --placer sa
```

### Container crashes (OOM)
Increase memory limit:
```bash
docker run --rm -m 16g ...
```

### Path translation errors on Windows
Use MSYS_NO_PATHCONV:
```bash
MSYS_NO_PATHCONV=1 docker run ...
```

## Files

```
projects/f32c-valent/
├── build-f32c.sh           # Build script
├── BUILD.md                # This file
└── rtl/
    └── proj/lattice/ulx3s/xram_sdram_12f_v2.0_c2_noscripts_trellis/
        ├── synth.ys                              # Yosys synthesis script
        ├── top_xram_sdram_trellis_minimal.vhd    # Top-level entity
        ├── stubs.vhd                             # GHDL-compatible stubs
        ├── f32c_xram.json                        # Synthesis output
        ├── f32c_xram_85k.config                  # PnR output
        └── f32c_xram_85k.bit                     # Final bitstream
```

## References

- [f32c Project](https://github.com/f32c/f32c)
- [ULX3S Board](https://github.com/emard/ulx3s)
- [GHDL](https://github.com/ghdl/ghdl)
- [Yosys](https://github.com/YosysHQ/yosys)
- [nextpnr](https://github.com/YosysHQ/nextpnr)
