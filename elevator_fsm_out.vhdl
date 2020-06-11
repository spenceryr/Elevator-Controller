library IEEE;
use IEEE.std_logic_1164.all;
use ieee.numeric_std.all;
use work.elevator_types.all;

entity elevator_fsm_outputs is
generic (floors: natural := 2);
port (elevator_state: in state_t;
      elevator_motion: out motion_t;
      door_state: out door_state_t);
end elevator_fsm_outputs;

architecture fsm_outputs_behavior of elevator_fsm_outputs is
begin
  process (elevator_state) is
  begin
    elevator_motion <= idle;
    door_state <= closed;
    case elevator_state is
    when opening_door => door_state <= opening;
    when door_opened => door_state <= opened;
    when waiting => door_state <= opened;
    when closing_door => door_state <= closing;
    when door_closed => door_state <= closed;
    when start_moving_down | moving_down => elevator_motion <= moving_down;
    when start_moving_up | moving_up => elevator_motion <= moving_up;
    when others =>
      elevator_motion <= idle;
      door_state <= closed;
    end case;
  end process;
end fsm_outputs_behavior;