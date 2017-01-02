----------------------------------------------------------------------------------
-- Company: /
-- Engineer: Lars Leenders
-- 
-- Create Date: 10.10.2016 21:20:42
-- Design Name: 
-- Module Name: gameTicksClockDiv - Behavioral
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
use IEEE.std_logic_unsigned.all;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;


--ticks zijn geen exacte 30fps wat zorgt voor een choppy beweging bij hogere movementspeeds
entity gameTicksClockDiv is
    Port ( clk_6Mhz : in STD_LOGIC;
           clr : in std_logic; --eventueel reset circuit
           gameTicks : out STD_LOGIC);
end gameTicksClockDiv;

architecture Behavioral of gameTicksClockDiv is
    signal q : std_logic_vector (19 downto 0); 
begin
process(clk_6Mhz, clr)
begin
    if clr = '1' then
        q <= "00000000000000000000";
    elsif rising_edge(clk_6Mhz) then
        q <= q + 1;
    end if;
    
    if (conv_integer(q) mod 200000) = 0 then
        gameTicks <= '0';
    else
        gameTicks <= '1';
    end if;
end process;

end Behavioral;
