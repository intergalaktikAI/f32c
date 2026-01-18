#!/bin/bash
# f32c XRAM SDRAM Build Script for ULX3S
# Uses open-source toolchain: GHDL + Yosys + nextpnr-ecp5
#
# Prerequisites:
#   - Docker Desktop running
#   - ghdl-yosys-patched image built (see docker/Dockerfile.ghdl-yosys-patched)
#
# Usage: ./build-f32c.sh [synth|pnr|bit|all|clean]

set -e

# Configuration
PROJECT_DIR="$(cd "$(dirname "$0")" && pwd)"
RTL_DIR="$PROJECT_DIR/rtl"
BUILD_DIR="$RTL_DIR/proj/lattice/ulx3s/xram_sdram_12f_v2.0_c2_noscripts_trellis"
DEVICE="85k"  # 12k, 45k, or 85k
PACKAGE="CABGA381"

# Docker images
GHDL_IMAGE="ghdl-yosys-patched"
NEXTPNR_IMAGE="hdlc/nextpnr:ecp5"

# Output files
JSON_FILE="f32c_xram.json"
CONFIG_FILE="f32c_xram_${DEVICE}.config"
BIT_FILE="f32c_xram_${DEVICE}.bit"

echo "=== f32c Build Script ==="
echo "Project: $PROJECT_DIR"
echo "Device: LFE5U-${DEVICE^^}"
echo ""

build_ghdl_image() {
    echo "=== Building GHDL patched image ==="
    cd "$PROJECT_DIR/../docker"
    docker build -f Dockerfile.ghdl-yosys-patched -t ghdl-yosys-patched .
}

run_synthesis() {
    echo "=== Running Synthesis (GHDL + Yosys) ==="
    echo "This may take 5-10 minutes..."

    docker run --rm -m 16g \
        -v "$RTL_DIR:/src" \
        -w "/src/proj/lattice/ulx3s/xram_sdram_12f_v2.0_c2_noscripts_trellis" \
        $GHDL_IMAGE \
        yosys -m ghdl synth.ys

    if [ -f "$BUILD_DIR/$JSON_FILE" ]; then
        echo "Synthesis complete: $JSON_FILE"
        ls -lh "$BUILD_DIR/$JSON_FILE"
    else
        echo "ERROR: Synthesis failed!"
        exit 1
    fi
}

run_pnr() {
    echo "=== Running Place & Route (nextpnr-ecp5) ==="
    echo "Using SA placer for ${DEVICE^^} device..."
    echo "This may take 30-60 minutes..."

    docker run --rm -m 8g \
        -v "$RTL_DIR:/src" \
        -w "/src/proj/lattice/ulx3s/xram_sdram_12f_v2.0_c2_noscripts_trellis" \
        $NEXTPNR_IMAGE \
        nextpnr-ecp5 \
            --${DEVICE} \
            --package $PACKAGE \
            --json $JSON_FILE \
            --lpf /src/proj/lattice/constraints/ulx3s_v20.lpf \
            --textcfg $CONFIG_FILE \
            --placer sa

    if [ -f "$BUILD_DIR/$CONFIG_FILE" ]; then
        echo "Place & Route complete: $CONFIG_FILE"
        ls -lh "$BUILD_DIR/$CONFIG_FILE"
    else
        echo "ERROR: Place & Route failed!"
        exit 1
    fi
}

run_bitstream() {
    echo "=== Generating Bitstream (ecppack) ==="

    docker run --rm \
        -v "$RTL_DIR:/src" \
        -w "/src/proj/lattice/ulx3s/xram_sdram_12f_v2.0_c2_noscripts_trellis" \
        $NEXTPNR_IMAGE \
        ecppack $CONFIG_FILE $BIT_FILE

    if [ -f "$BUILD_DIR/$BIT_FILE" ]; then
        echo "Bitstream complete: $BIT_FILE"
        ls -lh "$BUILD_DIR/$BIT_FILE"
    else
        echo "ERROR: Bitstream generation failed!"
        exit 1
    fi
}

run_clean() {
    echo "=== Cleaning build artifacts ==="
    rm -f "$BUILD_DIR"/*.json
    rm -f "$BUILD_DIR"/*.config
    rm -f "$BUILD_DIR"/*.bit
    echo "Clean complete."
}

case "${1:-all}" in
    synth)
        run_synthesis
        ;;
    pnr)
        run_pnr
        ;;
    bit)
        run_bitstream
        ;;
    all)
        run_synthesis
        run_pnr
        run_bitstream
        echo ""
        echo "=== BUILD COMPLETE ==="
        echo "Bitstream: $BUILD_DIR/$BIT_FILE"
        echo ""
        echo "To program FPGA:"
        echo "  fujprog $BIT_FILE"
        ;;
    clean)
        run_clean
        ;;
    image)
        build_ghdl_image
        ;;
    *)
        echo "Usage: $0 [synth|pnr|bit|all|clean|image]"
        echo ""
        echo "  synth - Run synthesis (GHDL + Yosys)"
        echo "  pnr   - Run place & route (nextpnr-ecp5)"
        echo "  bit   - Generate bitstream (ecppack)"
        echo "  all   - Run complete build"
        echo "  clean - Remove build artifacts"
        echo "  image - Build GHDL patched Docker image"
        exit 1
        ;;
esac
