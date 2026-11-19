// Converts a 17-bit binary score into six ASCII decimal digits.
module decodeScoreLCD (
    input  logic [16:0] score,
    output logic [47:0] b
);

    logic [23:0] bcd;
    integer i, j;

    always_comb begin

        bcd = 24'b0;

        // Double Dabble
        for (i = 16; i >= 0; i = i - 1) begin

            // Correct each BCD digit before shifting.
            for (j = 0; j < 6; j = j + 1) begin
                if (bcd[j*4 +: 4] >= 5)
                    bcd[j*4 +: 4] =
                        bcd[j*4 +: 4] + 4'd3;
            end

            // Shift in the next binary bit.
            bcd = {bcd[22:0], score[i]};

        end

        // Convert each BCD digit into ASCII.
        b[47:40] = {4'h3, bcd[23:20]};
        b[39:32] = {4'h3, bcd[19:16]};
        b[31:24] = {4'h3, bcd[15:12]};
        b[23:16] = {4'h3, bcd[11:8]};
        b[15:8]  = {4'h3, bcd[7:4]};
        b[7:0]   = {4'h3, bcd[3:0]};

    end

endmodule