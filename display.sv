
module display (
    input logic [47:0] scoreDots,
    input logic [47:0] comboDots,
    input logic [79:0] category,
    output logic [319:0] lcd
);

    always_comb begin

        // Fill LCD with spaces
        lcd = {40{8'h20}};

        // Row 1: SCORE: xxxxxx
        lcd[319:160] = {
            8'h53, 8'h43, 8'h4F, 8'h52, 8'h45, 8'h3A,
            scoreDots,
            8'h20, 8'h20
        };

        // Row 2: Judgment + combo
        lcd[159:0] = {
            category[79:24], // First 7 characters
            8'h20,
            8'h43, 8'h3A,
            comboDots[39:0]
        };

    end

endmodule
