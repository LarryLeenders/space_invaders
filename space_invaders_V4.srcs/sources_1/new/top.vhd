----------------------------------------------------------------------------------
-- Company: 
-- Engineer: Lars Leenders
-- 
-- Create Date: 
-- Design Name: 
-- Module Name: Top - spaceInvaders V3
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

entity Top is
    Port ( clk : in STD_LOGIC;
           Hsync : out STD_LOGIC;
           Vsync : out STD_LOGIC;
           btnC : in STD_LOGIC;
           btnL : in std_logic;
           btnR : in std_logic;
           led : out std_logic_vector(15 downto 0);
           vgaRed : out STD_LOGIC_VECTOR (3 downto 0);
           vgaGreen : out STD_LOGIC_VECTOR (3 downto 0);
           vgaBlue : out STD_LOGIC_VECTOR (3 downto 0));
end Top;

architecture Behavioural of Top is
component blk_mem_gen_0 is
    port(
        clka : IN STD_LOGIC;
        addra : IN STD_LOGIC_VECTOR(2 DOWNTO 0);
        douta : OUT STD_LOGIC_VECTOR(11 DOWNTO 0)
    );
    end component blk_mem_gen_0;
component clk_wiz_0 is
    port (
      -- Clock in ports
      clk_in1           : in     std_logic;
      -- Clock out ports
      MHz6          : out    std_logic;
      MHz25          : out    std_logic;
      -- Status and control signals
      reset             : in     std_logic;
      locked            : out    std_logic    
    );
    end component clk_wiz_0;

component DebouncerForControls is
    Port(
         sig : in STD_LOGIC;
         debounced_sig: out std_logic;
         clk : in std_logic
    );
    end component DebouncerForControls;

component clkdiv is
    Port ( clk : in STD_LOGIC;
           clr : in STD_LOGIC;
           clr1 : in std_logic;
           clk25 : out STD_LOGIC;
           clk8 : out STD_LOGIC );
end component clkdiv;

component vga_640x480 is
    Port ( clk : in STD_LOGIC;
           clr : in STD_LOGIC;
           hsync : out STD_LOGIC;
           vsync : out STD_LOGIC;
           hc : out STD_LOGIC_VECTOR (9 downto 0);
           vc : out STD_LOGIC_VECTOR (9 downto 0);
           vidon : out STD_LOGIC);
end component vga_640x480;

component LEDaansturing is
    PORT(clk : in std_logic;
           scorein : in STD_LOGIC_VECTOR (15 downto 0);
           leduit : out STD_LOGIC_VECTOR (15 downto 0);
           scoreuit : out STD_LOGIC_VECTOR (15 downto 0));
end component LEDaansturing;

component vga_beeld is
    Port ( clk : in std_logic;
           vidon : in STD_LOGIC;                           -- video on / off
           ticks : in std_logic;                           --gameticks 
           hc : in STD_LOGIC_VECTOR (9 downto 0);          -- horizontal counter
           vc : in STD_LOGIC_VECTOR (9 downto 0);          -- vertical counter
           M : in STD_LOGIC_VECTOR(0 to 125);   
           M3 : in STD_LOGIC_VECTOR(0 to 125);             -- welke pixel in tankgeheugen spreken we aan  horizontaal bekeken
           M2: in std_logic_vector(0 to 11);       --welke pixel in bulletgeheugen spreken we aan horizontaal bekeken
           btnC : in STD_LOGIC;                            -- button om de bullet sprite te spawnen
           btnL : in STD_LOGIC;                            --button om naar links te gaan
           btnR : in STD_LOGIC;                            --button om naar rechts te gaan
           rom_addr4 : out STD_LOGIC_VECTOR (5 downto 0);  -- 
           rom_addr4_alien : out STD_LOGIC_VECTOR (5 downto 0);
           rom_addr4_bullet: out std_logic_vector (2 downto 0); --
           red : out STD_LOGIC_VECTOR (3 downto 0);        -- rood
           green : out STD_LOGIC_VECTOR (3 downto 0);      -- groen
           blue : out STD_LOGIC_VECTOR (3 downto 0);      -- blauw
           uitscore: out std_logic_vector (15 downto 0) := "0000000000000000";   --score komt op de leds
           inscore: in std_logic_vector (15 downto 0) := "0000000000000000");
end component vga_beeld;

component blk_mem_gen_1 IS
  PORT (
    clka : IN STD_LOGIC;
    addra : IN STD_LOGIC_VECTOR(5 DOWNTO 0);
    douta : OUT STD_LOGIC_VECTOR(125 DOWNTO 0)
  );
END component blk_mem_gen_1;

COMPONENT blk_mem_gen_2 IS
  PORT (
    clka : IN STD_LOGIC;
    addra : IN STD_LOGIC_VECTOR(5 DOWNTO 0);
    douta : OUT STD_LOGIC_VECTOR(125 DOWNTO 0)
  );
END COMPONENT blk_mem_gen_2;

component gameTicksClockDiv is
    port(
         clk_6Mhz : in STD_LOGIC;
         clr : in std_logic; --eventueel reset circuit
         gameTicks : out STD_LOGIC
    );
end component gameTicksClockDiv;

signal clk25, clk6,clr1, reset, vidon, clr : STD_LOGIC;
signal hc, vc : STD_LOGIC_VECTOR (9 downto 0);
signal M, M3 : STD_LOGIC_VECTOR (0 to 125);
signal M2 : std_logic_vector(0 to 11);
signal rom_addr4_bullet : std_logic_vector (2 downto 0);
signal rom_addr4, rom_addr4_alien : STD_LOGIC_VECTOR ( 5 downto 0);
signal btnCsig, btnRsig, btnLsig : std_logic;
signal tick : std_logic;
signal inscore, uitscore: std_logic_vector(15 downto 0);
begin

ticks: gameTicksClockDiv port map(clk_6Mhz => clk6 , clr => clr, gameTicks => tick);

clocks: clk_wiz_0 port map(clk_in1 => clk, MHz6 => clk6 , MHz25 => clk25 ,reset => clr, locked => open);

debC: DebouncerForControls port map( sig => btnC , debounced_sig => btnCsig , clk => clk25);

debR: DebouncerForControls port map( sig => btnR , debounced_sig => btnRsig , clk => clk25);

debL: DebouncerForControls port map( sig => btnL , debounced_sig => btnLsig , clk => clk25);

Vga_controller: vga_640x480
    Port map (
    clk => clk25,
    clr => clr,
    hsync => Hsync,
    vsync => Vsync,
    hc => hc,
    vc => vc,
    vidon => vidon);
    
Vga_tekenaar: vga_beeld
    Port map(
    clk => clk,
    vidon => vidon,
    ticks => tick,
    hc => hc,
    vc => vc,
    M => M,
    M2 => M2,
    M3 => M3,
    btnC => btnCsig,
    btnL => btnLsig,
    btnR => btnRsig,
    rom_addr4_bullet => rom_addr4_bullet,
    rom_addr4_alien => rom_addr4_alien,
    rom_addr4 => rom_addr4,
    red => vgaRed,
    green => vgaGreen,
    blue => vgaBlue,
    inscore=>inscore,
    uitscore =>uitscore
    );
LEDS: LEDaansturing 
    PORT MAP(
    clk => clk,
    scorein => uitscore,
    scoreuit => inscore,
    leduit => led
    ); 
tank_sprite_Memory: blk_mem_gen_1
    Port map(
    clka => clk,
    addra => rom_addr4,
    douta => M);

bullet_sprite_Memory: blk_mem_gen_0 
    Port map(
        clka => clk,
        addra => rom_addr4_bullet,
        douta => M2);  
alien_sprite_Memory: blk_mem_gen_2 
Port map(
        clka => clk,
        addra => rom_addr4_alien,
        douta => M3); 
end Behavioural;
