-- Testbench for ulx3s_xram_sdram_vector
-- Tool: GHDL simulation
-- Purpose: Debug CPU startup issues

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity tb_top is
end tb_top;

architecture sim of tb_top is
  -- Clock period (25 MHz = 40 ns)
  constant CLK_PERIOD : time := 40 ns;

  -- Signals for DUT
  signal clk_25mhz : std_logic := '0';
  signal ftdi_rxd : std_logic;
  signal ftdi_txd : std_logic := '1';  -- idle high

  -- SDRAM
  signal sdram_clk : std_logic;
  signal sdram_cke : std_logic;
  signal sdram_csn : std_logic;
  signal sdram_rasn : std_logic;
  signal sdram_casn : std_logic;
  signal sdram_wen : std_logic;
  signal sdram_a : std_logic_vector(12 downto 0);
  signal sdram_ba : std_logic_vector(1 downto 0);
  signal sdram_dqm : std_logic_vector(1 downto 0);
  signal sdram_d : std_logic_vector(15 downto 0);

  -- User I/O
  signal led : std_logic_vector(7 downto 0);
  signal btn : std_logic_vector(6 downto 0) := (others => '0');
  signal sw : std_logic_vector(3 downto 0) := (others => '0');

  -- GPIO
  signal gp : std_logic_vector(27 downto 0);
  signal gn : std_logic_vector(27 downto 0);

  -- Video
  signal gpdi_dp : std_logic_vector(3 downto 0);
  signal gpdi_dn : std_logic_vector(3 downto 0);

  -- Flash
  signal flash_miso : std_logic := '1';
  signal flash_mosi : std_logic;
  signal flash_csn : std_logic;
  signal flash_holdn : std_logic;
  signal flash_wpn : std_logic;

  -- SD card
  signal sd_cmd : std_logic;
  signal sd_d : std_logic_vector(3 downto 0);
  signal sd_clk : std_logic;
  signal sd_cdn : std_logic := '1';  -- no card
  signal sd_wp : std_logic := '0';

  -- Simulation control
  signal sim_done : boolean := false;
  signal cycle_count : integer := 0;

  -- Serial bit time at 115200 baud = ~8.68us
  constant BIT_TIME : time := 8680 ns;

begin

  -- Clock generation
  clk_process: process
  begin
    while not sim_done loop
      clk_25mhz <= '0';
      wait for CLK_PERIOD / 2;
      clk_25mhz <= '1';
      wait for CLK_PERIOD / 2;
      cycle_count <= cycle_count + 1;
    end loop;
    wait;
  end process;

  -- DUT instantiation
  DUT: entity work.ulx3s_xram_sdram_vector
    port map (
      clk_25mhz => clk_25mhz,
      ftdi_rxd => ftdi_rxd,
      ftdi_txd => ftdi_txd,
      sdram_clk => sdram_clk,
      sdram_cke => sdram_cke,
      sdram_csn => sdram_csn,
      sdram_rasn => sdram_rasn,
      sdram_casn => sdram_casn,
      sdram_wen => sdram_wen,
      sdram_a => sdram_a,
      sdram_ba => sdram_ba,
      sdram_dqm => sdram_dqm,
      sdram_d => sdram_d,
      led => led,
      btn => btn,
      sw => sw,
      gp => gp,
      gn => gn,
      gpdi_dp => gpdi_dp,
      gpdi_dn => gpdi_dn,
      flash_miso => flash_miso,
      flash_mosi => flash_mosi,
      flash_csn => flash_csn,
      flash_holdn => flash_holdn,
      flash_wpn => flash_wpn,
      sd_cmd => sd_cmd,
      sd_d => sd_d,
      sd_clk => sd_clk,
      sd_cdn => sd_cdn,
      sd_wp => sd_wp
    );

  -- SDRAM model
  SDRAM: entity work.sdram_model
    generic map (
      C_size_kb => 1024,  -- 1MB for faster simulation
      C_cas_latency => 2
    )
    port map (
      clk   => sdram_clk,
      cke   => sdram_cke,
      csn   => sdram_csn,
      rasn  => sdram_rasn,
      casn  => sdram_casn,
      wen   => sdram_wen,
      ba    => sdram_ba,
      a     => sdram_a,
      dqm   => sdram_dqm,
      dq    => sdram_d
    );

  -- Serial stimulus process - send characters to bootloader
  serial_stimulus: process
    variable tx_byte : std_logic_vector(7 downto 0);
  begin
    ftdi_txd <= '1';  -- Idle high
    wait for 200 us;  -- Wait for CPU to start

    report "Sending CR (0x0D) to bootloader..." severity note;
    tx_byte := x"0D";  -- Carriage return
    -- Start bit
    ftdi_txd <= '0';
    wait for BIT_TIME;
    -- Data bits (LSB first)
    for i in 0 to 7 loop
      ftdi_txd <= tx_byte(i);
      wait for BIT_TIME;
    end loop;
    -- Stop bit
    ftdi_txd <= '1';
    wait for BIT_TIME;

    wait for 500 us;  -- Wait for response

    report "Sending 'h' (help) to bootloader..." severity note;
    tx_byte := x"68";  -- 'h' for help
    -- Start bit
    ftdi_txd <= '0';
    wait for BIT_TIME;
    -- Data bits (LSB first)
    for i in 0 to 7 loop
      ftdi_txd <= tx_byte(i);
      wait for BIT_TIME;
    end loop;
    -- Stop bit
    ftdi_txd <= '1';
    wait for BIT_TIME;

    wait;  -- Wait forever
  end process;

  -- Monitor process
  monitor: process
  begin
    report "=== Simulation Start ===" severity note;
    report "Watching for LED activity and CPU startup..." severity note;

    -- Wait for PLL to lock (roughly)
    wait for 1 us;
    report "After 1us: LED=" & to_string(led) severity note;

    wait for 10 us;
    report "After 10us: LED=" & to_string(led) severity note;

    wait for 100 us;
    report "After 100us: LED=" & to_string(led) severity note;
    report "SDRAM_CKE=" & std_logic'image(sdram_cke) severity note;
    report "SDRAM_CSN=" & std_logic'image(sdram_csn) severity note;

    wait for 289 us;  -- at 500us total
    report "After 500us: LED=" & to_string(led) severity note;
    report "FTDI_RXD (CPU TX)=" & std_logic'image(ftdi_rxd) severity note;

    wait for 400 us;  -- at 900us total
    report "After 900us: LED=" & to_string(led) severity note;

    wait for 600 us;  -- at 1500us total (after serial input at 200us + 500us)
    report "After 1500us: LED=" & to_string(led) severity note;
    report "FTDI_RXD (CPU TX)=" & std_logic'image(ftdi_rxd) severity note;

    wait for 500 us;  -- at 2000us total
    report "=== Simulation End (2000us) ===" severity note;
    report "Final LED=" & to_string(led) severity note;
    report "Final FTDI_RXD=" & std_logic'image(ftdi_rxd) severity note;
    report "Total cycles: " & integer'image(cycle_count) severity note;

    sim_done <= true;
    wait;
  end process;

  -- LED change detector
  led_watch: process(led)
  begin
    if now > 0 ns then
      report "LED changed to " & to_string(led) & " at " & time'image(now) severity note;
    end if;
  end process;

  -- Serial TX detector (from CPU)
  serial_watch: process(ftdi_rxd)
  begin
    if now > 0 ns and ftdi_rxd'event then
      report "Serial TX activity at " & time'image(now) severity note;
    end if;
  end process;

end sim;
