library IEEE;
use IEEE.std_logic_1164.all;
use ieee.numeric_std.all;
use work.elevator_types.all;
use STD.textio.all;

entity tb_elevator is
end tb_elevator;

architecture tb of tb_elevator is
    constant floors: natural := 5;
    constant door_wait_time: natural := 3;
    constant waiter_wait_time: natural := 1;
    constant move_wait_time: natural := 5;

    constant clk_period: time := 10 ns;
    signal clk: std_logic := '0';
    signal reset: std_logic := '1';
    
    signal ext_requests: std_logic_vector(floors-1 downto 0) := (others => '0');
    signal int_requests: std_logic_vector(floors-1 downto 0) := (others => '0');
    signal elevator_motion: motion_t := idle;
    signal door_state: door_state_t := closed;
    signal elevator_current_floor: natural := 0;
    
    signal done: std_logic := '0';
    
    file out_file: text open write_mode is "elevator_output.txt";
    
    component elevator_controller is
        generic (floors: natural := 2;
                 door_wait_time: natural := 5;
                 waiter_wait_time: natural := 3;
                 move_wait_time: natural := 10);
        port (clk: in std_logic;
              reset: in std_logic;
              ext_requests: in std_logic_vector(floors-1 downto 0);
              int_requests: in std_logic_vector(floors-1 downto 0);
              elevator_motion: out motion_t;
              door_state: out door_state_t;
              elevator_current_floor: out natural);
    end component;
    
begin
    uut: elevator_controller
        generic map (floors => floors,
                     door_wait_time => door_wait_time,
                     waiter_wait_time => waiter_wait_time,
                     move_wait_time => move_wait_time)
        port map (clk => clk,
                  reset => reset,
                  ext_requests => ext_requests,
                  int_requests => int_requests,
                  elevator_motion => elevator_motion,
                  door_state => door_state,
                  elevator_current_floor => elevator_current_floor);

    clock: process is
      variable buff: line;
    begin
      if done = '1' then
          wait;
      end if;
      wait for clk_period/2;
      clk <= '1';
      wait for clk_period/2;
      clk <= '0';
      report "Elevator is on floor " & natural'image(elevator_current_floor) & ", " & motion_t'image(elevator_motion) & ", Door is " & door_state_t'image(door_state);
      write(buff, "Elevator is on floor " & natural'image(elevator_current_floor) & ", " & motion_t'image(elevator_motion) & ", Door is " & door_state_t'image(door_state));
      writeline(out_file, buff);
    end process;
    
    tests: process is
      variable test_case: natural := 0;
      variable buff: line;
    begin
      wait for clk_period;
      reset <= '0';
      wait for clk_period;
      test_case := test_case + 1;
      write(buff, "Test Case: " & natural'image(test_case));
      writeline(out_file, buff);
      ext_requests <= "11111";
      int_requests <= "00000";
      wait for clk_period;
      ext_requests <= "00000";
      int_requests <= "00000";
      wait until ((elevator_current_floor = 1) and (door_state = opened));
      wait until ((elevator_current_floor = 2) and (door_state = opened));
      wait until ((elevator_current_floor = 3) and (door_state = opened));
      wait until ((elevator_current_floor = 4) and (door_state = opened));
      wait until ((elevator_current_floor = 5) and (door_state = opened));
      wait for clk_period/2;
      wait for clk_period * 10;

      test_case := test_case + 1;
      write(buff, "Test Case: " & natural'image(test_case));
      writeline(out_file, buff);
      ext_requests <= "11111";
      int_requests <= "00000";
      wait for clk_period;
      ext_requests <= "00000";
      int_requests <= "00000";
      wait until ((elevator_current_floor = 5) and (door_state = opened));
      wait until ((elevator_current_floor = 4) and (door_state = opened));
      wait until ((elevator_current_floor = 3) and (door_state = opened));
      wait until ((elevator_current_floor = 2) and (door_state = opened));
      wait until ((elevator_current_floor = 1) and (door_state = opened));
      wait for clk_period/2;
      wait for clk_period * 10;

      test_case := test_case + 1;
      write(buff, "Test Case: " & natural'image(test_case));
      writeline(out_file, buff);
      ext_requests <= "00100";
      int_requests <= "00010";
      wait for clk_period;
      ext_requests <= "00000";
      int_requests <= "00000";
      wait until ((elevator_current_floor = 2) and (door_state = opened));
      wait until ((elevator_current_floor = 3) and (door_state = opened));
      wait for clk_period/2;
      wait for clk_period * 10;

      test_case := test_case + 1;
      write(buff, "Test Case: " & natural'image(test_case));
      writeline(out_file, buff);
      ext_requests <= "10001";
      int_requests <= "00010";
      wait for clk_period;
      ext_requests <= "00000";
      int_requests <= "00000";
      wait until ((elevator_current_floor = 2) and (door_state = opened));
      wait until ((elevator_current_floor = 5) and (door_state = opened));
      wait until ((elevator_current_floor = 1) and (door_state = opened));
      wait for clk_period/2;
      wait for clk_period * 10;

      test_case := test_case + 1;
      write(buff, "Test Case: " & natural'image(test_case));
      writeline(out_file, buff);
      ext_requests <= "00100";
      int_requests <= "00000";
      wait for clk_period;
      ext_requests <= "00000";
      int_requests <= "00000";
      wait until elevator_motion = moving_up;
      wait for clk_period/2;
      ext_requests <= "10010";
      int_requests <= "00000";
      wait for clk_period;
      ext_requests <= "00000";
      int_requests <= "00000";
      wait until ((elevator_current_floor = 2) and (door_state = opened));
      wait until ((elevator_current_floor = 3) and (door_state = opened));
      wait for clk_period/2;
      ext_requests <= "00000";
      int_requests <= "00010";
      wait for clk_period;
      ext_requests <= "00000";
      int_requests <= "00000";
      wait until ((elevator_current_floor = 2) and (door_state = opened));
      wait until ((elevator_current_floor = 5) and (door_state = opened));
      wait for clk_period/2;
      wait for clk_period * 10;

      done <= '1';
      wait;
    end process;
    
end tb;
    