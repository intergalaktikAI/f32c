-- f32c XRAM SDRAM for ULX3S - Open-source toolchain version
-- Modified for GHDL + Yosys + nextpnr-ecp5 compatibility
-- Based on top_ulx3s_12f_xram_sdram.vhd by EMARD
-- Port names match ulx3s_v20.lpf

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;
use ieee.math_real.all;

use work.f32c_pack.all;

use work.boot_block_pack.all;
use work.boot_sio_mi32el.all;
use work.boot_sio_mi32eb.all;
use work.boot_sio_rv32el.all;
use work.boot_rom_mi32el.all;

-- ECP5 primitives declared as components (no vendor library needed for GHDL)

entity ulx3s_xram_sdram_vector is
  generic
  (
    -- ISA: either ARCH_MI32 or ARCH_RV32
    C_arch: integer := ARCH_MI32;
    C_debug: boolean := false;

    -- Main clock: 78.125 MHz (original Diamond working frequency)
    C_clk_freq: integer := 78;

    -- SoC configuration options
    C_boot_rom: boolean := true;
    C_xboot_rom: boolean := false;
    C_bram_size: integer := 2;
    C_bram_const_init: boolean := true;
    C_boot_write_protect: boolean := true;
    C_boot_rom_data_bits: integer := 32;
    C_boot_spi: boolean := true;
    C_xram_base: std_logic_vector(31 downto 28) := x"8";
    C_PC_mask: std_logic_vector(31 downto 0) := x"81ffffff";
    C_cached_addr_bits: integer := 25;
    C_acram: boolean := false;
    C_acram_wait_cycles: integer := 3;
    C_acram_emu_kb: integer := 128;
    C_sdram: boolean := true;
    C_sdram_wait_cycles: integer := 2;
    C_icache_size: integer := 8;
    C_dcache_size: integer := 8;
    C_branch_prediction: boolean := true;
    C_sio: integer := 1;
    C_spi: integer := 2;  -- Flash + SD card
    C_spi_fixed_speed: std_logic_vector := "11";
    C_simple_io: boolean := true;
    C_gpio: integer := 0;  -- Disabled for GHDL tristate fix
    C_gpio_pullup: boolean := false;
    C_gpio_adc: integer := 0;
    C_timer: boolean := true;
    C_pcm: boolean := false;
    C_synth: boolean := false;
    C_dacpwm: boolean := false;
    C_spdif: boolean := false;
    C_cw_simple_out: integer := -1;

    C_passthru_autodetect: boolean := false;

    C_vector: boolean := false;

    -- video parameters
    C_dvid_ddr: boolean := true;
    C_video_mode: integer := 1;
    C_shift_clock_synchronizer: boolean := true;

    C_vgahdmi: boolean := false;  -- disabled due to compositing2_fifo GHDL issue
    C_vgahdmi_fifo_data_width: integer range 8 to 32 := 16;
    C_vgahdmi_fifo_burst_max_bits: integer range 0 to 8 := 8;
    C_vgahdmi_fifo_fast_ram: boolean := true;
    C_vgahdmi_cache_size: integer := 0;
    C_vgahdmi_cache_use_i: boolean := false;
    C_compositing2_write_while_reading: boolean := true;

    C_vgatext: boolean := false
  );
  port
  (
    clk_25mhz: in std_logic;

    -- UART0 (FTDI USB slave serial)
    ftdi_rxd: out std_logic;
    ftdi_txd: in std_logic;

    -- SDRAM interface
    sdram_clk: out std_logic;
    sdram_cke: out std_logic;
    sdram_csn: out std_logic;
    sdram_rasn: out std_logic;
    sdram_casn: out std_logic;
    sdram_wen: out std_logic;
    sdram_a: out std_logic_vector(12 downto 0);
    sdram_ba: out std_logic_vector(1 downto 0);
    sdram_dqm: out std_logic_vector(1 downto 0);
    sdram_d: inout std_logic_vector(15 downto 0);

    -- Onboard blinky
    led: out std_logic_vector(7 downto 0);
    btn: in std_logic_vector(6 downto 0);
    sw: in std_logic_vector(3 downto 0);

    -- GPIO
    gp: out std_logic_vector(27 downto 0);
    gn: out std_logic_vector(27 downto 0);

    -- Digital Video
    gpdi_dp: out std_logic_vector(3 downto 0);
    gpdi_dn: out std_logic_vector(3 downto 0);

    -- Flash ROM
    flash_miso: in std_logic;
    flash_mosi: out std_logic;
    flash_csn: out std_logic;
    flash_holdn: out std_logic := '1';
    flash_wpn: out std_logic := '1';

    -- SD card
    sd_cmd: out std_logic;
    sd_d: inOut std_logic_vector(3 downto 0);
    sd_clk: out std_logic;
    sd_cdn: in std_logic;
    sd_wp: in std_logic
  );
end;

architecture Behavioral of ulx3s_xram_sdram_vector is
  function ceil_log2(x: integer) return integer is
  begin
      return integer(ceil((log2(real(x)-1.0E-6))-1.0E-6));
  end ceil_log2;

  signal clk: std_logic;
  signal clk_pixel_shift, clk_pixel: std_logic;
  signal pll_clk: std_logic_vector(3 downto 0);
  signal pll_lock: std_logic;
  signal ram_en: std_logic;
  signal ram_byte_we: std_logic_vector(3 downto 0) := (others => '0');
  signal ram_address: std_logic_vector(31 downto 0) := (others => '0');
  signal ram_data_write: std_logic_vector(31 downto 0) := (others => '0');
  signal ram_data_read: std_logic_vector(31 downto 0) := (others => '0');
  signal ram_ready: std_logic;
  signal dvid_crgb: std_logic_vector(7 downto 0);
  signal ddr_d: std_logic_vector(3 downto 0);

  signal S_reset: std_logic := '0';
  signal xdma_addr: std_logic_vector(29 downto 2) := ('0', others => '0');
  signal xdma_strobe: std_logic := '0';
  signal xdma_data_ready: std_logic := '0';
  signal xdma_data_in: std_logic_vector(31 downto 0) := (others => '-');

  signal S_rxd, S_txd: std_logic;
  signal S_f32c_sd_csn, S_f32c_sd_clk, S_f32c_sd_miso, S_f32c_sd_mosi: std_logic;
  signal S_flash_csn, S_flash_clk: std_logic;

  -- Internal signals for glue_xram ports
  signal S_simple_out: std_logic_vector(31 downto 0);
  signal S_simple_in: std_logic_vector(31 downto 0);
  signal S_gpio: std_logic_vector(127 downto 0);

  -- Internal bidirectional signals for SPI (glue_xram uses inout)
  signal S_spi_miso: std_logic_vector(C_spi-1 downto 0);
  signal S_spi_mosi: std_logic_vector(C_spi-1 downto 0);

  -- Internal SDRAM data bus (32-bit in glue_xram, but only 16 used)
  signal S_sdram_data: std_logic_vector(31 downto 0);
  signal S_sdram_dqm: std_logic_vector(3 downto 0);

  component ODDRX1F
    port(D0, D1, SCLK, RST: in std_logic; Q: out std_logic);
  end component;

  component OLVDS
    port(A: in std_logic; Z, ZN: out std_logic);
  end component;

begin
  -- Clock generation using ecp5pll (open-source compatible)
  -- 25MHz input -> 125MHz pixel shift, 25MHz pixel, 78.125MHz CPU
  -- Matches original Diamond configuration: clk_25_78_125_25
  I_pll: entity work.ecp5pll
  generic map (
    in_hz      => 25000000,
    out0_hz    => 125000000,  -- pixel shift clock
    out1_hz    => 25000000,   -- pixel clock
    out2_hz    => 78125000    -- CPU clock (78.125 MHz - original working frequency)
  )
  port map (
    clk_i      => clk_25mhz,
    clk_o      => pll_clk,
    locked     => pll_lock
  );
  clk_pixel_shift <= pll_clk(0);
  clk_pixel <= pll_clk(1);
  clk <= pll_clk(2);

  -- Simple serial passthrough
  S_rxd <= ftdi_txd;
  ftdi_rxd <= S_txd;

  -- SD card directly connected
  sd_d(3) <= S_f32c_sd_csn;
  sd_clk <= S_f32c_sd_clk;
  S_f32c_sd_miso <= sd_d(0);
  sd_cmd <= S_f32c_sd_mosi;
  sd_d(2 downto 1) <= (others => '1');

  -- SPI signal routing (single assignment to avoid multiple drivers)
  S_spi_miso <= S_f32c_sd_miso & flash_miso;  -- (1) SD card, (0) flash
  flash_mosi <= S_spi_mosi(0);
  S_f32c_sd_mosi <= S_spi_mosi(1);

  -- Simple_in mapping (single assignment to avoid multiple drivers)
  S_simple_in <= x"000" & sw & "000000000" & btn;

  -- SDRAM data bus: bidirectional, directly connect lower 16 bits
  -- Upper 16 bits of S_sdram_data are unused (left floating internally)
  sdram_d <= S_sdram_data(15 downto 0);
  sdram_dqm <= S_sdram_dqm(1 downto 0);

  -- Main SoC
  glue_xram: entity work.glue_xram
  generic map (
    C_arch => C_arch,
    C_clk_freq => C_clk_freq,
    C_boot_rom => C_boot_rom,
    C_bram_size => C_bram_size,
    C_bram_const_init => C_bram_const_init,
    C_boot_write_protect => C_boot_write_protect,
    C_boot_spi => C_boot_spi,
    C_branch_prediction => C_branch_prediction,
    C_PC_mask => C_PC_mask,
    C_acram => C_acram,
    C_acram_wait_cycles => C_acram_wait_cycles,
    C_sdram => C_sdram,
    C_sdram_clock_range => 2,
    C_sdram_ras => C_sdram_wait_cycles,
    C_sdram_cas => C_sdram_wait_cycles,
    C_sdram_pre => C_sdram_wait_cycles,
    C_sdram_address_width => 24,
    C_sdram_column_bits => 9,
    C_sdram_startup_cycles => 12000,
    C_sdram_cycles_per_refresh => 1524,
    C_icache_size => C_icache_size,
    C_dcache_size => C_dcache_size,
    C_cached_addr_bits => C_cached_addr_bits,
    C_xdma => C_xboot_rom,
    C_xram_base => C_xram_base,
    C_debug => C_debug,
    C_sio => C_sio,
    C_spi => C_spi,
    C_spi_fixed_speed => C_spi_fixed_speed,
    C_gpio => C_gpio,
    C_gpio_pullup => C_gpio_pullup,
    C_gpio_adc => C_gpio_adc,
    C_timer => C_timer,
    C_pcm => C_pcm,
    C_synth => C_synth,
    C_dacpwm => C_dacpwm,
    C_spdif => C_spdif,
    C_cw_simple_out => C_cw_simple_out,
    C_vector => C_vector,
    C_dvid_ddr => C_dvid_ddr,
    C_shift_clock_synchronizer => C_shift_clock_synchronizer,
    C_compositing2_write_while_reading => C_compositing2_write_while_reading,
    C_vgahdmi => C_vgahdmi,
    C_vgahdmi_mode => C_video_mode,
    C_vgahdmi_cache_size => C_vgahdmi_cache_size,
    C_vgahdmi_fifo_data_width => C_vgahdmi_fifo_data_width,
    C_vgahdmi_fifo_burst_max_bits => C_vgahdmi_fifo_burst_max_bits,
    C_vgatext => C_vgatext
  )
  port map (
    clk => clk,
    clk_pixel => clk_pixel,
    clk_pixel_shift => clk_pixel_shift,
    reset => S_reset,
    sio_rxd(0) => S_rxd,
    sio_txd(0) => S_txd,
    sio_break => open,

    spi_ss(0) => S_flash_csn,
    spi_ss(1) => S_f32c_sd_csn,
    spi_sck(0) => S_flash_clk,
    spi_sck(1) => S_f32c_sd_clk,
    spi_mosi => S_spi_mosi,
    spi_miso => S_spi_miso,

    gpio => S_gpio,
    simple_out => S_simple_out,
    simple_in => S_simple_in,

    -- SDRAM interface (directly inout connected)
    sdram_addr => sdram_a,
    sdram_data => S_sdram_data,
    sdram_ba => sdram_ba,
    sdram_dqm => S_sdram_dqm,
    sdram_ras => sdram_rasn,
    sdram_cas => sdram_casn,
    sdram_cke => sdram_cke,
    sdram_clk => sdram_clk,
    sdram_we => sdram_wen,
    sdram_cs => sdram_csn,

    -- ACRAM emulation
    acram_en => ram_en,
    acram_addr(29 downto 2) => ram_address(29 downto 2),
    acram_byte_we => ram_byte_we,
    acram_data_rd => ram_data_read,
    acram_data_wr => ram_data_write,
    acram_ready => ram_ready,

    -- exposed DMA
    xdma_addr => xdma_addr,
    xdma_strobe => xdma_strobe,
    xdma_write => '1',
    xdma_byte_sel => "1111",
    xdma_data_in => xdma_data_in,
    xdma_data_ready => xdma_data_ready,

    -- DVID output
    dvid_clock => dvid_crgb(7 downto 6),
    dvid_red   => dvid_crgb(5 downto 4),
    dvid_green => dvid_crgb(3 downto 2),
    dvid_blue  => dvid_crgb(1 downto 0)
  );

  -- LED output from simple_out
  led <= S_simple_out(7 downto 0);

  -- DDR HDMI output with differential buffers
  G_dvid_ddr: if C_dvid_ddr generate
    G_ddr_diff: for i in 0 to 3 generate
      gpdi_ddr: ODDRX1F port map(D0=>dvid_crgb(2*i), D1=>dvid_crgb(2*i+1), Q=>ddr_d(i), SCLK=>clk_pixel_shift, RST=>'0');
      gpdi_diff: OLVDS port map(A => ddr_d(i), Z => gpdi_dp(i), ZN => gpdi_dn(i));
    end generate;
  end generate;

  -- Flash clock generation
  flash_clock: entity work.ecp5_flash_clk
  port map
  (
    flash_csn => '0',
    flash_clk => S_flash_clk
  );
  flash_csn <= S_flash_csn;

  -- GPIO disabled for GHDL tristate fix - tie to ground
  gp <= (others => '0');
  gn <= (others => '0');

end Behavioral;
