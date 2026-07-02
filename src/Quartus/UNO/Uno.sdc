# Uno.sdc - Restricoes de temporização mínimas para o projeto UNO (DE2-115)
# Clock principal: CLOCK_50 = 50 MHz (periodo 20 ns)

create_clock -period 20.000 -name CLOCK_50 [get_ports CLOCK_50]

derive_pll_clocks
derive_clock_uncertainty

set_input_delay -clock CLOCK_50 2.0 [remove_from_collection [all_inputs] [get_ports {CLOCK_50}]]
set_output_delay -clock CLOCK_50 2.0 [all_outputs]