// Lindsey Sands
// lsands@g.hmc.edu
// 11-15-2026
// This is the testbench for the 
// character array decoder. 
// Lindsey Sands
// lsands@g.hmc.edu
// 11-15-2026
// This is the testbench for the address mux. 
module decodeCharArr_tb();
    logic 		chars;
	logic 		dots;
    
    decodeCharArr dut (
		.chars(chars), 

        .dots(dots), 
    );

	// generate clock
    always begin
        clk = 0; #5;
        clk = 1; #5;
    end

    initial begin
    // "OK"
	chars = 0'h4F_4B;
	#10;                        // wait required time
	assert (dots == 0'b0100_1111_0100_1011)       // check outputs
	else 
		$error("Char[] decoder test 1 failed."); 
	
    // "Song"
	chars = 0'h53_6F_6E_67;
	#10;                        // wait required time
	assert (dots == 0'b0101_0011_0110_1111_0110_1110_0110_0111)       // check outputs
	else 
		$error("Char[] decoder test 2 failed."); 
    end
    $finish
endmodule