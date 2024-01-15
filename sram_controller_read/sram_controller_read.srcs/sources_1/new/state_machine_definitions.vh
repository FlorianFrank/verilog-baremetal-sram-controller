`ifndef _state_machine_definitions_
`define _state_machine_definitions_

	// States of the notification signals
	//% The module is currently executing a task and not available. 
	`define PROCESSING 2'b00
	//% The module is currently available and wating for a NOTIFYING signal.
	`define AVAILABLE 2'b01
	//% Signal notifies the management module that the current execution was finished and to send the data via UART or Ethernet.
	`define NOTIFYING 2'b11
	
		
	// State machine of this module
	//% IDLE mode waiting for a NOTIFICATION signal from the management module.
	`define IDLE							   0
	//% Send trigger to the underlying read controller to start the read operation.
	`define TRIGGER_READ_OPERATION		       1
	//% Wait for the underlying read controller to finish the read operation.
	`define WAIT_FOR_READ_FINISHED		       2
	//% Notify the management controller, to send the data via Ethernet or UART.
	`define NOTIFY_MANAGEMENT_CONTROLLER       3
	
	`define MEM_CTR_DONE 					   6
	`define NEXT_READ        7
	
	 //% IDLE mode, the module is waiting for a notification from the memory_read module. 
    `define STATE_IDLE 		 0	
    //% Delay state, which is executed when the memory controller should wait tELEH time ti finish.
	 `define STATE_READ_DATA 1
    //% In this state the CE pin is set from high to low.
	 `define STATE_SET_CE 	 2
    //% In this state the OE pin is set from high to low. Afterwards, a transition to STATE_DELAY is executed.
	 `define STATE_SET_OE 	 3
	 
	 `define STATE_SET_CE_OE 4
    //% In this state OE and CE are set to HIGH again. 
	 //% The memory read controller get's notified that the read operation has finished.
	 //% After the notification, the module changes back to STATE_IDLE.
	 `define STATE_FINISHED  5
	
`endif //_state_machine_definitions_