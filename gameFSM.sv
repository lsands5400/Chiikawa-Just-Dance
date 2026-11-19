module gameFSM (
    input logic clk,
    input logic reset,

    // category from SPI receiver
    input logic [79:0] category,
    input logic category_valid,
    input logic same,

    // Status
    output logic ready,
    output logic done,

    // Values for LCD display
    output logic [16:0] score_value,
    output logic [3:0] combo_value
);

    // FSM states
    typedef enum logic [3:0] {
        INIT_SCORE,
        INIT_COMBO,
        IDLE,
        READ_SCORE,
        WAIT_SCORE,
        READ_COMBO,
        WAIT_COMBO,
        CALCULATE,
        WRITE_SCORE,
        WRITE_COMBO
    } state_t;

    state_t state;

    // RAM signals
    logic [16:0] ram_din;
    logic [16:0] ram_dout;
    logic ram_addr;
    logic ram_write_en;

    // category storage
    logic [79:0] category_reg;

    // Previous values read from RAM
    logic [16:0] old_score;
    logic [3:0] old_combo;

    // New values to write into RAM
    logic [16:0] new_score;
    logic [3:0] new_combo;

    // Score calculation signals
    logic [15:0] score_addend;
    logic [3:0] calculated_combo;
    logic [16:0] calculated_score;


    // ------------------------------------------------
    // RAM: address 0 = score, address 1 = combo
    // ------------------------------------------------

    ram #(
        .addr_width(1),
        .data_width(17)
    ) scoreComboRAM (
        .din(ram_din),
        .addr(ram_addr),
        .write_en(ram_write_en),
        .clk(clk),
        .dout(ram_dout)
    );


    // ------------------------------------------------
    // Convert category into score addend and new combo
    // ------------------------------------------------

    scoreConverter sc (
        .chars(category_reg),
        .comboIn(old_combo),
        .same(same),
        .scoreAddend(score_addend),
        .comboOut(calculated_combo)
    );


    // ------------------------------------------------
    // Calculate updated total score
    // ------------------------------------------------

    totalScore ts (
        .currScore(old_score),
        .scoreAddend(score_addend),
        .total(calculated_score)
    );


    // ------------------------------------------------
    // RAM control signals
    // ------------------------------------------------

    always_comb begin

        // Defaults
        ram_addr = 1'b0;
        ram_din = 17'b0;
        ram_write_en = 1'b0;

        ready = 1'b0;

        case (state)

            // Initialize score to zero
            INIT_SCORE: begin
                ram_addr = 1'b0;
                ram_din = 17'b0;
                ram_write_en = 1'b1;
            end

            // Initialize combo to zero
            INIT_COMBO: begin
                ram_addr = 1'b1;
                ram_din = 17'b0;
                ram_write_en = 1'b1;
            end

            // Wait for a new category
            IDLE: begin
                ready = 1'b1;
            end

            // Read previous score
            READ_SCORE, WAIT_SCORE: begin
                ram_addr = 1'b0;
            end

            // Read previous combo
            READ_COMBO, WAIT_COMBO: begin
                ram_addr = 1'b1;
            end

            // Write updated score
            WRITE_SCORE: begin
                ram_addr = 1'b0;
                ram_din = new_score;
                ram_write_en = 1'b1;
            end

            // Write updated combo
            WRITE_COMBO: begin
                ram_addr = 1'b1;
                ram_din = {13'b0, new_combo};
                ram_write_en = 1'b1;
            end

            default: begin
                ram_addr = 1'b0;
            end

        endcase
    end


    // ------------------------------------------------
    // FSM state transitions and registers
    // ------------------------------------------------

    always_ff @(posedge clk or posedge reset) begin

        if (reset) begin
            state <= INIT_SCORE;

            category_reg <= 80'b0;

            old_score <= 17'b0;
            old_combo <= 4'b0;

            new_score <= 17'b0;
            new_combo <= 4'b0;

            score_value <= 17'b0;
            combo_value <= 4'b0;

            done <= 1'b0;
        end

        else begin

            // done is a one-clock-cycle pulse
            done <= 1'b0;

            case (state)

                // Initialize RAM
                INIT_SCORE: begin
                    state <= INIT_COMBO;
                end

                INIT_COMBO: begin
                    state <= IDLE;
                end

                // Wait for SPI category
                IDLE: begin
                    if (category_valid) begin
                        category_reg <= category;
                        state <= READ_SCORE;
                    end
                end

                // Read score from RAM
                READ_SCORE: begin
                    state <= WAIT_SCORE;
                end

                WAIT_SCORE: begin
                    old_score <= ram_dout;
                    state <= READ_COMBO;
                end

                // Read combo from RAM
                READ_COMBO: begin
                    state <= WAIT_COMBO;
                end

                WAIT_COMBO: begin
                    old_combo <= ram_dout[3:0];
                    state <= CALCULATE;
                end

                // Calculate updated score and combo
                CALCULATE: begin
                    new_score <= calculated_score;
                    new_combo <= calculated_combo;
                    state <= WRITE_SCORE;
                end

                // Write updated score to RAM
                WRITE_SCORE: begin
                    state <= WRITE_COMBO;
                end

                // Write updated combo to RAM
                WRITE_COMBO: begin

                    score_value <= new_score;
                    combo_value <= new_combo;

                    done <= 1'b1;
                    state <= IDLE;

                end

                default: begin
                    state <= INIT_SCORE;
                end

            endcase
        end
    end

endmodule
