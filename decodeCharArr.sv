// Lindsey Sands
// lsands@g.hmc.edu
// 11-14-2026
// This is the LCD decoder module for char[]
module decodeCharArr(input logic[79:0] chars,
                        output logic[79:0] dots);

    decodeCharLCD dcl0(chars[7:0], dot0);
    decodeCharLCD dcl1(chars[15:8], dot1);
    decodeCharLCD dcl2(chars[23:16], dot2);
    decodeCharLCD dcl3(chars[31:24], dot3);
    decodeCharLCD dcl4(chars[39:32], dot4);
    decodeCharLCD dcl5(chars[47:40], dot5);
    decodeCharLCD dcl6(chars[55:48], dot6);
    decodeCharLCD dcl7(chars[63:56], dot7);
    decodeCharLCD dcl8(chars[71:64], dot8);
    decodeCharLCD dcl9(chars[79:72], dot9);

    assign dots = {dot9, dot8, dot7, dot6, dot5, dot4,
            dot3, dot2, dot1, dot0};
endmodule