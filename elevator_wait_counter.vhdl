library IEEE;
use IEEE.std_logic_1164.all;
use ieee.numeric_std.all;
use work.elevator_types.all;

entity wait_counter is
generic (wait_time: natural := 3);
port (clk: in std_logic;
      reset: in std_logic;
      elevator_state: in state_t;
      done_waiting: out boolean);
end wait_counter;

architecture wait_counter_behavior of wait_counter is
  signal counter: natural := 0;
begin
  process (clk, elevator_state, reset, counter) is
  begin
    if rising_edge(clk) then
      if reset = '1' then
        counter <= 0;
      elsif elevator_state = waiting then
        if counter = wait_time-1 then
          counter <= wait_time-1;
        else
          counter <= counter + 1;
        end if;
      else
        counter <= 0;
      end if;
    end if;
  end process;

  done_waiting <= counter = wait_time-1;

end wait_counter_behavior;