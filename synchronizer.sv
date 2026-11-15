// Lindsey Sands
// lsands@g.hmc.edu
// 11-14-2026
// This is the synchronizer module. 
module synchronizer(input logic clk, en,
                    input logic in,
                    output logic same,
                    output logic out);
    logic[3:0] intermediate;

    always_ff @ (posedge clk) begin
        if (en) begin
            intermediate <= in;
        end
        else begin
            intermediate <= intermediate;
        end
    end

    always_ff @ (posedge clk) begin
        if (en) begin
            out <= intermediate;
        end
        else begin
            out <= out;
        end
    end

    assign same = (out == intermediate);
endmodule