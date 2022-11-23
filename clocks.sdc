# Create clock constraints
create_clock -name clk -period 20.000 [get_ports {name_of_clock_port_in_top_.level_module}]
# Create virtual clocks for input and output delay constraints
create clock -name vclk -period 20.000
derive_pll_clocks
# derive clock uncertainty
derive_clock_uncertainty
