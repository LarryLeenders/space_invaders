----------------------------------------------------------------------------------
-- Company: 
-- Engineer: Leenders Lars
-- 
-- Create Date: 
-- Design Name: 
-- Module Name: vga_initials - Behavioral
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
use IEEE.STD_LOGIC_UNSIGNED.ALL;
use IEEE.std_logic_arith.all;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity vga_beeld is
    Port ( clk : in std_logic;
           vidon : in STD_LOGIC;                           -- video on / off
           ticks : in std_logic;                           --gameticks 
           hc : in STD_LOGIC_VECTOR (9 downto 0);          -- horizontal counter
           vc : in STD_LOGIC_VECTOR (9 downto 0);          -- vertical counter
           M : in STD_LOGIC_VECTOR(0 to 125);  
           M3 : in STD_LOGIC_VECTOR(0 to 125);            -- welke pixel in aliengeheugen spreken we aan  horizontaal bekeken
           M2: in std_logic_vector(0 to 11);               --welke pixel in bulletgeheugen spreken we aan horizontaal bekeken
           btnC : in STD_LOGIC;                            -- button om de bullet sprite te spawnen
           btnL : in STD_LOGIC;                            --button om naar links te gaan
           btnR : in STD_LOGIC;                            --button om naar rechts te gaan
           rom_addr4 : out STD_LOGIC_VECTOR (5 downto 0);  -- 
           rom_addr4_alien: out STD_LOGIC_VECTOR (5 downto 0);
           rom_addr4_bullet: out std_logic_vector (2 downto 0); --
           red : out STD_LOGIC_VECTOR (3 downto 0);        -- rood
           green : out STD_LOGIC_VECTOR (3 downto 0);      -- groen
           blue : out STD_LOGIC_VECTOR (3 downto 0);      -- blauw
           uitscore: out std_logic_vector (15 downto 0);   --score komt op de leds
           inscore: in std_logic_vector (15 downto 0) := "0000000000000000"
           );
end vga_beeld;

architecture Behavioral of vga_beeld is
constant hbp: std_logic_vector(9 downto 0) := "0010010000"; --144 horizontal blank period -> eens links ongemerkt zen pointer verzetten terug naar de linker kant.
constant vbp: std_logic_vector(9 downto 0) := "0000011111"; --31  vertical blank period -> zelfde maar naar boven 
constant w: integer := 42;                                  -- breedte van de sprite tank
constant h: integer := 40;                                  -- hoogte van de sprite tank
constant w2: integer := 4;                                  --bullet is 4 
constant h2: integer := 8;                                  --bullet is 8 


signal left_right : std_logic_vector(10 downto 0):= "00100110001"; --spawn tank in het midden van het scherm
signal up_down_alien: std_logic_vector(10 downto 0):= "00000110001";
signal left_right_alien: std_logic_vector(10 downto 0):= "00100110001";
signal left_right_bullet : std_logic_vector (10 downto 0) := "00101000011"; -- spawn bullet in het midden van de tank
signal up_down : std_logic_vector(10 downto 0):= "00110110100";  -- --spawn sprite onderaan het scherm
signal up_down_bullet : std_logic_vector(10 downto 0) := "00110111000"; --bullet moet spawnen boven de tank dus updownvan de tank +40
signal rom_addr, rom_addr_bullet, rom_addr_alien, rom_pix_bullet, rom_pix, rom_pix_alien: std_logic_vector(10 downto 0);
signal spriteon, spriteon_bullet, spriteon_alien, R, G, B: std_logic;
signal fly, hit: std_logic := '0';
begin
    
       --variables for drawing
        rom_pix <= hc -hbp - left_right;
        rom_pix_alien<= hc-hbp-left_right_alien;
        rom_pix_bullet <= hc-hbp-left_right_bullet;
        rom_addr_alien <= vc - vbp - up_down_alien;
        rom_addr <= vc - vbp - up_down;
        rom_addr_bullet <= vc-vbp-up_down_bullet;
        rom_addr4 <= rom_addr (5 downto 0);
        rom_addr4_alien <= rom_addr_alien (5 downto 0);
        rom_addr4_bullet <= rom_addr_bullet( 2 downto 0);
        

        --Enable sprite video out when within the sprite region
        spriteon <= '1' when (((hc >= left_right +hbp) and (hc < left_right + hbp + w)) and ((vc >= up_down + vbp) and (vc < up_down + vbp + h))) else '0';
        spriteon_bullet <= '1' when (((hc >= left_right_bullet +hbp) and (hc < left_right_bullet + hbp + w2))and ((vc >= up_down_bullet + vbp) and (vc < up_down_bullet + vbp + h2)) and (fly = '1')) else '0';
        spriteon_alien <= '1' when (((hc >= left_right_alien +hbp) and (hc < left_right_alien + hbp + w)) and ((vc >= up_down_alien + vbp) and (vc < up_down_alien + vbp + h))) else '0';
        
        process(vidon, left_right,left_right_bullet, btnL, btnR, fly) 
            variable speed : integer := 1;
            variable pressed : integer := 0;
            variable held : std_logic := '0';
            variable input : std_logic_vector (1 downto 0);
        begin
        input := btnL &  btnR; --add fly
        if(rising_edge(ticks)) then
            case input is --completely rewrite
                WHEN "10" => --enkel left ingedrukt
                    left_right <= conv_std_logic_vector(conv_integer(left_right)-speed, 11);
--                    if fly = '0' then
--                        left_right_bullet <= conv_std_logic_vector(conv_integer(left_right_bullet)-speed, 11);
--                    else    
                    
--                    end if;
                    held := '1';
                WHEN "01" => --enkel right ingedrukt
                   left_right <= conv_std_logic_vector(conv_integer(left_right)+speed, 11);
--                   if fly = '0' then
--                        left_right_bullet <= conv_std_logic_vector(conv_integer(left_right_bullet)+speed, 11);
--                   else
                   
--                   end if;
                   held := '1';
                WHEN "11" => --beiden ingedrukt, links krijgt prioriteit
                   left_right <= conv_std_logic_vector(conv_integer(left_right)-speed, 11);
--                   if fly = '0' then
--                        left_right_bullet <= conv_std_logic_vector(conv_integer(left_right_bullet)-speed, 11);
--                   else
                   
--                   end if;
                   held := '1';
                WHEN "00" => --niets ingedrukt
                    held := '0';
                WHEN others => --in alle andere gevallen
                    held := '0';
            end case;         
            if fly = '0' then
                left_right_bullet <= conv_std_logic_vector(conv_integer(left_right)+20, 11);
            else
            
            end if;
            
                --edge checking, als er te snel naar links gegaan wordt zijn er nog bugs
            if(conv_integer(left_right) <= 17) or (conv_integer(left_right) >= 600) then
                left_right <= conv_std_logic_vector(582, 11);
            elsif(conv_integer(left_right) >= 583) then
                left_right <= conv_std_logic_vector(18, 11);
            else
            
            end if;
                
            --snelheid aanpassing
            if(held = '1')then --om te zien hoe lang de knop al ingedrukt is
                pressed := pressed+1;
            else    --is de knop niet inigedrukt dan reset pressed en gaat de speed naar 0
                pressed := 0;
                speed := 1;
            end if;
            
            if((pressed mod 10) = 0) and (speed < 16) then --versnelling
                speed := speed * 2;
            else 
            
            end if;  
        end if;
        end process;

        --proces maken voor de kogel om omhoog te gaan en te spawnen als btnC wordt ingedrukt
        process(vidon, up_down_bullet, btnC, fly, left_right, left_right_bullet, fly, hit)     
        begin
        if(rising_edge(ticks)) then
            if btnC = '1' then
                fly <= '1';
            else
            
            end if;
            
            if fly = '1' then
               up_down_bullet <= conv_std_logic_vector(conv_integer(up_down_bullet)-4, 11);
            else
            
            end if;
            
            --hitdetection
            --if height bullet is between height alien and height alien + h and width bullet is between left_right_alien and left_righ_alien + w
            if (conv_integer(up_down_bullet) >= conv_integer(up_down_alien)) AND (conv_integer(up_down_bullet) <= conv_integer(up_down_alien)+40) AND (conv_integer(left_right_bullet) >= conv_integer(left_right_alien)) AND (conv_integer(left_right_bullet) <= conv_integer(left_right_alien)+42) then
                --hit
                uitscore <= conv_std_logic_vector(conv_integer(inscore)+1,16);
                fly <= '0';
                up_down_bullet <= "00110111000"; 
            else
                --no hit
            end if;
            
            if conv_integer(up_down_bullet)-4 <= 10 then
                --reset bullet
                --restore left_right_bullet to middle of tank 
                fly <= '0';
                up_down_bullet <= "00110111000";        
            else
            
            end if;
        end if;
        end process;
    
        --proces maken om alien te laten bewegen
        process(vidon, up_down_alien,left_right_alien, hit)
        variable speed_h, speed_v, counter: integer := 1;
        variable direction, gearshift_h, gearshift_v, godown, stop: std_logic := '0';
        variable input : std_logic_vector(3 downto 0);
        begin
        --check schrijven om sprite tot maximale hoogte van de tanksprite te laten gaan
        input := direction & gearshift_h & gearshift_v & godown;
        if(rising_edge(ticks)) then
        if conv_integer(up_down_alien) > 390 then
                 stop := '1';
          else
                 stop := '0';
         end if;
            if stop = '0'then
            CASE input IS
                        WHEN "0000" => --move left
                            left_right_alien <= conv_std_logic_vector(conv_integer(left_right_alien)-speed_h, 11);
                        WHEN "0001" => --move left and go down
                            left_right_alien <= conv_std_logic_vector(conv_integer(left_right_alien)-speed_h, 11);
                            up_down_alien <= conv_std_logic_vector(conv_integer(up_down_alien)+speed_v, 11);  
                        WHEN "0010" => --move left and increase vertical speed 
                              left_right_alien <= conv_std_logic_vector(conv_integer(left_right_alien)-speed_h, 11);
--                               if speed_v < 4 then
--                                  speed_v := speed_v*2;
--                              else
                              
--                              end if;       
                        WHEN "0011" => --move left, go down and increase vertical speed
                            left_right_alien <= conv_std_logic_vector(conv_integer(left_right_alien)-speed_h, 11);
                            up_down_alien <= conv_std_logic_vector(conv_integer(up_down_alien)+speed_v, 11);  
--                            if speed_v < 4   then
--                                speed_v := speed_v*2;
--                            else
                            
--                            end if;
                        WHEN "0100" => --move left and increase horizontal speed
                            left_right_alien <= conv_std_logic_vector(conv_integer(left_right_alien)-speed_h, 11);
--                            if speed_h < 4 then
--                               speed_h := speed_h*2;
--                           else
                           
--                           end if;
                        WHEN "0101" => --move left, go down and increase horizontal speed
                           left_right_alien <= conv_std_logic_vector(conv_integer(left_right_alien)-speed_h, 11);
                           up_down_alien <= conv_std_logic_vector(conv_integer(up_down_alien)+speed_v, 11);  
--                           if speed_h < 4 then
--                               speed_h := speed_h*2;
--                           else
                           
--                           end if;        
                        WHEN "1000" => --move right
                           left_right_alien <= conv_std_logic_vector(conv_integer(left_right_alien)+speed_h, 11);
                        WHEN "1001" => --go right and down        
                            left_right_alien <= conv_std_logic_vector(conv_integer(left_right_alien)+speed_h, 11);
                            up_down_alien <= conv_std_logic_vector(conv_integer(up_down_alien)+speed_v, 11);        
                        WHEN "1010" => --move right and increase verticalspeed
                            left_right_alien <= conv_std_logic_vector(conv_integer(left_right_alien)+speed_h, 11);
--                            if speed_v < 4 then
--                                speed_v := speed_v*2;
--                            else
                            
--                            end if;
                        WHEN "1011" => --move right, go down and increase vertical speed
                            left_right_alien <= conv_std_logic_vector(conv_integer(left_right_alien)+speed_h, 11);
                            up_down_alien <= conv_std_logic_vector(conv_integer(up_down_alien)+speed_v, 11);  
--                            if speed_v < 4 then
--                                speed_v := speed_v*2;
--                            else
                            
--                            end if;
                        WHEN "1100" => --move right and increase horizontal speed
                            left_right_alien <= conv_std_logic_vector(conv_integer(left_right_alien)+speed_h, 11);
--                            if speed_h < 4 then
--                                speed_h := speed_h*2;
--                            else
                            
--                            end if;
                        WHEN "1101" => --move right, increase horizontal speed and go down
                            left_right_alien <= conv_std_logic_vector(conv_integer(left_right_alien)+speed_h, 11);
--                            if speed_h < 4 then
--                                speed_h := speed_h*2;
--                            else
                            
--                            end if;     
                        WHEN others => 
                        up_down_alien <= conv_std_logic_vector(conv_integer(up_down_alien)+speed_v, 11); 
                                    --do nothing
                                   
                                   -- WHEN "0110" => --move left, increase both speeds
                                   -- WHEN "0111" => --go down, increase both speeds
                                   
                                   -- WHEN "1110" => --go right and increase both speeds
                                   -- WHEN "1111" => --move right, increase both speeds and go down
                    END CASE;
                    --alien is onderhevig aan dezelfde grenzen als de tank
--                     if(conv_integer(left_right_alien) <= 17) or (conv_integer(left_right_alien) >= 600) then
--                               left_right_alien <= conv_std_logic_vector(582, 11);
--                     elsif(conv_integer(left_right_alien) >= 583) and (conv_integer(left_right_alien) < 600) then
--                               left_right_alien <= conv_std_logic_vector(18, 11);
--                     else
                     
--                     end if;
                    --counter verhogen
                    counter := counter+1;
                    
                    
                    if((counter mod 1000) = 0) then
                         gearshift_h := '1';
                         gearshift_v := '0';
                         godown := '0';
                     elsif((counter mod 1500) = 0) then
                         gearshift_h := '0';
                         gearshift_v := '1';
                         godown := '0';
                     elsif((counter mod 50) = 0) then
                        gearshift_h := '0';
                        gearshift_v := '0';
                        godown := '1';
                     else 
                         godown := '0';
                         gearshift_h := '0';
                         gearshift_v := '0';
                     end if;            
            --alien is onderhevig aan dezelfde grenzen als de tank
             if(conv_integer(left_right_alien) <= 17) or (conv_integer(left_right_alien) >= 600) then
                       direction := '1';
             elsif(conv_integer(left_right_alien) >= 583) and (conv_integer(left_right_alien) < 600)then
                       direction := '0';
             else
             
             end if;
             --this copied block aids with bitstream generation speed and resolves timing problems, I do not know how or why
             CASE input IS
                             WHEN "0000" => --move left
                                 left_right_alien <= conv_std_logic_vector(conv_integer(left_right_alien)-speed_h, 11);
                             WHEN "0001" => --move left and go down
                                 left_right_alien <= conv_std_logic_vector(conv_integer(left_right_alien)-speed_h, 11);
                                 up_down_alien <= conv_std_logic_vector(conv_integer(up_down_alien)+speed_v, 11);  
                             WHEN "0010" => --move left and increase vertical speed 
                                  left_right_alien <= conv_std_logic_vector(conv_integer(left_right_alien)-speed_h, 11);
--                                   if speed_v < 4 then
--                                      speed_v := speed_v*2;
--                                  else
                                  
--                                  end if;
                             WHEN "0011" => --move left, go down and increase vertical speed
                                 left_right_alien <= conv_std_logic_vector(conv_integer(left_right_alien)-speed_h, 11);
                                 up_down_alien <= conv_std_logic_vector(conv_integer(up_down_alien)+speed_v, 11);  
--                                 if speed_v < 4 then
--                                     speed_v := speed_v*2;
--                                 else
                                 
--                                 end if;
                             WHEN "0100" => --move left and increase horizontal speed
                                 left_right_alien <= conv_std_logic_vector(conv_integer(left_right_alien)-speed_h, 11);
--                                 if speed_h < 4 then
--                                    speed_h := speed_h*2;
--                                else
                                
--                                end if;
                             WHEN "0101" => --move left, go down and increase horizontal speed
                                left_right_alien <= conv_std_logic_vector(conv_integer(left_right_alien)-speed_h, 11);
                                up_down_alien <= conv_std_logic_vector(conv_integer(up_down_alien)+speed_v, 11);  
--                                if speed_h < 4 then
--                                    speed_h := speed_h*2;
--                                else
                                
--                                end if;        
                             WHEN "1000" => --move right
                                left_right_alien <= conv_std_logic_vector(conv_integer(left_right_alien)+speed_h, 11);
                             WHEN "1001" => --go right and down        
                                 left_right_alien <= conv_std_logic_vector(conv_integer(left_right_alien)+speed_h, 11);
                                 up_down_alien <= conv_std_logic_vector(conv_integer(up_down_alien)+speed_v, 11);  
                             WHEN "1110" => --go right and increase both speeds
                                 left_right_alien <= conv_std_logic_vector(conv_integer(left_right_alien)+speed_h, 11);
--                                 if speed_v < 4 then
--                                     speed_v := speed_v*2;
--                                 else
                                  
--                                 end if;
                             WHEN "1011" => --move right, go down and increase vertical speed
                                 left_right_alien <= conv_std_logic_vector(conv_integer(left_right_alien)+speed_h, 11);
                                 up_down_alien <= conv_std_logic_vector(conv_integer(up_down_alien)+speed_v, 11);  
--                                 if speed_v < 4 then
--                                     speed_v := speed_v*2;
--                                 else
                                 
--                                 end if;
                             WHEN "1100" => --move right and increase horizontal speed
                                 left_right_alien <= conv_std_logic_vector(conv_integer(left_right_alien)+speed_h, 11);
--                                 if speed_h < 4 then
--                                     speed_h := speed_h*2;
--                                 else
                                 
--                                 end if;
                             WHEN "1101" => --move right, increase horizontal speed and go down
                                 left_right_alien <= conv_std_logic_vector(conv_integer(left_right_alien)+speed_h, 11);
                                 up_down_alien <= conv_std_logic_vector(conv_integer(up_down_alien)+speed_v, 11); 
--                                 if speed_h < 4 then
--                                     speed_h := speed_h*2;
--                                 else
                                 
--                                 end if;     
                             WHEN others => 
                             up_down_alien <= conv_std_logic_vector(conv_integer(up_down_alien)+speed_v, 11); 
                                         --do nothing
                                        
                                        -- WHEN "0110" => --move left, increase both speeds
                                        -- WHEN "0111" => --go down, increase both speeds
                                        -- WHEN "1010" => --move right and increase verticalspeed
                                        
                                        -- WHEN "1111" => --move right, increase both speeds and go down
                         END CASE;
                         --alien is onderhevig aan dezelfde grenzen als de tank
--                              if(conv_integer(left_right_alien) <= 17) or (conv_integer(left_right_alien) >= 600) then
--                                        left_right_alien <= conv_std_logic_vector(582, 11);
--                              elsif(conv_integer(left_right_alien) >= 583)and (conv_integer(left_right_alien) < 600) then
--                                        left_right_alien <= conv_std_logic_vector(18, 11);
--                              else
                              
--                              end if;
                                 --counter verhogen
                                -- counter := counter+2;
                                 
                                 if((counter mod 1000) = 0) then
                                     gearshift_h := '1';
                                     gearshift_v := '0';
                                     godown := '0';
                                 elsif((counter mod 1500) = 0) then
                                     gearshift_h := '0';
                                     gearshift_v := '1';
                                     godown := '0';
                                 elsif((counter mod 50) = 0)  then
                                    gearshift_h := '0';
                                    gearshift_v := '0';
                                    godown := '1';
                                 else 
                                     godown := '0';
                                     gearshift_h := '0';
                                     gearshift_v := '0';
                                 end if;            
                                     --alien is onderhevig aan dezelfde grenzen als de tank
                                      if(conv_integer(left_right_alien) <= 17) or (conv_integer(left_right_alien) >= 600) then
                                                direction := '1';
                                      elsif(conv_integer(left_right_alien) >= 583) and (conv_integer(left_right_alien) < 600) then
                                                direction := '0';
                                      else
                                      
                                      end if;
              --copied block ends hereµ
              else
                --game over
              end if;
              
        end if;
        end process;
        
        process (vidon, rom_pix, M, clk, M2, M3)
        variable j: integer;
        variable input : std_logic_vector(3 downto 0);
        begin
        input := vidon & spriteon & spriteon_bullet & spriteon_alien;
            if rising_edge (clk) then
                         red <= "0000";      --colours are active high
                         green <= "0000";
                         blue <= "0000";
                         
                CASE input is
                    WHEN "1000" => 
                        green <="0000"; 
                        red <= "0000";
                        blue <= "0000"; 
                    WHEN "1100" => 
                        j := conv_integer(rom_pix);
                        R <=  not M(j);
                        G <=  not M(j+42);
                        B <=  not M(j+84);
                        red <= R&R&R&R;
                        green <= G&G&G&'0';
                        blue <= B&B&B&B;  
                    WHEN "1010" =>
                        j := conv_integer(rom_pix_bullet);
                        R <=  not M2(j);
                        G <=  not M2(j+4);
                        B <=  not M2(j+8);
                        red <= R&R&R&R;
                        green <= G&G&G&'0';
                        blue <= B&B&B&B;
                    WHEN "1001" =>
                       j := conv_integer(rom_pix_alien);
                        R <=  not M3(j+42);
                        G <=  not M3(j);
                        B <=  not M3(j+84);
                        red <= R&R&R&R;
                        green <= G&G&G&'0';
                        blue <= B&B&B&B; 
                    WHEN others =>
                        green <="0000"; 
                        red <= "0000";
                        blue <= "0000"; 
                end CASE;
            end if;              
        end process;

end Behavioral;
