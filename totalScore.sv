// Lindsey Sands
// lsands@g.hmc.edu
// 11-14-2026
// This is the total score calculation module
module totalScore(input logic currScore, 
                    input logic scoreAddend, 
                    output logic addrSel,
                    output logic total);
    assign total = currScore + scoreAddend;
    assign addrSel = 1;
endmodule