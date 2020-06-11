library IEEE;
use IEEE.std_logic_1164.all;
use ieee.numeric_std.all;
use work.elevator_types.all;

entity elev_tracker is
generic (floors: natural := 2);
port (clk: in std_logic;
      reset: in std_logic;
      up: in std_logic;
      down: in std_logic;
      current_floor: out std_logic_vector(floors-1 downto 0));
end elev_tracker;

architecture track_behavior of elev_tracker is
  signal floors_temp: std_logic_vector(floors-1 downto 0) := (floors-1 downto 1 => '0') & '1';
begin
  process(clk, reset, up, down) is
  begin
    if rising_edge(clk) then
      if reset = '1' then
        floors_temp <= (floors_temp'high downto 1 => '0') & '1';
      elsif up = '1' and down = '0' and floors_temp(floors-1) = '0' then
        floors_temp <= floors_temp(floors-2 downto 0) & '0';
      elsif down = '1' and up = '0' and floors_temp(0) = '0' then
        floors_temp <= '0' & floors_temp(floors-1 downto 1);
      end if;
    end if;
  end process;

  current_floor <= floors_temp;

end track_behavior;