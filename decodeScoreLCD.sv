// Lindsey Sands
// lsands@g.hmc.edu
// 11-14-2026
// This is the LCD decoder module for numbers
module decodeScoreLCD (
    input  logic [15:0] score,
    output logic [39:0] b
);

    logic [19:0] bcd;
    integer i, j;

    always_comb begin

        // Initialize BCD
        bcd = 20'b0;

        // Double Dabble algorithm
        for (i = 15; i >= 0; i = i - 1) begin

            // Add 3 to BCD digits >= 5
            for (j = 0; j < 5; j = j + 1) begin
                if (bcd[j*4 +: 4] >= 5)
                    bcd[j*4 +: 4] =
                        bcd[j*4 +: 4] + 4'd3;
            end

            // Shift in next binary bit
            bcd = {bcd[18:0], score[i]};

        end

        // Convert BCD digits to ASCII
        b[39:32] = {4'h3, bcd[19:16]};
        b[31:24] = {4'h3, bcd[15:12]};
        b[23:16] = {4'h3, bcd[11:8]};
        b[15:8]  = {4'h3, bcd[7:4]};
        b[7:0]   = {4'h3, bcd[3:0]};

    end

endmodule
