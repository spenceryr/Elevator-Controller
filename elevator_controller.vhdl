library IEEE;
use IEEE.std_logic_1164.all;
use ieee.numeric_std.all;
use work.elevator_types.all;

entity elevator_controller is
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
end elevator_controller;

architecture top_structure of elevator_controller is
  component button_reg
    generic (floors: natural := 2);
    port (clk: in std_logic;
          reset: in std_logic;
          enable: in std_logic_vector(floors-1 downto 0);
          disable: in std_logic_vector(floors-1 downto 0);
          buttons_out: out std_logic_vector(floors-1 downto 0));
  end component;

  component elev_fsm is
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
  end component;

  component door_counter is
    generic (wait_time: natural := 5);
    port (clk: in std_logic;
          reset: in std_logic;
          elevator_state: in state_t;
          door_open_ready: out boolean;
          door_close_ready: out boolean);
  end component;

  component wait_counter is
    generic (wait_time: natural := 3);
    port (clk: in std_logic;
          reset: in std_logic;
          elevator_state: in state_t;
          done_waiting: out boolean);
  end component;

  component move_counter is
    generic (wait_time: natural := 10);
    port (clk: in std_logic;
          reset: in std_logic;
          elevator_state: in state_t;
          elevator_at_floor: out boolean);
  end component;

  component elevator_fsm_outputs is
    generic (floors: natural := 2);
    port (elevator_state: in state_t;
          elevator_motion: out motion_t;
          door_state: out door_state_t);
  end component;

  signal disable: std_logic_vector(floors-1 downto 0) := (others => '0');
  signal ext_buttons: std_logic_vector(floors-1 downto 0) := (others => '0');
  signal int_buttons: std_logic_vector(floors-1 downto 0) := (others => '0');
  signal door_open_ready: boolean := false;
  signal door_close_ready: boolean := false;
  signal done_waiting: boolean := false;
  signal elevator_at_floor: boolean := false;
  signal elevator_state: state_t := idle;
  signal elevator_current_floor_v: std_logic_vector(floors-1 downto 0) := (floors-1 downto 1 => '0') & '1';

begin
  ext_b_reg: button_reg
    generic map (floors => floors)
    port map (clk => clk,
              reset => reset,
              enable => ext_requests,
              disable => disable,
              buttons_out => ext_buttons);

  int_b_reg: button_reg
    generic map (floors => floors)
    port map (clk => clk,
              reset => reset,
              enable => int_requests,
              disable => disable,
              buttons_out => int_buttons);

  fsm: elev_fsm
    generic map (floors => floors)
    port map(clk => clk,
          reset => reset,
          ext_buttons => ext_buttons,
          int_buttons => int_buttons,
          door_open_ready => door_open_ready,
          door_close_ready => door_close_ready,
          done_waiting => done_waiting,
          elevator_at_floor => elevator_at_floor,
          disable => disable,
          elevator_state => elevator_state,
          elevator_current_floor => elevator_current_floor_v);

  dc: door_counter
    generic map (wait_time => door_wait_time)
    port map (clk => clk, 
          reset => reset, 
          elevator_state => elevator_state, 
          door_open_ready => door_open_ready, 
          door_close_ready => door_close_ready);

  wc: wait_counter
    generic map (wait_time => waiter_wait_time)
    port map (clk => clk, 
          reset => reset, 
          elevator_state => elevator_state, 
          done_waiting => done_waiting);

  mc: move_counter
    generic map (wait_time => move_wait_time)
    port map (clk => clk, 
          reset => reset, 
          elevator_state => elevator_state, 
          elevator_at_floor => elevator_at_floor);

  efo: elevator_fsm_outputs
    generic map (floors => floors)
    port map (elevator_state => elevator_state, 
          elevator_motion => elevator_motion, 
          door_state => door_state);

  process(elevator_current_floor_v) is
  begin
    elevator_current_floor <= 0;
    for i in elevator_current_floor_v'low to elevator_current_floor_v'high loop
      if elevator_current_floor_v(i) = '1' then
        elevator_current_floor <= i+1;
      end if;
    end loop;
  end process;

end top_structure;