library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library work;
use work.uart_common.all;

entity uart_rx is
    generic (
        C_CLK_PR_BIT : integer := f_CLKS_PR_BIT(GC_CLK_FRQ, GC_BAUD_RATE);
        C_DATA_BITS  : integer := GC_DATA_BITS
    );
    port (
        clk_i         : in std_logic;
        rst_n_i       : in std_logic;

        data_serial_i : in std_logic;

        data_valid_o  : out std_logic;
        data_par_o    : out std_logic_vector(C_DATA_BITS - 1 downto 0)
    );
end uart_rx;

architecture rtl of uart_rx is

    -- RX FSM
    type uart_rx_state_t is (
        s_RX_IDLE,
        s_RX_START,
        s_RX_RECEIVE,
        s_RX_PARITY,
        s_RX_STOP,
        s_RX_CLEANUP
    );
    signal rx_state_s      : uart_rx_state_t                     := s_RX_IDLE;

    -- Parity
    signal rx_one_count_s  : integer range 0 to C_DATA_BITS - 1  := 0;

    -- Data and clk count
    signal rx_clk_count_s  : integer range 0 to C_CLK_PR_BIT - 1 := 0;
    signal rx_data_valid_s : std_logic                           := '1';

    -- Data
    signal rx_par_data_s   : std_logic_vector(C_DATA_BITS - 1 downto 0);
    signal rx_bit_index    : integer range 0 to C_DATA_BITS - 1 := 0;

begin

    p_UART_RX_STATE : process (clk_i) is
    begin

        if (rising_edge(clk_i)) then
            if (rst_n = '0') then
                -- Set all signals <= '0';
            else

                case rx_state_s is

                    when s_RX_IDLE =>
                        rx_clk_count_s  <= 0;
                        rx_bit_index    <= 0;
                        rx_data_valid_s <= '0';
                        rx_state_s      <= s_RX_IDLE;

                        if (data_serial_i = '0') then
                            rx_state_s <= s_RX_START;
                        end if;

                    when s_RX_START =>
                        if (rx_clk_count_s = (C_CLK_PR_BIT - 1) / 2) then
                            if (data_serial_i = '0') then
                                rx_state_s     <= s_RX_RECEIVE;
                                rx_clk_count_s <= 0;
                            end if;
                        else
                            rx_clk_count_s <= rx_clk_count_s + 1;
                            rx_state_s     <= s_RX_START;
                        end if;

                    when s_RX_RECEIVE =>
                        if (rx_clk_count_s = C_CLK_PR_BIT - 1) then
                            if (rx_bit_index = C_DATA_BITS - 1) then
                                rx_state_s     <= s_RX_STOP;
                                rx_bit_index   <= 0;
                                rx_clk_count_s <= 0;
                            else
                                rx_par_data_s(rx_bit_index) <= data_serial_i;

                                if (data_serial_i = '1') then
                                    rx_one_count_s <= rx_one_count_s + 1;
                                end if;

                                rx_state_s     <= s_RX_RECEIVE;
                                rx_bit_index   <= rx_bit_index + 1;
                                rx_clk_count_s <= 0;
                            end if;
                        else
                            rx_clk_count_s <= rx_clk_count_s + 1;
                            rx_state_s     <= s_RX_RECEIVE;
                        end if;

                    when s_RX_PARITY =>
                        if ((rx_one_count_s mod 2) = 0) then
                            rx_parity_s <= '1';
                            rx_state_s  <= s_RX_STOP;
                        else
                            rx_parity_s <= '0';
                            rx_state_s  <= s_RX_STOP;
                        end if;

                    when s_RX_STOP =>
                        if (rx_clk_count_s = C_CLK_PR_BIT - 1) then
                        else
                            rx_clk_count_s <= rx_clk_count_s + 1;
                            rx_state_s     <= s_RX_STOP;
                        end if;

                    when s_RX_CLEANUP =>
                        rx_one_count_s <= 0;
                        rx_parity_s    <= '0';
                        rx_state_s     <= s_RX_IDLE;

                    when others =>
                        rx_state_s <= s_RX_IDLE;

                end case;
            end if;
        end if;
    end process p_UART_RX_STATE;

    data_par_o   <= rx_par_data_s;
    data_valid_o <= rx_data_valid_s;

end architecture;