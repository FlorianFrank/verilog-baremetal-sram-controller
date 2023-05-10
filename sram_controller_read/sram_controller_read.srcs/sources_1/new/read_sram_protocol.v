`timescale 1ns / 1ps
`include "state_machine_definitions.vh"

//% \addtogroup memctr Memory Controller
//% @{


//% @brief This module is responsible to set the timing of the cs and 
//% It sets the OE, WE, CS as well as the address and datalines accordingly. 
//% @author Florian Frank
//% @copyright University of Passau - Chair of Computer Engineering
module read_sram_protocol #(
	//% Clock frequency which drives this module (is required to calculate the right timing)
	parameter CLK_FREQUENCY=400, 
    parameter integer ADDRESS_BUS_SIZE=32,
    parameter integer DATA_BUS_SIZE=16,
    parameter integer CLOCK_CONFIG_WIDTH=16
	)(
	//% Input clock which drives this module.
	input wire clk,
	
	input wire reset, 
	
	input wire start, 				
   //% send one pulse (1 clock cycle of clk) to start the reading process
	input wire signal_start,

	output reg[DATA_BUS_SIZE-1:0] value,
	
	inout wire[DATA_BUS_SIZE-1:0] dlines,
	
	input wire[CLOCK_CONFIG_WIDTH-1] teleh,
	
	//% chip enable (connect this to the chip enable of the memory chip)
	output reg ce,			
   //% output enable (connect this to the chip enable of the memory chip)
	output reg oe,			
	//% this signal is raised for one clock cycle after the reading process is finished
    output reg signal_done = 0,
    
    output reg active, 
    
    output reg ready
	 
	);
	

	//% This parameter stores the time to wait between when reading from the memory (OE phase)
	//% e.g. tELEH (70ns) * 10 / ((10000/CLK_FREQUENCY))/ 2 (reaction only to the low -> high transision of the clock) = 14  
	//% So a counter needs to count up to 14 with a frequency of 400 MHz to satisfy the 70 ns OE phase
	parameter integer WAIT_TIME = teleh*10/((10000/CLK_FREQUENCY));
	
	//% This variable stores the timing counter to match the tELEH timing behavior.
   integer timing_ctr;

    //% This register specifies the current state of the state machine.
	 reg [2:0]state;
	 
	initial begin
		state <= `STATE_IDLE;
		timing_ctr <= WAIT_TIME;
	end
	

	integer finished_ctr = 0;
	 
    //% @brief The always block executes the state machine to set the OE and CE  values accordingly.
    always@(posedge clk) begin
        case (state)
				// Wait for incomming read request
            `STATE_IDLE: 
				begin
				
				if(start == 1) begin 
				active <= 1;
					signal_done <= 0;
				    oe <= 1;
                ce <= 1;
                if (signal_start == 1) 
					 begin
						  signal_done <= 0;
                    state <= `STATE_SET_CE;
                end
                end else active <= 0;
                ready <= 0;
            end
			
            `STATE_SET_CE: 
				begin
                ce <= 0;
                // delay could be inserted here if necessary using the STATE_DELAY
                // in combination with the next_state register
                
                // for the LAPIS FRAM, we don't need a delay here which is why go
                // directly to the next state: STATE_SET_OE
                state <= `STATE_SET_OE;
            end
				
            `STATE_SET_OE: 
				begin
                oe <= 0;
                // for the LAPIS FRAM, we need to wait 70 ns before the data is valid
                // after OE has been set to low
                // to achieve this we have to wait 7 clock cycles (á 10ns assuming a 100 MHz clock)
                state <= `STATE_DELAY;
            end
				
				// Use counter to wait for the read latency
            `STATE_DELAY: 
				begin
					oe <= 0;
					ce <= 0;
                if (timing_ctr == 0) begin
                    state <= `STATE_FINISHED;
						  timing_ctr <= WAIT_TIME;
						  end
                else
					 begin
                    timing_ctr <= timing_ctr - 1;
					end
					
					if(timing_ctr == 1)
						value <= dlines;
            end
				
            `STATE_FINISHED: begin
                oe <= 1;
                ce <= 1;
                active <= 0;
                ready <= 1;
					 if(finished_ctr < 4) begin
						signal_done <= 1;
						finished_ctr <= finished_ctr + 1;
					 end
					 else
						begin
						state <= 0;
						finished_ctr <= 0;
						end
            end
        endcase
    end
	 	 
endmodule
//% @}