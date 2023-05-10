`timescale 1ns / 1ps

`include "state_machine_definitions.vh"

//% \addtogroup memctr Memory Controller
//% @brief Contains all modules which are responsible to read and write from the memory module.
//% @{

//% @brief This module is responsible to read from an Rohm FRAM memory module.
//% It sets the OE, WE, CS as well as the address and datalines accordingly. 
//% @author Florian Frank
//% @copyright University of Passau - Chair of Computer Engineering
 module memory_read_top_module #(
	  //% @param Delay in clock cycles after each read operation.
	  parameter IDLE_DELAY=0/*1000000*/, 
	  //% Delay in clock cycles after each read operation.
	  parameter READ_START_DELAY=5, 
	  //% Size of the memory module in bytes
	  parameter MEM_SIZE=32767,
	  //% Frequency of the clock driving the management module. (used for synchronization purposes)
	  parameter FREQ_CLK1=100,
	  //% Frequency of the clock driving the memory controller. (used for synchronization purposes)
	  parameter FREQ_CLK2=400,
	  //% Data setup time defines how much time is waited until a read operation is executed.
	  parameter integer ADDRESS_BUS_SIZE=32,
      parameter integer DATA_BUS_SIZE=16,
      parameter integer CLOCK_CONFIG_WIDTH=16
	  )(
	
	//% Input clock which drives the memory controller.
	input wire clk, 
	
	input wire start,
	
	input wire reset,
	
	//% The value which should be read from the // TODO.
	output  wire[DATA_BUS_SIZE-1:0] value, 
	
	//% Data lines from which the data should be read
	input wire[DATA_BUS_SIZE-1:0] dlines,
	
	input wire[ADDRESS_BUS_SIZE-1:0] address,
	
	input wire[CLOCK_CONFIG_WIDTH-1:0] teleh, 
	
	//% Address lines specifying the address currently used. (only the Rohm FRAM is supported with a address width of 15 bit)
	output wire[ADDRESS_BUS_SIZE-1:0] alines,
	
	//% Chip enable signal.
	output wire ce,
	
	//% Output enable signal.
	output wire oe, 
	
	//% Write enable signal
	output wire we,	

	//% Synchronization input signal from the management module which indicates that the module should wait or should start working.
	input wire[1:0] sync_in, 
	
	//% Synchronization signal to indicate if the management should wait or should start working.
	output reg[1:0] sync_out,
	
	output wire active,
	
	output wire ready
	
	);

	
	
	reg [14:0] alines_reg;
	//% set WE permantenly to HIGH, to avoid accidential write operation.
   assign we = 1; 
   // instantiate the memory controller
   reg signal_start = 0;
	//% Signal form the underlysing read logic to indicate that the read operation is finished.
   wire signal_done;
		
	//% Clock synchronization counter counts the length of the notification pulse to match FREQ_CLK1 and FREQ_CLK2.
	integer clkCtr;
	
	//% State counter stores the current state of the state machine used within the always block.
	reg [2:0]state;
	
	//% Calculates the length of the notification pulse to synchroize between FREQ_CLK1 of the management module and FREQ_CLK2 of the memory controller.
	parameter WAIT_CYCLES = FREQ_CLK1/FREQ_CLK2 + 8; // TODO genaue anpassung
	
	//% Counter which counts the number of clock cycles to match the delay before starting to read specified by READ_START_DELAY.
	integer read_start_ctr;
	
	//% @brief The task increments the state up to NOTIFY_MANAGEMENT_CONTROLLER and restarts with the first state IDLE.
	task inc_state;
		begin
			if(state < `NOTIFY_MANAGEMENT_CONTROLLER)
				state <= state + 3'h1;
			else 
				state <= 3'h0;
		end
	endtask
	
	//% @brief Initial block initializes all registers at startup.
	initial begin
		clkCtr <= 0;
		state <= 3'h0;
		alines_reg <= 15'h00;
		read_start_ctr <= 0;
		sync_out <= `AVAILABLE;
	end
	 
	 //% Always block executes the state machine.
    always @(posedge clk) 
	 begin
		case(state)	
		
			// Wait for notification from ethernet controller to start reading
			`IDLE: 
			begin
				clkCtr <= 0;
				signal_start <= 0;
				if(sync_in == `NOTIFYING)
				begin
					inc_state();
					sync_out <= `PROCESSING;
				end
				else 
					sync_out <= `AVAILABLE;
			end
			
			// Send trigger to read controller to start read operation
			`TRIGGER_READ_OPERATION:
			begin
				if(read_start_ctr > READ_START_DELAY)
				begin
					inc_state();
					read_start_ctr <= 0;
				end
				else
					begin
					read_start_ctr <= read_start_ctr + 1;
					signal_start <= 1;
					end
			end
			
			// Wait for finished signal
			`WAIT_FOR_READ_FINISHED: 
			begin
				signal_start <= 0;
				// Disable ethernet module
				if(alines_reg < MEM_SIZE) 
				begin
				  // Wait for signal from memory controller to be finished
				  if (signal_done == 1) begin
						inc_state();
						clkCtr <= 0;
				  end
				end
				else
					state <= `MEM_CTR_DONE;
			end
			
		// In this step a synchronization command is sent to the ethernet controller
		`NOTIFY_MANAGEMENT_CONTROLLER: 
		begin 
			signal_start <= 0;
			if(signal_done == 0) begin
				// Use counter due to different input clocks of the two modules
				if(clkCtr < WAIT_CYCLES) 
				begin
					// Set sync_out to notify the Ethernet controller to read from the device
					sync_out <= `NOTIFYING;
					clkCtr <= clkCtr + 1;
				end
				else
				begin
					// Increment address for next iteration
					alines_reg <= alines_reg + 15'h1;
					inc_state();
				end		
			end
		end
		endcase
    end
	 
	//wire [2:0]debug_state;
	 
	 	// Reading module of the micro controller
   read_sram_protocol #(
		.CLK_FREQUENCY(FREQ_CLK2)) 
	memorycontroller_read (
		.clk(clk), 
		.teleh(teleh),
		.signal_start(signal_start), 
		.ce(ce), 
		.oe(oe), 
		.signal_done(signal_done),
		.value(value),
		.dlines(dlines));
	
	assign alines = alines_reg;

endmodule
//% @}