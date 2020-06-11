library IEEE;
use IEEE.std_logic_1164.all;
use ieee.numeric_std.all;
use work.elevator_types.all;

entity move_counter is
generic (wait_time: natural := 10);
port (clk: in std_logic;
      reset: in std_logic;
      elevator_state: in state_t;
      elevator_at_floor: out boolean);
end move_counter;

architecture move_counter_behavior of move_counter is
  signal counter: natural := 0;
begin
  process (clk, reset, counter, elevator_state) is
  begin
    if rising_edge(clk) then
      if reset = '1' then
        counter <= 0;
      elsif elevator_state = start_moving_up or elevator_state = moving_up then
        counter <= (counter + 1) mod wait_time;
      elsif elevator_state = start_moving_down or elevator_state = moving_down then
        counter <= (counter - 1) mod wait_time;
      else
        counter <= 0;
      end if;
    end if;
  end process;

  elevator_at_floor <= counter = 0 or abs counter = wait_time - 1;

end move_counter_behavior;