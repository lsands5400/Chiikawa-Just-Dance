// Lindsey Sands
// lsands@g.hmc.edu
// 11-14-2026
// This is the top module for the Chiikawa Just Dance game. 
module top(input logic start, 
            input logic songSelect, 
            input logic category,
            
            output logic gameStart,
            output logic lcd);
    lcdMux lm(start, songSelLCD, jdLCD, lcd);
    songFSM sf(songSelect, song, songSelLCD);
    justDance jd(start, category, jdLCD);
endmodule