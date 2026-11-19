// Lindsey Sands
// lsands@g.hmc.edu
// 11-15-2026
// This is the testbench for the address mux. 
module addrMux_tb();
    logic 		addrSel, clk;
	logic 		addr1, addr2, addrOut;
    
    addrMux dut (
		.addrSel(addrSel), 
		.addr1(addr1), 
        .addr2(addr2), 

        .addrOut(addrOut)
    );

	// generate clock
    always begin
        clk = 0; #5;
        clk = 1; #5;
    end

    initial begin
	addrSel = 0;
    addr1 = 1'b1;
    addr2 = 1'b0;
	
	#10;                        // wait required time
	assert (addrOut == 8'h00)       // check outputs
	else 
		$error("Address Mux test 1 failed."); 
	
	addrSel = 1;
	#10;                        // wait required time
	assert (addrOut == 8'h01)       // check outputs
	else 
		$error("Address Mux test 2 failed."); 
    $finish;
    end
endmodule