# Create clock constraints
create_clock -name clk -period 20.000 [get_ports {clk}]
# Create virtual clocks for input and output delay constraints
create_clock -name vclk -period 20.000
derive_pll_clocks
# derive clock uncertainty
derive_clock_uncertainty
