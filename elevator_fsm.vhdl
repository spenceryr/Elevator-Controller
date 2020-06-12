library IEEE;
use IEEE.std_logic_1164.all;
use ieee.numeric_std.all;
use work.elevator_types.all;

entity elev_fsm is
generic (floors: natural := 2);
port (clk: in std_logic;
      reset: in std_logic;
      ext_buttons: in std_logic_vector(floors-1 downto 0);
      int_buttons: in std_logic_vector(floors-1 downto 0);
      door_open_ready: in boolean;
      door_close_ready: in boolean;
      done_waiting: in boolean;
      elevator_at_floor: in boolean;
      disable: out std_logic_vector(floors-1 downto 0);
      elevator_state: out state_t;
      elevator_current_floor: out std_logic_vector(floors-1 downto 0));
end elev_fsm;

architecture fsm_behavior of elev_fsm is
    signal state: state_t := idle;

    type directions_t is (down, up);
    signal direction_priority: directions_t := up;

    signal track_up: std_logic := '0';
    signal track_down: std_logic := '0';
    signal current_floor: std_logic_vector(floors-1 downto 0) := (floors-1 downto 1 => '0') & '1';

    function find_target(buttons: std_logic_vector(floors-1 downto 0);
                          priority: directions_t)
                          return std_logic_vector is
      variable target: std_logic_vector(floors-1 downto 0) := (others => '0');
    begin
      if priority = down then
        target(buttons'low) := '1';
        for i in buttons'low to buttons'high loop
          if buttons(i) = '1' then
            return target;
          else
            target := target(buttons'high - 1 downto 0) & '0';
          end if;
        end loop;
      elsif priority = up then
        target(buttons'high) := '1';
        for i in buttons'low to buttons'high loop
          if buttons(buttons'high - i) = '1' then
            return target;
          else
            target := '0' & target(buttons'high downto 1);
          end if;
        end loop;
      end if;
      return target;
    end find_target;

    component elev_tracker
      generic (floors: natural := 2);
      port (clk: in std_logic;
            reset: in std_logic;
            up: in std_logic;
            down: in std_logic;
            current_floor: out std_logic_vector(floors-1 downto 0));
    end component;
begin
    
    curr_floor_tracker: elev_tracker generic map (floors => floors)
                                     port    map (clk => clk,
                                                  reset => reset,
                                                  up => track_up,
                                                  down => track_down,
                                                  current_floor => current_floor);

    process (state) is
    begin
      track_down <= '0';
      track_up <= '0';
      disable <= (others => '0');
      case state is
        when start_moving_up => track_up <= '1';
        when start_moving_down => track_down <= '1';
        when door_opened => disable <= current_floor;
        when others =>
          track_up <= '0';
          track_down <= '0';
          disable <= (others => '0');
      end case;
    end process;

    process (clk, state, door_open_ready,
             door_close_ready, done_waiting, elevator_at_floor,
             ext_buttons, int_buttons) is
      variable target_floor: std_logic_vector(floors-1 downto 0) := (others => '0');
    begin
      if rising_edge(clk) then
        if reset = '1' then
          state <= idle;
          direction_priority <= up;
          target_floor := (others => '0');
        else
          case state is
            when idle =>
              if current_floor = target_floor or unsigned(target_floor) = 0 then
                if unsigned(int_buttons) /= 0 then
                  target_floor := find_target(buttons => int_buttons, priority => direction_priority);
                elsif unsigned(ext_buttons) /= 0 then
                  target_floor := find_target(buttons => ext_buttons, priority => direction_priority);
                else
                  target_floor := (others => '0');
                end if;
              end if;

              if unsigned((int_buttons or ext_buttons) and current_floor) > 0 then
                state <= opening_door;
              elsif unsigned(target_floor) = 0 then
                if direction_priority = up then
                  direction_priority <= down;
                else
                  direction_priority <= up;
                end if;
                state <= idle;
              elsif unsigned(target_floor) > unsigned(current_floor) then
                direction_priority <= down;
                state <= start_moving_up;
              else
                direction_priority <= up;
                state <= start_moving_down;
              end if;
              
            when opening_door =>
              if door_open_ready then
                state <= door_opened;
              else
                state <= opening_door;
              end if;

            when door_opened =>
              state <= waiting;

            when waiting =>
              if done_waiting then
                state <= closing_door;
              else
                state <= waiting;
              end if;

            when closing_door =>
              if unsigned((int_buttons or ext_buttons) and current_floor) > 0 then
                state <= opening_door;
              elsif door_close_ready then
                state <= door_closed;
              else
                state <= closing_door;
              end if;

            when door_closed =>
              state <= idle;

            when start_moving_up =>
              state <= moving_up;
            when moving_up =>
              if elevator_at_floor then
                if unsigned((int_buttons or ext_buttons) and current_floor) > 0 then
                  state <= idle;
                elsif current_floor(floors-1) = '1' then
                  state <= idle;
                else
                  state <= start_moving_up;
                end if;
              else
                state <= moving_up;
              end if;

            when start_moving_down =>
              state <= moving_down;
            when moving_down =>
              if elevator_at_floor then
                if unsigned((int_buttons or ext_buttons) and current_floor) > 0 then
                  state <= idle;
                elsif current_floor(0) = '1' then
                  state <= idle;
                else
                  state <= start_moving_down;
                end if;
              else
                state <= moving_down;
              end if;

            when others =>
              state <= idle;
          end case;
        end if;
      end if;
    end process;

    elevator_state <= state;
    elevator_current_floor <= current_floor;

end fsm_behavior;