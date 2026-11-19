// Lindsey Sands
// lsands@g.hmc.edu
// 11-14-2026
// This is the top module for the Chiikawa Just Dance game. 
module top(input logic start, 
            input logic songSelect, 
            input logic[79:0] category,
            
            output logic[319:0] lcd);
    logic[319:0] songSelLCD, jdLCD;
    logic song;
    
    lcdMux lm(start, jdLCD, songSelLCD, lcd);
    songFSM sf(songSelect, song, songSelLCD);
    justDance jd(start, category, jdLCD);
endmodule