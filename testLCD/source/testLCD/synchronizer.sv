// Two-stage register pipeline for an 80-bit judgment.
module synchronizer (
    input logic clk,
    input logic en,
    input logic [79:0] in,
    output logic same,
    output logic [79:0] out
);

    logic [79:0] intermediate;

    always_ff @(posedge clk) begin
        if (en) begin
            intermediate <= in;
            out <= intermediate;
        end
    end

    // Check whether both pipeline stages match
    assign same = (out == intermediate);

endmodule