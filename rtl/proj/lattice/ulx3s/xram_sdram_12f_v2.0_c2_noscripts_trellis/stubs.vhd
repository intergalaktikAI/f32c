-- Stub entities for GHDL compatibility
-- These stubs satisfy GHDL's need to have all referenced entities exist
-- even if they're in generate blocks that won't be elaborated.
-- IMPORTANT: Interfaces must EXACTLY match what glue_xram_vector.vhd expects

-- ============================================
-- Stub for spi (GHDL-compatible: spi_miso/mosi changed from inOut)
-- Interface based on spi.vhd but with IN/OUT instead of INOUT
-- ============================================
library ieee;
use ieee.std_logic_1164.all;

entity spi is
generic (
  C_fixed_speed: boolean := true
);
port (
  ce, clk: in std_logic;
  bus_write: in std_logic;
  byte_sel: in std_logic_vector(3 downto 0);
  bus_in: in std_logic_vector(31 downto 0);
  bus_out: out std_logic_vector(31 downto 0);
  spi_sck: out std_logic;
  spi_cen: out std_logic_vector(3 downto 0);
  spi_mosi: out std_logic;
  spi_miso: in std_logic
);
end spi;

architecture stub of spi is
begin
  bus_out <= (others => '0');
  spi_sck <= '0';
  spi_cen <= (others => '1');
  spi_mosi <= '0';
end stub;

-- ============================================
-- Stub for usb_rx_phy_emard
-- ============================================
library ieee;
use ieee.std_logic_1164.all;

entity usb_rx_phy_emard is
generic (
  C_clk_input_hz: natural := 6000000;
  C_clk_bit_hz: natural   := 1500000;
  C_PA_bits: natural      := 8
);
port (
  clk, reset: in std_logic;
  usb_dif, usb_dp, usb_dn: in std_logic;
  linestate: out std_logic_vector(1 downto 0);
  clk_recovered, clk_recovered_edge: out std_logic;
  rawdata: out std_logic;
  rx_en: in std_logic;
  rx_active: out std_logic;
  rx_error: out std_logic;
  valid: out std_logic;
  data: out std_logic_vector(7 downto 0)
);
end usb_rx_phy_emard;

architecture stub of usb_rx_phy_emard is
begin
  linestate <= "00";
  clk_recovered <= '0';
  clk_recovered_edge <= '0';
  rawdata <= '0';
  rx_active <= '0';
  rx_error <= '0';
  valid <= '0';
  data <= (others => '0');
end stub;

-- ============================================
-- Stub for video_cache_i
-- ============================================
library ieee;
use ieee.std_logic_1164.all;

entity video_cache_i is
generic (
  C_icache_size: integer := 0;
  C_cached_addr_bits: integer := 20;
  C_icache_expire: boolean := false
);
port (
  clk: in std_logic;
  i_cacheable: in std_logic := '1';
  i_addr: in std_logic_vector(31 downto 2) := (others => '0');
  i_addr_strobe: in std_logic := '0';
  i_data: out std_logic_vector(31 downto 0);
  i_ready: out std_logic;
  i_flush: in std_logic := '0';
  i_addr_flush: in std_logic_vector(31 downto 2) := (others => '0');
  imem_addr_strobe: out std_logic;
  imem_addr: out std_logic_vector(31 downto 2);
  imem_data_in: in std_logic_vector(31 downto 0) := (others => '0');
  imem_data_ready: in std_logic := '0'
);
end video_cache_i;

architecture stub of video_cache_i is
begin
  i_data <= (others => '0');
  i_ready <= '0';
  imem_addr_strobe <= '0';
  imem_addr <= (others => '0');
end stub;

-- ============================================
-- Stub for video_cache_d
-- ============================================
library ieee;
use ieee.std_logic_1164.all;

entity video_cache_d is
generic (
  C_dcache_size: integer := 0;
  C_cached_addr_bits: integer := 20;
  C_cache_bursts: boolean := false;
  C_debug: boolean := false
);
port (
  clk: in std_logic;
  cpu_d_cacheable: in std_logic := '1';
  cpu_d_addr: in std_logic_vector(31 downto 2);
  cpu_d_data_in: out std_logic_vector(31 downto 0);
  cpu_d_data_out: in std_logic_vector(31 downto 0) := (others => '0');
  cpu_d_strobe, cpu_d_write: in std_logic := '0';
  cpu_d_byte_sel: in std_logic_vector(3 downto 0) := "1111";
  cpu_d_ready: out std_logic;
  dmem_addr_strobe: out std_logic;
  dmem_write: out std_logic;
  dmem_byte_sel: out std_logic_vector(3 downto 0);
  dmem_addr: out std_logic_vector(31 downto 2);
  dmem_burst_len: out std_logic_vector(2 downto 0);
  dmem_data_in: in std_logic_vector(31 downto 0) := (others => '0');
  dmem_data_out: out std_logic_vector(31 downto 0);
  dmem_data_ready: in std_logic := '0'
);
end video_cache_d;

architecture stub of video_cache_d is
begin
  cpu_d_data_in <= (others => '0');
  cpu_d_ready <= '0';
  dmem_addr_strobe <= '0';
  dmem_write <= '0';
  dmem_byte_sel <= "0000";
  dmem_addr <= (others => '0');
  dmem_burst_len <= "000";
  dmem_data_out <= (others => '0');
end stub;

-- ============================================
-- Stub for compositing2_fifo
-- ============================================
library ieee;
use ieee.std_logic_1164.all;

entity compositing2_fifo is
generic (
  C_synclen: integer := 2;
  C_fast_ram: boolean := true;
  C_write_while_reading: boolean := true;
  C_position_clipping: boolean := false;
  C_timeout: integer := 0;
  C_timeout_incomplete: boolean := false;
  C_burst_max_bits: integer := 0;
  C_width: integer := 640;
  C_height: integer := 480;
  C_vscroll: integer := 3;
  C_data_width: integer range 8 to 32 := 8;
  C_length_subtract: integer := 0;
  C_length_width: integer range 4 to 16 := 11;
  C_addr_width: integer := 11
);
port (
  clk, clk_pixel: in std_logic;
  addr_strobe: out std_logic;
  addr_out: out std_logic_vector(29 downto 2);
  suggest_burst: out std_logic_vector(C_burst_max_bits-1 downto 0) := (others => '0');
  suggest_cache: out std_logic;
  base_addr: in std_logic_vector(29 downto 2);
  data_ready: in std_logic;
  data_in: in std_logic_vector(31 downto 0);
  read_ready: out std_logic;
  data_out: out std_logic_vector(C_data_width-1 downto 0);
  active: in std_logic;
  frame: out std_logic;
  color_transparent, color_background: in std_logic_vector(C_data_width-1 downto 0) := (others => '0');
  fetch_next: in std_logic
);
end compositing2_fifo;

architecture stub of compositing2_fifo is
begin
  addr_strobe <= '0';
  addr_out <= (others => '0');
  suggest_burst <= (others => '0');
  suggest_cache <= '0';
  read_ready <= '0';
  data_out <= (others => '0');
  frame <= '0';
end stub;

-- ============================================
-- Stub for ledstrip
-- ============================================
library ieee;
use ieee.std_logic_1164.all;

entity ledstrip is
generic (
  C_clk_Hz: integer;
  C_addr_bits: integer := 2;
  C_bits: integer := 32;
  C_xram_base: std_logic_vector(31 downto 28) := x"8";
  C_ledstrip_full_circle: integer := 100;
  C_width: integer;
  C_height: integer;
  C_data_width: integer range 8 to 32 := 8;
  C_addr_width: integer := 11
);
port (
  ce, clk: in std_logic;
  bus_write: in std_logic;
  addr: in std_logic_vector(C_addr_bits-1 downto 0);
  byte_sel: in std_logic_vector(3 downto 0);
  bus_in: in std_logic_vector(31 downto 0);
  bus_out: out std_logic_vector(31 downto 0);
  video_frame: out std_logic;
  video_addr_strobe: out std_logic;
  video_addr: out std_logic_vector(29 downto 2);
  video_data_ready: in std_logic;
  from_xram: in std_logic_vector(31 downto 0);
  rotation_sensor: in std_logic;
  ledstrip_out: out std_logic
);
end ledstrip;

architecture stub of ledstrip is
begin
  bus_out <= (others => '0');
  video_frame <= '0';
  video_addr_strobe <= '0';
  video_addr <= (others => '0');
  ledstrip_out <= '0';
end stub;

-- ============================================
-- Stub for VGA_textmode
-- ============================================
library ieee;
use ieee.std_logic_1164.all;

entity VGA_textmode is
generic (
  C_vgatext_mode: integer;
  C_vgatext_bits: integer;
  C_vgatext_bram_mem: integer;
  C_vgatext_external_mem: integer;
  C_vgatext_reset: boolean;
  C_vgatext_palette: boolean;
  C_vgatext_text: boolean;
  C_vgatext_reg_read: boolean;
  C_vgatext_text_fifo: boolean;
  C_vgatext_font_bram8: boolean;
  C_vgatext_char_height: integer;
  C_vgatext_font_height: integer;
  C_vgatext_font_depth: integer;
  C_vgatext_font_linedouble: boolean;
  C_vgatext_font_widthdouble: boolean;
  C_vgatext_monochrome: boolean;
  C_vgatext_finescroll: boolean;
  C_vgatext_cursor: boolean;
  C_vgatext_cursor_blink: boolean;
  C_vgatext_bitmap: boolean;
  C_vgatext_bitmap_depth: integer;
  C_vgatext_bitmap_fifo_data_width: integer := 32;
  C_vgatext_bitmap_fifo: boolean
);
port (
  reset_i: in std_logic;
  clk_i: in std_logic;
  ce_i: in std_logic;
  bus_write_i: in std_logic;
  bus_addr_i: in std_logic_vector(2 downto 0);
  byte_sel_i: in std_logic_vector(3 downto 0);
  bus_data_i: in std_logic_vector(31 downto 0);
  bus_data_o: out std_logic_vector(31 downto 0);
  clk_pixel_i: in std_logic;
  bram_addr_o: out std_logic_vector(15 downto 2);
  bram_data_i: in std_logic_vector(31 downto 0) := (others => '0');
  text_active_o: out std_logic;
  textfifo_addr_o: out std_logic_vector(29 downto 2);
  textfifo_data_i: in std_logic_vector(31 downto 0) := (others => '0');
  textfifo_strobe_o: out std_logic;
  textfifo_rewind_o: out std_logic;
  bitmap_strobe_o: out std_logic;
  bitmap_addr_o: out std_logic_vector(29 downto 2);
  bitmap_ready_i: in std_logic := '0';
  bitmap_data_i: in std_logic_vector(C_vgatext_bitmap_fifo_data_width-1 downto 0) := (others => '0');
  bitmap_rewind_o: out std_logic;
  bitmap_active_o: out std_logic;
  hsync_o: out std_logic;
  vsync_o: out std_logic;
  blank_o: out std_logic;
  red_o: out std_logic_vector(7 downto 8-C_vgatext_bits);
  green_o: out std_logic_vector(7 downto 8-C_vgatext_bits);
  blue_o: out std_logic_vector(7 downto 8-C_vgatext_bits)
);
end VGA_textmode;

architecture stub of VGA_textmode is
begin
  bus_data_o <= (others => '0');
  bram_addr_o <= (others => '0');
  text_active_o <= '0';
  textfifo_addr_o <= (others => '0');
  textfifo_strobe_o <= '0';
  textfifo_rewind_o <= '0';
  bitmap_strobe_o <= '0';
  bitmap_addr_o <= (others => '0');
  bitmap_rewind_o <= '0';
  bitmap_active_o <= '0';
  hsync_o <= '0';
  vsync_o <= '0';
  blank_o <= '1';
  red_o <= (others => '0');
  green_o <= (others => '0');
  blue_o <= (others => '0');
end stub;

-- ============================================
-- Stub for VGA_textmode_bram
-- ============================================
library ieee;
use ieee.std_logic_1164.all;

entity VGA_textmode_bram is
generic (
  C_mem_size: integer := 4;
  C_label: string := "VGA";
  C_monochrome: boolean := true;
  C_font_height: integer := 16;
  C_font_depth: integer := 7
);
port (
  clk: in std_logic;
  imem_addr: in std_logic_vector(15 downto 2);
  imem_data_out: out std_logic_vector(31 downto 0);
  dmem_write: in std_logic;
  dmem_byte_sel: in std_logic_vector(3 downto 0);
  dmem_addr: in std_logic_vector(31 downto 2);
  dmem_data_in: in std_logic_vector(31 downto 0);
  dmem_data_out: out std_logic_vector(31 downto 0)
);
end VGA_textmode_bram;

architecture stub of VGA_textmode_bram is
begin
  imem_data_out <= (others => '0');
  dmem_data_out <= (others => '0');
end stub;

-- ============================================
-- Stub for VGA_textmode_font_bram8
-- ============================================
library ieee;
use ieee.std_logic_1164.all;

entity VGA_textmode_font_bram8 is
generic (
  C_font_height: integer := 8;
  C_font_depth: integer := 7
);
port (
  clk: in std_logic;
  imem_addr: in std_logic_vector(15 downto 2);
  imem_data_out: out std_logic_vector(7 downto 0);
  dmem_write: in std_logic;
  dmem_byte_sel: in std_logic_vector(3 downto 0);
  dmem_addr: in std_logic_vector(15 downto 2);
  dmem_data_in: in std_logic_vector(7 downto 0);
  dmem_data_out: out std_logic_vector(7 downto 0)
);
end VGA_textmode_font_bram8;

architecture stub of VGA_textmode_font_bram8 is
begin
  imem_data_out <= (others => '0');
  dmem_data_out <= (others => '0');
end stub;

-- ============================================
-- Stub for sram
-- ============================================
library ieee;
use ieee.std_logic_1164.all;
use work.sram_pack.all;

entity sram is
generic (
  C_ports: integer;
  C_prio_port: integer := -1;
  C_wait_cycles: integer;
  C_pipelined_read: boolean
);
port (
  clk: in std_logic;
  data_out: out std_logic_vector(31 downto 0);
  ready_out: out sram_ready_array;
  snoop_addr: out std_logic_vector(31 downto 2);
  snoop_cycle: out std_logic;
  bus_in: in sram_port_array;
  sram_a: out std_logic_vector(18 downto 0);
  sram_d: inOut std_logic_vector(15 downto 0);
  sram_wel, sram_lbl, sram_ubl: out std_logic
);
end sram;

architecture stub of sram is
begin
  data_out <= (others => '0');
  ready_out <= (others => '0');
  snoop_addr <= (others => '0');
  snoop_cycle <= '0';
  sram_a <= (others => '0');
  sram_d <= (others => 'Z');
  sram_wel <= '1';
  sram_lbl <= '1';
  sram_ubl <= '1';
end stub;

-- ============================================
-- Stub for sram_refresh
-- ============================================
library ieee;
use ieee.std_logic_1164.all;

entity sram_refresh is
generic (
  C_clk_freq: integer;
  C_addr_bits: integer := 11;
  C_refresh_cycle_ms: integer := 32
);
port (
  clk: in std_logic;
  refresh_addr: out std_logic_vector(C_addr_bits-1 downto 0);
  refresh_strobe: out std_logic;
  refresh_data_ready: in std_logic
);
end sram_refresh;

architecture stub of sram_refresh is
begin
  refresh_addr <= (others => '0');
  refresh_strobe <= '0';
end stub;

-- ============================================
-- Stub for sram8_controller
-- ============================================
library ieee;
use ieee.std_logic_1164.all;
use work.sram_pack.all;

entity sram8_controller is
generic (
  C_ports: integer;
  C_prio_port: integer := -1;
  C_wait_cycles: integer;
  C_pipelined_read: boolean
);
port (
  clk: in std_logic;
  data_out: out std_logic_vector(31 downto 0);
  ready_out: out sram_ready_array;
  snoop_addr: out std_logic_vector(31 downto 2);
  snoop_cycle: out std_logic;
  bus_in: in sram_port_array;
  sram_addr: out std_logic_vector(19 downto 0);
  sram_data: inOut std_logic_vector(7 downto 0);
  sram_wel: out std_logic
);
end sram8_controller;

architecture stub of sram8_controller is
begin
  data_out <= (others => '0');
  ready_out <= (others => '0');
  snoop_addr <= (others => '0');
  snoop_cycle <= '0';
  sram_addr <= (others => '0');
  sram_data <= (others => 'Z');
  sram_wel <= '1';
end stub;

-- ============================================
-- Stub for sdram32
-- ============================================
library ieee;
use ieee.std_logic_1164.all;
use work.sram_pack.all;

entity sdram32 is
generic (
  C_ports: integer;
  C_prio_port: integer := -1;
  C_ras: integer range 2 to 3 := 2;
  C_cas: integer range 2 to 3 := 2;
  C_pre: integer range 2 to 3 := 2;
  C_clock_range: integer range 0 to 5 := 2;
  C_ready_point: integer range 0 to 2 := 1;
  C_done_point: integer range 0 to 2 := 1;
  C_shift_read: boolean := false;
  C_allow_back2back: boolean := true;
  sdram_address_width: natural;
  sdram_column_bits: natural;
  sdram_startup_cycles: natural;
  cycles_per_refresh: natural
);
port (
  clk: in std_logic;
  reset: in std_logic;
  data_out: out std_logic_vector(31 downto 0);
  ready_out: out sram_ready_array;
  snoop_addr: out std_logic_vector(31 downto 2);
  snoop_cycle: out std_logic;
  bus_in: in sram_port_array;
  sdram_clk: out std_logic;
  sdram_cke: out std_logic;
  sdram_cs: out std_logic;
  sdram_ras: out std_logic;
  sdram_cas: out std_logic;
  sdram_we: out std_logic;
  sdram_dqm: out std_logic_vector(3 downto 0);
  sdram_addr: out std_logic_vector(12 downto 0);
  sdram_ba: out std_logic_vector(1 downto 0);
  sdram_data: inOut std_logic_vector(31 downto 0)
);
end sdram32;

architecture stub of sdram32 is
begin
  data_out <= (others => '0');
  ready_out <= (others => '0');
  snoop_addr <= (others => '0');
  snoop_cycle <= '0';
  sdram_clk <= '0';
  sdram_cke <= '0';
  sdram_cs <= '1';
  sdram_ras <= '1';
  sdram_cas <= '1';
  sdram_we <= '1';
  sdram_dqm <= (others => '1');
  sdram_addr <= (others => '0');
  sdram_ba <= (others => '0');
  sdram_data <= (others => 'Z');
end stub;

-- ============================================
-- Stub for acram
-- ============================================
library ieee;
use ieee.std_logic_1164.all;
use work.sram_pack.all;

entity acram is
generic (
  C_ports: integer;
  C_wait_cycles: integer range 2 to 65535 := 2;
  C_prio_port: integer := -1
);
port (
  clk: in std_logic;
  data_out: out std_logic_vector(31 downto 0);
  ready_out: out sram_ready_array;
  snoop_addr: out std_logic_vector(31 downto 2);
  snoop_cycle: out std_logic := '0';
  bus_in: in sram_port_array;
  acram_a: out std_logic_vector(29 downto 2);
  acram_data_wr: out std_logic_vector(31 downto 0);
  acram_data_rd: in std_logic_vector(31 downto 0);
  acram_byte_we: out std_logic_vector(3 downto 0);
  acram_ready: in std_logic := '0';
  acram_en: out std_logic
);
end acram;

architecture stub of acram is
begin
  data_out <= (others => '0');
  ready_out <= (others => '0');
  snoop_addr <= (others => '0');
  snoop_cycle <= '0';
  acram_a <= (others => '0');
  acram_data_wr <= (others => '0');
  acram_byte_we <= (others => '0');
  acram_en <= '0';
end stub;

-- ============================================
-- Stub for axiram
-- ============================================
library ieee;
use ieee.std_logic_1164.all;
use work.sram_pack.all;
use work.axi_pack.all;

entity axiram is
generic (
  C_ports: integer;
  C_wait_cycles: integer range 2 to 65535 := 2;
  C_prio_port: integer := -1
);
port (
  clk: in std_logic;
  data_out: out std_logic_vector(31 downto 0);
  ready_out: out sram_ready_array;
  snoop_addr: out std_logic_vector(31 downto 2);
  snoop_cycle: out std_logic := '0';
  bus_in: in sram_port_array;
  axi_aresetn: in std_logic := '1';
  axi_in: in T_axi_miso;
  axi_out: out T_axi_mosi
);
end axiram;

architecture stub of axiram is
begin
  data_out <= (others => '0');
  ready_out <= (others => '0');
  snoop_addr <= (others => '0');
  snoop_cycle <= '0';
  -- axi_out left unconnected (stub)
end stub;

-- ============================================
-- Stub for usbsio
-- ============================================
library ieee;
use ieee.std_logic_1164.all;

entity usbsio is
generic (
  C_big_endian: boolean := false;
  C_bypass: boolean := false
);
port (
  ce, clk: in std_logic;
  reset: in std_logic;
  bus_write: in std_logic;
  byte_sel: in std_logic_vector(3 downto 0);
  bus_in: in std_logic_vector(31 downto 0);
  bus_out: out std_logic_vector(31 downto 0);
  break: out std_logic;
  usb_clk: in std_logic;
  usb_diff_dp: in std_logic;
  usb_dp: inOut std_logic;
  usb_dn: inOut std_logic
);
end usbsio;

architecture stub of usbsio is
begin
  bus_out <= (others => '0');
  break <= '0';
  usb_dp <= 'Z';
  usb_dn <= 'Z';
end stub;

-- ============================================
-- Stub for rtc
-- ============================================
library ieee;
use ieee.std_logic_1164.all;

entity rtc is
generic (
  C_clk_freq_hz: natural := 0;
  C_clk_freq_mhz: natural := 0;
  C_boottime: boolean := true
);
port (
  ce, clk: in std_logic;
  bus_addr: in std_logic_vector(3 downto 2);
  byte_sel: in std_logic_vector(3 downto 0);
  bus_out: out std_logic_vector(31 downto 0);
  bus_in: in std_logic_vector(31 downto 0);
  bus_write: in std_logic
);
end rtc;

architecture stub of rtc is
begin
  bus_out <= (others => '0');
end stub;

-- ============================================
-- Stub for pid
-- ============================================
library ieee;
use ieee.std_logic_1164.all;

entity pid is
generic (
  C_pwm_bits: integer range 11 to 32 := 12;
  C_addr_unit_bits: integer range 1 to 3 := 1;
  C_pids: integer range 2 to 8 := 2;
  C_simulator: std_logic_vector(7 downto 0) := (others => '0');
  C_prescaler: integer range 10 to 26 := 18;
  C_fp: integer range 0 to 26 := 8;
  C_precision: integer range 0 to 8 := 1;
  C_addr_bits: integer := 2;
  C_bits: integer range 2 to 32 := 32
);
port (
  ce, clk: in std_logic;
  bus_write: in std_logic;
  addr: in std_logic_vector(C_addr_unit_bits+C_addr_bits-1 downto 0);
  byte_sel: in std_logic_vector(3 downto 0);
  bus_in: in std_logic_vector(31 downto 0);
  bus_out: out std_logic_vector(31 downto 0);
  setpoint: in std_logic_vector(23 downto 0) := (others => '0');
  encoder_a_in:  in  std_logic_vector(C_pids-1 downto 0) := (others => '-');
  encoder_b_in:  in  std_logic_vector(C_pids-1 downto 0) := (others => '-');
  encoder_a_out: out std_logic_vector(C_pids-1 downto 0);
  encoder_b_out: out std_logic_vector(C_pids-1 downto 0);
  bridge_f_out:  out std_logic_vector(C_pids-1 downto 0);
  bridge_r_out:  out std_logic_vector(C_pids-1 downto 0)
);
end pid;

architecture stub of pid is
begin
  bus_out <= (others => '0');
  encoder_a_out <= (others => '0');
  encoder_b_out <= (others => '0');
  bridge_f_out <= (others => '0');
  bridge_r_out <= (others => '0');
end stub;

-- ============================================
-- Stub for vector
-- ============================================
library ieee;
use ieee.std_logic_1164.all;

entity vector is
generic (
  C_addr_bits: integer := 3;
  C_vaddr_bits: integer range 2 to 16 := 11;
  C_vdata_bits: integer range 32 to 64 := 32;
  C_bram_pass_thru: boolean := false;
  C_vectors: integer range 2 to 8 := 8;
  C_float_addsub: boolean := true;
  C_float_multiply: boolean := true;
  C_float_divide: boolean := true;
  C_bram_in_reg: boolean := false;
  C_bram_out_reg: boolean := false;
  C_function_result_reg: boolean := false;
  C_bits: integer range 2 to 32 := 32
);
port (
  ce, clk: in std_logic;
  bus_write: in std_logic;
  addr: in std_logic_vector(C_addr_bits-1 downto 0);
  byte_sel: in std_logic_vector(3 downto 0);
  bus_in: in std_logic_vector(31 downto 0);
  bus_out: out std_logic_vector(31 downto 0);
  io_store_mode: out std_logic;
  io_addr: out std_logic_vector(29 downto 2);
  io_request: out std_logic;
  io_done: in std_logic;
  io_bram_we: in std_logic;
  io_bram_next: in std_logic;
  io_bram_addr: in std_logic_vector(C_vaddr_bits downto 0);
  io_bram_wdata: in std_logic_vector(C_vdata_bits-1 downto 0);
  io_bram_rdata: out std_logic_vector(C_vdata_bits-1 downto 0);
  vector_irq: out std_logic
);
end vector;

architecture stub of vector is
begin
  bus_out <= (others => '0');
  io_store_mode <= '0';
  io_addr <= (others => '0');
  io_request <= '0';
  io_bram_rdata <= (others => '0');
  vector_irq <= '0';
end stub;

-- ============================================
-- Stub for axi_vector_dma
-- ============================================
library ieee;
use ieee.std_logic_1164.all;
use work.axi_pack.all;

entity axi_vector_dma is
generic (
  C_vaddr_bits: integer := 11;
  C_vdata_bits: integer := 32;
  C_burst_max_bits: integer := 6
);
port (
  clk: in std_logic;
  addr: in std_logic_vector(29 downto 2);
  request: in std_logic;
  store_mode: in std_logic;
  done: out std_logic;
  bram_we: out std_logic := '0';
  bram_next: out std_logic := '0';
  bram_addr: out std_logic_vector(C_vaddr_bits downto 0);
  bram_wdata: out std_logic_vector(C_vdata_bits-1 downto 0);
  bram_rdata: in std_logic_vector(C_vdata_bits-1 downto 0);
  axi_in: in T_axi_miso;
  axi_out: out T_axi_mosi
);
end axi_vector_dma;

architecture stub of axi_vector_dma is
begin
  done <= '1';
  bram_we <= '0';
  bram_next <= '0';
  bram_addr <= (others => '0');
  bram_wdata <= (others => '0');
  -- axi_out left unconnected (stub)
end stub;

-- ============================================
-- Stub for f32c_vector_dma
-- ============================================
library ieee;
use ieee.std_logic_1164.all;

entity f32c_vector_dma is
generic (
  C_vaddr_bits: integer := 11;
  C_vdata_bits: integer := 32;
  C_burst_max_bits: integer := 3
);
port (
  clk: in std_logic;
  addr: in std_logic_vector(29 downto 2) := (others => '0');
  length: in std_logic_vector(C_vaddr_bits-1 downto 0) := (others => '1');
  request: in std_logic := '0';
  store_mode: in std_logic := '0';
  done: out std_logic := '0';
  bram_we: out std_logic := '0';
  bram_next: out std_logic := '0';
  bram_addr: out std_logic_vector(C_vaddr_bits downto 0);
  bram_wdata: out std_logic_vector(C_vdata_bits-1 downto 0);
  bram_rdata: in std_logic_vector(C_vdata_bits-1 downto 0);
  addr_strobe: out std_logic;
  addr_out: out std_logic_vector(29 downto 2);
  suggest_burst: out std_logic_vector(C_burst_max_bits-1 downto 0) := (others => '0');
  suggest_cache: out std_logic;
  data_ready: in std_logic;
  data_write: out std_logic;
  data_in: in std_logic_vector(31 downto 0);
  data_out: out std_logic_vector(31 downto 0)
);
end f32c_vector_dma;

architecture stub of f32c_vector_dma is
begin
  done <= '1';
  bram_we <= '0';
  bram_next <= '0';
  bram_addr <= (others => '0');
  bram_wdata <= (others => '0');
  addr_strobe <= '0';
  addr_out <= (others => '0');
  suggest_burst <= (others => '0');
  suggest_cache <= '0';
  data_write <= '0';
  data_out <= (others => '0');
end stub;

-- ============================================
-- Stub for tv
-- ============================================
library ieee;
use ieee.std_logic_1164.all;

entity tv is
generic (
  C_big_endian: boolean := false;
  C_clk_freq: integer := 81250000;
  C_pixclk_div: std_logic_vector := "00111";
  C_hpos_first: std_logic_vector := x"000";
  C_hpos_last: std_logic_vector := x"200"
);
port (
  clk, clk_dac: in std_logic;
  fetch_next: out std_logic;
  pixel_data: in std_logic_vector(15 downto 0);
  mode: in std_logic_vector(1 downto 0) := "10";
  dac_out: out std_logic_vector(3 downto 0);
  vblank, vsync: out std_logic
);
end tv;

architecture stub of tv is
begin
  fetch_next <= '0';
  dac_out <= (others => '0');
  vblank <= '0';
  vsync <= '0';
end stub;

-- ============================================
-- Stub for axi_read
-- ============================================
library ieee;
use ieee.std_logic_1164.all;
use work.axi_pack.all;

entity axi_read is
port (
  axi_aresetn, axi_aclk: in std_logic;
  axi_in: in T_axi_miso;
  axi_out: out T_axi_mosi;
  iaddr: in std_logic_vector(29 downto 2);
  iaddr_strobe: in std_logic;
  iburst: in std_logic_vector(7 downto 0);
  oready: out std_logic;
  odata: out std_logic_vector(31 downto 0);
  iread_ready: in std_logic
);
end entity;

architecture stub of axi_read is
begin
  -- axi_out left unconnected (stub)
  oready <= '0';
  odata <= (others => '0');
end stub;

-- ============================================
-- Stub for videofifo
-- ============================================
library ieee;
use ieee.std_logic_1164.all;

entity videofifo is
generic (
  C_bram: boolean := false;
  C_synclen: integer := 3;
  C_step: integer := 0;
  C_postpone_step: integer := 0;
  C_width: integer := 4
);
port (
  clk, clk_pixel: in std_logic;
  addr_strobe: out std_logic;
  addr_out: out std_logic_vector(29 downto 2);
  base_addr: in std_logic_vector(29 downto 2);
  data_ready: in std_logic;
  data_in: in std_logic_vector(31 downto 0);
  data_out: out std_logic_vector(31 downto 0);
  start: in std_logic;
  frame: out std_logic;
  rewind: in std_logic := '0';
  fetch_next: in std_logic
);
end videofifo;

architecture stub of videofifo is
begin
  addr_strobe <= '0';
  addr_out <= (others => '0');
  data_out <= (others => '0');
  frame <= '0';
end stub;

-- ============================================
-- Stub for vga2lcd
-- ============================================
library ieee;
use ieee.std_logic_1164.all;

entity vga2lcd is
generic (
  C_shift_clock_synchronizer: boolean := false;
  C_depth: integer := 8
);
port (
  clk_pixel: in std_logic;
  clk_shift: in std_logic;
  in_red: in std_logic_vector(C_depth-1 downto 0);
  in_green: in std_logic_vector(C_depth-1 downto 0);
  in_blue: in std_logic_vector(C_depth-1 downto 0);
  in_blank: in std_logic;
  in_hsync: in std_logic;
  in_vsync: in std_logic;
  out_red_green: out std_logic_vector(1 downto 0);
  out_green_blue: out std_logic_vector(1 downto 0);
  out_blue_sync: out std_logic_vector(1 downto 0);
  out_clock: out std_logic_vector(1 downto 0)
);
end vga2lcd;

architecture stub of vga2lcd is
begin
  out_red_green <= (others => '0');
  out_green_blue <= (others => '0');
  out_blue_sync <= (others => '0');
  out_clock <= (others => '0');
end stub;

-- ============================================
-- Stub for vga2lcd35
-- ============================================
library ieee;
use ieee.std_logic_1164.all;

entity vga2lcd35 is
generic (
  C_depth: integer := 8
);
port (
  clk_pixel: in std_logic;
  clk_shift: in std_logic;
  in_red: in std_logic_vector(C_depth-1 downto 0);
  in_green: in std_logic_vector(C_depth-1 downto 0);
  in_blue: in std_logic_vector(C_depth-1 downto 0);
  in_hsync: in std_logic;
  out_rgb: out std_logic_vector(C_depth-1 downto 0)
);
end vga2lcd35;

architecture stub of vga2lcd35 is
begin
  out_rgb <= (others => '0');
end stub;

-- ============================================
-- Stub for pcm
-- ============================================
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity pcm is
port (
  clk: in std_logic;
  io_ce, io_bus_write: in std_logic;
  io_addr: in std_logic_vector(1 downto 0);
  io_byte_sel: in std_logic_vector(3 downto 0);
  io_bus_in: in std_logic_vector(31 downto 0);
  io_bus_out: out std_logic_vector(31 downto 0);
  addr_strobe: out std_logic;
  data_ready: in std_logic;
  addr_out: out std_logic_vector(29 downto 2);
  data_in: in std_logic_vector(31 downto 0);
  out_pcm_l, out_pcm_r: out signed(15 downto 0);
  out_l, out_r: out std_logic
);
end pcm;

architecture stub of pcm is
begin
  io_bus_out <= (others => '0');
  addr_strobe <= '0';
  addr_out <= (others => '0');
  out_pcm_l <= (others => '0');
  out_pcm_r <= (others => '0');
  out_l <= '0';
  out_r <= '0';
end stub;

-- ============================================
-- Stub for dacpwm
-- ============================================
library ieee;
use ieee.std_logic_1164.all;

entity dacpwm is
generic (
  C_pcm_bits: integer := 12;
  C_dac_bits: integer := 4
);
port (
  clk: in std_logic;
  pcm: in std_logic_vector(C_pcm_bits-1 downto 0);
  dac: out std_logic_vector(C_dac_bits-1 downto 0)
);
end dacpwm;

architecture stub of dacpwm is
begin
  dac <= (others => '0');
end stub;

-- ============================================
-- Stub for synth
-- ============================================
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity synth is
generic (
  C_clk_freq: integer := 25000000;
  C_addr_bits: integer := 1;
  C_data_bits: integer := 32;
  C_ref_freq: real := 440.0;
  C_ref_octave: integer := 5;
  C_ref_tone: integer := 9;
  C_slow_octave: integer := 7;
  C_voice_addr_bits: integer := 7;
  C_voice_vol_bits: integer := 11;
  C_wav_addr_bits: integer := 10;
  C_wav_data_bits: integer := 12;
  C_pa_data_bits: integer := 32;
  C_amplify: integer := 0;
  C_multiplier: boolean := true;
  C_multiplier_sign_fix: boolean := false;
  C_keyboard: boolean := false;
  C_bus_freq_write: boolean := true;
  C_zero_cross: boolean := false;
  C_vol_velocity_bits: integer := 6;
  C_out_bits: integer := 24
);
port (
  clk, io_ce, io_bus_write: in std_logic;
  io_addr: in std_logic_vector(C_addr_bits-1 downto 0);
  io_byte_sel: in std_logic_vector(3 downto 0);
  io_bus_in: in std_logic_vector(C_data_bits-1 downto 0);
  keyboard: in std_logic_vector(6 downto 0) := (others => '0');
  pcm_out: out signed(C_out_bits-1 downto 0)
);
end synth;

architecture stub of synth is
begin
  pcm_out <= (others => '0');
end stub;

-- ============================================
-- Stub for sigmadelta
-- ============================================
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity sigmadelta is
generic (
  C_bits: integer range 2 to 16 := 12
);
port (
  clk: in std_logic;
  in_pcm: in signed(C_bits-1 downto 0);
  out_pwm: out std_logic
);
end sigmadelta;

architecture stub of sigmadelta is
begin
  out_pwm <= '0';
end stub;

-- ============================================
-- Stub for spdif_tx
-- ============================================
library ieee;
use ieee.std_logic_1164.all;

entity spdif_tx is
generic (
  C_clk_freq: integer := 25000000;
  C_sample_freq: integer := 48000
);
port (
  clk: in std_logic;
  data_in: in std_logic_vector(23 downto 0);
  address_out: out std_logic := '0';
  spdif_out: out std_logic
);
end spdif_tx;

architecture stub of spdif_tx is
begin
  address_out <= '0';
  spdif_out <= '0';
end stub;

-- ============================================
-- Stub for i2s
-- ============================================
library ieee;
use ieee.std_logic_1164.all;

entity i2s is
generic (
  fmt: integer := 0;
  clk_hz: integer := 25000000;
  lrck_hz: integer := 48000
);
port (
  clk: in std_logic;
  l, r: in std_logic_vector(15 downto 0);
  din: out std_logic;
  bck: out std_logic;
  lrck: out std_logic
);
end i2s;

architecture stub of i2s is
begin
  din <= '0';
  bck <= '0';
  lrck <= '0';
end stub;

-- ============================================
-- Stub for fm
-- ============================================
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity fm is
generic (
  C_stereo: boolean := false;
  C_filter: boolean := false;
  C_downsample: boolean := false;
  C_rds_msg_len: integer range 2 to 2048 := 273;
  C_readable_reg: boolean := false;
  C_fmdds_hz: integer;
  C_rds_clock_multiply: integer;
  C_rds_clock_divide: integer
);
port (
  ce, clk: in std_logic;
  bus_write: in std_logic;
  addr: in std_logic_vector(1 downto 0);
  byte_sel: in std_logic_vector(3 downto 0);
  bus_in: in std_logic_vector(31 downto 0);
  bus_out: out std_logic_vector(31 downto 0);
  fm_irq: out std_logic;
  clk_fmdds: in std_logic;
  pcm_in_left, pcm_in_right: in signed(15 downto 0) := (others => '0');
  pwm_out_left, pwm_out_right: out std_logic;
  fm_antenna: out std_logic
);
end fm;

architecture stub of fm is
begin
  bus_out <= (others => '0');
  fm_irq <= '0';
  pwm_out_left <= '0';
  pwm_out_right <= '0';
  fm_antenna <= '0';
end stub;

-- ============================================
-- Stub for ECP5 primitives
-- ============================================
library ieee;
use ieee.std_logic_1164.all;

entity EHXPLLL is
generic (
  PLLRST_ENA: string := "DISABLED";
  INTFB_WAKE: string := "DISABLED";
  STDBY_ENABLE: string := "DISABLED";
  DPHASE_SOURCE: string := "DISABLED";
  OUTDIVIDER_MUXA: string := "DIVA";
  OUTDIVIDER_MUXB: string := "DIVB";
  OUTDIVIDER_MUXC: string := "DIVC";
  OUTDIVIDER_MUXD: string := "DIVD";
  CLKI_DIV: integer := 1;
  CLKOP_ENABLE: string := "ENABLED";
  CLKOP_DIV: integer := 8;
  CLKOP_CPHASE: integer := 0;
  CLKOP_FPHASE: integer := 0;
  CLKOP_TRIM_POL: string := "RISING";
  CLKOP_TRIM_DELAY: integer := 0;
  CLKOS_ENABLE: string := "DISABLED";
  CLKOS_DIV: integer := 8;
  CLKOS_CPHASE: integer := 0;
  CLKOS_FPHASE: integer := 0;
  CLKOS_TRIM_POL: string := "RISING";
  CLKOS_TRIM_DELAY: integer := 0;
  CLKOS2_ENABLE: string := "DISABLED";
  CLKOS2_DIV: integer := 8;
  CLKOS2_CPHASE: integer := 0;
  CLKOS2_FPHASE: integer := 0;
  CLKOS3_ENABLE: string := "DISABLED";
  CLKOS3_DIV: integer := 8;
  CLKOS3_CPHASE: integer := 0;
  CLKOS3_FPHASE: integer := 0;
  FEEDBK_PATH: string := "CLKOP";
  CLKFB_DIV: integer := 1;
  PLL_LOCK_MODE: integer := 0;
  PLL_LOCK_DELAY: integer := 200;
  REFIN_RESET: string := "DISABLED";
  SYNC_ENABLE: string := "DISABLED";
  INT_LOCK_STICKY: string := "ENABLED"
);
port (
  CLKI: in std_logic := 'X';
  CLKFB: in std_logic := 'X';
  PHASESEL1: in std_logic := 'X';
  PHASESEL0: in std_logic := 'X';
  PHASEDIR: in std_logic := 'X';
  PHASESTEP: in std_logic := 'X';
  PHASELOADREG: in std_logic := 'X';
  STDBY: in std_logic := 'X';
  PLLWAKESYNC: in std_logic := 'X';
  RST: in std_logic := 'X';
  ENCLKOP: in std_logic := 'X';
  ENCLKOS: in std_logic := 'X';
  ENCLKOS2: in std_logic := 'X';
  ENCLKOS3: in std_logic := 'X';
  CLKOP: out std_logic := 'X';
  CLKOS: out std_logic := 'X';
  CLKOS2: out std_logic := 'X';
  CLKOS3: out std_logic := 'X';
  LOCK: out std_logic := 'X';
  INTLOCK: out std_logic := 'X';
  REFCLK: out std_logic := 'X';
  CLKINTFB: out std_logic := 'X'
);
end EHXPLLL;

architecture stub of EHXPLLL is
begin
  CLKOP <= CLKI;
  CLKOS <= CLKI;
  CLKOS2 <= CLKI;
  CLKOS3 <= CLKI;
  LOCK <= '1';
  INTLOCK <= '1';
  REFCLK <= CLKI;
  CLKINTFB <= CLKI;
end stub;

library ieee;
use ieee.std_logic_1164.all;

entity ODDRX1F is
port (
  D0, D1, SCLK, RST: in std_logic;
  Q: out std_logic
);
end ODDRX1F;

architecture stub of ODDRX1F is
begin
  Q <= D0;
end stub;

library ieee;
use ieee.std_logic_1164.all;

entity OLVDS is
port (
  A: in std_logic;
  Z, ZN: out std_logic
);
end OLVDS;

architecture stub of OLVDS is
begin
  Z <= A;
  ZN <= not A;
end stub;
