library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

package elevator_types is

  type state_t is (idle, opening_door, door_opened,
                   waiting, closing_door, door_closed,
                   start_moving_down, moving_down, start_moving_up,
                   moving_up);
  type motion_t is (idle, moving_up, moving_down);

  type door_state_t is (opened, closed, opening, closing);

end package elevator_types;