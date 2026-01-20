-- Simple SDRAM Model for GHDL Simulation
-- Target: MT48LC16M16A2 (32MB, 16-bit data)
-- This is a behavioral model for simulation only

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity sdram_model is
    generic (
        C_size_kb : integer := 1024;  -- Model size in KB (default 1MB for faster sim)
        C_cas_latency : integer := 2   -- CAS latency
    );
    port (
        clk   : in std_logic;
        cke   : in std_logic;
        csn   : in std_logic;
        rasn  : in std_logic;
        casn  : in std_logic;
        wen   : in std_logic;
        ba    : in std_logic_vector(1 downto 0);
        a     : in std_logic_vector(12 downto 0);
        dqm   : in std_logic_vector(1 downto 0);
        dq    : inout std_logic_vector(15 downto 0)
    );
end sdram_model;

architecture behavioral of sdram_model is
    -- Memory array (16-bit words)
    constant MEM_SIZE : integer := C_size_kb * 512;  -- words (KB * 1024 / 2)
    type mem_array_t is array(0 to MEM_SIZE - 1) of std_logic_vector(15 downto 0);
    signal memory : mem_array_t := (others => (others => '0'));

    -- Command decoding
    constant CMD_NOP       : std_logic_vector(3 downto 0) := "0111";
    constant CMD_ACTIVE    : std_logic_vector(3 downto 0) := "0011";
    constant CMD_READ      : std_logic_vector(3 downto 0) := "0101";
    constant CMD_WRITE     : std_logic_vector(3 downto 0) := "0100";
    constant CMD_PRECHARGE : std_logic_vector(3 downto 0) := "0010";
    constant CMD_REFRESH   : std_logic_vector(3 downto 0) := "0001";
    constant CMD_MODE      : std_logic_vector(3 downto 0) := "0000";

    signal cmd : std_logic_vector(3 downto 0);

    -- Row address latches (per bank)
    type row_array_t is array(0 to 3) of std_logic_vector(12 downto 0);
    signal active_row : row_array_t := (others => (others => '0'));
    signal bank_active : std_logic_vector(3 downto 0) := "0000";

    -- Read pipeline for CAS latency
    type read_pipe_t is array(0 to 3) of std_logic_vector(15 downto 0);
    signal read_pipe : read_pipe_t := (others => (others => '0'));
    signal read_valid_pipe : std_logic_vector(3 downto 0) := "0000";

    -- Data output enable
    signal dq_out : std_logic_vector(15 downto 0) := (others => '0');
    signal dq_oe : std_logic := '0';

begin
    -- Command is {CSN, RASN, CASN, WEN}
    cmd <= csn & rasn & casn & wen;

    -- Data bus driver
    dq <= dq_out when dq_oe = '1' else (others => 'Z');

    process(clk)
        variable full_addr : integer;
        variable bank : integer;
        variable row : std_logic_vector(12 downto 0);
        variable col : std_logic_vector(8 downto 0);
        variable addr_int : integer;
    begin
        if rising_edge(clk) then
            -- Default: shift read pipeline
            read_pipe(3) <= read_pipe(2);
            read_pipe(2) <= read_pipe(1);
            read_pipe(1) <= read_pipe(0);
            read_pipe(0) <= (others => '0');

            read_valid_pipe(3) <= read_valid_pipe(2);
            read_valid_pipe(2) <= read_valid_pipe(1);
            read_valid_pipe(1) <= read_valid_pipe(0);
            read_valid_pipe(0) <= '0';

            -- Output data after CAS latency
            if read_valid_pipe(C_cas_latency) = '1' then
                dq_out <= read_pipe(C_cas_latency);
                dq_oe <= '1';
            else
                dq_oe <= '0';
            end if;

            if cke = '1' then
                bank := to_integer(unsigned(ba));

                case cmd is
                    when CMD_ACTIVE =>
                        -- Activate row
                        active_row(bank) <= a;
                        bank_active(bank) <= '1';

                    when CMD_READ =>
                        -- Read command
                        if bank_active(bank) = '1' then
                            row := active_row(bank);
                            col := a(8 downto 0);
                            -- Calculate address: bank(2) + row(13) + col(9) = 24 bits = 16M words
                            -- But we limit to model size
                            addr_int := (bank * 2**22 + to_integer(unsigned(row)) * 512 + to_integer(unsigned(col))) mod MEM_SIZE;
                            read_pipe(0) <= memory(addr_int);
                            read_valid_pipe(0) <= '1';
                        end if;

                    when CMD_WRITE =>
                        -- Write command
                        if bank_active(bank) = '1' then
                            row := active_row(bank);
                            col := a(8 downto 0);
                            addr_int := (bank * 2**22 + to_integer(unsigned(row)) * 512 + to_integer(unsigned(col))) mod MEM_SIZE;
                            -- Apply byte masks
                            if dqm(0) = '0' then
                                memory(addr_int)(7 downto 0) <= dq(7 downto 0);
                            end if;
                            if dqm(1) = '0' then
                                memory(addr_int)(15 downto 8) <= dq(15 downto 8);
                            end if;
                        end if;

                    when CMD_PRECHARGE =>
                        -- Precharge bank(s)
                        if a(10) = '1' then
                            -- All banks
                            bank_active <= "0000";
                        else
                            bank_active(bank) <= '0';
                        end if;

                    when CMD_REFRESH =>
                        -- Auto refresh - no action needed in model
                        null;

                    when CMD_MODE =>
                        -- Mode register set - no action needed in model
                        null;

                    when others =>
                        -- NOP or invalid
                        null;
                end case;
            end if;
        end if;
    end process;

end behavioral;
