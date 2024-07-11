`timescale 1ns/1ns

module bound_flasher_tb();

reg clk, rst, flick;
wire [15:0] led;
bound_flasher bf1(clk, rst, flick, led);

initial 
begin

	clk = 0;
	rst = 1;
	flick = 0;

	#2;
	rst = 0;

	#6;
	rst = 1;

	#24;
	flick = 1;

	#500 rst = 0;

	#10 rst = 1;

	#6;
	flick = 0;

	#2;

	#290;

	#2;
	flick = 1;
	rst = 0;

	#6;
	rst = 1;

	#2;
	flick = 0;

	#60;

	#2;
	flick = 1;

	#6;
	flick = 0;
	rst = 1;

	#300; 
	flick = 1;

	#200; 
	rst = 0;

	#3
	rst = 1;

	#100 
	flick = 0;

	#100 
	flick = 1;

	#100 
	flick = 0;

	#2000 $finish;
end

initial begin
	$recordfile ("waves");
	$recordvars ("depth=0", bound_flasher_tb);
end

always #5 clk = ~clk;

endmodule