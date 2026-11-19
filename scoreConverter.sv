// Lindsey Sands
// lsands@g.hmc.edu
// 11-14-2026
// This is the score conversion module. 
// It takes the char[] input from the MCU and converts it to a score.
// Converts the received judgment into a score addend and new combo.
module scoreConverter (
    input logic [79:0] chars,
    input logic [3:0] comboIn,
    input logic same,

    output logic [15:0] scoreAddend,
    output logic [3:0] comboOut
);

    always_comb begin

        // Default values.
        scoreAddend = 16'd0;
        comboOut = 4'd0;

        case (chars)

            // Perfect
            80'h50_65_72_66_65_63_74_20_20_20: begin

                if (same) begin
                    comboOut = comboIn + 4'd1;
                    scoreAddend = 16'd3000 * comboOut;
                end
                else begin
                    comboOut = 4'd0;
                    scoreAddend = 16'd3000;
                end

            end

            // Good
            80'h47_6F_6F_64_20_20_20_20_20_20: begin
                scoreAddend = 16'd2000;
                comboOut = 4'd0;
            end

            // OK
            80'h4F_4B_20_20_20_20_20_20_20_20: begin
                scoreAddend = 16'd1000;
                comboOut = 4'd0;
            end

            // Miss
            80'h4D_69_73_73_20_20_20_20_20_20: begin
                scoreAddend = 16'd0;
                comboOut = 4'd0;
            end

            default: begin
                scoreAddend = 16'd0;
                comboOut = 4'd0;
            end

        endcase
    end

endmodule