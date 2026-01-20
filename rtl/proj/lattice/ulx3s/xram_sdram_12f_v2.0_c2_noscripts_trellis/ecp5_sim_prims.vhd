-- ECP5 Simulation Primitives for GHDL
-- These are behavioral models for simulation only
-- PLL model with proper frequency multiplication/division using wait for

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

-- EHXPLLL (ECP5 PLL) - simulation model with proper clock generation
-- Uses wait for statements to generate correct output frequencies
entity EHXPLLL is
  generic (
    CLKI_DIV         : integer := 1;
    CLKFB_DIV        : integer := 1;
    CLKOP_DIV        : integer := 8;
    CLKOS_DIV        : integer := 8;
    CLKOS2_DIV       : integer := 8;
    CLKOS3_DIV       : integer := 8;
    CLKOP_ENABLE     : string  := "ENABLED";
    CLKOS_ENABLE     : string  := "DISABLED";
    CLKOS2_ENABLE    : string  := "DISABLED";
    CLKOS3_ENABLE    : string  := "DISABLED";
    CLKOP_CPHASE     : integer := 0;
    CLKOS_CPHASE     : integer := 0;
    CLKOS2_CPHASE    : integer := 0;
    CLKOS3_CPHASE    : integer := 0;
    CLKOP_FPHASE     : integer := 0;
    CLKOS_FPHASE     : integer := 0;
    CLKOS2_FPHASE    : integer := 0;
    CLKOS3_FPHASE    : integer := 0;
    FEEDBK_PATH      : string  := "CLKOP";
    CLKOP_TRIM_POL   : string  := "RISING";
    CLKOP_TRIM_DELAY : integer := 0;
    CLKOS_TRIM_POL   : string  := "RISING";
    CLKOS_TRIM_DELAY : integer := 0;
    OUTDIVIDER_MUXA  : string  := "DIVA";
    OUTDIVIDER_MUXB  : string  := "DIVB";
    OUTDIVIDER_MUXC  : string  := "DIVC";
    OUTDIVIDER_MUXD  : string  := "DIVD";
    PLL_LOCK_MODE    : integer := 0;
    PLL_LOCK_DELAY   : integer := 200;
    STDBY_ENABLE     : string  := "DISABLED";
    REFIN_RESET      : string  := "DISABLED";
    SYNC_ENABLE      : string  := "DISABLED";
    INT_LOCK_STICKY  : string  := "ENABLED";
    DPHASE_SOURCE    : string  := "DISABLED";
    PLLRST_ENA       : string  := "DISABLED";
    INTFB_WAKE       : string  := "DISABLED"
  );
  port (
    CLKI, CLKFB      : in std_logic := 'X';
    RST, STDBY       : in std_logic := '0';
    PLLWAKESYNC      : in std_logic := 'X';
    PHASESEL1        : in std_logic := 'X';
    PHASESEL0        : in std_logic := 'X';
    PHASEDIR         : in std_logic := 'X';
    PHASESTEP        : in std_logic := 'X';
    PHASELOADREG     : in std_logic := 'X';
    ENCLKOP          : in std_logic := 'X';
    ENCLKOS          : in std_logic := 'X';
    ENCLKOS2         : in std_logic := 'X';
    ENCLKOS3         : in std_logic := 'X';
    CLKOP            : out std_logic := '0';
    CLKOS            : out std_logic := '0';
    CLKOS2           : out std_logic := '0';
    CLKOS3           : out std_logic := '0';
    LOCK             : out std_logic := '0';
    INTLOCK          : out std_logic := '0';
    REFCLK           : out std_logic := '0';
    CLKINTFB         : out std_logic := '0'
  );
end EHXPLLL;

architecture sim of EHXPLLL is
  -- Internal clock signals
  signal clkop_int : std_logic := '0';
  signal clkos_int : std_logic := '0';
  signal clkos2_int : std_logic := '0';
  signal clkos3_int : std_logic := '0';
  signal lock_int : std_logic := '0';
  signal pll_active : boolean := false;

  -- Measured input period (we measure first rising edge to determine period)
  signal input_period : time := 40 ns;  -- default 25 MHz
  signal period_measured : boolean := false;
  signal first_edge_time : time := 0 ns;

begin

  -- Measure input clock period on first two rising edges
  measure_period: process
  begin
    wait until rising_edge(CLKI);
    first_edge_time <= now;
    wait until rising_edge(CLKI);
    input_period <= now - first_edge_time;
    period_measured <= true;
    pll_active <= true;
    wait;  -- stop after measurement
  end process;

  -- Lock signal generation (after some startup time)
  lock_gen: process
  begin
    wait until pll_active;
    wait for 100 * input_period;  -- lock after ~100 input cycles
    lock_int <= '1';
    wait;
  end process;

  -- CLKOP clock generation (primary output)
  -- VCO freq = input_freq * CLKFB_DIV / CLKI_DIV
  -- CLKOP freq = VCO freq / CLKOP_DIV = input_freq * CLKFB_DIV / (CLKI_DIV * CLKOP_DIV)
  -- CLKOP period = input_period * CLKI_DIV * CLKOP_DIV / CLKFB_DIV
  clkop_gen: process
    variable half_period : time;
  begin
    wait until period_measured and RST = '0';
    half_period := (input_period * CLKI_DIV * CLKOP_DIV) / (CLKFB_DIV * 2);
    loop
      if RST = '1' then
        clkop_int <= '0';
        wait until RST = '0';
      else
        clkop_int <= '1';
        wait for half_period;
        clkop_int <= '0';
        wait for half_period;
      end if;
    end loop;
  end process;

  -- CLKOS clock generation (secondary 1)
  -- CLKOS period = input_period * CLKI_DIV * CLKOS_DIV / CLKFB_DIV
  clkos_gen: process
    variable half_period : time;
  begin
    wait until period_measured and RST = '0';
    half_period := (input_period * CLKI_DIV * CLKOS_DIV) / (CLKFB_DIV * 2);
    loop
      if RST = '1' then
        clkos_int <= '0';
        wait until RST = '0';
      else
        clkos_int <= '1';
        wait for half_period;
        clkos_int <= '0';
        wait for half_period;
      end if;
    end loop;
  end process;

  -- CLKOS2 clock generation (secondary 2)
  -- CLKOS2 period = input_period * CLKI_DIV * CLKOS2_DIV / CLKFB_DIV
  clkos2_gen: process
    variable half_period : time;
  begin
    wait until period_measured and RST = '0';
    half_period := (input_period * CLKI_DIV * CLKOS2_DIV) / (CLKFB_DIV * 2);
    loop
      if RST = '1' then
        clkos2_int <= '0';
        wait until RST = '0';
      else
        clkos2_int <= '1';
        wait for half_period;
        clkos2_int <= '0';
        wait for half_period;
      end if;
    end loop;
  end process;

  -- CLKOS3 clock generation (secondary 3)
  -- CLKOS3 period = input_period * CLKI_DIV * CLKOS3_DIV / CLKFB_DIV
  clkos3_gen: process
    variable half_period : time;
  begin
    wait until period_measured and RST = '0';
    half_period := (input_period * CLKI_DIV * CLKOS3_DIV) / (CLKFB_DIV * 2);
    loop
      if RST = '1' then
        clkos3_int <= '0';
        wait until RST = '0';
      else
        clkos3_int <= '1';
        wait for half_period;
        clkos3_int <= '0';
        wait for half_period;
      end if;
    end loop;
  end process;

  -- Output assignments
  CLKOP <= clkop_int when CLKOP_ENABLE = "ENABLED" else '0';
  CLKOS <= clkos_int when CLKOS_ENABLE = "ENABLED" else '0';
  CLKOS2 <= clkos2_int when CLKOS2_ENABLE = "ENABLED" else '0';
  CLKOS3 <= clkos3_int when CLKOS3_ENABLE = "ENABLED" else '0';
  LOCK <= lock_int;
  INTLOCK <= lock_int;
  REFCLK <= CLKI;
  CLKINTFB <= clkop_int;

end sim;

-- ODDRX1F (DDR output) - simulation model
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity ODDRX1F is
  port (
    D0   : in std_logic;
    D1   : in std_logic;
    SCLK : in std_logic;
    RST  : in std_logic;
    Q    : out std_logic
  );
end ODDRX1F;

architecture sim of ODDRX1F is
  signal q_int : std_logic := '0';
begin
  process(SCLK, RST)
  begin
    if RST = '1' then
      q_int <= '0';
    elsif rising_edge(SCLK) then
      q_int <= D0;
    elsif falling_edge(SCLK) then
      q_int <= D1;
    end if;
  end process;
  Q <= q_int;
end sim;

-- OLVDS (LVDS output buffer) - simulation model
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity OLVDS is
  port (
    A  : in std_logic;
    Z  : out std_logic;
    ZN : out std_logic
  );
end OLVDS;

architecture sim of OLVDS is
begin
  Z <= A;
  ZN <= not A;
end sim;
