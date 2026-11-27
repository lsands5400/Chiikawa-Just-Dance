// Lindsey Sands
// lsands@g.hmc.edu
// 11-14-2026
// This is the top module for the Chiikawa Just Dance game. 
module top(input logic start, 
            input logic songSelect, 
			input logic spi_sclk,
			input logic spi_cs_n,
			input logic spi_mosi,
			output logic spi_ready,
  
            output logic song,
            output logic[319:0] lcd);
    logic[319:0] songSelLCD, jdLCD;
	logic gameStart;
	
    // Internal High Speed Oscillator generates clock signal at 
    // 12 MHz
    HSOSC #(.CLKHF_DIV(2'b10))
		clk (.CLKHFPU(1'b1), .CLKHFEN(1'b1), .CLKHF(int_osc));

    lcdMux lm(start, jdLCD, songSelLCD, lcd);
    songFSM sf(int_osc, reset, en, songSelect, start, songSelLCD, gameStart, song);
    justDance jd(int_osc, reset, gameStart, spi_sclk, spi_cs_n, spi_mosi, spi_ready, 
		jdLCD, ready, done, frame_error);
endmodule