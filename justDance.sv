// Lindsey Sands
// lsands@g.hmc.edu
// 11-14-2026
// This is the game module for the Chiikawa Just Dance game. 
module justDance(input logic start,
                    input logic string, 
                    output logic lcd);
    
    // Address select
    addrMux(addrSel, addr1, addr2, addr);

    // instantiate RAM
    ram r1(din, addr, write_en, clk, dout);

    // clock 
    // TODO: Implement this

    synchronizer(clk,dataIn, sameAsLast, dataOut);

    // Receive char[]
    // TODO: Implement this

    // Convert char[] to score addend
    scoreConverter sc(clk, chars, dout, sameAsLast, 
                        addrSel, scoreAddend, comboOut);

    // Add to total score
    totalScore ts(currScore, scoreAddend, totalScore);

    // Convert char[] to the display dot values
    decodeCharArr dca(chars, dots);

    // Convert each score to the display dot value
    decodeScoreLCD dsl(totalScore, scoreDots);

    // Convert each score to the display dot value
    decodeScoreLCD ds2(comboOut, comboDots);

    display d(scoreDots, comboDots, stringDots, LCD);

endmodule