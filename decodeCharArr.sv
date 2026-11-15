// Lindsey Sands
// lsands@g.hmc.edu
// 11-14-2026
// This is the LCD decoder module for char[]
module decodeCharArr(input logic chars,
                        output logic dots);
    // TODO: Finish this implementation
    for i in chars:
        decodeCharLCD(chars[i])
endmodule