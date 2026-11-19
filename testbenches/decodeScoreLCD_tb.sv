// Lindsey Sands
// lsands@g.hmc.edu
// 11-15-2026
// This is the testbench for the score decoder. 
module decodeScoreLCD_tb();
    logic 		score;
	logic 		b;
    
    decodeScoreLCD dut (
		.score(score), 

        .b(b)
    );

	// generate clock
    always begin
        clk = 0; #5;
        clk = 1; #5;
    end

    initial begin
	score = 13000;
	#10;                        // wait required time
	assert (b == 0011_0001_0011_0011_0011_0000_0011_0000_0011_0000)       // check outputs
	else 
		$error("Score decoder test 1 failed."); 

    score = 2000;
	#10;                        // wait required time
	assert (b == 0011_0010_0011_0000_0011_0000_0011_0000)       // check outputs
	else 
		$error("Score decoder test 2 failed."); 
	
	score = 56000;
	#10;                        // wait required time
	assert (b == 0011_0101_0011_0110_0011_0000_0011_0000_0011_0000)       // check outputs
	else 
		$error("Score decoder test 3 failed."); 
    end
endmodule