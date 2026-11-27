/ Lindsey Sands
// lsands@g.hmc.edu
// 11-14-2026
// This is the total score calculation module
module totalScore(input logic[16:0] currScore, 
                    input logic[13:0] scoreAddend, 
                    output logic addrSel,
                    output logic[16:0] total);
    assign total = currScore + scoreAddend;
endmodule