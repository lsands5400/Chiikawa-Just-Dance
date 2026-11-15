// Lindsey Sands
// lsands@g.hmc.edu
// 11-15-2026
// This is the testbench for the totalScore module.  
module totalScore_tb();
    logic 		currScore;
    logic       scoreAddend;
    logic       total;
	logic 		addrSel;
    
    totalScore dut (
		.currScore(currScore), 
        .scoreAddend(scoreAddend),

        .addrSel(addrSel),
        .total(total) 
    );

	// generate clock
    always begin
        clk = 0; #5;
        clk = 1; #5;
    end

    initial begin
	currScore = 13000;
    scoreAddend = 3000;
	#10;                        // wait required time
	assert (total == 16000)       // check outputs
	else 
		$error("Total score test 1 failed."); 

    currScore = 2000;
    scoreAddend = 1000;
	#10;                        // wait required time
	assert (total == 3000)       // check outputs
	else 
		$error("Total score test 2 failed."); 
	
	currScore = 2000;
    scoreAddend = 0;
	#10;                        // wait required time
	assert (total == 2000)       // check outputs
	else 
		$error("Total score test 3 failed."); 
    end
    $finish
endmodule