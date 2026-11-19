// Lindsey Sands
// lsands@g.hmc.edu
// 11-15-2026
// This is the testbench for the scoreConverter module.  
module scoreConverter_tb();
    logic 		clk, same, addrSel;
    logic [79:0]       chars;
    logic [3:0]       comboIn, comboOut;
    logic [13:0]      scoreAddend;
    
    scoreConverter dut (
		.clk(clk), 
        .chars(chars),
        .comboIn(comboIn),
        .same(same),

        .addrSel(addrSel),
        .scoreAddend(scoreAddend),
        .comboOut(comboOut)
    );

	// generate clock
    always begin
        clk = 0; #5;
        clk = 1; #5;
    end

    initial begin
    comboIn = 0;
    same = 0;
    chars = 80'h50_65_72_66_65_63_74_20_20_20;
	#10;                        // wait required time
	assert (scoreAddend == 3000)       // check outputs
	else 
		$error("Score converter test 1 failed."); 

    chars = 80'h47_6F_6F_64_20_20_20_20_20_20;
	#10;                        // wait required time
	assert (scoreAddend == 2000)       // check outputs
	else 
		$error("Score converter test 2 failed."); 
	
	chars = 80'h4F_4B_20_20_20_20_20_20_20_20;
	#10;                        // wait required time
	assert (scoreAddend == 1000)       // check outputs
	else 
		$error("Score converter test 3 failed.");

    chars = 80'h4D_69_73_73_20_20_20_20_20_20;
	#10;                        // wait required time
	assert (scoreAddend == 0)       // check outputs
	else 
		$error("Score converter test 4 failed."); 

    chars = 80'h50_65_72_66_65_63_74_20_20_20;
	#10;                        // wait required time
	assert (scoreAddend == 3000)       // check outputs
	else 
		$error("Score converter test 5a failed."); 
    assert (comboOut == 0)       // check outputs
	else 
		$error("Score converter test 5b failed.");

    comboIn = 1;
    chars = 80'h50_65_72_66_65_63_74_20_20_20;
	#10;                        // wait required time
	assert (scoreAddend == 3000)       // check outputs
	else 
		$error("Score converter test 6 failed."); 
    assert (comboOut == 0)       // check outputs
	else 
		$error("Score converter test 6b failed.");

    comboIn = 1;
		same = 1;
    chars = 80'h50_65_72_66_65_63_74_20_20_20;
	#10;                        // wait required time
	assert (scoreAddend == 6000)       // check outputs
	else 
		$error("Score converter test 7 failed."); 
    assert (comboOut == 2)       // check outputs
	else 
		$error("Score converter test 7b failed.");

    comboIn = 2;
    same = 0;
    chars = 80'h50_65_72_66_65_63_74_20_20_20;
	#10;                        // wait required time
	assert (scoreAddend == 3000)       // check outputs
	else 
		$error("Score converter test 8 failed."); 
    assert (comboOut == 0)       // check outputs
	else 
		$error("Score converter test 8b failed.");

    comboIn = 2;
    same = 1;
    chars = 80'h50_65_72_66_65_63_74_20_20_20;
	#10;                        // wait required time
	assert (scoreAddend == 9000)       // check outputs
	else 
		$error("Score converter test 8 failed."); 
    assert (comboOut == 3)       // check outputs
	else 
		$error("Score converter test 8b failed.");
		$finish;
    end
endmodule