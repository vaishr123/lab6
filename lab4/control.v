module control(
    input wire clock,
    input wire reset,
	 
    input wire greater109_out,
    input wire equal0_out,
	 
    output reg element_write,
    output reg i_write,
    output reg i_drive,
    output reg plus13_drive,
	 output reg minus13_drive,
	 output reg plus1_drive,
    output reg memory_write,
    output reg memory_drive,
    output reg address_write);

    parameter state_reset =     4'h0;
    parameter state_read1 =     4'h1;
    parameter state_read2 =     4'h2;
    parameter state_compare =   4'h3;
	 parameter state_subtract =  4'h4;
	 parameter state_add = 		  4'h5;
	 parameter state_plus1 = 	  4'h6;
    parameter state_end =       4'h7;

    reg [3:0] state;
    reg [3:0] next_state;

    always @* begin
		element_write = 1'b0;
		i_write = 1'b0;
		i_drive = 1'b0;
		plus13_drive = 1'b0;
		minus13_drive = 1'b0;
		plus1_drive = 1'b0;
		memory_write = 1'b0;
		memory_drive = 1'b0;
		address_write = 1'b0;
      next_state = state_reset;

	case (state)

	    state_reset: begin
		next_state = state_read1;
	    end

	    state_read1: begin
		// transfer i to memory address
		i_drive = 1'b1;
		address_write = 1'b1;
		next_state = state_read2;
	    end

	    state_read2: begin
		// read memory[i]
		memory_drive = 1'b1;
		element_write = 1'b1;
		next_state = state_compare;
	    end

	    state_compare: begin
		// is memory[i] more than the current max?
		if (greater109_out == 1'b1) begin
		    next_state = state_subtract;
		end 
		else begin
		    next_state = state_add;
		end
	    end
	    state_subtract: begin
		//subtracts 13
		minus13_drive = 1'b1;
		memory_write = 1'b1;
		next_state = state_plus1;
	    end
		 
		 state_add: begin
		 //adds 13
		 plus13_drive = 1'b1;
		 memory_write = 1'b1;
		 next_state = state_plus1;
		 end

	    state_plus1: begin
		// increment i
		 plus1_drive = 1'b1;
		i_write = 1'b1;
		if (equal0_out == 1'b1) begin
			 next_state = state_end;
		end else begin
			 next_state = state_read1;
		end 
	   end

	   state_end: begin
			 next_state = state_end;
	   end

	endcase
    end

    always @(posedge clock) begin
        if (reset == 1'b1) begin
            state <= state_reset;
        end else begin
            state <= next_state;
        end
    end

endmodule
