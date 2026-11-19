// Lindsey Sands
// lsands@g.hmc.edu
// 11-14-2026
// This is the score conversion module. 
// It takes the char[] input from the MCU and converts it to a score.
module scoreConverter(input logic clk,
                        input logic[79:0] chars,
                        input logic[3:0] comboIn,
                        input logic same,

                        output logic addrSel,
                        output logic[13:0] scoreAddend,
                        output logic[3:0] comboOut);

    always_comb
        case(chars)
            // Perfect
            80'h50_65_72_66_65_63_74_20_20_20: 
                if (same) begin
                    comboOut = comboIn + 1;
                    scoreAddend = 12'd3000*comboOut;
                end
                else begin
                    comboOut = 0;
                    scoreAddend = 12'd3000;
                end

            // Good
            80'h47_6F_6F_64_20_20_20_20_20_20: 
            begin
                scoreAddend = 12'd2000;
                comboOut = 0;
            end

            // OK
            80'h4F_4B_20_20_20_20_20_20_20_20:
            begin
                scoreAddend = 12'd1000;
                comboOut = 0;
            end

            // Miss 
            80'h4D_69_73_73_20_20_20_20_20_20:
            begin
                scoreAddend = 0;
                comboOut = 0;
            end
            default:
                begin
                scoreAddend = 0;
                comboOut = 0;
            end
        endcase
    
    assign addrSel = 0;
endmodule