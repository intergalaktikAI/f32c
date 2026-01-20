#!/bin/bash
# GHDL Simulation Script for f32c ULX3S
# Run with Docker from rtl folder

set -e

echo "=== GHDL Simulation for f32c ==="
echo "Analyzing VHDL files..."

# GHDL options
GHDL_OPTS="--std=08 --ieee=synopsys -fexplicit -frelaxed-rules"

# 1. Packages first (no dependencies)
ghdl -a $GHDL_OPTS ../../../../soc/sram_pack.vhd
ghdl -a $GHDL_OPTS ../../../../soc/axi_pack.vhd
ghdl -a $GHDL_OPTS ../../../../soc/sdram_pack.vhd
ghdl -a $GHDL_OPTS ../../../../soc/vgahdmi/video_mode_pack.vhd

# 2. CPU definitions
ghdl -a $GHDL_OPTS ../../../../cpu/defs_mi32.vhd
ghdl -a $GHDL_OPTS ../../../../cpu/defs_rv32.vhd
ghdl -a $GHDL_OPTS ../../../../cpu/defs_f32c.vhd

# 3. Bootloader packages
ghdl -a $GHDL_OPTS ../../../../generic/bootloader/defs_bootblock.vhd
ghdl -a $GHDL_OPTS ../../../../generic/bootloader/boot_sio_rv32el.vhd
ghdl -a $GHDL_OPTS ../../../../generic/bootloader/boot_sio_mi32el.vhd
ghdl -a $GHDL_OPTS ../../../../generic/bootloader/boot_sio_mi32eb.vhd
ghdl -a $GHDL_OPTS ../../../../generic/bootloader/boot_rom_mi32el.vhd

# 4. Generic components (BRAM, ROM)
ghdl -a $GHDL_OPTS ../../../../generic/bram.vhd
ghdl -a $GHDL_OPTS ./bram_true2p_1clk_ghdl.vhd  # GHDL version with memory init
ghdl -a $GHDL_OPTS ./bram_true2p_2clk_ghdl.vhd  # GHDL version with memory init
ghdl -a $GHDL_OPTS ./rom_ghdl.vhd  # GHDL version with R_ack init
ghdl -a $GHDL_OPTS ../../../../generic/acram_emu.vhd

# 5. CPU core components
ghdl -a $GHDL_OPTS ../../../../cpu/idecode_mi32.vhd
ghdl -a $GHDL_OPTS ../../../../cpu/idecode_rv32.vhd
ghdl -a $GHDL_OPTS ../../../../cpu/debug.vhd
ghdl -a $GHDL_OPTS ./f32c_core_ghdl.vhd  # GHDL version with signal inits and MI32 reset

# 6. f32c cache (depends on f32c_core and bram)
ghdl -a $GHDL_OPTS ./f32c_cache_ghdl.vhd

# 8. SoC peripherals
ghdl -a $GHDL_OPTS ./sio_ghdl.vhd  # GHDL version with signal inits
ghdl -a $GHDL_OPTS ./gpio_ghdl.vhd
ghdl -a $GHDL_OPTS ../../../../soc/timer.vhd
ghdl -a $GHDL_OPTS ../../../../soc/rtc.vhd
ghdl -a $GHDL_OPTS ../../../../soc/sdram_mz.vhd
ghdl -a $GHDL_OPTS ../../../../soc/sdram_mz_wrap.vhd
ghdl -a $GHDL_OPTS ../../../../soc/sdram32.vhd
ghdl -a $GHDL_OPTS ../../../../soc/sram.vhd
ghdl -a $GHDL_OPTS ../../../../soc/sram_refresh.vhd
ghdl -a $GHDL_OPTS ../../../../soc/sram8.vhd
ghdl -a $GHDL_OPTS ../../../../soc/acram.vhd
ghdl -a $GHDL_OPTS ../../../../soc/axiram.vhd
ghdl -a $GHDL_OPTS ../../../../soc/axi_read.vhd

# 9. PID controller (order matters: rotary_decoder and simotor before pid)
ghdl -a $GHDL_OPTS ../../../../soc/pid/ctrlpid.vhd
ghdl -a $GHDL_OPTS ../../../../soc/pid/rotary_decoder.vhd
ghdl -a $GHDL_OPTS ../../../../soc/pid/simotor.vhd
ghdl -a $GHDL_OPTS ../../../../soc/pid/pid.vhd

# 10. Video (cvbs before tv)
ghdl -a $GHDL_OPTS ../../../../soc/cvbs.vhd
ghdl -a $GHDL_OPTS ../../../../soc/vgahdmi/vga.vhd
ghdl -a $GHDL_OPTS ../../../../soc/vgahdmi/tv.vhd
ghdl -a $GHDL_OPTS ../../../../soc/vgahdmi/videofifo.vhd
ghdl -a $GHDL_OPTS ../../../../soc/vgahdmi/ws2812b.vhd
ghdl -a $GHDL_OPTS ../../../../soc/vgahdmi/pulse_counter.vhd
ghdl -a $GHDL_OPTS ../../../../soc/vgahdmi/TMDS_encoder.vhd
ghdl -a $GHDL_OPTS ../../../../soc/vgahdmi/vga2dvid.vhd
ghdl -a $GHDL_OPTS ../../../../soc/vgahdmi/vga2lcd.vhd
ghdl -a $GHDL_OPTS ../../../../soc/vgahdmi/vga2lcd35.vhd

# 11. Audio
ghdl -a $GHDL_OPTS ../../../../soc/simple_ADC.vhd
ghdl -a $GHDL_OPTS ../../../../soc/sigmadelta.vhd
ghdl -a $GHDL_OPTS ../../../../soc/pcm.vhd
ghdl -a $GHDL_OPTS ../../../../soc/dacpwm.vhd
ghdl -a $GHDL_OPTS ../../../../soc/i2s.vhd
ghdl -a $GHDL_OPTS ../../../../soc/spdif_tx.vhd
ghdl -a $GHDL_OPTS ../../../../soc/synth.vhd

# 12. FM/RDS (dependencies first: rds, fmgen, bram_rds before fm)
ghdl -a $GHDL_OPTS ../../../../soc/fm/lowpass.vhd
ghdl -a $GHDL_OPTS ../../../../soc/fm/message.vhd
ghdl -a $GHDL_OPTS ../../../../soc/fm/rds.vhd
ghdl -a $GHDL_OPTS ../../../../soc/fm/fmgen.vhd
ghdl -a $GHDL_OPTS ../../../../soc/fm/bram_rds.vhd
ghdl -a $GHDL_OPTS ../../../../soc/fm/fm.vhd

# 13. USB
ghdl -a $GHDL_OPTS ../../../../soc/usb11_phy/usb_rx_phy_48MHz.vhd
ghdl -a $GHDL_OPTS ../../../../soc/usb11_phy/usb_tx_phy.vhd
ghdl -a $GHDL_OPTS ../../../../soc/usb11_phy/usb_phy.vhd
ghdl -a $GHDL_OPTS ../../../../soc/usb_serial/usb_control.vhd
ghdl -a $GHDL_OPTS ../../../../soc/usb_serial/usb_init.vhd
ghdl -a $GHDL_OPTS ../../../../soc/usb_serial/usb_packet.vhd
ghdl -a $GHDL_OPTS ../../../../soc/usb_serial/usb_transact.vhd
ghdl -a $GHDL_OPTS ../../../../soc/usb_serial/usb_serial.vhd
ghdl -a $GHDL_OPTS ../../../../soc/usb_serial/usbsio.vhd
ghdl -a $GHDL_OPTS ../../../../generic/usb_transceiver.vhd

# 14. Vector processor (FPU common first, then stages, then pipeline)
ghdl -a $GHDL_OPTS ../../../../soc/vector/fpu/mul/common/fpnormalize_fpnormalize.vhd
ghdl -a $GHDL_OPTS ../../../../soc/vector/fpu/mul/common/fpround_fpround.vhd
ghdl -a $GHDL_OPTS ../../../../soc/vector/fpu/mul/common/packfp_packfp.vhd
ghdl -a $GHDL_OPTS ../../../../soc/vector/fpu/mul/common/unpackfp_unpackfp.vhd
ghdl -a $GHDL_OPTS ../../../../soc/vector/fpu/mul/multiplier/fpmul_stage1_struct.vhd
ghdl -a $GHDL_OPTS ../../../../soc/vector/fpu/mul/multiplier/fpmul_stage2_struct.vhd
ghdl -a $GHDL_OPTS ../../../../soc/vector/fpu/mul/multiplier/fpmul_stage3_struct.vhd
ghdl -a $GHDL_OPTS ../../../../soc/vector/fpu/mul/multiplier/fpmul_stage4_struct.vhd
ghdl -a $GHDL_OPTS ../../../../soc/vector/fpu/mul/multiplier/fpmul_pipeline.vhd
ghdl -a $GHDL_OPTS ../../../../soc/vector/fpu/add_sub_emiraga/add_sub_emiraga.vhd
ghdl -a $GHDL_OPTS ../../../../soc/vector/fpu/float_divide_goldschmidt.vhd
ghdl -a $GHDL_OPTS ../../../../soc/vector/vector.vhd
ghdl -a $GHDL_OPTS ../../../../soc/vector/f32c_vector_dma.vhd
ghdl -a $GHDL_OPTS ../../../../soc/vector/axi_vector_dma.vhd

# 15. Stubs for unused entities
ghdl -a $GHDL_OPTS ./stubs.vhd

# 15b. ECP5 simulation primitives (MUST be after stubs.vhd to override stub PLL)
ghdl -a $GHDL_OPTS ./ecp5_sim_prims.vhd

# 16. glue_xram (main SoC)
ghdl -a $GHDL_OPTS ./glue_xram_vector_ghdl.vhd

# 17. ECP5 PLL
ghdl -a $GHDL_OPTS ../../../../lattice/chip/ecp5u/ecp5pll.vhd
ghdl -a $GHDL_OPTS ../../../../lattice/chip/ecp5u/ecp5_flash_clk.vhd

# 18. Top module (simulation version uses serial bootloader, not SPI flash)
ghdl -a $GHDL_OPTS ./top_xram_sdram_sim.vhd

# 19. SDRAM model for testbench
ghdl -a $GHDL_OPTS ./sdram_model.vhd

# 20. Testbench
ghdl -a $GHDL_OPTS ./tb_top.vhd

echo "Elaborating testbench..."
ghdl -e $GHDL_OPTS tb_top

echo "Running simulation (500us with warnings suppressed)..."
ghdl -r $GHDL_OPTS tb_top --wave=sim.ghw --stop-time=500us --assert-level=error 2>&1 | tee sim.log

echo ""
echo "=== Simulation Complete ==="
echo "Waveform: sim.ghw (view with gtkwave)"
echo "Log: sim.log"
