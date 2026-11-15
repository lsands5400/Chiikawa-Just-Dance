// Lindsey Sands
// lsands@g.hmc.edu
// 11-14-2026
// This is the score conversion module. 
// It takes the char[] input from the MCU and converts it to a score.
module scoreConverter(input logic clk,
                        input logic chars,
                        input logic prevChars,
                        output logic scoreAddend,
                        output logic combo);

    always_comb
        case(chars)
            // Perfect
            0'h50_65_72_66_65_63_74: 
                if (prevChars == chars) begin
                    // TODO: Where is this initialized to 1?
                    combo = combo + 1;
                    scoreAddend = 3000*combo;
                end
                else begin
                    combo = 0;
                    scoreAddend = 3000;
                end

            // Good
            0'h47_6F_6F_64:
                scoreAddend = 2000;
                combo = 0;

            // OK
            0'h4F_4B:
                scoreAddend = 1000;
                combo = 0;

            // Miss 
            0'h4D_69_73_73:
                scoreAddend = 0;
                combo = 0;
        endcase
    
endmodule