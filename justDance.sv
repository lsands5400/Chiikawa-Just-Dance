// Lindsey Sands
// lsands@g.hmc.edu
// 11-14-2026
// This is the top module for the Chiikawa Just Dance game. 
module justDance();
    
    // clock 
    // TODO: Implement this

    // Receive char[]
    // TODO: Implement this

    // Convert char[] to the display dot values
    decodeCharArr(chars, dots);

    // Convert char[] to score addend
    scoreConverter(clk, chars, prevChars, scoreAddend, combo);

    // Add to total score
    totalScore(currScore, scoreAddend, totalScore);

    // Convert each score character to the display dot value
    for i in chars:
        decodeScoreLCD(totalScore);

endmodule