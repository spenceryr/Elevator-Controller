library IEEE;
use IEEE.std_logic_1164.all;
use ieee.numeric_std.all;
use work.elevator_types.all;

entity button_reg is
generic (floors: natural := 2);
port (clk: in std_logic;
      reset: in std_logic;
      enable: in std_logic_vector(floors-1 downto 0);
      disable: in std_logic_vector(floors-1 downto 0);
      buttons_out: out std_logic_vector(floors-1 downto 0));
end button_reg;

architecture buttons_behavior of button_reg is
  signal button_temp: std_logic_vector(floors-1 downto 0) := (others => '0');
begin
  process(clk, reset, enable, disable) begin
    if rising_edge(clk) then
      if reset = '1' then
        button_temp <= (others => '0');
      else
        button_temp <= (button_temp or enable) and (not disable);
      end if;
    end if;
  end process;

  buttons_out <= button_temp;

end buttons_behavior;