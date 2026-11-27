
module spiReceiver (
    input logic clk,
    input logic reset,

    // SPI inputs
    input logic spi_sclk,
    input logic spi_cs_n,
    input logic spi_mosi,

    // Handshake with game FSM
    input logic game_ready,

    // Completed judgment
    output logic [79:0] category,
    output logic category_valid,

    // Status signals
    output logic spi_ready,
    output logic frame_error
);

    // ----------------------------------------
    // Synchronize SPI pins into FPGA clock domain
    // ----------------------------------------

    logic sclk_meta, sclk_sync, sclk_prev;
    logic cs_meta, cs_sync, cs_prev;
    logic mosi_meta, mosi_sync;

    always_ff @(posedge clk or posedge reset) begin
        if (reset) begin
            sclk_meta <= 1'b0;
            sclk_sync <= 1'b0;

            cs_meta <= 1'b1;
            cs_sync <= 1'b1;

            mosi_meta <= 1'b0;
            mosi_sync <= 1'b0;
        end
        else begin
            sclk_meta <= spi_sclk;
            sclk_sync <= sclk_meta;

            cs_meta <= spi_cs_n;
            cs_sync <= cs_meta;

            mosi_meta <= spi_mosi;
            mosi_sync <= mosi_meta;
        end
    end

    // ----------------------------------------
    // SPI receiver registers
    // ----------------------------------------

    logic [79:0] shift_reg;
    logic [6:0] bit_count;

    logic frame_allowed;
    logic overflow;

    logic sclk_rising;
    logic cs_falling;
    logic cs_rising;

    assign sclk_rising = sclk_sync && !sclk_prev;
    assign cs_falling = !cs_sync && cs_prev;
    assign cs_rising = cs_sync && !cs_prev;

    // The MCU can send only when the game can accept a judgment.
    assign spi_ready = game_ready && !category_valid;

    // ----------------------------------------
    // Receive and assemble SPI frame
    // ----------------------------------------

    always_ff @(posedge clk or posedge reset) begin

        if (reset) begin
            sclk_prev <= 1'b0;
            cs_prev <= 1'b1;

            shift_reg <= 80'b0;
            bit_count <= 7'b0;

            frame_allowed <= 1'b0;
            overflow <= 1'b0;

            category <= 80'h20_20_20_20_20_20_20_20_20_20;
            category_valid <= 1'b0;

            frame_error <= 1'b0;
        end

        else begin

            sclk_prev <= sclk_sync;
            cs_prev <= cs_sync;

            // Frame error is a one-clock-cycle pulse.
            frame_error <= 1'b0;

            // FSM accepted the previous judgment.
            if (category_valid && game_ready) begin
                category_valid <= 1'b0;
            end

            // Start of SPI transaction.
            if (cs_falling) begin
                shift_reg <= 80'b0;
                bit_count <= 7'b0;

                frame_allowed <= spi_ready;
                overflow <= 1'b0;
            end

            // Sample MOSI on rising SCLK edges.
            else if (!cs_sync && sclk_rising) begin

                if (frame_allowed) begin

                    if (bit_count < 80) begin
                        shift_reg <= {
                            shift_reg[78:0],
                            mosi_sync
                        };

                        bit_count <= bit_count + 1'b1;
                    end
                    else begin
                        overflow <= 1'b1;
                    end

                end

            end

            // End of SPI transaction.
            if (cs_rising) begin

                frame_allowed <= 1'b0;

                if (frame_allowed &&
                    bit_count == 80 &&
                    !overflow) begin

                    category <= shift_reg;
                    category_valid <= 1'b1;

                end
                else begin
                    frame_error <= 1'b1;
                end

            end

        end
    end

endmodule
