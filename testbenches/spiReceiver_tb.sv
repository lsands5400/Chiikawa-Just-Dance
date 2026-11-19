
`timescale 1ns/1ps

module spiReceiver_tb;

    logic clk = 0;
    logic reset = 1;

    logic spi_sclk = 0;
    logic spi_cs_n = 1;
    logic spi_mosi = 0;

    logic game_ready = 1;

    logic [79:0] category;
    logic category_valid;
    logic spi_ready;
    logic frame_error;

    // 12 MHz FPGA clock
    always #41.667 clk = ~clk;

    spiReceiver dut (
        .clk(clk),
        .reset(reset),

        .spi_sclk(spi_sclk),
        .spi_cs_n(spi_cs_n),
        .spi_mosi(spi_mosi),

        .game_ready(game_ready),

        .category(category),
        .category_valid(category_valid),

        .spi_ready(spi_ready),
        .frame_error(frame_error)
    );

    // Send one 80-bit SPI transaction.
    // Mode 0: MOSI changes before rising SCLK.
    task send_frame(input logic [79:0] word);

        begin

            wait(spi_ready);

            // Assert chip select
            #500;
            spi_cs_n = 0;

            #1000;

            // Send MSB first
            for (int i = 79; i >= 0; i--) begin

                spi_mosi = word[i];

                #1000;
                spi_sclk = 1;

                #1000;
                spi_sclk = 0;

            end

            #1000;
            spi_cs_n = 1;

            // Wait for completed judgment
            wait(category_valid);

            if (category !== word) begin
                $error("Incorrect category received!");
                $display("Expected: %h", word);
                $display("Received: %h", category);
                $fatal;
            end

            if (frame_error) begin
                $fatal(1, "Unexpected frame error!");
            end

            $display("PASS: Received %s", word);

            // Wait until receiver is ready again.
            wait(spi_ready);

        end

    endtask

    initial begin

        #500;

        reset = 0;

        #500;

        send_frame(
            80'h50_65_72_66_65_63_74_20_20_20
        );

        send_frame(
            80'h47_6F_6F_64_20_20_20_20_20_20
        );

        send_frame(
            80'h4F_4B_20_20_20_20_20_20_20_20
        );

        send_frame(
            80'h4D_69_73_73_20_20_20_20_20_20
        );

        $display("All SPI receiver tests passed!");

        $finish;

    end

endmodule
