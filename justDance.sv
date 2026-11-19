
module justDance (
    input logic clk,
    input logic reset,
    input logic start,

    // SPI connections
    input logic spi_sclk,
    input logic spi_cs_n,
    input logic spi_mosi,
    output logic spi_ready,

    // LCD
    output logic [319:0] lcd,

    // Status
    output logic ready,
    output logic done,
    output logic frame_error
);

    logic [79:0] category;
    logic category_valid;

    logic [79:0] previousCategory;
    logic sameAsLast;
    logic judgmentAccepted;

    logic [16:0] score_value;
    logic [3:0] combo_value;

    logic [47:0] scoreASCII;
    logic [47:0] comboASCII;

    // ----------------------------------------
    // SPI receiver
    // ----------------------------------------

    spiReceiver receiver (
        .clk(clk),
        .reset(reset),

        .spi_sclk(spi_sclk),
        .spi_cs_n(spi_cs_n),
        .spi_mosi(spi_mosi),

        .game_ready(ready && start),

        .category(category),
        .category_valid(category_valid),

        .spi_ready(spi_ready),
        .frame_error(frame_error)
    );

    // ----------------------------------------
    // Previous judgment tracking
    // ----------------------------------------

    assign judgmentAccepted =
        category_valid && ready && start;

    assign sameAsLast =
        (category == previousCategory);

    always_ff @(posedge clk or posedge reset) begin
        if (reset) begin
            previousCategory <=
                80'h20_20_20_20_20_20_20_20_20_20;
        end
        else if (judgmentAccepted) begin
            previousCategory <= category;
        end
    end

    // ----------------------------------------
    // Game FSM
    // ----------------------------------------

    gameFSM gfsm (
        .clk(clk),
        .reset(reset),

        .category(category),
        .category_valid(category_valid),
        .same(sameAsLast),

        .ready(ready),
        .done(done),

        .score_value(score_value),
        .combo_value(combo_value)
    );

    // ----------------------------------------
    // Score decoder
    // ----------------------------------------

    decodeScoreLCD scoreDecoder (
        .score(score_value),
        .b(scoreASCII)
    );

    // ----------------------------------------
    // Combo decoder
    // ----------------------------------------

    decodeScoreLCD comboDecoder (
        .score({13'b0, combo_value}),
        .b(comboASCII)
    );

    // ----------------------------------------
    // LCD display
    // ----------------------------------------

    display lcdDisplay (
        .scoreDots(scoreASCII),
        .comboDots(comboASCII),
        .category(category),
        .lcd(lcd)
    );

endmodule
