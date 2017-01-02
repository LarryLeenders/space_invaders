----------------------------------------------------------------------------------
-- Company: 
-- Engineer: Lars Leenders
-- 
-- Create Date: 10.10.2016 21:17:38
-- Design Name: 
-- Module Name: debouncerForControls - Behavioral
-- Project Name: 
-- Target Devices: 
-- Tool Versions: 
-- Description: 
-- 
-- Dependencies: 
-- 
-- Revision:
-- Revision 0.01 - File Created
-- Additional Comments:
-- 
----------------------------------------------------------------------------------


library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;


--input vanuit topmodule hier aan leggen en debouncen zodat deze verder verwerkt kan worden.
entity DebouncerForControls is
    Port ( sig : in STD_LOGIC;
           debounced_sig: out std_logic;
           clk : in std_logic
    );
end DebouncerForControls;

architecture Behavioral of DebouncerForControls is
    signal Q1, Q2, Q3 : std_logic;

begin
process(clk) begin
        if rising_edge (clk) then
                Q1 <= sig;
                Q2 <= Q1;
                Q3 <= Q2;
        end if;
end process;
debounced_sig <= Q1 and Q2 and Q3;
end Behavioral;
