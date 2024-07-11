module bound_flasher(
  input clk,
  input rst,
  input flick,
  output reg [15:0] LED
);

integer COUNTER;
integer i;

parameter NORMAL    = 2'b00;
parameter UP        = 2'b01;
parameter DOWN      = 2'b10;
parameter KICK_BACK = 2'b11;

parameter INIT              = 4'b0001;
parameter ZERO_TO_FIVE      = 4'b0010;
parameter OFF_TO_ZERO       = 4'b0011;
parameter ZERO_TO_TEN       = 4'b0100;
parameter OFF_TO_FIVE       = 4'b0101;
parameter FIVE_TO_FIFTEEN   = 4'b0110;
parameter BLINK             = 4'b0111;
parameter BLINK_RESET       = 4'b1000;

reg [1:0] exe;
reg [3:0] current_state;
reg [3:0] next_state;

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

always @(current_state or exe)
begin
	case (current_state)
		INIT: begin
			if(exe == UP) next_state = ZERO_TO_FIVE;
			else next_state = INIT;
		end
		
		ZERO_TO_FIVE: begin
			if(exe == UP) next_state = ZERO_TO_FIVE;
			else next_state = OFF_TO_ZERO;
		end
		
		OFF_TO_ZERO: begin
			if(exe == DOWN) next_state = OFF_TO_ZERO;
			else next_state = ZERO_TO_TEN;
		end
		
		ZERO_TO_TEN: begin
			if(exe == KICK_BACK) next_state = OFF_TO_ZERO;		
			else if(exe == DOWN) next_state = OFF_TO_FIVE;
			else next_state = ZERO_TO_TEN;
		end
		
		OFF_TO_FIVE: begin
			if(exe == DOWN) next_state = OFF_TO_FIVE;
			else next_state = FIVE_TO_FIFTEEN;
		end
		
		FIVE_TO_FIFTEEN: begin
			if(exe == KICK_BACK) next_state = OFF_TO_FIVE;
			else if(exe == DOWN) next_state = BLINK;
			else next_state = FIVE_TO_FIFTEEN;
		end

        BLINK: begin
            if (exe == DOWN) next_state = BLINK;
            else if(exe == UP) next_state = BLINK_RESET;
        end

        BLINK_RESET: begin
            if (exe == DOWN) next_state = BLINK_RESET;
            else next_state = INIT;
        end
		
		default: next_state = INIT;
	endcase
end

always @(current_state or flick or COUNTER) begin
	exe = 2'b00;

	case(current_state)
        INIT: begin
            if(COUNTER >= 0) exe = DOWN;
            else if(flick) exe = UP;
            else exe = NORMAL;
        end
        
        ZERO_TO_FIVE: begin
            if(COUNTER < 5) exe = UP;
            else exe = DOWN;
        end
        
        OFF_TO_ZERO: begin
            if(COUNTER >= 0) exe = DOWN;
            else exe = UP;
        end
        
        ZERO_TO_TEN: begin
            if(flick && (COUNTER == 5 || COUNTER == 10)) exe = KICK_BACK;
            else if(COUNTER == 10) exe = DOWN;
            else exe = UP;
        end
        
        OFF_TO_FIVE: begin
            if(COUNTER > 4) exe = DOWN;
            else exe = UP;
        end
        
        FIVE_TO_FIFTEEN: begin
            if(flick && (COUNTER == 5 || COUNTER == 10)) exe = KICK_BACK;
            else if(COUNTER == 15) exe = DOWN;
            else exe = UP;
        end

        BLINK: begin
            if (COUNTER >= 0) exe = DOWN;
            else exe = UP;
        end

        BLINK_RESET: begin
            if (COUNTER >= 0) begin 
                COUNTER <= 0;
                exe = DOWN;
            end
            else begin 
                for(i = 0; i < 2; i = i + 1) begin
                    if(i == 1) begin
                        COUNTER <= -1;
                        exe = UP;
                    end
                end
            end
        end
        
        default: exe = NORMAL;
	endcase
end

always @(COUNTER or current_state)
begin
	if(COUNTER == -1)
        if (current_state == BLINK_RESET) LED <= {16{1'b0}};
        else begin
            for(i = 0; i < 16; i = i + 1) LED[i] = 0;
        end
	else
        if (current_state == BLINK_RESET) LED <= {16{1'b1}};
        else begin
            for(i = 0; i < 16; i = i + 1)
                begin
                    if (current_state == INIT) LED <= {16{1'b0}};
                    else if(i <= COUNTER) LED[i] = 1'b1;
                    else LED[i] = 1'b0;
                end
        end
end
endmodule
