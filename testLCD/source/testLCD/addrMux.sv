// Lindsey Sands
// lsands@g.hmc.edu
// 11-14-2026
// This is the mux for selecting the read/write address. 
module addrMux(input logic  addrSel,
                input logic addr1,
                input logic addr2,
                output logic    addrOut);
    assign addrOut = addrSel ? addr1 : addr2;
endmodule