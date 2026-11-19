
module categoryCDC (
    // SPI clock domain (source)
    input  logic spi_clk,
    input  logic reset,
    input  logic [79:0] category_in,
    input  logic category_valid,
    output logic category_ready,

    // Game clock domain (destination)
    input  logic clk,
    output logic [79:0] category_out,
    output logic category_out_valid,
    input  logic category_out_ready
);

    // Source-side storage
    logic [79:0] category_hold;
    logic request_toggle;

    // Destination-side request synchronizer
    logic request_meta;
    logic request_sync;

    // Destination acknowledgment
    logic acknowledge_toggle;

    // Source-side acknowledgment synchronizer
    logic acknowledge_meta;
    logic acknowledge_sync;

    // ----------------------------------------
    // Source clock domain: SPI
    // ----------------------------------------

    always_ff @(posedge spi_clk or posedge reset) begin
        if (reset) begin
            category_hold <= 80'h20_20_20_20_20_20_20_20_20_20;
            request_toggle <= 1'b0;
        end
        else begin
            if (category_valid && category_ready) begin
                category_hold <= category_in;
                request_toggle <= ~request_toggle;
            end
        end
    end

    // Synchronize acknowledgment back to SPI domain
    always_ff @(posedge spi_clk or posedge reset) begin
        if (reset) begin
            acknowledge_meta <= 1'b0;
            acknowledge_sync <= 1'b0;
        end
        else begin
            acknowledge_meta <= acknowledge_toggle;
            acknowledge_sync <= acknowledge_meta;
        end
    end

    // Source can accept another judgment after acknowledgment
    assign category_ready = (request_toggle == acknowledge_sync);


    // ----------------------------------------
    // Destination clock domain: FPGA game clock
    // ----------------------------------------

    // Synchronize request toggle into game clock domain
    always_ff @(posedge clk or posedge reset) begin
        if (reset) begin
            request_meta <= 1'b0;
            request_sync <= 1'b0;
        end
        else begin
            request_meta <= request_toggle;
            request_sync <= request_meta;
        end
    end

    // Capture the stable 80-bit category and acknowledge it
    always_ff @(posedge clk or posedge reset) begin
        if (reset) begin
            category_out <= 80'h20_20_20_20_20_20_20_20_20_20;
            category_out_valid <= 1'b0;
            acknowledge_toggle <= 1'b0;
        end
        else begin

            if (!category_out_valid &&
                request_sync != acknowledge_toggle) begin

                category_out <= category_hold;
                category_out_valid <= 1'b1;

            end

            else if (category_out_valid && category_out_ready) begin

                category_out_valid <= 1'b0;
                acknowledge_toggle <= request_sync;

            end

        end
    end

endmodule
