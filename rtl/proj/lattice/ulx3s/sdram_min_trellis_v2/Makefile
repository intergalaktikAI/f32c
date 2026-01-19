# f32c sdram_min - Open-source FPGA Toolchain Build
# Target: ULX3S (LFE5U-12F)
# Tools: GHDL + Yosys + nextpnr-ecp5 + ecppack
#
# Usage:
#   make all      - Build bitstream (requires Docker or native tools)
#   make docker   - Build using Docker
#   make native   - Build using native tools (oss-cad-suite)
#   make prog     - Program ULX3S board

# Paths - adjust F32C_ROOT for your setup
F32C_ROOT ?= $(realpath ../../../../../..)
F32C ?= $(F32C_ROOT)/f32c
F32C_VALENT ?= $(F32C_ROOT)/f32c-valent

# Docker settings
DOCKER_IMAGE ?= f32c-patched:latest
DOCKER_MOUNT ?= -v $(F32C_ROOT):/projects
DOCKER_WORKDIR ?= /projects/f32c-valent/rtl/proj/lattice/ulx3s/sdram_min_trellis_v2

# Target device
DEVICE ?= 12k
PACKAGE ?= CABGA381
SPEED ?= 6

# Output files
JSON = sdram_min.json
CONFIG = sdram_min.config
BITSTREAM = sdram_min.bit

.PHONY: all docker native synth pnr bit clean prog help

# Default: try native, fall back to docker
all: $(BITSTREAM)

# Docker-based build
docker: clean
	docker run --rm $(DOCKER_MOUNT) -w $(DOCKER_WORKDIR) $(DOCKER_IMAGE) \
		yosys -m ghdl synth.ys
	docker run --rm $(DOCKER_MOUNT) -w $(DOCKER_WORKDIR) $(DOCKER_IMAGE) \
		nextpnr-ecp5 --$(DEVICE) --package $(PACKAGE) --speed $(SPEED) \
		--json $(JSON) --lpf ulx3s_nextpnr.lpf --lpf-allow-unconstrained \
		--textcfg $(CONFIG)
	docker run --rm $(DOCKER_MOUNT) -w $(DOCKER_WORKDIR) $(DOCKER_IMAGE) \
		ecppack --compress --input $(CONFIG) --bit $(BITSTREAM)

# Native build (requires oss-cad-suite in PATH)
native: synth_native.ys
	yosys -m ghdl synth_native.ys
	nextpnr-ecp5 --$(DEVICE) --package $(PACKAGE) --speed $(SPEED) \
		--json $(JSON) --lpf ulx3s_nextpnr.lpf --lpf-allow-unconstrained \
		--textcfg $(CONFIG)
	ecppack --compress --input $(CONFIG) --bit $(BITSTREAM)

# Generate native synth script with resolved paths
synth_native.ys: synth.ys
	@echo "Generating synth_native.ys with paths:"
	@echo "  F32C=$(F32C)"
	@echo "  F32C_VALENT=$(F32C_VALENT)"
	sed -e 's|/projects/f32c/|$(F32C)/|g' \
	    -e 's|/projects/f32c-valent/|$(F32C_VALENT)/|g' \
	    synth.ys > synth_native.ys

$(JSON): synth.ys
	@if command -v docker >/dev/null 2>&1; then \
		echo "Building with Docker..."; \
		docker run --rm $(DOCKER_MOUNT) -w $(DOCKER_WORKDIR) $(DOCKER_IMAGE) \
			yosys -m ghdl synth.ys; \
	else \
		echo "Building with native tools..."; \
		$(MAKE) synth_native.ys; \
		yosys -m ghdl synth_native.ys; \
	fi

$(CONFIG): $(JSON)
	@if command -v docker >/dev/null 2>&1; then \
		docker run --rm $(DOCKER_MOUNT) -w $(DOCKER_WORKDIR) $(DOCKER_IMAGE) \
			nextpnr-ecp5 --$(DEVICE) --package $(PACKAGE) --speed $(SPEED) \
			--json $(JSON) --lpf ulx3s_nextpnr.lpf --lpf-allow-unconstrained \
			--textcfg $(CONFIG); \
	else \
		nextpnr-ecp5 --$(DEVICE) --package $(PACKAGE) --speed $(SPEED) \
			--json $(JSON) --lpf ulx3s_nextpnr.lpf --lpf-allow-unconstrained \
			--textcfg $(CONFIG); \
	fi

$(BITSTREAM): $(CONFIG)
	@if command -v docker >/dev/null 2>&1; then \
		docker run --rm $(DOCKER_MOUNT) -w $(DOCKER_WORKDIR) $(DOCKER_IMAGE) \
			ecppack --compress --input $(CONFIG) --bit $(BITSTREAM); \
	else \
		ecppack --compress --input $(CONFIG) --bit $(BITSTREAM); \
	fi

# Program ULX3S via fujprog
prog: $(BITSTREAM)
	fujprog $(BITSTREAM)

# Clean generated files
clean:
	rm -f $(JSON) $(CONFIG) $(BITSTREAM) synth_native.ys

help:
	@echo "f32c sdram_min Build System"
	@echo ""
	@echo "Targets:"
	@echo "  all     - Build bitstream (auto-detect Docker/native)"
	@echo "  docker  - Build using Docker"
	@echo "  native  - Build using native tools"
	@echo "  prog    - Program ULX3S board"
	@echo "  clean   - Remove generated files"
	@echo ""
	@echo "Variables:"
	@echo "  DEVICE=$(DEVICE) (12k, 25k, 45k, 85k)"
	@echo "  F32C=$(F32C)"
	@echo "  F32C_VALENT=$(F32C_VALENT)"
	@echo ""
	@echo "Requirements:"
	@echo "  Docker with $(DOCKER_IMAGE)"
	@echo "  OR oss-cad-suite in PATH"
