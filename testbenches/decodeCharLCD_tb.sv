// Lindsey Sands
// lsands@g.hmc.edu
// 11-15-2026
// This is the testbench for the character decoder. 
module decodeCharLCD_tb();
    logic 		char;
	logic 		b;
    
    decodeCharLCD dut (
		.char(char), 

        .b(b), 
    );

	// generate clock
    always begin
        clk = 0; #5;
        clk = 1; #5;
    end

    initial begin
    // "O"
	char = 0'h4F;
	#10;                        // wait required time
	assert (b == 0'b0100_1111)       // check outputs
	else 
		$error("Char decoder test 1 failed."); 

	// "K"
    char = 0'h4B;
	#10;                        // wait required time
	assert (b == 0'b0100_1011)       // check outputs
	else 
		$error("Char decoder test 2 failed."); 
	
    // "o"
	char = 0'h6F;
	#10;                        // wait required time
	assert (b == 0'b0110_1111)       // check outputs
	else 
		$error("Char decoder test 3 failed."); 

    // "n"
	char = 0'h6E;
	#10;                        // wait required time
	assert (b == 0'b0110_1110)       // check outputs
	else 
		$error("Char decoder test 4 failed."); 
    end
    $finish
endmodule