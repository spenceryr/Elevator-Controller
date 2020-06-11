library IEEE;
use IEEE.std_logic_1164.all;
use ieee.numeric_std.all;
use work.elevator_types.all;

entity door_counter is
generic (wait_time: natural := 5);
port (clk: in std_logic;
      reset: in std_logic;
      elevator_state: in state_t;
      door_open_ready: out boolean;
      door_close_ready: out boolean);
end door_counter;

architecture door_counter_behavior of door_counter is
  signal counter: natural := 0;
begin
  process (clk, reset, elevator_state, counter) is
  begin
    if rising_edge(clk) then
      if reset = '1' then
        counter <= 0;
      elsif elevator_state = opening_door then
        if counter = wait_time-1 then
          counter <= wait_time-1;
        else
          counter <= counter + 1;
        end if;
      elsif elevator_state = closing_door then
        if counter = 0 then
          counter <= 0;
        else
          counter <= counter - 1;
        end if;
      end if;
    end if;
  end process;

  door_open_ready <= counter = wait_time-1;
  door_close_ready <= counter = 0;

end door_counter_behavior;