module top(
    input wire OSC_50,
    input wire [3:0] KEY,               // ~KEY[0] toggles reset
                                        // ~KEY[1] is manual clock
    output wire [6:0] HEX0,             // HEX1-HEX0 shows bus value
    output wire [6:0] HEX1,
	 output wire [6:0] HEX2,
	 output wire [6:0] HEX3,
	 output wire [6:0] HEX4,
	 output wire [6:0] HEX5,
	 output wire [6:0] HEX6,
    output wire [8:0] LED_GREEN);       // LED_GREEN[8] shows reset

    wire reset;
    wire clock;                         // clock signal for circuit

    wire [7:0] bus;
	 
    wire element_write;
	 wire [7:0] element_out;

    wire [7:0] i_out;
    wire i_write, i_drive;

    wire [7:0] plus1_out;
    wire plus1_drive;
	 
	 wire [7:0] plus13_out;
	 wire plus13_drive;
	 
	 wire [7:0] minus13_out;
	 wire minus13_drive;

    wire address_write;
    wire memory_write;
    wire [7:0] memory_out;
    wire memory_drive;

    wire greater109_out;
    wire equal0_out;

    reset_toggle u1 (OSC_50, ~KEY[0], reset, LED_GREEN[8]); // maintains the reset signal
    clocks u2 (OSC_50, ~KEY[1], clock);

    register element (clock, reset, element_write, bus, element_out);
    register i (clock, reset, i_write, bus, i_out);

    greater109 u10 (element_out, greater109_out);
    equal0 u11 (element_out, equal0_out);
    plus1 u12 (i_out, plus1_out);
	 plus13 u13 (element_out, plus13_out);
	 minus13 u50 (element_out, minus13_out);

    ram u9 (bus, ~address_write, clock, bus, memory_write, memory_out);

    tristate plus13t (plus13_out, bus, plus13_drive);
    tristate minus13t (minus13_out, bus, minus13_drive);
    tristate plus1t (plus1_out, bus, plus1_drive);
    tristate memoryt (memory_out, bus, memory_drive);
	 tristate i_drivet (i_out, bus, i_drive);

    hexdigit u14 (bus[3:0], HEX0);      // display bus on HEX0, HEX1 for debugging
    hexdigit u15 (bus[7:4], HEX1);
	 
	 hexdigit u99 (i_out[3:0], HEX2);      // display bus on HEX0, HEX1 for debugging
    hexdigit u95 (i_out[7:4], HEX3);
	 //hexdigit u85 (state, HEX4);
	 hexdigit u67 (element_out[3:0], HEX5);
	 hexdigit u45 (element_out[7:4], HEX6);


				 
	 control u18 (clock, reset, greater109_out, equal0_out, element_write, i_write, i_drive, 
		plus13_drive, minus13_drive, plus1_drive, memory_write, memory_drive, address_write);

endmodule
