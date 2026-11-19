// Lindsey Sands
// lsands@g.hmc.edu
// 11-15-2026
// This is the testbench for the justDance module. 
module justDance_tb();
    logic 		category;
		logic 		start;
    logic       lcd;
		logic int_osc;
    
    justDance dut (
		.start(start), 
		.category(category), 

        .lcd(lcd)
    );

    // TODO: Put proper assert values in

	// generate clock
    HSOSC #(.CLKHF_DIV(2'b01))
		clk (.CLKHFPU(1'b1), .CLKHFEN(1'b1), .CLKHF(int_osc));

    initial begin
    // score = 0, combo = 0
	category = 80'h50_65_72_66_65_63_74;
	#10;                        // wait required time
	// assert (lcd == 0'h)       // check outputs
	// else 
	// 	$error("Perfect test failed."); 

    // score = 3000, combo = 0
    category = 80'h47_6F_6F_64;
	#10;                        // wait required time
	// assert (lcd == )       // check outputs
	// else 
	// 	$error("Good test failed."); 
	
    // score = 5000, combo = 0
	category = 80'h4F_4B;
	#10;                        // wait required time
	// assert (lcd == 0')       // check outputs
	// else 
	// 	$error("OK test failed.");

    // score = 6000, combo = 0
    category = 80'h4D_69_73_73;
	#10;                        // wait required time
	// assert (lcd == 0')       // check outputs
	// else 
	// 	$error("Miss test failed.");
        
    // score = 6000, combo = 0
    category = 80'h50_65_72_66_65_63_74;
	#10;                        // wait required time
	// assert (lcd == 0')       // check outputs
	// else 
	// 	$error("Perfect combo test 1 failed.");

    // score = 9000, combo = 0
    category = 80'h50_65_72_66_65_63_74;
	#10;                        // wait required time
	// assert (lcd == 0')       // check outputs
	// else 
	// 	$error("Perfect combo test 2 failed.");

    // score = 15000, combo = 1
    category = 80'h50_65_72_66_65_63_74;
	#10;                        // wait required time
	// assert (lcd == 0')       // check outputs
	// else 
	// 	$error("Perfect combo test 3 failed.");
    
    // score = 24000, combo = 2
    category = 80'h50_65_72_66_65_63_74;
	#10;                        // wait required time
	// assert (lcd == 0')       // check outputs
	// else 
	// 	$error("Perfect combo test 4 failed.");
    end
endmodule