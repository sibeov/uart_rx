library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library work;
use work.uart_common.all;
use work.de1_soc_common.all;

entity uart_rx_tb is
end entity uart_rx_tb;

architecture sim of uart_rx_tb is

    -- clk
    signal clk_tb           : std_logic := '0';
    signal clk_ena_tb       : boolean   := false;
    constant TBC_CLK_FRQ    : integer   := 50;
    constant TBC_CKK_PRD_TM : time      := (1 sec / TBC_CLK_FRQ);
begin
end architecture sim;