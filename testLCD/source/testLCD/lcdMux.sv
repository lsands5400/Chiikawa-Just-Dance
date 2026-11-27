// Lindsey Sands
// lsands@g.hmc.edu
// 11-19-2026
// This is the mux for selecting the lcd output. 
module lcdMux(input logic  lcdSel,
                input logic lcd1,
                input logic lcd2,
                output logic    lcdOut);
    assign lcdOut = lcdSel ? lcd1 : lcd2;
endmodule