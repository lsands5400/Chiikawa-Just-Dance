// Lindsey Sands
// lsands@g.hmc.edu
// 11-15-2026
// This is the song selection FSM. 

module songFSM (
    input  logic clk,
    input  logic reset,
    input  logic en,
    input  logic songSelect,
    input  logic startButton,

    output logic [319:0] songSelLCD,
    output logic start,
    output logic song
);

    typedef enum logic [1:0] {
        S0, S1, S2
    } statetype;

    statetype state, nextstate;

    logic startButtonPrev;
    logic startPulse;

    // Rising edge detection
    always_ff @(posedge clk) begin
        if (reset)
            startButtonPrev <= 1'b0;
        else
            startButtonPrev <= startButton;
    end

    assign startPulse = startButton && !startButtonPrev;

    // State register
    always_ff @(posedge clk) begin
        if (reset)
            state <= S0;
        else if (en)
            state <= nextstate;
    end

    // Next-state logic
    always_comb begin
        nextstate = state;

        case (state)
            S0: begin
                if (songSelect)
                    nextstate = S1;
            end

            S1: begin
                if (songSelect && !startPulse)
                    nextstate = S2;
            end

            S2: begin
                if (songSelect && !startPulse)
                    nextstate = S0;
            end

            default: nextstate = S0;
        endcase
    end

    // Output logic
    always_comb begin
        start = 1'b0;
        song = 1'b0;
        songSelLCD = {20{8'h20}};

        case (state)

            // S0: Select a song
            S0: begin
                songSelLCD[159:56] = {
                    8'h53, // S
                    8'h65, // e
                    8'h6C, // l
                    8'h65, // e
                    8'h63, // c
                    8'h74, // t
                    8'h20, // space
                    8'h61, // a
                    8'h20, // space
                    8'h73, // s
                    8'h6F, // o
                    8'h6E, // n
                    8'h67  // g
                };
            end

            // S1: Morning Dance
            S1: begin
                songSelLCD[159:56] = {
                    8'h4D, // M
                    8'h6F, // o
                    8'h72, // r
                    8'h6E, // n
                    8'h69, // i
                    8'h6E, // n
                    8'h67, // g
                    8'h20, // space
                    8'h44, // D
                    8'h61, // a
                    8'h6E, // n
                    8'h63, // c
                    8'h65  // e
                };

                song = 1'b0;

                if (startPulse)
                    start = 1'b1;
            end

            // S2: Pajama Party
            S2: begin
                songSelLCD[159:56] = {
                    8'h50, // P
                    8'h61, // a
                    8'h6A, // j
                    8'h61, // a
                    8'h6D, // m
                    8'h61, // a
                    8'h20, // space
                    8'h50, // P
                    8'h61, // a
                    8'h72, // r
                    8'h74, // t
                    8'h79  // y
                };

                song = 1'b1;

                if (startPulse)
                    start = 1'b1;
            end

            default: begin
                songSelLCD = {20{8'h20}};
            end

        endcase
    end

endmodule
