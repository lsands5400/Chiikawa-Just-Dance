
module top (
    input  logic reset,

    output logic lcd_rs,
    output logic lcd_rw,
    output logic lcd_e,
    output logic [3:0] lcd_db
);

    logic clk_12mhz;
	
	// Internal High Speed Oscillator generates clock signal at 
    // 12 MHz
    HSOSC #(.CLKHF_DIV(2'b10))
		clk (.CLKHFPU(1'b1), .CLKHFEN(1'b1), .CLKHF(int_osc));

    // LCD Hello World controller
    lcd_hello_world #(
        .CLK_HZ(12000000)
    ) lcd_inst (
        .clk(innt_osc),
        .reset(reset),

        .lcd_rs(lcd_rs),
        .lcd_rw(lcd_rw),
        .lcd_e(lcd_e),
        .lcd_db(lcd_db)
    );

endmodule
