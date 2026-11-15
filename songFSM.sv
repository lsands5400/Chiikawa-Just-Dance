// Lindsey Sands
// lsands@g.hmc.edu
// 11-15-2026
// This is the song selection FSM. 
module songFSM(songSelect);
    typedef enum type {S0, S1, S2} statetype;
    statetype state, nextstate;
    always_comb
        case(state)
            // select song
            S0:

            S1:

            S2:

        endcase

endmodule