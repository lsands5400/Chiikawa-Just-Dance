// Lindsey Sands
// lsands@g.hmc.edu
// 11-15-2026
// This is the testbench for the justDance module. 

HSOSC #(.CLKHF_DIV(2'b01))
		clk (.CLKHFPU(1'b1), .CLKHFEN(1'b1), .CLKHF(int_osc));