// Lindsey Sands
// lsands@g.hmc.edu
// 11-15-2026
// This is the testbench for the LCD mux. 
module lcdMux_tb();
    logic 		lcdSel, clk;
	logic 		lcd1, lcd2, lcdOut;
    
    lcdMux dut (
		.lcdSel(lcdSel), 
		.lcd1(lcd1), 
        .lcd2(lcd2), 

        .lcdOut(lcdOut)
    );

	// generate clock
    always begin
        clk = 0; #5;
        clk = 1; #5;
    end

    initial begin
	lcdSel = 0;
    lcd1 = 1'b1;
    lcd2 = 1'b0;
	
	#10;                        // wait required time
	assert (lcdOut == 8'h00)       // check outputs
	else 
		$error("LCD Mux test 1 failed."); 
	
	lcdSel = 1;
	#10;                        // wait required time
	assert (lcdOut == 8'h01)       // check outputs
	else 
		$error("LCD Mux test 2 failed."); 
    $finish;
    end
endmodule