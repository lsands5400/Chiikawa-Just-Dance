
module lcd_hello_world #(
    parameter integer CLK_HZ = 12000000
)(
    input  logic clk,
    input  logic reset,

    output logic lcd_rs,
    output logic lcd_rw,
    output logic lcd_e,
    output logic [3:0] lcd_db
);

    // Timing parameters
    localparam integer POWER_WAIT = CLK_HZ / 20;     // 50 ms
    localparam integer SHORT_WAIT = CLK_HZ / 10000;  // 100 us
    localparam integer LONG_WAIT  = CLK_HZ / 500;    // 2 ms
	localparam integer INIT_WAIT = CLK_HZ / 200; // 5 ms

    typedef enum logic [2:0] {
        POWER_UP,
        SETUP,
        ENABLE_HIGH,
        ENABLE_LOW,
        WAIT_TIME,
        FINISHED
    } state_t;

    state_t state;

    logic [31:0] timer;
    logic [5:0] index;
    logic nibble_phase;

    logic [7:0] current_byte;
    logic current_rs;
    logic [3:0] current_nibble;
    logic special_nibble;

    // LCD message sequence:
    // 0-3: Special initialization nibbles
    // 4: Function set
    // 5: Display ON
    // 6: Clear display
    // 7: Entry mode
    // 8-19: HELLO WORLD!
    // 20: Move cursor to second line
    // 21-35: ICE40 UP5K TEST

    function automatic [7:0] get_data(input logic [5:0] i);
        case (i)
            4:  get_data = 8'h28; // 4-bit, 2-line, 5x8
            5:  get_data = 8'h0C; // Display ON
            6:  get_data = 8'h01; // Clear display
            7:  get_data = 8'h06; // Entry mode

            8:  get_data = "H";
            9:  get_data = "E";
            10: get_data = "L";
            11: get_data = "L";
            12: get_data = "O";
            13: get_data = " ";
            14: get_data = "W";
            15: get_data = "O";
            16: get_data = "R";
            17: get_data = "L";
            18: get_data = "D";
            19: get_data = "!";

            20: get_data = 8'hC0; // Second line

            21: get_data = "I";
            22: get_data = "C";
            23: get_data = "E";
            24: get_data = "4";
            25: get_data = "0";
            26: get_data = " ";
            27: get_data = "U";
            28: get_data = "P";
            29: get_data = "5";
            30: get_data = "K";
            31: get_data = " ";
            32: get_data = "T";
            33: get_data = "E";
            34: get_data = "S";
            35: get_data = "T";

            default: get_data = 8'h00;
        endcase
    endfunction

    function automatic logic get_rs(input logic [5:0] i);
        if (i >= 8 && i <= 19)
            get_rs = 1'b1;
        else if (i >= 21 && i <= 35)
            get_rs = 1'b1;
        else
            get_rs = 1'b0;
    endfunction

    always_comb begin
        current_byte = get_data(index);
        current_rs = get_rs(index);

        // First four initialization operations are single nibbles.
        special_nibble = (index < 4);

        case (index)
            0, 1, 2: current_nibble = 4'h3;
            3:       current_nibble = 4'h2;
            default: begin
                if (!nibble_phase)
                    current_nibble = current_byte[7:4];
                else
                    current_nibble = current_byte[3:0];
            end
        endcase
    end

    // R/W is permanently low: write only.
    assign lcd_rw = 1'b0;

    always_ff @(posedge clk) begin
        if (reset) begin
            state        <= POWER_UP;
            timer        <= 0;
            index        <= 0;
            nibble_phase <= 0;

            lcd_rs       <= 0;
            lcd_e        <= 0;
            lcd_db       <= 0;
        end
        else begin
            case (state)

                // Wait for LCD power supply to stabilize.
                POWER_UP: begin
                    lcd_e <= 0;

                    if (timer >= POWER_WAIT - 1) begin
                        timer <= 0;
                        state <= SETUP;
                    end
                    else begin
                        timer <= timer + 1;
                    end
                end

                // Put data and control signals on LCD pins.
                SETUP: begin
                    lcd_rs <= special_nibble ? 0 : current_rs;
                    lcd_db <= current_nibble;
                    lcd_e  <= 0;

                    timer <= 0;
                    state <= ENABLE_HIGH;
                end

                // Enable pulse.
                ENABLE_HIGH: begin
					lcd_e <= 1;

					if (timer >= 11) begin
						timer <= 0;
						state <= ENABLE_LOW;
					end
					else begin
						timer <= timer + 1;
					end
				end

                // Falling edge latches the nibble.
                ENABLE_LOW: begin
                    lcd_e <= 0;

                    if (timer >= 2) begin
                        timer <= 0;
                        state <= WAIT_TIME;
                    end
                    else begin
                        timer <= timer + 1;
                    end
                end

                // Allow LCD controller to process the data.
                WAIT_TIME: begin

                    if (timer >= (
						index == 0 ? INIT_WAIT :
						index == 6 ? LONG_WAIT :
									 SHORT_WAIT
					) - 1) begin

                        timer <= 0;

                        if (special_nibble) begin
                            if (index == 3) begin
                                index        <= 4;
                                nibble_phase <= 0;
                            end
                            else begin
                                index <= index + 1;
                            end

                            state <= SETUP;
                        end

                        else if (!nibble_phase) begin
                            nibble_phase <= 1;
                            state <= SETUP;
                        end

                        else begin
                            nibble_phase <= 0;

                            if (index == 35) begin
                                state <= FINISHED;
                            end
                            else begin
                                index <= index + 1;
                                state <= SETUP;
                            end
                        end
                    end
                    else begin
                        timer <= timer + 1;
                    end
                end

                // Keep the message on the display.
                FINISHED: begin
                    lcd_e <= 0;
                    lcd_rs <= 0;
                end

                default: state <= POWER_UP;

            endcase
        end
    end

endmodule
