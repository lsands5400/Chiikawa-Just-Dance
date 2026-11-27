// Lindsey Sands
// lsands@g.hmc.edu
// 11-15-2026
// This is the song selection FSM. 
module songFSM(input logic songSelect,
                input logic start,
                output logic songSelLCD, 
                output logic song);
    typedef enum logic [2:0] {S0, S1, S2} statetype;

    statetype state, nextstate;

    always_ff@(posedge clk) begin
        if (en)
            state <= nextstate;
        else
            state <= state;
    end

    always_comb
        case(state)
            // select song
            S0:
                if (songSelect) begin
                    nextstate = S1;
                end
                else begin
                    nextstate = S0;
                end
            S1:
                if (songSelect) begin
                    nextstate = S2;
                end
                else begin
                    nextstate = S1;
                end
                // if (start) begin
                    // song = 0;
                    // songSelLCD = //TODO: decide LCD message
                // end
            S2:
                if (songSelect) begin
                    nextstate = S0;
                end
                else begin
                    nextstate = S2;
                end
                // if (start) begin
                    // song = 1;
                    // songSelLCD = //TODO: decide LCD message
                // end
        endcase

endmodule