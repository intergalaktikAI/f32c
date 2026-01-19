# f32c sdram_min Makefile
# Uses Docker with GHDL+Yosys+nextpnr-ecp5
# Note: Different Docker images for synthesis vs P&R due to version compatibility

PROJ=sdram_min
FPGA_SIZE?=12
CONSTRAINTS=ulx3s_nextpnr.lpf

# Path to RTL root (relative to this Makefile location)
RTL_ROOT=$(shell cd ../../../.. && pwd)

# Docker images:
# - ghdl-yosys-patched: GHDL+Yosys 0.36 (stable, no crashes)
# - f32c-patched: has nextpnr-ecp5 and ecppack
SYNTH_IMAGE=ghdl-yosys-patched:latest
PNR_IMAGE=f32c-patched:latest

# Docker run command with RTL mounted at /src
DOCKER_SYNTH=docker run --rm -v "$(RTL_ROOT):/src" -w /src/proj/lattice/ulx3s/sdram_min_trellis_v2 $(SYNTH_IMAGE)
DOCKER_PNR=docker run --rm -v "$(RTL_ROOT):/src" -w /src/proj/lattice/ulx3s/sdram_min_trellis_v2 $(PNR_IMAGE)

all: $(PROJ).bit

# Synthesis with GHDL+Yosys (use older version to avoid crash)
$(PROJ).json: synth_docker.ys Makefile $(wildcard *.vhd)
	$(DOCKER_SYNTH) yosys -m ghdl synth_docker.ys

# Place and route with nextpnr-ecp5
$(PROJ).config: $(PROJ).json $(CONSTRAINTS)
	$(DOCKER_PNR) nextpnr-ecp5 --$(FPGA_SIZE)k --speed 6 --package CABGA381 \
		--json $(PROJ).json \
		--lpf $(CONSTRAINTS) \
		--lpf-allow-unconstrained \
		--timing-allow-fail \
		--textcfg $(PROJ).config

# Bitstream generation
$(PROJ).bit: $(PROJ).config
	$(DOCKER_PNR) ecppack --compress $(PROJ).config $(PROJ).bit

# Program ULX3S board
prog: $(PROJ).bit
	fujprog $<

clean:
	rm -f $(PROJ).bit $(PROJ).config $(PROJ).json *~

.PHONY: all prog clean
