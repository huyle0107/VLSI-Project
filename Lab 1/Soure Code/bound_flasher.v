module bound_flasher(
  input clk,
  input rst,
  input flick,
  output reg [15:0] LED
);

parameter 
    NORMAL    = 2'b00,
    UP        = 2'b01,
    DOWN      = 2'b10,
    KICK_BACK = 2'b11;

parameter 
    INIT              = 4'b0001,
    ZERO_TO_FIVE      = 4'b0010,
    OFF_TO_ZERO       = 4'b0011,
    ZERO_TO_TEN       = 4'b0100,
    OFF_TO_FIVE       = 4'b0101,
    FIVE_TO_FIFTEEN   = 4'b0110,
    BLINK             = 4'b0111,
    BLINK_RESET       = 4'b1000;

integer COUNTER;
integer i;

reg [1:0] exe;
reg [3:0] current_state, next_state;

always @(posedge clk or negedge rst)
begin
	if(!rst) begin
        current_state <= INIT;
        COUNTER <= -1;
    end
	else begin
        current_state <= next_state;
		if(exe == UP) COUNTER <= COUNTER + 1;
		else if (exe == NORMAL) COUNTER <= COUNTER;
		else COUNTER <= COUNTER - 1;
	end
end

always @(COUNTER or current_state)
begin
	if(COUNTER == -1) LED = {16{1'b0}};
	else
        if (current_state == BLINK_RESET) LED = {16{1'b1}};
        else begin
            for(i = 0; i < 16; i = i + 1)
                begin
                    if (current_state == INIT) LED = {16{1'b0}};
                    else if(i <= COUNTER) LED[i] = 1'b1;
                    else LED[i] = 1'b0;
                end
        end
end

always @(current_state or flick or COUNTER) begin
	exe = 2'b00;

	case(current_state)
        INIT: exe = (COUNTER >= 0) ? DOWN : (flick ? UP : NORMAL);

        ZERO_TO_FIVE: exe = (COUNTER < 5) ? UP : DOWN;

        OFF_TO_ZERO: exe = (COUNTER >= 0) ? DOWN : UP;

        ZERO_TO_TEN: exe = (flick && (COUNTER == 5 || COUNTER == 10)) ? KICK_BACK : 
                            ((COUNTER == 10) ? DOWN : UP);

        OFF_TO_FIVE: exe = (COUNTER > 4) ? DOWN : UP;

        FIVE_TO_FIFTEEN: exe = (flick && (COUNTER == 5 || COUNTER == 10)) ? KICK_BACK : 
                                ((COUNTER == 15) ? DOWN : UP);

        BLINK, BLINK_RESET: exe = (COUNTER >= 0) ? DOWN : UP;
        
        default: exe = NORMAL;
	endcase
end

always @(current_state or exe)
begin
    case (current_state)
        INIT: next_state = (exe == UP) ? ZERO_TO_FIVE : INIT;

        ZERO_TO_FIVE: next_state = (exe == UP) ? ZERO_TO_FIVE : OFF_TO_ZERO;

        OFF_TO_ZERO: next_state = (exe == DOWN) ? OFF_TO_ZERO : ZERO_TO_TEN;

        ZERO_TO_TEN: next_state = (exe == KICK_BACK) ? OFF_TO_ZERO : 
                                   ((exe == DOWN) ? OFF_TO_FIVE : ZERO_TO_TEN);

        OFF_TO_FIVE: next_state = (exe == DOWN) ? OFF_TO_FIVE : FIVE_TO_FIFTEEN;

        FIVE_TO_FIFTEEN: next_state = (exe == KICK_BACK) ? OFF_TO_FIVE : 
                                       ((exe == DOWN) ? BLINK : FIVE_TO_FIFTEEN);

        BLINK: next_state = (exe == DOWN) ? BLINK : BLINK_RESET;

        BLINK_RESET: next_state = (exe == DOWN) ? BLINK_RESET : INIT;

        default: next_state = INIT;
    endcase
end
endmodule
